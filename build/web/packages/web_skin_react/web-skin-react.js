(function (root, factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD.
        define(['react'], factory);
    } else {
        // Browser globals
        root.WebSkinReact = factory(root.React);
    }
}(this, function (React) {

/**
 * almond 0.1.2 Copyright (c) 2011, The Dojo Foundation All Rights Reserved.
 * Available via the MIT or new BSD license.
 * see: http://github.com/jrburke/almond for details
 */
//Going sloppy to avoid 'use strict' string cost, but strict practices should
//be followed.
/*jslint sloppy: true */
/*global setTimeout: false */

var requirejs, require, define;
(function (undef) {
    var defined = {},
        waiting = {},
        config = {},
        defining = {},
        aps = [].slice,
        main, req;

    /**
     * Given a relative module name, like ./something, normalize it to
     * a real name that can be mapped to a path.
     * @param {String} name the relative name
     * @param {String} baseName a real name that the name arg is relative
     * to.
     * @returns {String} normalized name
     */
    function normalize(name, baseName) {
        var baseParts = baseName && baseName.split("/"),
            map = config.map,
            starMap = (map && map['*']) || {},
            nameParts, nameSegment, mapValue, foundMap,
            foundI, foundStarMap, starI, i, j, part;

        //Adjust any relative paths.
        if (name && name.charAt(0) === ".") {
            //If have a base name, try to normalize against it,
            //otherwise, assume it is a top-level require that will
            //be relative to baseUrl in the end.
            if (baseName) {
                //Convert baseName to array, and lop off the last part,
                //so that . matches that "directory" and not name of the baseName's
                //module. For instance, baseName of "one/two/three", maps to
                //"one/two/three.js", but we want the directory, "one/two" for
                //this normalization.
                baseParts = baseParts.slice(0, baseParts.length - 1);

                name = baseParts.concat(name.split("/"));

                //start trimDots
                for (i = 0; (part = name[i]); i++) {
                    if (part === ".") {
                        name.splice(i, 1);
                        i -= 1;
                    } else if (part === "..") {
                        if (i === 1 && (name[2] === '..' || name[0] === '..')) {
                            //End of the line. Keep at least one non-dot
                            //path segment at the front so it can be mapped
                            //correctly to disk. Otherwise, there is likely
                            //no path mapping for a path starting with '..'.
                            //This can still fail, but catches the most reasonable
                            //uses of ..
                            return true;
                        } else if (i > 0) {
                            name.splice(i - 1, 2);
                            i -= 2;
                        }
                    }
                }
                //end trimDots

                name = name.join("/");
            }
        }

        //Apply map config if available.
        if ((baseParts || starMap) && map) {
            nameParts = name.split('/');

            for (i = nameParts.length; i > 0; i -= 1) {
                nameSegment = nameParts.slice(0, i).join("/");

                if (baseParts) {
                    //Find the longest baseName segment match in the config.
                    //So, do joins on the biggest to smallest lengths of baseParts.
                    for (j = baseParts.length; j > 0; j -= 1) {
                        mapValue = map[baseParts.slice(0, j).join('/')];

                        //baseName segment has  config, find if it has one for
                        //this name.
                        if (mapValue) {
                            mapValue = mapValue[nameSegment];
                            if (mapValue) {
                                //Match, update name to the new value.
                                foundMap = mapValue;
                                foundI = i;
                                break;
                            }
                        }
                    }
                }

                if (foundMap) {
                    break;
                }

                //Check for a star map match, but just hold on to it,
                //if there is a shorter segment match later in a matching
                //config, then favor over this star map.
                if (!foundStarMap && starMap && starMap[nameSegment]) {
                    foundStarMap = starMap[nameSegment];
                    starI = i;
                }
            }

            if (!foundMap && foundStarMap) {
                foundMap = foundStarMap;
                foundI = starI;
            }

            if (foundMap) {
                nameParts.splice(0, foundI, foundMap);
                name = nameParts.join('/');
            }
        }

        return name;
    }

    function makeRequire(relName, forceSync) {
        return function () {
            //A version of a require function that passes a moduleName
            //value for items that may need to
            //look up paths relative to the moduleName
            return req.apply(undef, aps.call(arguments, 0).concat([relName, forceSync]));
        };
    }

    function makeNormalize(relName) {
        return function (name) {
            return normalize(name, relName);
        };
    }

    function makeLoad(depName) {
        return function (value) {
            defined[depName] = value;
        };
    }

    function callDep(name) {
        if (waiting.hasOwnProperty(name)) {
            var args = waiting[name];
            delete waiting[name];
            defining[name] = true;
            main.apply(undef, args);
        }

        if (!defined.hasOwnProperty(name)) {
            throw new Error('No ' + name);
        }
        return defined[name];
    }

    /**
     * Makes a name map, normalizing the name, and using a plugin
     * for normalization if necessary. Grabs a ref to plugin
     * too, as an optimization.
     */
    function makeMap(name, relName) {
        var prefix, plugin,
            index = name.indexOf('!');

        if (index !== -1) {
            prefix = normalize(name.slice(0, index), relName);
            name = name.slice(index + 1);
            plugin = callDep(prefix);

            //Normalize according
            if (plugin && plugin.normalize) {
                name = plugin.normalize(name, makeNormalize(relName));
            } else {
                name = normalize(name, relName);
            }
        } else {
            name = normalize(name, relName);
        }

        //Using ridiculous property names for space reasons
        return {
            f: prefix ? prefix + '!' + name : name, //fullName
            n: name,
            p: plugin
        };
    }

    function makeConfig(name) {
        return function () {
            return (config && config.config && config.config[name]) || {};
        };
    }

    main = function (name, deps, callback, relName) {
        var args = [],
            usingExports,
            cjsModule, depName, ret, map, i;

        //Use name if no relName
        relName = relName || name;

        //Call the callback to define the module, if necessary.
        if (typeof callback === 'function') {

            //Pull out the defined dependencies and pass the ordered
            //values to the callback.
            //Default to [require, exports, module] if no deps
            deps = !deps.length && callback.length ? ['require', 'exports', 'module'] : deps;
            for (i = 0; i < deps.length; i++) {
                map = makeMap(deps[i], relName);
                depName = map.f;

                //Fast path CommonJS standard dependencies.
                if (depName === "require") {
                    args[i] = makeRequire(name);
                } else if (depName === "exports") {
                    //CommonJS module spec 1.1
                    args[i] = defined[name] = {};
                    usingExports = true;
                } else if (depName === "module") {
                    //CommonJS module spec 1.1
                    cjsModule = args[i] = {
                        id: name,
                        uri: '',
                        exports: defined[name],
                        config: makeConfig(name)
                    };
                } else if (defined.hasOwnProperty(depName) || waiting.hasOwnProperty(depName)) {
                    args[i] = callDep(depName);
                } else if (map.p) {
                    map.p.load(map.n, makeRequire(relName, true), makeLoad(depName), {});
                    args[i] = defined[depName];
                } else if (!defining[depName]) {
                    throw new Error(name + ' missing ' + depName);
                }
            }

            ret = callback.apply(defined[name], args);

            if (name) {
                //If setting exports via "module" is in play,
                //favor that over return value and exports. After that,
                //favor a non-undefined return value over exports use.
                if (cjsModule && cjsModule.exports !== undef &&
                    cjsModule.exports !== defined[name]) {
                    defined[name] = cjsModule.exports;
                } else if (ret !== undef || !usingExports) {
                    //Use the return value from the function.
                    defined[name] = ret;
                }
            }
        } else if (name) {
            //May just be an object definition for the module. Only
            //worry about defining if have a module name.
            defined[name] = callback;
        }
    };

    requirejs = require = req = function (deps, callback, relName, forceSync) {
        if (typeof deps === "string") {
            //Just return the module wanted. In this scenario, the
            //deps arg is the module name, and second arg (if passed)
            //is just the relName.
            //Normalize module name, if it contains . or ..
            return callDep(makeMap(deps, callback).f);
        } else if (!deps.splice) {
            //deps is a config object, not an array.
            config = deps;
            if (callback.splice) {
                //callback is an array, which means it is a dependency list.
                //Adjust args if there are dependencies
                deps = callback;
                callback = relName;
                relName = null;
            } else {
                deps = undef;
            }
        }

        //Support require(['a'])
        callback = callback || function () {};

        //Simulate async callback;
        if (forceSync) {
            main(undef, deps, callback, relName);
        } else {
            setTimeout(function () {
                main(undef, deps, callback, relName);
            }, 15);
        }

        return req;
    };

    /**
     * Just drops the config on the floor, but returns req in case
     * the config return value is used.
     */
    req.config = function (cfg) {
        config = cfg;
        return req;
    };

    define = function (name, deps, callback) {

        //This module may not have dependencies
        if (!deps.splice) {
            //deps is not an array, so probably means
            //an object literal or factory function for
            //the value. Adjust args.
            callback = deps;
            deps = [];
        }

        waiting[name] = [name, deps, callback];
    };

    define.amd = {
        jQuery: true
    };
}());

define("almond", function(){});

define('utils/joinClasses',['require','exports','module'],function (require, exports, module) {/**
 * Copyright 2013-2014, Facebook, Inc.
 * All rights reserved.
 *
 * This file contains an unmodified version of:
 * https://github.com/facebook/react/blob/v0.12.0/src/utils/joinClasses.js
 *
 * This source code is licensed under the BSD-style license found here:
 * https://github.com/facebook/react/blob/v0.12.0/LICENSE
 * An additional grant of patent rights can be found here:
 * https://github.com/facebook/react/blob/v0.12.0/PATENTS
 */



/**
 * Combines multiple className strings into one.
 * http://jsperf.com/joinclasses-args-vs-array
 *
 * @param {...?string} classes
 * @return {string}
 */
function joinClasses(className/*, ... */) {
  if (!className) {
    className = '';
  }
  var nextClass;
  var argLength = arguments.length;
  if (argLength > 1) {
    for (var ii = 1; ii < argLength; ii++) {
      nextClass = arguments[ii];
      if (nextClass) {
        className = (className ? className + ' ' : '') + nextClass;
      }
    }
  }
  return className;
}

module.exports = joinClasses;

});

define('utils/classSet',['require','exports','module'],function (require, exports, module) {/**
 * Copyright 2013-2014, Facebook, Inc.
 * All rights reserved.
 *
 * This file contains an unmodified version of:
 * https://github.com/facebook/react/blob/v0.12.0/src/vendor/stubs/cx.js
 *
 * This source code is licensed under the BSD-style license found here:
 * https://github.com/facebook/react/blob/v0.12.0/LICENSE
 * An additional grant of patent rights can be found here:
 * https://github.com/facebook/react/blob/v0.12.0/PATENTS
 */

/**
 * This function is used to mark string literals representing CSS class names
 * so that they can be transformed statically. This allows for modularization
 * and minification of CSS class names.
 *
 * In static_upstream, this function is actually implemented, but it should
 * eventually be replaced with something more descriptive, and the transform
 * that is used in the main stack should be ported for use elsewhere.
 *
 * @param string|object className to modularize, or an object of key/values.
 *                      In the object case, the values are conditions that
 *                      determine if the className keys should be included.
 * @param [string ...]  Variable list of classNames in the string case.
 * @return string       Renderable space-separated CSS className.
 */
function cx(classNames) {
  if (typeof classNames == 'object') {
    return Object.keys(classNames).filter(function(className) {
      return classNames[className];
    }).join(' ');
  } else {
    return Array.prototype.join.call(arguments, ' ');
  }
}

module.exports = cx;
});

define('utils/Object.assign',['require','exports','module'],function (require, exports, module) {/**
 * Copyright 2014, Facebook, Inc.
 * All rights reserved.
 *
 * This file contains an unmodified version of:
 * https://github.com/facebook/react/blob/v0.12.0/src/vendor/stubs/Object.assign.js
 *
 * This source code is licensed under the BSD-style license found here:
 * https://github.com/facebook/react/blob/v0.12.0/LICENSE
 * An additional grant of patent rights can be found here:
 * https://github.com/facebook/react/blob/v0.12.0/PATENTS
 */

// https://people.mozilla.org/~jorendorff/es6-draft.html#sec-object.assign

function assign(target, sources) {
  if (target == null) {
    throw new TypeError('Object.assign target cannot be null or undefined');
  }

  var to = Object(target);
  var hasOwnProperty = Object.prototype.hasOwnProperty;

  for (var nextIndex = 1; nextIndex < arguments.length; nextIndex++) {
    var nextSource = arguments[nextIndex];
    if (nextSource == null) {
      continue;
    }

    var from = Object(nextSource);

    // We don't currently support accessors nor proxies. Therefore this
    // copy cannot throw. If we ever supported this then we must handle
    // exceptions and side-effects. We don't support symbols so they won't
    // be transferred.

    for (var key in from) {
      if (hasOwnProperty.call(from, key)) {
        to[key] = from[key];
      }
    }
  }

  return to;
};

module.exports = assign;

});

define('utils/cloneWithProps',['require','exports','module','react','./joinClasses','./Object.assign'],function (require, exports, module) {/**
 * Copyright 2013-2014, Facebook, Inc.
 * All rights reserved.
 *
 * This file contains modified versions of:
 * https://github.com/facebook/react/blob/v0.12.0/src/utils/cloneWithProps.js
 * https://github.com/facebook/react/blob/v0.12.0/src/core/ReactPropTransferer.js
 *
 * This source code is licensed under the BSD-style license found here:
 * https://github.com/facebook/react/blob/v0.12.0/LICENSE
 * An additional grant of patent rights can be found here:
 * https://github.com/facebook/react/blob/v0.12.0/PATENTS
 *
 * TODO: This should be replaced as soon as cloneWithProps is available via
 *  the core React package or a separate package.
 *  @see https://github.com/facebook/react/issues/1906
 */

var React = require('react');
var joinClasses = require('./joinClasses');
var assign = require("./Object.assign");

/**
 * Creates a transfer strategy that will merge prop values using the supplied
 * `mergeStrategy`. If a prop was previously unset, this just sets it.
 *
 * @param {function} mergeStrategy
 * @return {function}
 */
function createTransferStrategy(mergeStrategy) {
  return function(props, key, value) {
    if (!props.hasOwnProperty(key)) {
      props[key] = value;
    } else {
      props[key] = mergeStrategy(props[key], value);
    }
  };
}

var transferStrategyMerge = createTransferStrategy(function(a, b) {
  // `merge` overrides the first object's (`props[key]` above) keys using the
  // second object's (`value`) keys. An object's style's existing `propA` would
  // get overridden. Flip the order here.
  return assign({}, b, a);
});

function emptyFunction() {}

/**
 * Transfer strategies dictate how props are transferred by `transferPropsTo`.
 * NOTE: if you add any more exceptions to this list you should be sure to
 * update `cloneWithProps()` accordingly.
 */
var TransferStrategies = {
  /**
   * Never transfer `children`.
   */
  children: emptyFunction,
  /**
   * Transfer the `className` prop by merging them.
   */
  className: createTransferStrategy(joinClasses),
  /**
   * Transfer the `style` prop (which is an object) by merging them.
   */
  style: transferStrategyMerge
};

/**
 * Mutates the first argument by transferring the properties from the second
 * argument.
 *
 * @param {object} props
 * @param {object} newProps
 * @return {object}
 */
function transferInto(props, newProps) {
  for (var thisKey in newProps) {
    if (!newProps.hasOwnProperty(thisKey)) {
      continue;
    }

    var transferStrategy = TransferStrategies[thisKey];

    if (transferStrategy && TransferStrategies.hasOwnProperty(thisKey)) {
      transferStrategy(props, thisKey, newProps[thisKey]);
    } else if (!props.hasOwnProperty(thisKey)) {
      props[thisKey] = newProps[thisKey];
    }
  }
  return props;
}

/**
 * Merge two props objects using TransferStrategies.
 *
 * @param {object} oldProps original props (they take precedence)
 * @param {object} newProps new props to merge in
 * @return {object} a new object containing both sets of props merged.
 */
function mergeProps(oldProps, newProps) {
  return transferInto(assign({}, oldProps), newProps);
}


var ReactPropTransferer = {
  mergeProps: mergeProps
};

var CHILDREN_PROP = 'children';

/**
 * Sometimes you want to change the props of a child passed to you. Usually
 * this is to add a CSS class.
 *
 * @param {object} child child component you'd like to clone
 * @param {object} props props you'd like to modify. They will be merged
 * as if you used `transferPropsTo()`.
 * @return {object} a clone of child with props merged in.
 */
function cloneWithProps(child, props) {
  var newProps = ReactPropTransferer.mergeProps(props, child.props);

  // Use `child.props.children` if it is provided.
  if (!newProps.hasOwnProperty(CHILDREN_PROP) &&
    child.props.hasOwnProperty(CHILDREN_PROP)) {
    newProps.children = child.props.children;
  }

  if (React.version.substr(0, 4) === '0.12'){
    var mockLegacyFactory = function(){};
    mockLegacyFactory.isReactLegacyFactory = true;
    mockLegacyFactory.type = child.type;

    return React.createElement(mockLegacyFactory, newProps);
  }

  // The current API doesn't retain _owner and _context, which is why this
  // doesn't use ReactElement.cloneAndReplaceProps.
  return React.createElement(child.type, newProps);
}

module.exports = cloneWithProps;
});

define('constants',['require','exports','module'],function (require, exports, module) {module.exports = {
  CLASSES: {
    'alert': 'alert',
    'button': 'btn',
    'button-group': 'btn-group',
    'button-toolbar': 'btn-toolbar',
    'column': 'col',
    'input-group': 'input-group',
    'form': 'form',
    'icon': 'icon',
    'label': 'label',
    'list-group-item': 'list-group-item',
    'panel': 'panel',
    'panel-group': 'panel-group',
    'progress-bar': 'progress-bar',
    'nav': 'nav',
    'navbar': 'navbar',
    'modal': 'modal',
    'row': 'row',
    'tooltip': 'tooltip',
    'well': 'well'
  },
  STYLES: {
    'default': 'default',
    'light': 'light',
    'inverse': 'inverse',
    'primary': 'primary',
    'success': 'success',
    'info': 'alt',
    'warning': 'warning',
    'danger': 'danger',
    'link': 'link',
    'inline': 'inline',
    'tabs': 'tabs',
    'pills': 'pills'
  },
  SIZES: {
    'xxl': 'xxl',
    'xl': 'xl',
    'large': 'lg',
    'medium': 'md',
    'small': 'sm',
    'xsmall': 'xs'
  },
  INPUT_TYPES: {
    /// `<select>`
    'select': 'select',
    /// `<textarea>`
    'textarea': 'textarea',
    /// `<p class="form-control-static">`
    'static': 'static',
    /// `<button type="submit">`
    'submit': 'submit',
    /// actual HTML5 input types
    /// @see http://bit.ly/webskin-valid-input-types
    'checkbox': 'checkbox',
    'radio': 'radio',
    'text': 'text',
    'email': 'email',
    'tel': 'tel',
    'number': 'number',
    'password': 'password',
    'url': 'url',
    'search': 'search',
    'color': 'color',
    'datetime': 'datetime',
    'datetime-local': 'datetime-local',
    'date': 'date',
    'month': 'month',
    'time': 'time',
    'week': 'week',
    'file': 'file'
  },
  GLYPHS: [
    'align-center',
    'align-justify',
    'align-left',
    'align-right',
    'arrow-down',
    'arrow-down-sign-outline',
    'arrow-left',
    'arrow-right',
    'arrow-up',
    'arrow-up-sign-outline',
    'attachment',
    'backward',
    'blackline',
    'blackline-review',
    'blacklines-next',
    'blacklines-prev',
    'blocked',
    'bold',
    'bookmark',
    'calendar',
    'carousel-next',
    'carousel-prev',
    'certification',
    'chart-bar',
    'checkmark',
    'checkmark-sign',
    'checkmark-sign-outline',
    'chevron-double-down',
    'chevron-double-left',
    'chevron-double-right',
    'chevron-double-up',
    'chevron-down',
    'chevron-down-sm',
    'chevron-left',
    'chevron-left-sm',
    'chevron-right',
    'chevron-right-sm',
    'chevron-up',
    'chevron-up-sm',
    'clipboard',
    'close',
    'close-sign',
    'close-sign-outline',
    'cloud',
    'cloud-download',
    'cloud-upload',
    'cog',
    'comment',
    'comment-add',
    'comment-ban',
    'comment-checkmark',
    'comment-cursor',
    'comment-disconnect',
    'comment-filter',
    'comment-lines',
    'comment-on',
    'comment-outline',
    'comment-outline-lines',
    'comment-reopen',
    'comment-reply',
    'comment-upload-support',
    'comments-arrow-down',
    'comments-arrow-up',
    'connection',
    'contract',
    'copy',
    'cut',
    'decimals-decrease',
    'decimals-increase',
    'delete-backspace',
    'demote',
    'doc-outline',
    'docpart-add-after',
    'docpart-add-before',
    'docpart-demote',
    'docpart-move-down',
    'docpart-move-up',
    'docpart-promote',
    'docpart-remove',
    'download-available',
    'downloaded',
    'draw-border-color',
    'draw-cursor-pointer',
    'draw-line',
    'draw-line-arrow-down',
    'draw-line-arrow-up',
    'draw-oval-outline',
    'draw-rectangle-arrow-outline',
    'draw-square-outline',
    'drawer',
    'drawer-full',
    'eject',
    'empty-sign-outline',
    'enter',
    'exit',
    'expand',
    'eye',
    'eye-blocked',
    'feedback',
    'file',
    'file-book',
    'file-book-copy',
    'file-book-properties',
    'file-book-sm',
    'file-certification',
    'file-control',
    'file-copy',
    'file-datacollections',
    'file-dc-beta',
    'file-dragndrop',
    'file-dragndrop-new',
    'file-dt-beta',
    'file-export',
    'file-generic',
    'file-image',
    'file-import',
    'file-link',
    'file-msexcel',
    'file-mspowerpoint',
    'file-msword',
    'file-new',
    'file-paginate',
    'file-pdf',
    'file-presentation',
    'file-preview',
    'file-project',
    'file-properties',
    'file-save',
    'file-save-as',
    'file-trash',
    'file-validate',
    'file-workbook',
    'filter',
    'filter-outline',
    'find',
    'first',
    'flag',
    'folder',
    'folder-move',
    'folder-open',
    'font',
    'format',
    'formula',
    'forward',
    'github',
    'gripper',
    'gripper-rule',
    'heartbeat',
    'help-sign',
    'help-sign-outline',
    'highlighter',
    'home',
    'italic',
    'key',
    'last',
    'library-bookshelf',
    'link',
    'link-broken',
    'link-create',
    'link-format',
    'link-remove',
    'link-source',
    'lock',
    'menu-list',
    'message-forward',
    'minus',
    'minus-sign',
    'minus-sign-outline',
    'next',
    'note',
    'notification',
    'notification-sign-outline',
    'page-break',
    'pause',
    'pencil',
    'pencil-draw',
    'pencil-sign',
    'pending',
    'play',
    'play-sign-outline',
    'plus',
    'plus-sign',
    'plus-sign-outline',
    'previous',
    'print',
    'promote',
    'quote-close',
    'quote-open',
    'redo',
    'refresh',
    'rename',
    'reply',
    'review',
    'review-stamp-approved',
    'review-stamp-reviewed',
    'review-stamp-signed',
    'search',
    'spellcheck',
    'stop',
    'support-sign-corner',
    'symbol',
    'table',
    'table-insert-column',
    'table-insert-row',
    'table-remove-column',
    'table-remove-column-after',
    'table-remove-row',
    'table-remove-row-after',
    'tag',
    'tags',
    'task-link',
    'template-child',
    'template-master',
    'trash',
    'twfr-checkmark-sign-outline',
    'twfr-cog',
    'twfr-comment-outline-lines',
    'twfr-demote',
    'twfr-discard-changes',
    'twfr-feedback',
    'twfr-file',
    'twfr-file-add',
    'twfr-file-attachment',
    'twfr-file-book',
    'twfr-file-book-copy',
    'twfr-file-book-properties',
    'twfr-file-certification',
    'twfr-file-control',
    'twfr-file-datacollections',
    'twfr-file-datacollections-draft',
    'twfr-file-datacollections-frozen',
    'twfr-file-dc-beta',
    'twfr-file-dc-draft-beta',
    'twfr-file-dc-frozen-beta',
    'twfr-file-draft',
    'twfr-file-dt-beta',
    'twfr-file-export',
    'twfr-file-frozen',
    'twfr-file-generic',
    'twfr-file-generic-add',
    'twfr-file-image',
    'twfr-file-import',
    'twfr-file-link',
    'twfr-file-msexcel',
    'twfr-file-mspowerpoint',
    'twfr-file-msword',
    'twfr-file-pdf',
    'twfr-file-presentation',
    'twfr-file-presentation-draft',
    'twfr-file-presentation-frozen',
    'twfr-file-preview',
    'twfr-file-project',
    'twfr-file-url',
    'twfr-file-workbook',
    'twfr-file-workbook-draft',
    'twfr-file-workbook-frozen',
    'twfr-folder',
    'twfr-folder-add',
    'twfr-folder-move',
    'twfr-folder-open',
    'twfr-folder-zip',
    'twfr-formula',
    'twfr-formula-sum',
    'twfr-history',
    'twfr-insert',
    'twfr-library-bookshelf',
    'twfr-link',
    'twfr-link-add',
    'twfr-link-format',
    'twfr-link-remove',
    'twfr-lock',
    'twfr-menu-list',
    'twfr-move-down',
    'twfr-move-up',
    'twfr-off-device-droid',
    'twfr-off-device-ios',
    'twfr-on-device-droid',
    'twfr-on-device-ios',
    'twfr-permissions',
    'twfr-promote',
    'twfr-recently-updated',
    'twfr-reminder',
    'twfr-rename',
    'twfr-sec-sign-outline',
    'twfr-source-make',
    'twfr-tab-add',
    'twfr-table-cells-add',
    'twfr-table-cells-delete',
    'twfr-task-check',
    'twfr-task-create',
    'twfr-trash',
    'twfr-trash-restore',
    'twfr-unlock',
    'twfr-workspaces',
    'undo',
    'unlock',
    'update-available',
    'upload',
    'user',
    'users',
    'view-print-area',
    'view-trash',
    'warning-sign-outline',
    'xbrl-flagged-sign',
    'xbrl-mixed-sign',
    'zoom-in',
    'zoom-out',
    'zoom-page-height',
    'zoom-page-width'
  ],
  GLYPH_COLORS: {
    'oneColor': 'icon-color',
    'twoColor': 'icon-two-color',
    'muted': 'text-muted',
    'white': 'text-white',
    'primary': 'text-primary',
    'alt': 'text-alt',
    'success': 'text-success',
    'warning': 'text-warning',
    'danger': 'text-danger',
    'gray': 'text-gray',
    'green': 'text-green',
    'greenAlt': 'text-green-alt',
    'greenAlt2': 'text-green-alt2',
    'blue': 'text-blue',
    'orange': 'text-orange',
    'purple': 'text-purple',
    'red': 'text-red'
  }
};

});

define('WebSkinMixin',['require','exports','module','react','./constants'],function (require, exports, module) {var React = require('react');
var constants = require('./constants');

var WebSkinMixin = {
  propTypes: {
    wsClass: React.PropTypes.oneOf(Object.keys(constants.CLASSES)),
    wsStyle: React.PropTypes.oneOf(Object.keys(constants.STYLES)),
    wsSize: React.PropTypes.oneOf(Object.keys(constants.SIZES))
  },

  getWsClassSet: function () {
    var classes = {};

    var wsClass = this.props.wsClass && constants.CLASSES[this.props.wsClass];
    if (wsClass) {
      classes[wsClass] = true;

      var prefix = wsClass + '-';

      var wsSize = this.props.wsSize && constants.SIZES[this.props.wsSize];
      if (wsSize) {
        classes[prefix + wsSize] = true;
      }

      var wsStyle = this.props.wsStyle && constants.STYLES[this.props.wsStyle];
      if (this.props.wsStyle) {
        classes[prefix + wsStyle] = true;
      }
    }

    return classes;
  },

  prefixClass: function(subClass) {
    return constants.CLASSES[this.props.wsClass] + '-' + subClass;
  }
};

module.exports = WebSkinMixin;

});

define('utils/ValidComponentChildren',['require','exports','module','react'],function (require, exports, module) {var React = require('react');

/**
 * Maps children that are typically specified as `props.children`,
 * but only iterates over children that are "valid components".
 *
 * The mapFunction provided index will be normalised to the components mapped,
 * so an invalid component would not increase the index.
 *
 * @param {?*} children Children tree container.
 * @param {function(*, int)} mapFunction.
 * @param {*} mapContext Context for mapFunction.
 * @return {object} Object containing the ordered map of results.
 */
function mapValidComponents(children, func, context) {
  var index = 0;

  return React.Children.map(children, function (child) {
    if (React.isValidElement(child)) {
      var lastIndex = index;
      index++;
      return func.call(context, child, lastIndex);
    }

    return child;
  });
}

/**
 * Iterates through children that are typically specified as `props.children`,
 * but only iterates over children that are "valid components".
 *
 * The provided forEachFunc(child, index) will be called for each
 * leaf child with the index reflecting the position relative to "valid components".
 *
 * @param {?*} children Children tree container.
 * @param {function(*, int)} forEachFunc.
 * @param {*} forEachContext Context for forEachContext.
 */
function forEachValidComponents(children, func, context) {
  var index = 0;

  return React.Children.forEach(children, function (child) {
    if (React.isValidElement(child)) {
      func.call(context, child, index);
      index++;
    }
  });
}

/**
 * Count the number of "valid components" in the Children container.
 *
 * @param {?*} children Children tree container.
 * @returns {number}
 */
function numberOfValidComponents(children) {
  var count = 0;

  React.Children.forEach(children, function (child) {
    if (React.isValidElement(child)) { count++; }
  });

  return count;
}

/**
 * Determine if the Child container has one or more "valid components".
 *
 * @param {?*} children Children tree container.
 * @returns {boolean}
 */
function hasValidComponent(children) {
  var hasValid = false;

  React.Children.forEach(children, function (child) {
    if (!hasValid && React.isValidElement(child)) {
      hasValid = true;
    }
  });

  return hasValid;
}

module.exports = {
  map: mapValidComponents,
  forEach: forEachValidComponents,
  numberOf: numberOfValidComponents,
  hasValidComponent: hasValidComponent
};
});

define('PanelGroup',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./utils/cloneWithProps','./WebSkinMixin','./utils/ValidComponentChildren'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var cloneWithProps = require('./utils/cloneWithProps');

var WebSkinMixin = require('./WebSkinMixin');
var ValidComponentChildren = require('./utils/ValidComponentChildren');

var validAccordionActiveKeyTypes = React.PropTypes.oneOfType(React.PropTypes.string, React.PropTypes.number, React.PropTypes.func, React.PropTypes.bool);

var PanelGroup = React.createClass({displayName: "PanelGroup",
  mixins: [WebSkinMixin],

  propTypes: {
    /// Will create a group of collapsible panels in which only one panel can be open at any given time
    accordion: React.PropTypes.bool,
    /// Will create a group of collapsible panels in which more than one panel can be open at any given time
    collapsible: React.PropTypes.bool,
    onSelect: React.PropTypes.func,
    /// Instantiates a "controlled" panel group.
    activeKey: React.PropTypes.any,
    /// Activates one or more panels initially, and allows the built-in controller to handle the logic
    defaultActiveKey: React.PropTypes.any
  },

  hasInvalidActiveKey: function () {
    var activeStateExists = this.state.activeKey ? 1 : 0;
    var activePropExists = this.props.activeKey ? 1 : 0;

    var multipleActiveKeys = activeStateExists + activePropExists;
    return this.props.accordion && multipleActiveKeys > 1;
  },

  getDefaultProps: function () {
    return {
      wsClass: 'panel-group'
    };
  },

  getInitialState: function () {
    var defaultActiveKey = this.props.defaultActiveKey;

    /// If the group allows more than one panel to be open at once
    /// convert the type of activeKey to an object
    if (!this.props.accordion && defaultActiveKey) {
      if (typeof defaultActiveKey !== 'object') {
        defaultActiveKey = [defaultActiveKey];
      }
    }

    return {
      activeKey: defaultActiveKey
    };
  },

  render: function () {
    if (this.hasInvalidActiveKey()) {
      throw new Error('Accordions can only have a single active key at any given time. Try using the collapsible prop instead of the accordion prop if you need more than one panel to be expanded at a time.');
    }

    var classes = this.getWsClassSet();
    var parentProps = {
      'role': 'tablist',
      'aria-multiselectable': !this.props.accordion
    };

    /// All accordions are collapsible, but not all collapsible structures are accordions.
    this.props.collapsible = this.props.collapsible || this.props.accordion;

    return (
      React.createElement("div", React.__spread({},  parentProps), 
        React.createElement("div", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes)), onSelect: null}), 
            ValidComponentChildren.map(this.props.children, this.renderPanel)
        )
      )
    );
  },

  renderPanel: function (child, index) {
    var activeKey =
      this.props.activeKey != null ? this.props.activeKey : this.state.activeKey;

    var panelProps = {
      wsStyle: child.props.wsStyle || this.props.wsStyle,
      key: child.key ? child.key : index,
      ref: child.ref
    };

    if (this.props.collapsible) {
      panelProps.collapsible = true;
      panelProps.onSelect = this.handleSelect;

      if (this.props.accordion) {
        /// Only one panel can be open at a time.
        panelProps.expanded = (child.props.eventKey === activeKey);
      } else {
        /// Multiple panels can be open at a time.

        if (!activeKey) {
          panelProps.expanded = false;
        } else {
          if (typeof activeKey !== 'object') {
            activeKey = [activeKey];
          }

          /// One or more panels should be open.
          panelProps.expanded = activeKey.indexOf(child.props.eventKey) > -1;
        }
      }
    }

    return cloneWithProps(
      child,
      panelProps
    );
  },

  shouldComponentUpdate: function() {
    // Defer any updates to this component during the `onSelect` handler.
    return !this._isChanging;
  },

  handleAccordionSelect: function (key) {
    if (this.props.activeKey === key || this.state.activeKey === key) {
      key = null;
    }

    this.setState({
      activeKey: key
    });
  },

  handleMultiSelect: function (key) {
    var keys = this.props.activeKey || this.state.activeKey;

    if (typeof keys === 'object') { /// More than one panel is open.
      if (keys && keys.indexOf(key) > -1) {
        /// Collapse a panel that is currently expanded
        keys.splice(keys.indexOf(key), 1);
      } else {
        /// Expand a panel that is currently collapsed
        keys.push(key);
      }
    } else { /// One or zero panels are open.
      if (keys) {
        /// One panel is open.
        keys = [key];
      } else {
        /// No panels are open.
        keys = [];
      }
    }

    this.setState({
      activeKey: keys
    });
  },

  handleSelect: function (e, key) {
    e.preventDefault();

    if (this.props.onSelect) {
      this._isChanging = true;
      this.props.onSelect(key);
      this._isChanging = false;
    }

    this.props.accordion ? this.handleAccordionSelect(key) : this.handleMultiSelect(key);
  }
});

module.exports = PanelGroup;

});

define('Accordion',['require','exports','module','react','./PanelGroup'],function (require, exports, module) {var React = require('react');
var PanelGroup = require('./PanelGroup');

var Accordion = React.createClass({displayName: "Accordion",
  render: function () {
    return (
      React.createElement(PanelGroup, React.__spread({},  this.props, {accordion: true}), 
        this.props.children
      )
    );
  }
});

module.exports = Accordion;
});

define('utils/domUtils',['require','exports','module'],function (require, exports, module) {
/**
 * Shortcut to compute element style
 *
 * @param {HTMLElement} elem
 * @returns {CssStyle}
 */
function getComputedStyles(elem) {
  return elem.ownerDocument.defaultView.getComputedStyle(elem, null);
}

/**
 * Get elements offset
 *
 * TODO: REMOVE JQUERY!
 *
 * @param {HTMLElement} DOMNode
 * @returns {{top: number, left: number}}
 */
function getOffset(DOMNode) {
  if (window.jQuery) {
    return window.jQuery(DOMNode).offset();
  }

  var docElem = document.documentElement;
  var box = { top: 0, left: 0 };

  // If we don't have gBCR, just use 0,0 rather than error
  // BlackBerry 5, iOS 3 (original iPhone)
  if ( typeof DOMNode.getBoundingClientRect !== 'undefined' ) {
    box = DOMNode.getBoundingClientRect();
  }

  return {
    top: box.top + window.pageYOffset - docElem.clientTop,
    left: box.left + window.pageXOffset - docElem.clientLeft
  };
}

/**
 * Get elements position
 *
 * TODO: REMOVE JQUERY!
 *
 * @param {HTMLElement} elem
 * @param {HTMLElement?} offsetParent
 * @returns {{top: number, left: number}}
 */
function getPosition(elem, offsetParent) {
  if (window.jQuery) {
    return window.jQuery(elem).position();
  }

  var offset,
      parentOffset = {top: 0, left: 0};

  // Fixed elements are offset from window (parentOffset = {top:0, left: 0}, because it is its only offset parent
  if (getComputedStyles(elem).position === 'fixed' ) {
    // We assume that getBoundingClientRect is available when computed position is fixed
    offset = elem.getBoundingClientRect();

  } else {
    if (!offsetParent) {
      // Get *real* offsetParent
      offsetParent = offsetParent(elem);
    }

    // Get correct offsets
    offset = getOffset(elem);
    if ( offsetParent.nodeName !== 'HTML') {
      parentOffset = getOffset(offsetParent);
    }

    // Add offsetParent borders
    parentOffset.top += parseInt(getComputedStyles(offsetParent).borderTopWidth, 10);
    parentOffset.left += parseInt(getComputedStyles(offsetParent).borderLeftWidth, 10);
  }

  // Subtract parent offsets and element margins
  return {
    top: offset.top - parentOffset.top - parseInt(getComputedStyles(elem).marginTop, 10),
    left: offset.left - parentOffset.left - parseInt(getComputedStyles(elem).marginLeft, 10)
  };
}

/**
 * Get parent element
 *
 * @param {HTMLElement?} elem
 * @returns {HTMLElement}
 */
function offsetParent(elem) {
  var docElem = document.documentElement;
  var offsetParent = elem.offsetParent || docElem;

  while ( offsetParent && ( offsetParent.nodeName !== 'HTML' &&
    getComputedStyles(offsetParent).position === 'static' ) ) {
    offsetParent = offsetParent.offsetParent;
  }

  return offsetParent || docElem;
}

module.exports = {
  getComputedStyles: getComputedStyles,
  getOffset: getOffset,
  getPosition: getPosition,
  offsetParent: offsetParent
};
});

define('utils/EventListener',['require','exports','module'],function (require, exports, module) {/**
 * Copyright 2013-2014 Facebook, Inc.
 *
 * This file contains a modified version of:
 * https://github.com/facebook/react/blob/v0.12.0/src/vendor/stubs/EventListener.js
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * TODO: remove in favour of solution provided by:
 *  https://github.com/facebook/react/issues/285
 */

/**
 * Does not take into account specific nature of platform.
 */
var EventListener = {
  /**
   * Listen to DOM events during the bubble phase.
   *
   * @param {DOMEventTarget} target DOM element to register listener on.
   * @param {string} eventType Event type, e.g. 'click' or 'mouseover'.
   * @param {function} callback Callback function.
   * @return {object} Object with a `remove` method.
   */
  listen: function(target, eventType, callback) {
    if (target.addEventListener) {
      target.addEventListener(eventType, callback, false);
      return {
        remove: function() {
          target.removeEventListener(eventType, callback, false);
        }
      };
    } else if (target.attachEvent) {
      target.attachEvent('on' + eventType, callback);
      return {
        remove: function() {
          target.detachEvent('on' + eventType, callback);
        }
      };
    }
  }
};

module.exports = EventListener;

});

define('AffixMixin',['require','exports','module','react','./utils/domUtils','./utils/EventListener'],function (require, exports, module) {/* global window, document */

var React = require('react');
var domUtils = require('./utils/domUtils');
var EventListener = require('./utils/EventListener');

var AffixMixin = {
  propTypes: {
    offset: React.PropTypes.number,
    offsetTop: React.PropTypes.number,
    offsetBottom: React.PropTypes.number
  },

  getInitialState: function () {
    return {
      affixClass: 'affix-top'
    };
  },

  getPinnedOffset: function (DOMNode) {
    if (this.pinnedOffset) {
      return this.pinnedOffset;
    }

    DOMNode.className = DOMNode.className.replace(/affix-top|affix-bottom|affix/, '');
    DOMNode.className += DOMNode.className.length ? ' affix' : 'affix';

    this.pinnedOffset = domUtils.getOffset(DOMNode).top - window.pageYOffset;

    return this.pinnedOffset;
  },

  checkPosition: function () {
    var DOMNode, scrollHeight, scrollTop, position, offsetTop, offsetBottom,
        affix, affixType, affixPositionTop;

    // TODO: or not visible
    if (!this.isMounted()) {
      return;
    }

    DOMNode = this.getDOMNode();
    scrollHeight = document.documentElement.offsetHeight;
    scrollTop = window.pageYOffset;
    position = domUtils.getOffset(DOMNode);

    if (this.affixed === 'top') {
      position.top += scrollTop;
    }

    offsetTop = this.props.offsetTop != null ?
      this.props.offsetTop : this.props.offset;
    offsetBottom = this.props.offsetBottom != null ?
      this.props.offsetBottom : this.props.offset;

    if (offsetTop == null && offsetBottom == null) {
      return;
    }
    if (offsetTop == null) {
      offsetTop = 0;
    }
    if (offsetBottom == null) {
      offsetBottom = 0;
    }

    if (this.unpin != null && (scrollTop + this.unpin <= position.top)) {
      affix = false;
    } else if (offsetBottom != null && (position.top + DOMNode.offsetHeight >= scrollHeight - offsetBottom)) {
      affix = 'bottom';
    } else if (offsetTop != null && (scrollTop <= offsetTop)) {
      affix = 'top';
    } else {
      affix = false;
    }

    if (this.affixed === affix) {
      return;
    }

    if (this.unpin != null) {
      DOMNode.style.top = '';
    }

    affixType = 'affix' + (affix ? '-' + affix : '');

    this.affixed = affix;
    this.unpin = affix === 'bottom' ?
      this.getPinnedOffset(DOMNode) : null;

    if (affix === 'bottom') {
      DOMNode.className = DOMNode.className.replace(/affix-top|affix-bottom|affix/, 'affix-bottom');
      affixPositionTop = scrollHeight - offsetBottom - DOMNode.offsetHeight;
    }

    this.setState({
      affixClass: affixType,
      affixPositionTop: affixPositionTop
    });
  },

  checkPositionWithEventLoop: function () {
    setTimeout(this.checkPosition, 0);
  },

  componentDidMount: function () {
    var self = this;

    this._onWindowScrollListener =
      EventListener.listen(window, 'scroll', function () {
        self._scrollPositionChanged = true;
        self.checkPosition();
      });
    this._onDocumentClickListener =
      EventListener.listen(document, 'click', function () {
        // Don't do anything on click if the scroll position has
        // not changed since the last time a click handler fired.
        if (self._scrollPositionChanged) {
          self.checkPositionWithEventLoop();
          self._scrollPositionChanged = false;
        }
      });
  },

  componentWillUnmount: function () {
    if (this._onWindowScrollListener) {
      this._onWindowScrollListener.remove();
    }

    if (this._onDocumentClickListener) {
      this._onDocumentClickListener.remove();
    }
  },

  componentDidUpdate: function (prevProps, prevState) {
    if (prevState.affixClass === this.state.affixClass) {
      this.checkPositionWithEventLoop();
    }
  }
};

module.exports = AffixMixin;

});

define('utils/createChainedFunction',['require','exports','module'],function (require, exports, module) {/**
 * Safe chained function
 *
 * Will only create a new function if needed,
 * otherwise will pass back existing functions or null.
 *
 * @param {function} one
 * @param {function} two
 * @returns {function|null}
 */
function createChainedFunction(one, two) {
  var hasOne = typeof one === 'function';
  var hasTwo = typeof two === 'function';

  if (!hasOne && !hasTwo) { return null; }
  if (!hasOne) { return two; }
  if (!hasTwo) { return one; }

  return function chainedFunction() {
    one.apply(this, arguments);
    two.apply(this, arguments);
  };
}

module.exports = createChainedFunction;
});

define('Affix',['require','exports','module','react','./utils/joinClasses','./AffixMixin','./utils/domUtils','./utils/cloneWithProps','./utils/ValidComponentChildren','./utils/createChainedFunction'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var AffixMixin = require('./AffixMixin');
var domUtils = require('./utils/domUtils');
var cloneWithProps = require('./utils/cloneWithProps');

var ValidComponentChildren = require('./utils/ValidComponentChildren');
var createChainedFunction = require('./utils/createChainedFunction');

var Affix = React.createClass({displayName: "Affix",
  propTypes: {
    componentClass: React.PropTypes.node,
    eventKey: React.PropTypes.any
  },

  statics: {
    domUtils: domUtils
  },

  mixins: [AffixMixin],

  getDefaultProps: function () {
    return {
      componentClass: 'div'
    }
  },

  renderAffixItem: function (child, index) {
    return cloneWithProps(
      child,
      {
        onSelect: createChainedFunction(child.props.onSelect, this.props.onSelect),
        key: child.key ? child.key : index
      }
    )
  },

  render: function () {
    var holderStyle = {top: this.state.affixPositionTop};
    var Component = this.props.componentClass;

    return (
      React.createElement(Component, React.__spread({},  this.props, {className: joinClasses(this.props.className, this.state.affixClass), style: holderStyle}), 
        ValidComponentChildren.map(this.props.children, this.renderAffixItem)
      )
    );
  }
});

module.exports = Affix;

});

define('WebSkinAlertStyles',['require','exports','module','react','./constants','./utils/Object.assign'],function (require, exports, module) {var React = require('react');
var constants = require('./constants');
var assign = require('./utils/Object.assign');

/// Helper function to produce the custom set of constants
/// that will be used to define the wsStyle propType for the Alert class
var WebSkinAlertStyles = function() {
  var alertWsStyles = constants.STYLES;
  alertWsStyles = assign({}, alertWsStyles, {
    gray: 'gray',
    info: 'default'
  });

  return alertWsStyles;
};

module.exports = WebSkinAlertStyles;

});

define('WebSkinAlertMixin',['require','exports','module','react','./constants','./utils/Object.assign','./WebSkinAlertStyles'],function (require, exports, module) {var React = require('react');
var constants = require('./constants');
var assign = require('./utils/Object.assign');
var WebSkinAlertStyles = require('./WebSkinAlertStyles');

/// Custom WebSkinMixin implementation to support the
/// classNames required to render all the Alert component
/// variations as specified by Web Skin
///
/// Identical to WebSkinMixin except for the wsStyle prop
/// which maps info to default, and adds gray as a valid prop value
var WebSkinAlertMixin = {
  propTypes: {
    wsClass: React.PropTypes.oneOf(Object.keys(constants.CLASSES)),
    wsStyle: React.PropTypes.oneOf(Object.keys(WebSkinAlertStyles())),
    wsSize: React.PropTypes.oneOf(Object.keys(constants.SIZES))
  },

  getWsClassSet: function () {
    var classes = {};

    var wsClass = this.props.wsClass && constants.CLASSES[this.props.wsClass];
    if (wsClass) {
      classes[wsClass] = true;

      var prefix = wsClass + '-';

      var wsSize = this.props.wsSize && constants.SIZES[this.props.wsSize];
      if (wsSize) {
        classes[prefix + wsSize] = true;
      }

      var wsStyle = this.props.wsStyle && WebSkinAlertStyles()[this.props.wsStyle];
      if (this.props.wsStyle) {
        classes[prefix + wsStyle] = true;
      }
    }

    return classes;
  }
};

module.exports = WebSkinAlertMixin;

});

define('Alert',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./WebSkinAlertMixin'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var WebSkinAlertMixin = require('./WebSkinAlertMixin');


var Alert = React.createClass({displayName: "Alert",
  mixins: [WebSkinAlertMixin],

  propTypes: {
    onDismiss: React.PropTypes.func,
    dismissAfter: React.PropTypes.number
  },

  getDefaultProps: function () {
    return {
      wsClass: 'alert',
      wsStyle: 'default'
    };
  },

  renderDismissButton: function () {
    return (
      React.createElement("button", {
        type: "button", 
        className: "close", 
        onClick: this.props.onDismiss, 
        "aria-hidden": "true"}, 
        "×"
      )
    );
  },

  render: function () {
    var classes = this.getWsClassSet();
    var isDismissible = !!this.props.onDismiss;

    classes['alert-dismissible'] = isDismissible;

    return (
      React.createElement("div", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes))}), 
        isDismissible ? this.renderDismissButton() : null, 
        this.props.children
      )
    );
  },

  componentDidMount: function() {
    if (this.props.dismissAfter && this.props.onDismiss) {
      this.dismissTimer = setTimeout(this.props.onDismiss, this.props.dismissAfter);
    }
  },

  componentWillUnmount: function() {
    clearTimeout(this.dismissTimer);
  }
});

module.exports = Alert;

});

define('Badge',['require','exports','module','react','./utils/joinClasses','./utils/ValidComponentChildren','./utils/classSet'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var ValidComponentChildren = require('./utils/ValidComponentChildren');
var classSet = require('./utils/classSet');

var Badge = React.createClass({displayName: "Badge",
  propTypes: {
    pullRight: React.PropTypes.bool
  },

  hasContent: function () {
    return ValidComponentChildren.hasValidComponent(this.props.children) ||
      (typeof this.props.children === 'string') ||
      (typeof this.props.children === 'number')
  },

  render: function () {
    var classes = {
      'pull-right': this.props.pullRight,
      'badge': this.hasContent()
    };
    return (
      React.createElement("span", React.__spread({}, 
        this.props, 
        {className: joinClasses(this.props.className, classSet(classes))}), 
        this.props.children
      )
    );
  }
});

module.exports = Badge;

});

define('Button',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./WebSkinMixin'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var WebSkinMixin = require('./WebSkinMixin');

var Button = React.createClass({displayName: "Button",
  mixins: [WebSkinMixin],

  propTypes: {
    active:   React.PropTypes.bool,
    disabled: React.PropTypes.bool,
    block:    React.PropTypes.bool,
    navItem:    React.PropTypes.bool,
    navDropdown: React.PropTypes.bool,
    componentClass: React.PropTypes.node,
    noText: React.PropTypes.bool,
    pullRight: React.PropTypes.bool,
    callout: React.PropTypes.bool,
    href: React.PropTypes.string,
    target: React.PropTypes.string
  },

  getDefaultProps: function () {
    return {
      wsClass: 'button',
      wsStyle: 'default',
      type: 'button'
    };
  },

  render: function () {
    var classes = this.props.navDropdown ? {} : this.getWsClassSet();

    classes['active'] = this.props.active;
    classes['btn-block'] = this.props.block;
    classes['no-text'] = this.props.noText;
    classes['pull-right'] = this.props.pullRight;
    classes['btn-callout'] = this.props.callout;

    if (this.props.navItem) {
      return this.renderNavItem(classes);
    }

    return this[this.renderFuncName()](classes);
  },

  renderFuncName: function () {
    return this.props.href || this.props.target || this.props.onSelect ?
      'renderAnchor' : 'renderButton';
  },

  renderAnchor: function (classes) {

    var Component = this.props.componentClass || 'a';
    classes['disabled'] = this.props.disabled;

    return (
      React.createElement(Component, React.__spread({}, 
        this.props, 
        {type: null, 
        className: joinClasses(this.props.className, classSet(classes)), 
        role: "button"}), 
        this.props.children
      )
    );
  },

  renderButton: function (classes) {
    var Component = this.props.componentClass || 'button';

    return (
      React.createElement(Component, React.__spread({}, 
        this.props, 
        {className: joinClasses(this.props.className, classSet(classes))}), 
        this.props.children
      )
    );
  },

  renderNavItem: function (classes) {
    var liClasses = {
      active: this.props.active
    };

    return (
      React.createElement("li", {className: classSet(liClasses)}, 
        this[this.renderFuncName()](classes)
      )
    );
  }
});

module.exports = Button;

});

define('ButtonGroup',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./WebSkinMixin','./Button'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var WebSkinMixin = require('./WebSkinMixin');
var Button = require('./Button');

var ButtonGroup = React.createClass({displayName: "ButtonGroup",
  mixins: [WebSkinMixin],

  propTypes: {
    vertical:  React.PropTypes.bool,
    justified: React.PropTypes.bool
  },

  getDefaultProps: function () {
    return {
      wsClass: 'button-group'
    };
  },

  render: function () {
    var classes = this.getWsClassSet();
    classes['btn-group'] = !this.props.vertical;
    classes['btn-group-vertical'] = this.props.vertical;
    classes['btn-group-justified'] = this.props.justified;

    return (
      React.createElement("div", React.__spread({}, 
        this.props, 
        {className: joinClasses(this.props.className, classSet(classes))}), 
        this.props.children
      )
    );
  }
});

module.exports = ButtonGroup;

});

define('ButtonToolbar',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./WebSkinMixin','./Button'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var WebSkinMixin = require('./WebSkinMixin');
var Button = require('./Button');

var ButtonToolbar = React.createClass({displayName: "ButtonToolbar",
  mixins: [WebSkinMixin],

  getDefaultProps: function () {
    return {
      wsClass: 'button-toolbar'
    };
  },

  render: function () {
    var classes = this.getWsClassSet();

    return (
      React.createElement("div", React.__spread({}, 
        this.props, 
        {role: "toolbar", 
        className: joinClasses(this.props.className, classSet(classes))}), 
        this.props.children
      )
    );
  }
});

module.exports = ButtonToolbar;

});

define('Carousel',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./utils/cloneWithProps','./WebSkinMixin','./utils/ValidComponentChildren'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var cloneWithProps = require('./utils/cloneWithProps');
var WebSkinMixin = require('./WebSkinMixin');
var ValidComponentChildren = require('./utils/ValidComponentChildren');

var Carousel = React.createClass({displayName: "Carousel",
  mixins: [WebSkinMixin],

  propTypes: {
    slide: React.PropTypes.bool,
    indicators: React.PropTypes.bool,
    controls: React.PropTypes.bool,
    pauseOnHover: React.PropTypes.bool,
    wrap: React.PropTypes.bool,
    onSelect: React.PropTypes.func,
    onSlideEnd: React.PropTypes.func,
    activeIndex: React.PropTypes.number,
    defaultActiveIndex: React.PropTypes.number,
    direction: React.PropTypes.oneOf(['prev', 'next'])
  },

  getDefaultProps: function () {
    return {
      slide: true,
      interval: 5000,
      pauseOnHover: true,
      wrap: true,
      indicators: true,
      controls: true
    };
  },

  getInitialState: function () {
    return {
      activeIndex: this.props.defaultActiveIndex == null ?
        0 : this.props.defaultActiveIndex,
      previousActiveIndex: null,
      direction: null
    };
  },

  getDirection: function (prevIndex, index) {
    if (prevIndex === index) {
      return null;
    }

    return prevIndex > index ?
      'prev' : 'next';
  },

  componentWillReceiveProps: function (nextProps) {
    var activeIndex = this.getActiveIndex();

    if (nextProps.activeIndex != null && nextProps.activeIndex !== activeIndex) {
      clearTimeout(this.timeout);
      this.setState({
        previousActiveIndex: activeIndex,
        direction: nextProps.direction != null ?
          nextProps.direction : this.getDirection(activeIndex, nextProps.activeIndex)
      });
    }
  },

  componentDidMount: function () {
    this.waitForNext();
  },

  componentWillUnmount: function() {
    clearTimeout(this.timeout);
  },

  next: function (e) {
    if (e) {
      e.preventDefault();
    }

    var index = this.getActiveIndex() + 1;
    var count = ValidComponentChildren.numberOf(this.props.children);

    if (index > count - 1) {
      if (!this.props.wrap) {
        return;
      }
      index = 0;
    }

    this.handleSelect(index, 'next');
  },

  prev: function (e) {
    if (e) {
      e.preventDefault();
    }

    var index = this.getActiveIndex() - 1;

    if (index < 0) {
      if (!this.props.wrap) {
        return;
      }
      index = ValidComponentChildren.numberOf(this.props.children) - 1;
    }

    this.handleSelect(index, 'prev');
  },

  pause: function () {
    this.isPaused = true;
    clearTimeout(this.timeout);
  },

  play: function () {
    this.isPaused = false;
    this.waitForNext();
  },

  waitForNext: function () {
    if (!this.isPaused && this.props.slide && this.props.interval &&
        this.props.activeIndex == null) {
      this.timeout = setTimeout(this.next, this.props.interval);
    }
  },

  handleMouseOver: function () {
    if (this.props.pauseOnHover) {
      this.pause();
    }
  },

  handleMouseOut: function () {
    if (this.isPaused) {
      this.play();
    }
  },

  render: function () {
    var classes = {
      carousel: true,
      slide: this.props.slide
    };

    return (
      React.createElement("div", React.__spread({}, 
        this.props, 
        {className: joinClasses(this.props.className, classSet(classes)), 
        onMouseOver: this.handleMouseOver, 
        onMouseOut: this.handleMouseOut}), 
        this.props.indicators ? this.renderIndicators() : null, 
        React.createElement("div", {className: "carousel-inner", ref: "inner"}, 
          ValidComponentChildren.map(this.props.children, this.renderItem)
        ), 
        this.props.controls ? this.renderControls() : null
      )
    );
  },

  renderPrev: function () {
    return (
      React.createElement("a", {className: "left carousel-control hitarea", href: "#prev", key: 0, onClick: this.prev}, 
        React.createElement("i", {className: "icon icon-carousel-prev icon-lg"}), 
        React.createElement("i", {className: "sr-only"}, "Previous")
      )
    );
  },

  renderNext: function () {
    return (
      React.createElement("a", {className: "right carousel-control hitarea", href: "#next", key: 1, onClick: this.next}, 
        React.createElement("i", {className: "icon icon-carousel-next icon-lg"}), 
        React.createElement("i", {className: "sr-only"}, "Next")
      )
    );
  },

  renderControls: function () {
    if (this.props.wrap) {
      var activeIndex = this.getActiveIndex();
      var count = ValidComponentChildren.numberOf(this.props.children);

      return [
        (activeIndex !== 0) ? this.renderPrev() : null,
        (activeIndex !== count - 1) ? this.renderNext() : null
      ];
    }

    return [
      this.renderPrev(),
      this.renderNext()
    ];
  },

  renderIndicator: function (child, index) {
    var className = (index === this.getActiveIndex()) ?
      'active' : null;

    return (
      React.createElement("li", {
        key: index, 
        className: className, 
        onClick: this.handleSelect.bind(this, index, null)})
    );
  },

  renderIndicators: function () {
    var indicators = [];
    ValidComponentChildren
      .forEach(this.props.children, function(child, index) {
        indicators.push(
          this.renderIndicator(child, index),

          // Force whitespace between indicator elements, bootstrap
          // requires this for correct spacing of elements.
          ' '
        );
      }, this);

    return (
      React.createElement("ol", {className: "page-indicators"}, 
        indicators
      )
    );
  },

  getActiveIndex: function () {
    return this.props.activeIndex != null ? this.props.activeIndex : this.state.activeIndex;
  },

  handleItemAnimateOutEnd: function () {
    this.setState({
      previousActiveIndex: null,
      direction: null
    }, function() {
      this.waitForNext();

      if (this.props.onSlideEnd) {
        this.props.onSlideEnd();
      }
    });
  },

  renderItem: function (child, index) {
    var activeIndex = this.getActiveIndex();
    var isActive = (index === activeIndex);
    var isPreviousActive = this.state.previousActiveIndex != null &&
            this.state.previousActiveIndex === index && this.props.slide;

    return cloneWithProps(
        child,
        {
          active: isActive,
          ref: child.ref,
          key: child.key ? child.key : index,
          index: index,
          animateOut: isPreviousActive,
          animateIn: isActive && this.state.previousActiveIndex != null && this.props.slide,
          direction: this.state.direction,
          onAnimateOutEnd: isPreviousActive ? this.handleItemAnimateOutEnd: null
        }
      );
  },

  handleSelect: function (index, direction) {
    clearTimeout(this.timeout);

    var previousActiveIndex = this.getActiveIndex();
    direction = direction || this.getDirection(previousActiveIndex, index);

    if (this.props.onSelect) {
      this.props.onSelect(index, direction);
    }

    if (this.props.activeIndex == null && index !== previousActiveIndex) {
      if (this.state.previousActiveIndex != null) {
        // If currently animating don't activate the new index.
        // TODO: look into queuing this canceled call and
        // animating after the current animation has ended.
        return;
      }

      this.setState({
        activeIndex: index,
        previousActiveIndex: previousActiveIndex,
        direction: direction
      });
    }
  }
});

module.exports = Carousel;

});

define('utils/TransitionEvents',['require','exports','module'],function (require, exports, module) {/**
 * Copyright 2013-2014, Facebook, Inc.
 * All rights reserved.
 *
 * This file contains a modified version of:
 * https://github.com/facebook/react/blob/v0.12.0/src/addons/transitions/ReactTransitionEvents.js
 *
 * This source code is licensed under the BSD-style license found here:
 * https://github.com/facebook/react/blob/v0.12.0/LICENSE
 * An additional grant of patent rights can be found here:
 * https://github.com/facebook/react/blob/v0.12.0/PATENTS
 */

var canUseDOM = !!(
  typeof window !== 'undefined' &&
    window.document &&
    window.document.createElement
  );

/**
 * EVENT_NAME_MAP is used to determine which event fired when a
 * transition/animation ends, based on the style property used to
 * define that event.
 */
var EVENT_NAME_MAP = {
  transitionend: {
    'transition': 'transitionend',
    'WebkitTransition': 'webkitTransitionEnd',
    'MozTransition': 'mozTransitionEnd',
    'OTransition': 'oTransitionEnd',
    'msTransition': 'MSTransitionEnd'
  },

  animationend: {
    'animation': 'animationend',
    'WebkitAnimation': 'webkitAnimationEnd',
    'MozAnimation': 'mozAnimationEnd',
    'OAnimation': 'oAnimationEnd',
    'msAnimation': 'MSAnimationEnd'
  }
};

var endEvents = [];

function detectEvents() {
  var testEl = document.createElement('div');
  var style = testEl.style;

  // On some platforms, in particular some releases of Android 4.x,
  // the un-prefixed "animation" and "transition" properties are defined on the
  // style object but the events that fire will still be prefixed, so we need
  // to check if the un-prefixed events are useable, and if not remove them
  // from the map
  if (!('AnimationEvent' in window)) {
    delete EVENT_NAME_MAP.animationend.animation;
  }

  if (!('TransitionEvent' in window)) {
    delete EVENT_NAME_MAP.transitionend.transition;
  }

  for (var baseEventName in EVENT_NAME_MAP) {
    var baseEvents = EVENT_NAME_MAP[baseEventName];
    for (var styleName in baseEvents) {
      if (styleName in style) {
        endEvents.push(baseEvents[styleName]);
        break;
      }
    }
  }
}

if (canUseDOM) {
  detectEvents();
}

// We use the raw {add|remove}EventListener() call because EventListener
// does not know how to remove event listeners and we really should
// clean up. Also, these events are not triggered in older browsers
// so we should be A-OK here.

function addEventListener(node, eventName, eventListener) {
  node.addEventListener(eventName, eventListener, false);
}

function removeEventListener(node, eventName, eventListener) {
  node.removeEventListener(eventName, eventListener, false);
}

var ReactTransitionEvents = {
  addEndEventListener: function(node, eventListener) {
    if (endEvents.length === 0) {
      // If CSS transitions are not supported, trigger an "end animation"
      // event immediately.
      window.setTimeout(eventListener, 0);
      return;
    }
    endEvents.forEach(function(endEvent) {
      addEventListener(node, endEvent, eventListener);
    });
  },

  removeEndEventListener: function(node, eventListener) {
    if (endEvents.length === 0) {
      return;
    }
    endEvents.forEach(function(endEvent) {
      removeEventListener(node, endEvent, eventListener);
    });
  }
};

module.exports = ReactTransitionEvents;

});

define('CarouselItem',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./utils/TransitionEvents'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var TransitionEvents = require('./utils/TransitionEvents');

var CarouselItem = React.createClass({displayName: "CarouselItem",
  propTypes: {
    direction: React.PropTypes.oneOf(['prev', 'next']),
    onAnimateOutEnd: React.PropTypes.func,
    active: React.PropTypes.bool,
    caption: React.PropTypes.node
  },

  getInitialState: function () {
    return {
      direction: null
    };
  },

  getDefaultProps: function () {
    return {
      animation: true
    };
  },

  handleAnimateOutEnd: function () {
    if (this.props.onAnimateOutEnd && this.isMounted()) {
      this.props.onAnimateOutEnd(this.props.index);
    }
  },

  componentWillReceiveProps: function (nextProps) {
    if (this.props.active !== nextProps.active) {
      this.setState({
        direction: null
      });
    }
  },

  componentDidUpdate: function (prevProps) {
    if (!this.props.active && prevProps.active) {
      TransitionEvents.addEndEventListener(
        this.getDOMNode(),
        this.handleAnimateOutEnd
      );
    }

    if (this.props.active !== prevProps.active) {
      setTimeout(this.startAnimation, 20);
    }
  },

  startAnimation: function () {
    if (!this.isMounted()) {
      return;
    }

    this.setState({
      direction: this.props.direction === 'prev' ?
        'right' : 'left'
    });
  },

  render: function () {
    var classes = {
      item: true,
      active: (this.props.active && !this.props.animateIn) || this.props.animateOut,
      next: this.props.active && this.props.animateIn && this.props.direction === 'next',
      prev: this.props.active && this.props.animateIn && this.props.direction === 'prev'
    };

    if (this.state.direction && (this.props.animateIn || this.props.animateOut)) {
      classes[this.state.direction] = true;
    }

    return (
      React.createElement("div", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes))}), 
        this.props.children, 
        this.props.caption ? this.renderCaption() : null
      )
    );
  },

  renderCaption: function () {
    return (
      React.createElement("div", {className: "carousel-caption"}, 
        this.props.caption
      )
    );
  }
});

module.exports = CarouselItem;
});

define('Col',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./constants'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var constants = require('./constants');


var Col = React.createClass({displayName: "Col",
  propTypes: {
    xs: React.PropTypes.number,
    sm: React.PropTypes.number,
    md: React.PropTypes.number,
    lg: React.PropTypes.number,
    xsOffset: React.PropTypes.number,
    smOffset: React.PropTypes.number,
    mdOffset: React.PropTypes.number,
    lgOffset: React.PropTypes.number,
    xsPush: React.PropTypes.number,
    smPush: React.PropTypes.number,
    mdPush: React.PropTypes.number,
    lgPush: React.PropTypes.number,
    xsPull: React.PropTypes.number,
    smPull: React.PropTypes.number,
    mdPull: React.PropTypes.number,
    lgPull: React.PropTypes.number,
    componentClass: React.PropTypes.node.isRequired
  },

  getDefaultProps: function () {
    return {
      componentClass: 'div'
    };
  },

  render: function () {
    var ComponentClass = this.props.componentClass;
    var classes = {};

    Object.keys(constants.SIZES).forEach(function (key) {
      var size = constants.SIZES[key];
      var prop = size;
      var classPart = size + '-';

      if (this.props[prop]) {
        classes['col-' + classPart + this.props[prop]] = true;
      }

      prop = size + 'Offset';
      classPart = size + '-offset-';
      if (this.props[prop] >= 0) {
        classes['col-' + classPart + this.props[prop]] = true;
      }

      prop = size + 'Push';
      classPart = size + '-push-';
      if (this.props[prop] >= 0) {
        classes['col-' + classPart + this.props[prop]] = true;
      }

      prop = size + 'Pull';
      classPart = size + '-pull-';
      if (this.props[prop] >= 0) {
        classes['col-' + classPart + this.props[prop]] = true;
      }
    }, this);

    return (
      React.createElement(ComponentClass, React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes))}), 
        this.props.children
      )
    );
  }
});

module.exports = Col;

});

define('CollapsibleMixin',['require','exports','module','react','./utils/TransitionEvents'],function (require, exports, module) {var React = require('react');
var TransitionEvents = require('./utils/TransitionEvents');

var CollapsibleMixin = {

  propTypes: {
    defaultExpanded: React.PropTypes.bool,
    expanded: React.PropTypes.bool
  },

  getInitialState: function () {
    var defaultExpanded = this.props.defaultExpanded != null ?
      this.props.defaultExpanded :
      this.props.expanded != null ?
        this.props.expanded :
        false;

    return {
      expanded: defaultExpanded,
      collapsing: false
    };
  },

  componentWillUpdate: function (nextProps, nextState) {
    var willExpanded = nextProps.expanded != null ? nextProps.expanded : nextState.expanded;
    if (willExpanded === this.isExpanded()) {
      return;
    }

    /// if the expanded state is being toggled, ensure node has a dimension value
    /// this is needed for the animation to work and needs to be set before
    /// the collapsing class is applied (after collapsing is applied the in class
    /// is removed and the node's dimension will be wrong)

    var node = this.getCollapsibleDOMNode();
    var dimension = this.dimension();
    var value = '0';

    if (!willExpanded) {
      value = this.getCollapsibleDimensionValue();
    }

    node.style[dimension] = value + 'px';

    this._afterWillUpdate();
  },

  componentDidUpdate: function (prevProps, prevState) {
    /// check if expanded is being toggled; if so, set collapsing
    this._checkToggleCollapsing(prevProps, prevState);

    /// check if collapsing was turned on; if so, start animation
    this._checkStartAnimation();
  },

  /// helps enable test stubs
  _afterWillUpdate: function () {
  },

  _checkStartAnimation: function () {
    if (!this.state.collapsing) {
      return;
    }

    var node = this.getCollapsibleDOMNode();
    var dimension = this.dimension();
    var value = this.getCollapsibleDimensionValue();

    /// setting the dimension here starts the transition animation
    var result;
    if (this.isExpanded()) {
      result = value + 'px';
    } else {
      result = '0px';
    }
    node.style[dimension] = result;
  },

  _checkToggleCollapsing: function (prevProps, prevState) {
    var wasExpanded = prevProps.expanded != null ? prevProps.expanded : prevState.expanded;
    var isExpanded = this.isExpanded();
    if (wasExpanded !== isExpanded) {
      if (wasExpanded) {
        this._handleCollapse();
      } else {
        this._handleExpand();
      }
    }
  },

  _handleExpand: function () {
    var self = this;
    var node = this.getCollapsibleDOMNode();
    var dimension = this.dimension();

    var complete = (function () {
      self._removeEndEventListener(node, complete);
      /// remove dimension value - this ensures the collapsible item can grow
      /// in dimension after initial display (such as an image loading)
      node.style[dimension] = '';
      self.setState({
        collapsing:false
      });
    });

    this._addEndEventListener(node, complete);

    this.setState({
      collapsing: true
    });
  },

  _handleCollapse: function () {
    var self = this;
    var node = this.getCollapsibleDOMNode();

    var complete = (function () {
      self._removeEndEventListener(node, complete);
      self.setState({
        collapsing: false
      });
    });

    this._addEndEventListener(node, complete);

    this.setState({
      collapsing: true
    });
  },

  /// helps enable test stubs
  _addEndEventListener: function (node, complete) {
    TransitionEvents.addEndEventListener(node, complete);
  },

  /// helps enable test stubs
  _removeEndEventListener: function (node, complete) {
    TransitionEvents.removeEndEventListener(node, complete);
  },

  dimension: function () {
    return (typeof this.getCollapsibleDimension === 'function') ?
      this.getCollapsibleDimension() :
      'height';
  },

  isExpanded: function () {
    return this.props.expanded != null ? this.props.expanded : this.state.expanded;
  },

  getCollapsibleClassSet: function (className) {
    var classes = {};

    if (typeof className === 'string') {
      className.split(' ').forEach(function (className) {
        if (className) {
          classes[className] = true;
        }
      });
    }

    classes['collapsing'] = this.state.collapsing;
    classes['collapse'] = !this.state.collapsing;
    classes['in'] = this.isExpanded() && !this.state.collapsing;

    return classes;
  }
};

module.exports = CollapsibleMixin;

});

define('CollapsibleNav',['require','exports','module','react','./utils/joinClasses','./WebSkinMixin','./CollapsibleMixin','./utils/classSet','./utils/domUtils','./utils/cloneWithProps','./utils/ValidComponentChildren','./utils/createChainedFunction'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var WebSkinMixin = require('./WebSkinMixin');
var CollapsibleMixin = require('./CollapsibleMixin');
var classSet = require('./utils/classSet');
var domUtils = require('./utils/domUtils');
var cloneWithProps = require('./utils/cloneWithProps');

var ValidComponentChildren = require('./utils/ValidComponentChildren');
var createChainedFunction = require('./utils/createChainedFunction');


var CollapsibleNav = React.createClass({displayName: "CollapsibleNav",
  mixins: [WebSkinMixin, CollapsibleMixin],

  propTypes: {
    onSelect: React.PropTypes.func,
    expanded: React.PropTypes.bool,
    eventKey: React.PropTypes.any
  },

  getCollapsibleDOMNode: function () {
    return this.getDOMNode();
  },

  getCollapsibleDimensionValue: function () {
    var height = 0;
    var nodes = this.refs;
    for (var key in nodes) {
      if (nodes.hasOwnProperty(key)) {

        var n = nodes[key].getDOMNode()
          , h = n.offsetHeight
          , computedStyles = domUtils.getComputedStyles(n);

        height += (h + parseInt(computedStyles.marginTop, 10) + parseInt(computedStyles.marginBottom, 10));
      }
    }
    return height;
  },

  render: function () {
    /// this.props.collapsible is set in NavBar when a eventKey is supplied.
    var classes = this.props.collapsible ? this.getCollapsibleClassSet() : {};
    /// prevent duplicating navbar-collapse call if passed as prop. kind of overkill...
    /// good candidate to have check implemented as a util that can also be used elsewhere.
    if (this.props.className == undefined || this.props.className.split(" ").indexOf('navbar-collapse') == -1)
      classes['navbar-collapse'] = this.props.collapsible;

    return (
      React.createElement("div", {eventKey: this.props.eventKey, className: joinClasses(this.props.className, classSet(classes))}, 
        ValidComponentChildren.map(this.props.children, (this.props.collapsible) ? this.renderCollapsibleNavChildren : this.renderChildren)
      )
    );
  },

  getChildActiveProp: function (child) {
    if (child.props.active) {
      return true;
    }
    if (this.props.activeKey != null) {
      if (child.props.eventKey == this.props.activeKey) {
        return true;
      }
    }
    if (this.props.activeHref != null) {
      if (child.props.href === this.props.activeHref) {
        return true;
      }
    }

    return child.props.active;
  },

  renderChildren: function (child, index) {
    var key = child.key ? child.key : index;
    return cloneWithProps(
      child,
      {
        activeKey: this.props.activeKey,
        activeHref: this.props.activeHref,
        ref: 'nocollapse_' + key,
        key: key,
        navItem: true
      }
    );
  },

  renderCollapsibleNavChildren: function (child, index) {
    var key = child.key ? child.key : index;
    return cloneWithProps(
      child,
      {
        active: this.getChildActiveProp(child),
        activeKey: this.props.activeKey,
        activeHref: this.props.activeHref,
        onSelect: createChainedFunction(child.props.onSelect, this.props.onSelect),
        ref: 'collapsible_' + key,
        key: key,
        navItem: true
      }
    );
  }
});

module.exports = CollapsibleNav;

});

define('DropdownStateMixin',['require','exports','module','react','./utils/EventListener'],function (require, exports, module) {var React = require('react');
var EventListener = require('./utils/EventListener');

/**
 * Checks whether a node is within
 * a root nodes tree
 *
 * @param {DOMElement} node
 * @param {DOMElement} root
 * @returns {boolean}
 */
function isNodeInRoot(node, root) {
  while (node) {
    if (node === root) {
      return true;
    }
    node = node.parentNode;
  }

  return false;
}

var DropdownStateMixin = {
  getInitialState: function () {
    return {
      open: false
    };
  },

  setDropdownState: function (newState, onStateChangeComplete) {
    if (newState) {
      this.bindRootCloseHandlers();
    } else {
      this.unbindRootCloseHandlers();
    }

    this.setState({
      open: newState
    }, onStateChangeComplete);
  },

  handleDocumentKeyUp: function (e) {
    if (e.keyCode === 27) {
      this.setDropdownState(false);
    }
  },

  handleDocumentClick: function (e) {
    // If the click originated from within this component
    // don't do anything.
    if (isNodeInRoot(e.target, this.getDOMNode())) {
      return;
    }

    this.setDropdownState(false);
  },

  bindRootCloseHandlers: function () {
    this._onDocumentClickListener =
      EventListener.listen(document, 'click', this.handleDocumentClick);
    this._onDocumentKeyupListener =
      EventListener.listen(document, 'keyup', this.handleDocumentKeyUp);
  },

  unbindRootCloseHandlers: function () {
    if (this._onDocumentClickListener) {
      this._onDocumentClickListener.remove();
    }

    if (this._onDocumentKeyupListener) {
      this._onDocumentKeyupListener.remove();
    }
  },

  componentWillUnmount: function () {
    this.unbindRootCloseHandlers();
  }
};

module.exports = DropdownStateMixin;
});

define('DropdownMenu',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./utils/cloneWithProps','./utils/createChainedFunction','./utils/ValidComponentChildren'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var cloneWithProps = require('./utils/cloneWithProps');

var createChainedFunction = require('./utils/createChainedFunction');
var ValidComponentChildren = require('./utils/ValidComponentChildren');

var DropdownMenu = React.createClass({displayName: "DropdownMenu",
  propTypes: {
    pullRight: React.PropTypes.bool,
    pullLeft: React.PropTypes.bool,
    onSelect: React.PropTypes.func
  },

  render: function () {
    var classes = {
      'dropdown-menu': true,
      'dropdown-menu-right': this.props.pullRight,
      'dropdown-menu-left': this.props.pullLeft
    };

    return (
        React.createElement("ul", React.__spread({}, 
          this.props, 
          {className: joinClasses(this.props.className, classSet(classes)), 
          role: "menu"}), 
          ValidComponentChildren.map(this.props.children, this.renderMenuItem)
        )
      );
  },

  renderMenuItem: function (child, index) {
    return cloneWithProps(
      child,
      {
        className: 'menu-item',
        // Capture onSelect events
        onSelect: createChainedFunction(child.props.onSelect, this.props.onSelect),

        // Force special props to be transferred
        key: child.key ? child.key : index,
        ref: child.ref
      }
    );
  }
});

module.exports = DropdownMenu;

});

define('Glyphicon',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./WebSkinMixin','./constants'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var WebSkinMixin = require('./WebSkinMixin');
var constants = require('./constants');

var Glyphicon = React.createClass({displayName: "Glyphicon",
  mixins: [WebSkinMixin],

  propTypes: {
    glyph: React.PropTypes.string.isRequired,
    color: React.PropTypes.oneOf(Object.keys(constants.GLYPH_COLORS))
  },

  getDefaultProps: function () {
    return {
      wsClass: 'icon'
    };
  },

  render: function () {
    var classes = this.getWsClassSet();

    classes['icon-' + this.props.glyph] = true;

    // add color modifier
    var color = this.props.color && constants.GLYPH_COLORS[this.props.color];
    if (color) {
      classes[color] = true;
    }

    return (
      React.createElement("i", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes))}), 
        this.props.children
      )
    );
  }
});

module.exports = Glyphicon;

});

define('DropdownButton',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./utils/cloneWithProps','./utils/createChainedFunction','./WebSkinMixin','./DropdownStateMixin','./Button','./ButtonGroup','./DropdownMenu','./Glyphicon','./utils/ValidComponentChildren'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var cloneWithProps = require('./utils/cloneWithProps');

var createChainedFunction = require('./utils/createChainedFunction');
var WebSkinMixin = require('./WebSkinMixin');
var DropdownStateMixin = require('./DropdownStateMixin');
var Button = require('./Button');
var ButtonGroup = require('./ButtonGroup');
var DropdownMenu = require('./DropdownMenu');
var Glyphicon = require('./Glyphicon');
var ValidComponentChildren = require('./utils/ValidComponentChildren');


var DropdownButton = React.createClass({displayName: "DropdownButton",
  mixins: [WebSkinMixin, DropdownStateMixin],

  propTypes: {
    /// Floats Button parent right using `pull-right` CSS class,
    /// and adds `dropdown-menu-right` CSS class to DropDownMenu
    /// unless `menuPullLeft` prop is set
    pullRight:       React.PropTypes.bool,
    /// Adds `dropdown-menu-right` CSS class to `DropdownMenu`
    /// to right-align the menu without floating the parent
    /// `ButtonGroup` / `<li>`
    menuPullRight:   React.PropTypes.bool,
    /// Adds `dropdown-menu-left` CSS class to `DropdownMenu`,
    /// which can be used in combination with the `pullRight`
    /// prop to left-align a menu triggered from a
    /// right-aligned `ButtonGroup` / `<li>`
    menuPullLeft:    React.PropTypes.bool,
    dropup:          React.PropTypes.bool,
    title:           React.PropTypes.node,
    href:            React.PropTypes.string,
    onClick:         React.PropTypes.func,
    onSelect:        React.PropTypes.func,
    navItem:         React.PropTypes.bool,
    noCaret:         React.PropTypes.bool,
    indicator:       React.PropTypes.oneOf(['caret', 'icon', 'none']),
    openedIndicator: React.PropTypes.string,
    closedIndicator: React.PropTypes.string,
    /// Add a custom CSS class to the `.caret` or indicator glyph
    indicatorClassName: React.PropTypes.string
  },

  getDefaultProps: function() {
    return {
      noCaret: false,
      indicator: 'caret',
      openedIndicator: 'chevron-up',
      closedIndicator: 'chevron-down'
    };
  },

  render: function () {
    var classes = {
      'dropdown-toggle': true,
      'hitarea': this.props.navItem
    };

    var renderMethod = this.props.navItem ?
      'renderNavItem' : 'renderButtonGroup';

    return this[renderMethod]([
      React.createElement(Button, React.__spread({}, 
        this.props, 
        {ref: "dropdownButton", 
        className: joinClasses(this.props.className, classSet(classes)), 
        onClick: this.handleDropdownClick, 
        key: 0, 
        navDropdown: this.props.navItem, 
        navItem: null, 
        title: null, 
        pullRight: null, 
        dropup: null}), 
        this.props.title, 
        ' ', 
        this.renderIndicatorIcon()
      ),
      React.createElement(DropdownMenu, {
        ref: "menu", 
        "aria-labelledby": this.props.id, 
        pullRight: !this.props.menuPullLeft && (this.props.pullRight || this.props.menuPullRight), 
        pullLeft: this.props.menuPullLeft, 
        key: 1}, 
        ValidComponentChildren.map(this.props.children, this.renderMenuItem)
      )
    ]);
  },

  renderIndicatorIcon: function() {
    var indicatorClasses = {
      'align-right': this.props.indicator === 'icon',
      'caret': this.props.indicator === 'caret',
      'caret-sm': this.props.indicator === 'caret' && this.props.wsSize === 'xsmall'
    };

    indicatorClasses[this.props.indicatorClassName] = this.props.indicatorClassName;

    if (this.props.noCaret || this.props.indicator == 'none') {
      return null;
    } else if (this.props.indicator == 'icon') {
      var currentIcon = this.state.open ?
        this.props.openedIndicator : this.props.closedIndicator;
      return (React.createElement(Glyphicon, {glyph: currentIcon, className: classSet(indicatorClasses)}));
    }

    return (React.createElement("i", {className: classSet(indicatorClasses), "aria-hidden": "true"}));
  },

  renderButtonGroup: function (children) {
    var groupClasses = {
      'dropdown': true,
      'dropup': this.props.dropup,
      'open': this.state.open,
      'pull-right': this.props.pullRight
    };

    return (
      React.createElement(ButtonGroup, {
        wsSize: this.props.wsSize, 
        className: joinClasses(this.props.className, classSet(groupClasses))}, 
        children
      )
    );
  },

  renderNavItem: function (children) {
    var classes = {
      'nav-item': true,
      'dropdown': true,
      'dropup': this.props.dropup,
      'open': this.state.open
    };

    return (
      React.createElement("li", {className: joinClasses(this.props.className, classSet(classes))}, 
        children
      )
    );
  },

  renderMenuItem: function (child, index) {
    // Only handle the option selection if an onSelect prop has been set on the
    // component or it's child, this allows a user not to pass an onSelect
    // handler and have the browser preform the default action.
    var handleOptionSelect = this.props.onSelect || child.props.onSelect ?
      this.handleOptionSelect : null;

    return cloneWithProps(
      child,
      {
        // Capture onSelect events
        onSelect: createChainedFunction(child.props.onSelect, handleOptionSelect),

        // Force special props to be transferred
        key: child.key ? child.key : index,
        ref: child.ref
      }
    );
  },

  handleDropdownClick: function (e) {
    e.preventDefault();

    this.setDropdownState(!this.state.open);
  },

  handleOptionSelect: function (key) {
    if (this.props.onSelect) {
      this.props.onSelect(key);
    }

    this.setDropdownState(false);
  }
});

module.exports = DropdownButton;

});

define('FadeMixin',['require','exports','module'],function (require, exports, module) {/*global document */
// TODO: listen for onTransitionEnd to remove el
function getElementsAndSelf (root, classes){
  var els = root.querySelectorAll('.' + classes.join('.'));

  els = [].map.call(els, function(e){ return e; });

  for(var i = 0; i < classes.length; i++){
    if( !root.className.match(new RegExp('\\b' +  classes[i] + '\\b'))){
      return els;
    }
  }
  els.unshift(root);
  return els;
}

module.exports = {
  _fadeIn: function () {
    var els;

    if (this.isMounted()) {
      els = getElementsAndSelf(this.getDOMNode(), ['fade']);

      if (els.length) {
        els.forEach(function (el) {
          el.className += ' in';
        });
      }
    }
  },

  _fadeOut: function () {
    var els = getElementsAndSelf(this._fadeOutEl, ['fade', 'in']);

    if (els.length) {
      els.forEach(function (el) {
        el.className = el.className.replace(/\bin\b/, '');
      });
    }

    setTimeout(this._handleFadeOutEnd, 300);
  },

  _handleFadeOutEnd: function () {
    if (this._fadeOutEl && this._fadeOutEl.parentNode) {
      this._fadeOutEl.parentNode.removeChild(this._fadeOutEl);
    }
  },

  componentDidMount: function () {
    if (document.querySelectorAll) {
      // Firefox needs delay for transition to be triggered
      setTimeout(this._fadeIn, 20);
    }
  },

  componentWillUnmount: function () {
    var els = getElementsAndSelf(this.getDOMNode(), ['fade']),
        container = (this.props.container && this.props.container.getDOMNode()) || document.body;

    if (els.length) {
      this._fadeOutEl = document.createElement('div');
      container.appendChild(this._fadeOutEl);
      this._fadeOutEl.appendChild(this.getDOMNode().cloneNode(true));
      // Firefox needs delay for transition to be triggered
      setTimeout(this._fadeOut, 20);
    }
  }
};

});

define('Grid',['require','exports','module','react','./utils/joinClasses'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');

var Grid = React.createClass({displayName: "Grid",
  propTypes: {
    componentClass: React.PropTypes.node.isRequired,
    /// Whether or not to render the Grid surrounded
    /// by a DOM elem with CSS class `container`
    isContainer: React.PropTypes.bool
  },

  getDefaultProps: function () {
    return {
      componentClass: 'div',
      isContainer: true
    };
  },

  render: function () {
    var ComponentClass = this.props.componentClass;
    var className = this.props.isContainer ? 'container' : '';

    return (
      React.createElement(ComponentClass, React.__spread({}, 
        this.props, 
        {className: joinClasses(this.props.className, className)}), 
        this.props.children
      )
    );
  }
});

module.exports = Grid;

});

define('Input',['require','exports','module','react','./constants','./utils/joinClasses','./utils/classSet','./Button','./utils/cloneWithProps'],function (require, exports, module) {var React = require('react');
var constants = require('./constants');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var Button = require('./Button');
var cloneWithProps = require('./utils/cloneWithProps');

var Input = React.createClass({displayName: "Input",

  propTypes: {
    id: function(props) {
      var idPropType = false;

      if (props.type) {
        idPropType = React.PropTypes.string.isRequired;
      }

      return idPropType;
    },
    /// Can be either a valid HTML5 input type, or the
    /// "custom" prop types listed in `constants.INPUT_TYPES`
    type: React.PropTypes.oneOf(Object.keys(constants.INPUT_TYPES)),
    label: React.PropTypes.node,
    help: React.PropTypes.node,
    addonBefore: React.PropTypes.node,
    addonAfter: React.PropTypes.node,
    buttonBefore: React.PropTypes.node,
    buttonAfter: React.PropTypes.node,
    wsSize: React.PropTypes.oneOf(Object.keys(constants.SIZES)),
    wsStyle: function (props) {
      if (props.type === 'submit') {
        // Return early if `type=submit` as the `Button` component
        // it transfers these props to has its own propType checks.
        return;
      }

      return React.PropTypes.oneOf(['success', 'warning', 'error']).apply(null, arguments);
    },
    hasFeedback: React.PropTypes.bool,
    /// Whether or not to wrap the instance in it's own `<div class="form-group">`
    group: React.PropTypes.bool,
    groupClassName: React.PropTypes.string,
    wrapperClassName: React.PropTypes.string,
    labelClassName: React.PropTypes.string,
    disabled: React.PropTypes.bool
  },

  getDefaultProps: function () {
    return {
      group: true,
      /// Default ref for the input generated based on the `type` prop.
      ref: 'input',
      /// Default key for the input generated based on the `type` prop.
      key: 'input'
    };
  },

  getInputDOMNode: function () {
    return this.refs.input.getDOMNode();
  },

  getValue: function () {
    if (this.props.type) {
      if (this.props.type == "select" && this.props.multiple) {
        return this.getSelectedOptions();
      } else {
        return this.getInputDOMNode().value;
      }
    }
    else {
      throw Error('Cannot use getValue without specifying input type.');
    }
  },

  getChecked: function () {
    return this.getInputDOMNode().checked;
  },

  getSelectedOptions: function () {
    var values = [];

    Array.prototype.forEach.call(
      this.getInputDOMNode().getElementsByTagName('option'),
      function (option) {
        if (option.selected) {
          var value = option.getAttribute('value') || option.innerHTML;

          values.push(value);
        }
      }
    );

    return values;
  },

  isCheckboxOrRadio: function () {
    return this.props.type === 'radio' || this.props.type === 'checkbox';
  },

  isFile: function () {
    return this.props.type === 'file';
  },

  renderInput: function () {
    var input = null;

    if (!this.props.type) {
      return this.props.children
    }

    var classes = {
      'form-control': !this.isCheckboxOrRadio() && !this.isFile(),
      'form-control-static': this.props.type === 'static'
    };

    if (this.props.wsSize) {
      classes['input-' + constants.SIZES[this.props.wsSize]] = true;
    }

    switch (this.props.type) {
      case 'select':
        input = (
          React.createElement("select", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes))}), 
            this.props.children
          )
        );
        break;
      case 'textarea':
        input = React.createElement("textarea", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes))}));
        break;
      case 'static':
        input = React.createElement("input", React.__spread({},  this.props, {readOnly: true, className: joinClasses(this.props.className, classSet(classes))}));
        break;
      case 'submit':
        input = (
          React.createElement(Button, React.__spread({},  this.props, {componentClass: "button", value: null}), this.props.value)
        );
        break;
      default:
        input = React.createElement("input", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes))}));
    }

    return input;
  },

  renderInputGroup: function (children) {
    var self = this;

    var renderInputGroupChildButton = function (child) {
      return cloneWithProps(
        child,
        {
          // Propagate wsSize property from parent
          wsSize: self.props.wsSize
        }
      );
    };

    var addonBefore = this.props.addonBefore ? (
      React.createElement("span", {className: "input-group-addon", key: "addonBefore"}, 
        this.props.addonBefore
      )
    ) : null;

    var addonAfter = this.props.addonAfter ? (
      React.createElement("span", {className: "input-group-addon", key: "addonAfter"}, 
        this.props.addonAfter
      )
    ) : null;

    var buttonBefore = this.props.buttonBefore ? (
      React.createElement("span", {className: "input-group-btn", key: "btnBefore"}, 
        renderInputGroupChildButton(this.props.buttonBefore)
      )
    ) : null;

    var buttonAfter = this.props.buttonAfter ? (
      React.createElement("span", {className: "input-group-btn", key: "btnAfter"}, 
        renderInputGroupChildButton(this.props.buttonAfter)
      )
    ) : null;

    var groupClasses = {
      'input-group': true
    };

    if (this.props.wsSize) {
      groupClasses['input-group-' + constants.SIZES[this.props.wsSize]] = true;
    }

    return addonBefore || addonAfter || buttonBefore || buttonAfter ? (
      React.createElement("div", {className: classSet(groupClasses), key: "input-group"}, 
        addonBefore, 
        buttonBefore, 
        children, 
        addonAfter, 
        buttonAfter
      )
    ) : children;
  },

  renderIcon: function () {
    var classes = {
      'icon': true,
      'form-control-feedback': true,
      'icon-checkmark-sign-outline': this.props.wsStyle === 'success',
      'icon-warning-sign-outline': this.props.wsStyle === 'warning',
      'icon-blocked': this.props.wsStyle === 'error'
    };

    return this.props.hasFeedback ? (
      React.createElement("i", {className: classSet(classes), key: "icon"})
    ) : null;
  },

  renderHelp: function () {
    return this.props.help ? (
      React.createElement("span", {className: "help-block", key: "help"}, 
        this.props.help
      )
    ) : null;
  },

  renderCheckboxandRadioWrapper: function (children) {
    var classes = {
      'checkbox': this.props.type === 'checkbox',
      'radio': this.props.type === 'radio'
    };

    return (
      React.createElement("div", {className: classSet(classes), key: "checkboxRadioWrapper"}, 
        children
      )
    );
  },

  renderWrapper: function (children) {
    return this.props.wrapperClassName ? (
      React.createElement("div", {className: this.props.wrapperClassName, key: "wrapper"}, 
        children
      )
    ) : children;
  },

  renderLabel: function (children) {
    var classes = {
      'control-label': !this.isCheckboxOrRadio()
    };
    classes[this.props.labelClassName] = this.props.labelClassName;

    return this.props.label ? (
      React.createElement("label", {htmlFor: this.props.id, className: classSet(classes), key: "label"}, 
        children, 
        this.props.label
      )
    ) : children;
  },

  renderFormGroup: function (children) {
    var classes = {
      /// Only add the form-group CSS class if group is not explicitly set to false
      'form-group': this.props.group,
      'has-feedback': this.props.hasFeedback,
      'has-success': this.props.wsStyle === 'success',
      'has-warning': this.props.wsStyle === 'warning',
      'has-error': this.props.wsStyle === 'error'
    };
    classes[this.props.groupClassName] = this.props.groupClassName;

    return (
      React.createElement("div", {className: classSet(classes)}, 
        children
      )
    );
  },

  render: function () {
    if (this.isCheckboxOrRadio()) {
      return this.renderFormGroup(
        this.renderWrapper([
          this.renderCheckboxandRadioWrapper([
            this.renderInput(),
            this.renderLabel()
          ]),
          this.renderHelp()
        ])
      );
    }
    else {
      return this.renderFormGroup([
        this.renderLabel(),
        this.renderWrapper([
          this.renderInputGroup(
            this.renderInput()
          ),
          this.renderIcon(),
          this.renderHelp()
        ])
      ]);
    }
  }
});

module.exports = Input;

});

define('Interpolate',['require','exports','module','react','./utils/ValidComponentChildren','./utils/Object.assign'],function (require, exports, module) {// https://www.npmjs.org/package/react-interpolate-component


var React = require('react');
var ValidComponentChildren = require('./utils/ValidComponentChildren');
var assign = require('./utils/Object.assign');

var REGEXP = /\%\((.+?)\)s/;

var Interpolate = React.createClass({
  displayName: 'Interpolate',

  propTypes: {
    format: React.PropTypes.string
  },

  getDefaultProps: function() {
    return { component: 'span' };
  },

  render: function() {
    var format = (ValidComponentChildren.hasValidComponent(this.props.children) ||
        (typeof this.props.children === 'string')) ?
        this.props.children : this.props.format;
    var parent = this.props.component;
    var unsafe = this.props.unsafe === true;
    var props = assign({}, this.props);

    delete props.children;
    delete props.format;
    delete props.component;
    delete props.unsafe;

    if (unsafe) {
      var content = format.split(REGEXP).reduce(function(memo, match, index) {
        var html;

        if (index % 2 === 0) {
          html = match;
        } else {
          html = props[match];
          delete props[match];
        }

        if (React.isValidElement(html)) {
          throw new Error('cannot interpolate a React component into unsafe text');
        }

        memo += html;

        return memo;
      }, '');

      props.dangerouslySetInnerHTML = { __html: content };

      return React.createElement(parent, props);
    } else {
      var kids = format.split(REGEXP).reduce(function(memo, match, index) {
        var child;

        if (index % 2 === 0) {
          if (match.length === 0) {
            return memo;
          }

          child = match;
        } else {
          child = props[match];
          delete props[match];
        }

        memo.push(child);

        return memo;
      }, []);

      return React.createElement(parent, props, kids);
    }
  }
});

module.exports = Interpolate;

});

define('Jumbotron',['require','exports','module','react','./utils/joinClasses'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');

var Jumbotron = React.createClass({displayName: "Jumbotron",

  render: function () {
    return (
      React.createElement("div", React.__spread({},  this.props, {className: joinClasses(this.props.className, 'jumbotron')}), 
        this.props.children
      )
    );
  }
});

module.exports = Jumbotron;
});

define('Label',['require','exports','module','react','./constants','./utils/joinClasses','./utils/classSet'],function (require, exports, module) {var React = require('react');
var constants = require('./constants');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');

var Label = React.createClass({displayName: "Label",
  propTypes: {
    wsStyle: React.PropTypes.oneOf(Object.keys(constants.STYLES))
  },

  getDefaultProps: function () {
    return {
      wsClass: 'label'
    };
  },

  getBsLabelClassSet: function () {
    var classes = {};

    var wsClass = this.props.wsClass && constants.CLASSES[this.props.wsClass];
    if (wsClass) {
      classes[wsClass] = true;
    }

    var wsStyle = this.props.wsStyle && constants.STYLES[this.props.wsStyle];
    if (wsStyle) {
      classes['bg-' + wsStyle] = true;
    }

    return classes;
  },

  render: function () {
    /// Labels use the bg-* CSS utility classes provided by web-skin
    /// instead of their own label-* modifier classes
    var classes = this.getBsLabelClassSet();

    return (
      React.createElement("span", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes))}), 
        this.props.children
      )
    );
  }
});

module.exports = Label;

});

define('ListGroup',['require','exports','module','react','./utils/cloneWithProps','./utils/joinClasses','./utils/ValidComponentChildren','./utils/createChainedFunction'],function (require, exports, module) {var React = require('react');
var cloneWithProps = require('./utils/cloneWithProps');
var joinClasses = require('./utils/joinClasses');

var ValidComponentChildren = require('./utils/ValidComponentChildren');
var createChainedFunction = require('./utils/createChainedFunction');

var ListGroup = React.createClass({displayName: "ListGroup",
  propTypes: {
    onClick: React.PropTypes.func
  },

  render: function () {
    return (
      React.createElement("div", React.__spread({},  this.props, {className: joinClasses(this.props.className, 'list-group')}), 
        ValidComponentChildren.map(this.props.children, this.renderListItem)
      )
    );
  },

  renderListItem: function (child, index) {
    return cloneWithProps(child, {
      ref: child.ref,
      key: child.key ? child.key : index
    });
  }
});

module.exports = ListGroup;

});

define('ListGroupItem',['require','exports','module','react','./utils/joinClasses','./WebSkinMixin','./utils/classSet','./utils/cloneWithProps','./utils/ValidComponentChildren'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var WebSkinMixin = require('./WebSkinMixin');
var classSet = require('./utils/classSet');
var cloneWithProps = require('./utils/cloneWithProps');

var ValidComponentChildren = require('./utils/ValidComponentChildren');

var ListGroupItem = React.createClass({displayName: "ListGroupItem",
  mixins: [WebSkinMixin],

  propTypes: {
    wsStyle: React.PropTypes.oneOf(['danger','info','success','warning']),
    active: React.PropTypes.any,
    disabled: React.PropTypes.any,
    header: React.PropTypes.node,
    onClick: React.PropTypes.func,
    eventKey: React.PropTypes.any,
    href: React.PropTypes.string,
    target: React.PropTypes.string
  },

  getDefaultProps: function () {
    return {
      wsClass: 'list-group-item'
    };
  },

  render: function () {
    var classes = this.getWsClassSet();

    classes['active'] = this.props.active;
    classes['disabled'] = this.props.disabled;

    if (this.props.href || this.props.target || this.props.onClick) {
      return this.renderAnchor(classes);
    } else {
      return this.renderSpan(classes);
    }
  },

  renderSpan: function (classes) {
    return (
      React.createElement("span", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes))}), 
        this.props.header ? this.renderStructuredContent() : this.props.children
      )
    );
  },

  renderAnchor: function (classes) {
    classes['hitarea'] = true;
    return (
      React.createElement("a", React.__spread({}, 
        this.props, 
        {className: joinClasses(this.props.className, classSet(classes))
      }), 
        this.props.header ? this.renderStructuredContent() : this.props.children
      )
    );
  },

  renderStructuredContent: function () {
    var header;
    if (React.isValidElement(this.props.header)) {
      header = cloneWithProps(this.props.header, {
        className: 'list-group-item-heading'
      });
    } else {
      header = (
        React.createElement("h4", {className: "list-group-item-heading"}, 
          this.props.header
        )
      );
    }

    var content = (
      React.createElement("p", {className: "list-group-item-text"}, 
        this.props.children
      )
    );

    return {
      header: header,
      content: content
    };
  }
});

module.exports = ListGroupItem;

});

define('MenuItem',['require','exports','module','react','./utils/joinClasses','./utils/classSet'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');

var MenuItem = React.createClass({displayName: "MenuItem",
  propTypes: {
    header:   React.PropTypes.bool,
    divider:  React.PropTypes.bool,
    active:  React.PropTypes.bool,
    disabled:  React.PropTypes.bool,
    checked:  React.PropTypes.bool,
    href:     React.PropTypes.string,
    title:    React.PropTypes.string,
    target:    React.PropTypes.string,
    onSelect: React.PropTypes.func,
    eventKey: React.PropTypes.any
  },

  handleClick: function (e) {
    if (this.props.onSelect) {
      e.preventDefault();
      this.props.onSelect(this.props.eventKey, this.props.href, this.props.target);
    }
  },

  renderAnchor: function () {
    return (
      React.createElement("a", {onClick: this.handleClick, href: this.props.href, target: this.props.target, title: this.props.title, tabIndex: "-1", 
         className: this.props.disabled ? "hitarea disabled" : "hitarea"}, 
        this.props.children
      )
    );
  },

  render: function () {
    var classes = {
        'menu-item': true,
        'dropdown-header': this.props.header,
        'divider': this.props.divider,
        'active': this.props.active,
        'checked': this.props.checked
      };

    var children = null;
    if (this.props.header) {
      children = this.props.children;
    } else if (!this.props.divider) {
      children = this.renderAnchor();
    }

    return (
      React.createElement("li", React.__spread({},  this.props, {role: "presentation", title: null, href: null, 
        className: joinClasses(this.props.className, classSet(classes))}), 
        children
      )
    );
  }
});

module.exports = MenuItem;

});

define('Modal',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./WebSkinMixin','./FadeMixin','./utils/EventListener'],function (require, exports, module) {/* global document:false */

var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var WebSkinMixin = require('./WebSkinMixin');
var FadeMixin = require('./FadeMixin');
var EventListener = require('./utils/EventListener');


// TODO:
// - aria-labelledby
// - Add `modal-body` div if only one child passed in that doesn't already have it
// - Tests

var Modal = React.createClass({displayName: "Modal",
  mixins: [WebSkinMixin, FadeMixin],

  propTypes: {
    title: React.PropTypes.node,
    backdrop: React.PropTypes.oneOf(['static', true, false]),
    backdropClassName: React.PropTypes.string,
    keyboard: React.PropTypes.bool,
    closeButton: React.PropTypes.bool,
    animation: React.PropTypes.bool,
    onRequestHide: React.PropTypes.func.isRequired,
    /// The node type for `.modal-content`
    contentComponentClass: React.PropTypes.node
  },

  getDefaultProps: function () {
    return {
      wsClass: 'modal',
      backdrop: true,
      keyboard: true,
      animation: true,
      closeButton: true,
      contentComponentClass: 'div'
    };
  },

  render: function () {
    var modalStyle = {display: 'block'};
    var dialogClasses = this.getWsClassSet();
    delete dialogClasses.modal;
    dialogClasses['modal-dialog'] = true;

    var ContentComponent = this.props.contentComponentClass;

    var classes = {
      'modal': true,
      'fade': this.props.animation,
      'slide': this.props.animation,
      'in': !this.props.animation || !document.querySelectorAll
    };

    var modal = (
      React.createElement("div", React.__spread({}, 
        this.props, 
        {title: null, 
        tabIndex: "-1", 
        role: "dialog", 
        style: modalStyle, 
        className: joinClasses(this.props.className, classSet(classes)), 
        onClick: this.props.backdrop === true ? this.handleBackdropClick : null, 
        ref: "modal"}), 
        React.createElement("div", {className: classSet(dialogClasses), role: "document"}, 
          React.createElement(ContentComponent, {className: "modal-content"}, 
            this.props.title ? this.renderHeader() : null, 
            this.props.children
          )
        )
      )
    );

    return this.props.backdrop ?
      this.renderBackdrop(modal) : modal;
  },

  renderBackdrop: function (modal) {
    var classes = {
      'backdrop': true,
      'modal-backdrop': true,
      /// Required class to get the correct opacity on the backdrop
      'fade': true
    };

    classes[this.props.backdropClassName] = this.props.backdropClassName;
    classes['in'] = !this.props.animation || !document.querySelectorAll;

    var onClick = this.props.backdrop === true ?
      this.handleBackdropClick : null;

    return (
      React.createElement("div", null, 
        React.createElement("div", {className: classSet(classes), ref: "backdrop", onClick: onClick}), 
        modal
      )
    );
  },

  renderHeader: function () {
    var closeButton;
    if (this.props.closeButton) {
      closeButton = (
          React.createElement("button", {type: "button", className: "close", onClick: this.props.onRequestHide}, 
            React.createElement("i", {"aria-hidden": "true"}, "×"), 
            React.createElement("span", {className: "sr-only"}, "Close")
          )
        );
    }

    var style = this.props.wsStyle;
    var classes = {
      'modal-header': true
    };
    classes['bg-' + style] = style;
    classes['text-' + style] = style;

    var className = classSet(classes);

    return (
      React.createElement("div", {className: className}, 
        closeButton, 
        this.renderTitle()
      )
    );
  },

  renderTitle: function () {
    return (
      React.isValidElement(this.props.title) ?
        this.props.title : React.createElement("h4", {className: "modal-title"}, this.props.title)
    );
  },

  iosClickHack: function () {
    // IOS only allows click events to be delegated to the document on elements
    // it considers 'clickable' - anchors, buttons, etc. We fake a click handler on the
    // DOM nodes themselves. Remove if handled by React: https://github.com/facebook/react/issues/1169
    this.refs.modal.getDOMNode().onclick = function () {};
    this.refs.backdrop.getDOMNode().onclick = function () {};
  },

  componentDidMount: function () {
    this._onDocumentKeyupListener =
      EventListener.listen(document, 'keyup', this.handleDocumentKeyUp);

    var container = (this.props.container && this.props.container.getDOMNode()) || document.body;
    container.className += container.className.length ? ' modal-open' : 'modal-open';

    if (this.props.backdrop) {
      this.iosClickHack();
    }
  },

  componentDidUpdate: function (prevProps) {
    if (this.props.backdrop && this.props.backdrop !== prevProps.backdrop) {
      this.iosClickHack();
    }
  },

  componentWillUnmount: function () {
    this._onDocumentKeyupListener.remove();
    var container = (this.props.container && this.props.container.getDOMNode()) || document.body;
    container.className = container.className.replace(/ ?modal-open/, '');
  },

  handleBackdropClick: function (e) {
    if (e.target !== e.currentTarget) {
      return;
    }

    this.props.onRequestHide();
  },

  handleDocumentKeyUp: function (e) {
    if (this.props.keyboard && e.keyCode === 27) {
      this.props.onRequestHide();
    }
  }
});

module.exports = Modal;

});

define('Nav',['require','exports','module','react','./utils/joinClasses','./WebSkinMixin','./CollapsibleMixin','./utils/classSet','./utils/domUtils','./utils/cloneWithProps','./utils/ValidComponentChildren','./utils/createChainedFunction'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var WebSkinMixin = require('./WebSkinMixin');
var CollapsibleMixin = require('./CollapsibleMixin');
var classSet = require('./utils/classSet');
var domUtils = require('./utils/domUtils');
var cloneWithProps = require('./utils/cloneWithProps');

var ValidComponentChildren = require('./utils/ValidComponentChildren');
var createChainedFunction = require('./utils/createChainedFunction');


var Nav = React.createClass({displayName: "Nav",
  mixins: [WebSkinMixin, CollapsibleMixin],

  propTypes: {
    wsStyle: React.PropTypes.oneOf(['tabs','pills']),
    stacked: React.PropTypes.bool,
    justified: React.PropTypes.bool,
    onSelect: React.PropTypes.func,
    collapsible: React.PropTypes.bool,
    expanded: React.PropTypes.bool,
    navbar: React.PropTypes.bool,
    eventKey: React.PropTypes.any,
    wizard: React.PropTypes.bool,
    pullRight: React.PropTypes.bool
  },

  getDefaultProps: function () {
    return {
      wsClass: 'nav'
    };
  },

  getCollapsibleDOMNode: function () {
    return this.getDOMNode();
  },

  getCollapsibleDimensionValue: function () {
    var node = this.refs.ul.getDOMNode(),
        height = node.offsetHeight,
        computedStyles = domUtils.getComputedStyles(node);

    return height + parseInt(computedStyles.marginTop, 10) + parseInt(computedStyles.marginBottom, 10);
  },

  render: function () {
    var classes = this.props.collapsible ? this.getCollapsibleClassSet() : {};

    classes['navbar-collapse'] = this.props.collapsible;

    if (this.props.navbar && !this.props.collapsible) {
      return (this.renderUl());
    }

    return (
      React.createElement("nav", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes))}), 
        this.renderUl()
      )
    );
  },

  renderUl: function () {
    var classes = this.getWsClassSet();

    var rightAlign = this.props.pullRight || this.props.right;

    classes['nav-stacked'] = this.props.stacked;
    classes['nav-justified'] = this.props.justified;
    classes['nav-wizard'] = this.props.wizard;
    classes['navbar-nav'] = this.props.navbar;
    classes['pull-right'] = rightAlign && !this.props.navbar;
    classes['navbar-right'] = rightAlign && this.props.navbar;

    return (
      React.createElement("ul", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes)), ref: "ul"}), 
        ValidComponentChildren.map(this.props.children, this.renderNavItem)
      )
    );
  },

  getChildActiveProp: function (child) {
    if (child.props.active) {
      return true;
    }
    if (this.props.activeKey != null) {
      if (child.props.eventKey == this.props.activeKey) {
        return true;
      }
    }
    if (this.props.activeHref != null) {
      if (child.props.href === this.props.activeHref) {
        return true;
      }
    }

    return child.props.active;
  },

  renderNavItem: function (child, index) {
    return cloneWithProps(
      child,
      {
        completed: child.props.completed,
        active: this.getChildActiveProp(child),
        activeKey: this.props.activeKey,
        activeHref: this.props.activeHref,
        wizard: (index === 0 ? null : this.props.wizard),
        onSelect: createChainedFunction(child.props.onSelect, this.props.onSelect),
        ref: child.ref,
        key: child.key ? child.key : index,
        navItem: true
      }
    );
  }
});

module.exports = Nav;

});

define('Navbar',['require','exports','module','react','./utils/joinClasses','./WebSkinMixin','./utils/classSet','./utils/cloneWithProps','./utils/ValidComponentChildren','./utils/createChainedFunction','./Nav'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var WebSkinMixin = require('./WebSkinMixin');
var classSet = require('./utils/classSet');
var cloneWithProps = require('./utils/cloneWithProps');

var ValidComponentChildren = require('./utils/ValidComponentChildren');
var createChainedFunction = require('./utils/createChainedFunction');
var Nav = require('./Nav');


var Navbar = React.createClass({displayName: "Navbar",
  mixins: [WebSkinMixin],

  propTypes: {
    fixedTop: React.PropTypes.bool,
    fixedBottom: React.PropTypes.bool,
    staticTop: React.PropTypes.bool,
    inverse: React.PropTypes.bool,
    /// @deprecated - does nothing since WS does not support `.container-fluid`
    fluid: React.PropTypes.bool,
    /// If set to false, the `.container-wide` variation class
    /// will be omitted from the `.container` within the Navbar
    wideContainer: React.PropTypes.bool,
    role: React.PropTypes.string,
    componentClass: React.PropTypes.node.isRequired,
    brand: React.PropTypes.node,
    toggleButton: React.PropTypes.node,
    toggleNavKey: React.PropTypes.oneOfType([
      React.PropTypes.string,
      React.PropTypes.number
    ]),
    onToggle: React.PropTypes.func,
    navExpanded: React.PropTypes.bool,
    defaultNavExpanded: React.PropTypes.bool
  },

  getDefaultProps: function () {
    return {
      wsClass: 'navbar',
      wsStyle: 'default',
      wideContainer: true,
      role: 'navigation',
      componentClass: 'Nav'
    };
  },

  getInitialState: function () {
    return {
      navExpanded: this.props.defaultNavExpanded
    };
  },

  shouldComponentUpdate: function() {
    // Defer any updates to this component during the `onSelect` handler.
    return !this._isChanging;
  },

  handleToggle: function () {
    if (this.props.onToggle) {
      this._isChanging = true;
      this.props.onToggle();
      this._isChanging = false;
    }

    this.setState({
      navExpanded: !this.state.navExpanded
    });
  },

  isNavExpanded: function () {
    return this.props.navExpanded != null ? this.props.navExpanded : this.state.navExpanded;
  },

  useDefaultPositionClass: function () {
    var defaultPositionProp = this.props.staticTop;
    return defaultPositionProp || (!this.props.fixedTop && !this.props.fixedBottom);
  },

  render: function () {
    var classes = this.getWsClassSet();
    var ComponentClass = this.props.componentClass;
    /// CSS class that should be used on a navbar if no variation is specified
    var defaultPositionClass = 'navbar-static-top';

    classes['navbar-fixed-top'] = this.props.fixedTop;
    classes['navbar-fixed-bottom'] = this.props.fixedBottom;
    classes[defaultPositionClass] = this.useDefaultPositionClass();
    classes['navbar-inverse'] = this.props.inverse;

    return (
      React.createElement(ComponentClass, React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes))}), 
        React.createElement("div", {className: this.props.wideContainer ? 'container container-wide' : 'container'}, 
          (this.props.brand || this.props.toggleButton || this.props.toggleNavKey != null) ? this.renderHeader() : null, 
          ValidComponentChildren.map(this.props.children, this.renderChild)
        )
      )
    );
  },

  renderChild: function (child, index) {
    return cloneWithProps(child, {
      navbar: true,
      collapsible: this.props.toggleNavKey != null && this.props.toggleNavKey === child.props.eventKey,
      expanded: this.props.toggleNavKey != null && this.props.toggleNavKey === child.props.eventKey && this.isNavExpanded(),
      key: child.key ? child.key : index,
      ref: child.ref
    });
  },

  renderHeader: function () {
    var brand;

    if (this.props.brand) {
      brand = React.isValidElement(this.props.brand) ?
        cloneWithProps(this.props.brand, {
          className: 'navbar-brand'
        }) : React.createElement("span", {className: "navbar-brand"}, this.props.brand);
    }

    return (
      React.createElement("div", {className: "navbar-header"}, 
        brand, 
        (this.props.toggleButton || this.props.toggleNavKey != null) ? this.renderToggleButton() : null
      )
    );
  },

  renderToggleButton: function () {
    var children;

    if (React.isValidElement(this.props.toggleButton)) {
      return cloneWithProps(this.props.toggleButton, {
        className: 'navbar-toggle',
        onClick: createChainedFunction(this.handleToggle, this.props.toggleButton.props.onClick)
      });
    }

    children = (this.props.toggleButton != null) ?
      this.props.toggleButton : [
        React.createElement("span", {className: "sr-only", key: 0}, "Toggle navigation"),
        React.createElement("i", {className: "icon icon-menu-list", "aria-hidden": "true"})
    ];

    return (
      React.createElement("button", {className: "navbar-toggle", type: "button", onClick: this.handleToggle}, 
        children
      )
    );
  }
});

module.exports = Navbar;

});

define('NavItem',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./WebSkinMixin'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var WebSkinMixin = require('./WebSkinMixin');

var NavItem = React.createClass({displayName: "NavItem",
  mixins: [WebSkinMixin],

  propTypes: {
    onSelect: React.PropTypes.func,
    active: React.PropTypes.bool,
    /// Used in nav-wizard nav variation to display a checkmark icon
    completed: React.PropTypes.bool,
    disabled: React.PropTypes.bool,
    href: React.PropTypes.string,
    title: React.PropTypes.string,
    eventKey: React.PropTypes.any,
    target: React.PropTypes.string,
    children: React.PropTypes.any
  },

  getDefaultProps: function () {
    return {
      disabled: null,
      active: false
    }
  },

  render: function () {
    var itemProps = {
      active: this.props.active,
      completed: this.props.completed,
      className: this.props.className
    };

    this.props.className = 'hitarea';

    var HitareaComponent = 'button';

    if (this.props.href || this.props.target || this.props.onSelect) {
      HitareaComponent = 'a';
      this.props.className = this.props.disabled ? 'hitarea disabled' : 'hitarea';

      if (this.props.href === '#') {
        this.props.role = 'button';
      }
    }

    var classes = {
      'nav-item': true,
      'active': itemProps.active,
      'completed': itemProps.completed
    };

    var wizardArrow = this.props.wizard ? React.createElement("div", {className: "wizard-inner", "aria-hidden": "true"}, React.createElement("i", {className: "wizard-arrow"})) : null;

    return (
      React.createElement("li", React.__spread({},  itemProps, {className: joinClasses(itemProps.className, classSet(classes))}), 
        React.createElement(HitareaComponent, React.__spread({}, 
          this.props, 
          {active: null, 
          completed: null, 
          onClick: this.handleClick, 
          ref: "anchor"}), 
          this.props.children
        ), 
        wizardArrow
      )
    );
  },

  handleClick: function (e) {
    if (this.props.onSelect) {
      e.preventDefault();

      if (!this.props.disabled) {
        this.props.onSelect(this.props.eventKey, this.props.href, this.props.target);
      }
    }
  }
});

module.exports = NavItem;

});

define('utils/CustomPropTypes',['require','exports','module','react'],function (require, exports, module) {var React = require('react');

var ANONYMOUS = '<<anonymous>>';

var CustomPropTypes = {
  /**
   * Checks whether a prop provides a DOM element
   *
   * The element can be provided in two forms:
   * - Directly passed
   * - Or passed an object which has a `getDOMNode` method which will return the required DOM element
   *
   * @param props
   * @param propName
   * @param componentName
   * @returns {Error|undefined}
   */
  mountable: createMountableChecker()
};

/**
 * Create chain-able isRequired validator
 *
 * Largely copied directly from:
 *  https://github.com/facebook/react/blob/0.11-stable/src/core/ReactPropTypes.js#L94
 */
function createChainableTypeChecker(validate) {
  function checkType(isRequired, props, propName, componentName) {
    componentName = componentName || ANONYMOUS;
    if (props[propName] == null) {
      if (isRequired) {
        return new Error(
          'Required prop `' + propName + '` was not specified in ' +
            '`' + componentName + '`.'
        );
      }
    } else {
      return validate(props, propName, componentName);
    }
  }

  var chainedCheckType = checkType.bind(null, false);
  chainedCheckType.isRequired = checkType.bind(null, true);

  return chainedCheckType;
}

function createMountableChecker() {
  function validate(props, propName, componentName) {
    if (typeof props[propName] !== 'object' ||
      typeof props[propName].getDOMNode !== 'function' && props[propName].nodeType !== 1) {
      return new Error(
        'Invalid prop `' + propName + '` supplied to ' +
          '`' + componentName + '`, expected a DOM element or an object that has a `getDOMNode` method'
      );
    }
  }

  return createChainableTypeChecker(validate);
}

module.exports = CustomPropTypes;
});

define('OverlayMixin',['require','exports','module','react','./utils/CustomPropTypes'],function (require, exports, module) {var React = require('react');
var CustomPropTypes = require('./utils/CustomPropTypes');

module.exports = {
  propTypes: {
    container: CustomPropTypes.mountable
  },

  getDefaultProps: function () {
    return {
      container: {
        // Provide `getDOMNode` fn mocking a React component API. The `document.body`
        // reference needs to be contained within this function so that it is not accessed
        // in environments where it would not be defined, e.g. nodejs. Equally this is needed
        // before the body is defined where `document.body === null`, this ensures
        // `document.body` is only accessed after componentDidMount.
        getDOMNode: function getDOMNode() {
          return document.body;
        }
      }
    };
  },

  componentWillUnmount: function () {
    this._unrenderOverlay();
    if (this._overlayTarget) {
      this.getContainerDOMNode()
        .removeChild(this._overlayTarget);
      this._overlayTarget = null;
    }
  },

  componentDidUpdate: function () {
    this._renderOverlay();
  },

  componentDidMount: function () {
    this._renderOverlay();
  },

  _mountOverlayTarget: function () {
    this._overlayTarget = document.createElement('div');
    this.getContainerDOMNode()
      .appendChild(this._overlayTarget);
  },

  _renderOverlay: function () {
    if (!this._overlayTarget) {
      this._mountOverlayTarget();
    }

    var overlay = this.renderOverlay();

    // Save reference to help testing
    if (overlay !== null) {
      this._overlayInstance = React.render(overlay, this._overlayTarget);
    } else {
      // Unrender if the component is null for transitions to null
      this._unrenderOverlay();
    }
  },

  _unrenderOverlay: function () {
    React.unmountComponentAtNode(this._overlayTarget);
    this._overlayInstance = null;
  },

  getOverlayDOMNode: function () {
    if (!this.isMounted()) {
      throw new Error('getOverlayDOMNode(): A component must be mounted to have a DOM node.');
    }

    if (this._overlayInstance) {
      return this._overlayInstance.getDOMNode();
    }

    return null;
  },

  getContainerDOMNode: function () {
    return this.props.container.getDOMNode ?
      this.props.container.getDOMNode() : this.props.container;
  }
};

});

define('ModalTrigger',['require','exports','module','react','./OverlayMixin','./utils/cloneWithProps','./utils/createChainedFunction'],function (require, exports, module) {var React = require('react');
var OverlayMixin = require('./OverlayMixin');
var cloneWithProps = require('./utils/cloneWithProps');

var createChainedFunction = require('./utils/createChainedFunction');

var ModalTrigger = React.createClass({displayName: "ModalTrigger",
  mixins: [OverlayMixin],

  propTypes: {
    modal: React.PropTypes.node.isRequired
  },

  getInitialState: function () {
    return {
      isOverlayShown: false
    };
  },

  show: function () {
    this.setState({
      isOverlayShown: true
    });
  },

  hide: function () {
    this.setState({
      isOverlayShown: false
    });
  },

  toggle: function () {
    this.setState({
      isOverlayShown: !this.state.isOverlayShown
    });
  },

  renderOverlay: function () {
    if (!this.state.isOverlayShown) {
      return React.createElement("span", null);
    }

    return cloneWithProps(
      this.props.modal,
      {
        onRequestHide: this.hide
      }
    );
  },

  render: function () {
    var child = React.Children.only(this.props.children);
    return cloneWithProps(
      child,
      {
        onClick: createChainedFunction(child.props.onClick, this.toggle)
      }
    );
  }
});

module.exports = ModalTrigger;
});

define('OverlayTrigger',['require','exports','module','react','./OverlayMixin','./utils/domUtils','./utils/cloneWithProps','./utils/createChainedFunction','./utils/Object.assign'],function (require, exports, module) {var React = require('react');
var OverlayMixin = require('./OverlayMixin');
var domUtils = require('./utils/domUtils');
var cloneWithProps = require('./utils/cloneWithProps');

var createChainedFunction = require('./utils/createChainedFunction');
var assign = require('./utils/Object.assign');

/**
 * Check if value one is inside or equal to the of value
 *
 * @param {string} one
 * @param {string|array} of
 * @returns {boolean}
 */
function isOneOf(one, of) {
  if (Array.isArray(of)) {
    return of.indexOf(one) >= 0;
  }
  return one === of;
}

var OverlayTrigger = React.createClass({displayName: "OverlayTrigger",
  mixins: [OverlayMixin],

  propTypes: {
    trigger: React.PropTypes.oneOfType([
      React.PropTypes.oneOf(['manual', 'click', 'hover', 'focus']),
      React.PropTypes.arrayOf(React.PropTypes.oneOf(['click', 'hover', 'focus']))
    ]),
    placement: React.PropTypes.oneOf(['top','right', 'bottom', 'left']),
    delay: React.PropTypes.number,
    delayShow: React.PropTypes.number,
    delayHide: React.PropTypes.number,
    defaultOverlayShown: React.PropTypes.bool,
    overlay: React.PropTypes.node.isRequired
  },

  getDefaultProps: function () {
    return {
      placement: 'right',
      trigger: ['hover', 'focus']
    };
  },

  getInitialState: function () {
    return {
      isOverlayShown: this.props.defaultOverlayShown == null ?
        false : this.props.defaultOverlayShown,
      overlayLeft: null,
      overlayTop: null
    };
  },

  show: function () {
    this.setState({
      isOverlayShown: true
    }, function() {
      this.updateOverlayPosition();
    });
  },

  hide: function () {
    this.setState({
      isOverlayShown: false
    });
  },

  toggle: function () {
    this.state.isOverlayShown ?
      this.hide() : this.show();
  },

  renderOverlay: function () {
    if (!this.state.isOverlayShown) {
      return React.createElement("span", null);
    }

    return cloneWithProps(
      this.props.overlay,
      {
        onRequestHide: this.hide,
        placement: this.props.placement,
        positionLeft: this.state.overlayLeft,
        positionTop: this.state.overlayTop
      }
    );
  },

  render: function () {
    if (this.props.trigger === 'manual') {
      return React.Children.only(this.props.children);
    }

    var props = {};

    if (isOneOf('click', this.props.trigger)) {
      props.onClick = createChainedFunction(this.toggle, this.props.onClick);
    }

    if (isOneOf('hover', this.props.trigger)) {
      props.onMouseOver = createChainedFunction(this.handleDelayedShow, this.props.onMouseOver);
      props.onMouseOut = createChainedFunction(this.handleDelayedHide, this.props.onMouseOut);
    }

    if (isOneOf('focus', this.props.trigger)) {
      props.onFocus = createChainedFunction(this.handleDelayedShow, this.props.onFocus);
      props.onBlur = createChainedFunction(this.handleDelayedHide, this.props.onBlur);
    }

    return cloneWithProps(
      React.Children.only(this.props.children),
      props
    );
  },

  componentWillUnmount: function() {
    clearTimeout(this._hoverDelay);
  },

  componentDidMount: function() {
    if (this.props.defaultOverlayShown) {
      this.updateOverlayPosition();
    }
  },

  handleDelayedShow: function () {
    var self = this;

    if (this._hoverDelay != null) {
      clearTimeout(this._hoverDelay);
      this._hoverDelay = null;
      return;
    }

    var delay = this.props.delayShow != null ?
      this.props.delayShow : this.props.delay;

    if (!delay) {
      this.show();
      return;
    }

    this._hoverDelay = setTimeout(function() {
      self._hoverDelay = null;
      self.show();
    }, delay);
  },

  handleDelayedHide: function () {
    var self = this;

    if (this._hoverDelay != null) {
      clearTimeout(this._hoverDelay);
      this._hoverDelay = null;
      return;
    }

    var delay = this.props.delayHide != null ?
      this.props.delayHide : this.props.delay;

    if (!delay) {
      this.hide();
      return;
    }

    this._hoverDelay = setTimeout(function() {
      self._hoverDelay = null;
      self.hide();
    }, delay);
  },

  updateOverlayPosition: function () {
    if (!this.isMounted()) {
      return;
    }

    var pos = this.calcOverlayPosition();

    this.setState({
      overlayLeft: pos.left,
      overlayTop: pos.top
    });
  },

  calcOverlayPosition: function () {
    var childOffset = this.getPosition();

    var overlayNode = this.getOverlayDOMNode();
    var overlayHeight = overlayNode.offsetHeight;
    var overlayWidth = overlayNode.offsetWidth;

    switch (this.props.placement) {
      case 'right':
        return {
          top: childOffset.top + childOffset.height / 2 - overlayHeight / 2,
          left: childOffset.left + childOffset.width
        };
      case 'left':
        return {
          top: childOffset.top + childOffset.height / 2 - overlayHeight / 2,
          left: childOffset.left - overlayWidth
        };
      case 'top':
        return {
          top: childOffset.top - overlayHeight,
          left: childOffset.left + childOffset.width / 2 - overlayWidth / 2
        };
      case 'bottom':
        return {
          top: childOffset.top + childOffset.height,
          left: childOffset.left + childOffset.width / 2 - overlayWidth / 2
        };
      default:
        throw new Error('calcOverlayPosition(): No such placement of "' + this.props.placement + '" found.');
    }
  },

  getPosition: function () {
    var node = this.getDOMNode();
    var container = this.getContainerDOMNode();

    var offset = container.tagName == 'BODY' ?
      domUtils.getOffset(node) : domUtils.getPosition(node, container);

    return assign({}, offset, {
      height: node.offsetHeight,
      width: node.offsetWidth
    });
  }
});

module.exports = OverlayTrigger;

});

define('PageHeader',['require','exports','module','react','./utils/joinClasses'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');

var PageHeader = React.createClass({displayName: "PageHeader",

  render: function () {
    return (
      React.createElement("div", React.__spread({},  this.props, {className: joinClasses(this.props.className, 'page-header')}), 
        React.createElement("h1", null, this.props.children)
      )
    );
  }
});

module.exports = PageHeader;
});

define('Panel',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./utils/cloneWithProps','./WebSkinMixin','./CollapsibleMixin'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var cloneWithProps = require('./utils/cloneWithProps');

var WebSkinMixin = require('./WebSkinMixin');
var CollapsibleMixin = require('./CollapsibleMixin');

var Panel = React.createClass({displayName: "Panel",
  mixins: [WebSkinMixin, CollapsibleMixin],

  propTypes: {
    collapsible: React.PropTypes.bool,
    onSelect: React.PropTypes.func,
    header: React.PropTypes.node,
    footer: React.PropTypes.node,
    eventKey: React.PropTypes.any,
    inverse: React.PropTypes.any
  },

  getDefaultProps: function () {
    return {
      wsClass: 'panel',
      wsStyle: 'default',
      inverse: false
    };
  },

  handleSelect: function (e) {
    e.selected = true;
    if (this.props.onSelect) {
      this._isChanging = true;
      this.props.onSelect(e, this.props.eventKey);
      this._isChanging = false;
    } else {
      e.preventDefault();
    }

    if (e.selected) {
      this.handleToggle();
    }
  },

  handleToggle: function () {
    this.setState({
      expanded: !this.state.expanded
    });
  },

  getCollapsibleDimensionValue: function () {
    return this.refs.panel.getDOMNode().scrollHeight;
  },

  getCollapsibleDOMNode: function () {
    if (!this.isMounted() || !this.refs || !this.refs.panel) {
      return null;
    }

    return this.refs.panel.getDOMNode();
  },

  render: function () {
    var classes = this.getWsClassSet();
    classes['panel'] = true;
    classes['panel-inverse'] = this.props.inverse;

    return (
      React.createElement("div", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes)), 
        id: this.props.collapsible ? null : this.props.id, onSelect: null}), 
        this.renderHeading(), 
        this.props.collapsible ? this.renderCollapsibleBody() : this.renderBody(), 
        this.renderFooter()
      )
    );
  },

  renderCollapsibleBody: function () {
    var collapseClass = this.prefixClass('collapse');
    return (
      React.createElement("div", {className: classSet(this.getCollapsibleClassSet(collapseClass)), 
           id: this.props.id, 
           ref: "panel", 
           "aria-expanded": this.isExpanded() ? 'true' : 'false'}, 
        this.renderBody()
      )
    );
  },

  renderBody: function () {
    var self = this;
    var allChildren = this.props.children;
    var bodyElements = [];
    var panelBodyChildren = [];
    var bodyClass = this.prefixClass('body');

    function getProps() {
      return {key: bodyElements.length};
    }

    function addPanelChild (child) {
      bodyElements.push(cloneWithProps(child, getProps()));
    }

    function addPanelBody (children) {
      bodyElements.push(
        React.createElement("div", React.__spread({className: bodyClass},  getProps(), {ref: "body"}), 
          children
        )
      );
    }

    function maybeRenderPanelBody () {
      if (panelBodyChildren.length === 0) {
        return;
      }

      addPanelBody(panelBodyChildren);
      panelBodyChildren = [];
    }

    // Handle edge cases where we should not iterate through children.
    if (!Array.isArray(allChildren) || allChildren.length === 0) {
      if (this.shouldRenderFill(allChildren)) {
        addPanelChild(allChildren);
      } else {
        addPanelBody(allChildren);
      }
    } else {

      allChildren.forEach(function(child) {
        if (self.shouldRenderFill(child)) {
          maybeRenderPanelBody();

          // Separately add the filled element.
          addPanelChild(child);
        } else {
          panelBodyChildren.push(child);
        }
      });

      maybeRenderPanelBody();
    }

    return bodyElements;
  },

  shouldRenderFill: function (child) {
    return React.isValidElement(child) && child.props.fill != null;
  },

  renderHeading: function () {
    var header = this.props.header;

    if (!header) {
      return null;
    }

    // Check to see if the header prop is a heading element
    // and if it is, add the standard panel-title CSS class
    if (React.isValidElement(header) && !Array.isArray(header)) {
      header = cloneWithProps(header, {
        className: this.prefixClass('title')
      });
    }

    var headingProps = {
      'data-toggle': this.props.collapsible,
      'onClick': this.props.collapsible ? this.handleSelect : null
    };

    var classes = {
      'panel-heading': true,
      'open': this.props.collapsible && this.isExpanded()
    };

    return this.props.collapsible ? (
      React.createElement("div", React.__spread({},  headingProps, {className: classSet(classes), ref: "heading"}), 
        header, 
        React.createElement("i", {className: "caret", "aria-hidden": "true"})
      )
    ) : (
      React.createElement("div", React.__spread({},  headingProps, {className: classSet(classes), ref: "heading"}), 
        header
      )
    );
  },

  renderFooter: function () {
    if (!this.props.footer) {
      return null;
    }

    return (
      React.createElement("div", {className: this.prefixClass('footer'), ref: "footer"}, 
        this.props.footer
      )
    );
  }
});

module.exports = Panel;

});

define('PageItem',['require','exports','module','react','./utils/joinClasses','./utils/classSet'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');

var PageItem = React.createClass({displayName: "PageItem",

  propTypes: {
    href: React.PropTypes.string,
    target: React.PropTypes.string,
    disabled: React.PropTypes.bool,
    previous: React.PropTypes.bool,
    next: React.PropTypes.bool,
    onSelect: React.PropTypes.func,
    eventKey: React.PropTypes.any
  },

  render: function () {
    var classes = {
      'disabled': this.props.disabled,
      'previous': this.props.previous,
      'next': this.props.next
    };

    return (
      React.createElement("li", React.__spread({}, 
        this.props, 
        {className: joinClasses(this.props.className, classSet(classes))}), 
        React.createElement("a", {
          href: this.props.href, 
          title: this.props.title, 
          target: this.props.target, 
          onClick: this.handleSelect, 
          ref: "anchor", 
          className: "hitarea"}, 
          this.props.children
        )
      )
    );
  },

  handleSelect: function (e) {
    if (this.props.onSelect) {
      e.preventDefault();

      if (!this.props.disabled) {
        this.props.onSelect(this.props.eventKey, this.props.href, this.props.target);
      }
    }
  }
});

module.exports = PageItem;

});

define('Pager',['require','exports','module','react','./utils/joinClasses','./utils/cloneWithProps','./utils/ValidComponentChildren','./utils/createChainedFunction'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var cloneWithProps = require('./utils/cloneWithProps');

var ValidComponentChildren = require('./utils/ValidComponentChildren');
var createChainedFunction = require('./utils/createChainedFunction');

var Pager = React.createClass({displayName: "Pager",

  propTypes: {
    onSelect: React.PropTypes.func
  },

  render: function () {
    return (
      React.createElement("ul", React.__spread({}, 
        this.props, 
        {className: joinClasses(this.props.className, 'pager nav')}), 
        ValidComponentChildren.map(this.props.children, this.renderPageItem)
      )
    );
  },

  renderPageItem: function (child, index) {
    return cloneWithProps(
      child,
      {
        className: 'nav-item',
        onSelect: createChainedFunction(child.props.onSelect, this.props.onSelect),
        ref: child.ref,
        key: child.key ? child.key : index
      }
    );
  }
});

module.exports = Pager;

});

define('Popover',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./WebSkinMixin'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var WebSkinMixin = require('./WebSkinMixin');


var Popover = React.createClass({displayName: "Popover",
  mixins: [WebSkinMixin],

  propTypes: {
    placement: React.PropTypes.oneOf(['top','right', 'bottom', 'left', '']),
    positionLeft: React.PropTypes.number,
    positionTop: React.PropTypes.number,
    arrowOffsetLeft: React.PropTypes.number,
    arrowOffsetTop: React.PropTypes.number,
    title: React.PropTypes.node
  },

  getDefaultProps: function () {
    return {
      placement: 'right'
    };
  },

  render: function () {
    var classes = {};
    classes['popover'] = true;
    classes[this.props.placement] = true;
    classes['in'] = this.props.positionLeft != null || this.props.positionTop != null;

    var style = {};
    style['left'] = this.props.positionLeft;
    style['top'] = this.props.positionTop;
    style['display'] = 'block';

    var arrowStyle = {};
    arrowStyle['left'] = this.props.arrowOffsetLeft;
    arrowStyle['top'] = this.props.arrowOffsetTop;

    return (
      React.createElement("div", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes)), style: style, title: null}), 
        React.createElement("div", {className: "arrow", style: arrowStyle}), 
        React.createElement("div", {className: "inner"}, 
          this.props.title ? this.renderTitle() : null, 
          React.createElement("div", {className: "content"}, 
              this.props.children
          )
        )
      )
    );
  },

  renderTitle: function() {
    return (
      React.createElement("h3", {className: "title"}, this.props.title)
    );
  }
});

module.exports = Popover;

});

define('ProgressBar',['require','exports','module','react','./utils/joinClasses','./Interpolate','./WebSkinMixin','./utils/classSet','./utils/cloneWithProps','./utils/ValidComponentChildren'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var Interpolate = require('./Interpolate');
var WebSkinMixin = require('./WebSkinMixin');
var classSet = require('./utils/classSet');
var cloneWithProps = require('./utils/cloneWithProps');

var ValidComponentChildren = require('./utils/ValidComponentChildren');


var ProgressBar = React.createClass({displayName: "ProgressBar",
  mixins: [WebSkinMixin],

  propTypes: {
    min: React.PropTypes.number,
    now: React.PropTypes.number,
    max: React.PropTypes.number,
    label: React.PropTypes.node,
    srOnly: React.PropTypes.bool,
    indeterminate: React.PropTypes.bool,
    wsSize: React.PropTypes.oneOf(['small', 'xsmall'])
  },

  getDefaultProps: function () {
    return {
      wsClass: 'progress-bar',
      wsStyle: 'default',
      min: 0,
      max: 100,
      now: 0
    };
  },

  getPercentage: function (now, min, max) {
    return Math.ceil((now - min) / (max - min) * 100);
  },

  render: function () {
    var classes = {
      progress: true
    };

    if (this.props.indeterminate || this.props.striped) {
      classes['progress-indeterminate'] = true;
      this.props.now = null;
    }

    if (!ValidComponentChildren.hasValidComponent(this.props.children)) {
      if (!this.props.isChild) {
        return (
          React.createElement("div", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes))}), 
            this.renderProgressBar()
          )
        );
      } else {
        return (
          this.renderProgressBar()
        );
      }
    } else {
      return (
        React.createElement("div", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes))}), 
          ValidComponentChildren.map(this.props.children, this.renderChildBar)
        )
      );
    }
  },

  renderChildBar: function (child, index) {
    return cloneWithProps(child, {
      isChild: true,
      key: child.key ? child.key : index,
      ref: child.ref
    });
  },

  renderProgressBar: function () {
    var percentage;

    if (this.props.indeterminate) {
      percentage = 100;
    } else {
      percentage = this.getPercentage(
        this.props.now,
        this.props.min,
        this.props.max
      );
    }

    var label;

    if (typeof this.props.label === "string") {
      label = this.renderLabel(percentage);
    } else if (this.props.label) {
      label = this.props.label;
    }

    if (this.props.srOnly) {
      label = this.renderScreenReaderOnlyLabel(label);
    }

    var classes = this.getWsClassSet();

    return (
      React.createElement("div", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes)), role: "progressbar", 
        style: {width: percentage + '%'}, 
        "aria-valuenow": this.props.now, 
        "aria-valuemin": this.props.min, 
        "aria-valuemax": this.props.max}), 
        label
      )
    );
  },

  renderLabel: function (percentage) {
    var InterpolateClass = this.props.interpolateClass || Interpolate;

    return (
      React.createElement(InterpolateClass, {
        now: this.props.now, 
        min: this.props.min, 
        max: this.props.max, 
        percent: percentage, 
        wsStyle: this.props.wsStyle}, 
        this.props.label
      )
    );
  },

  renderScreenReaderOnlyLabel: function (label) {
    return (
      React.createElement("span", {className: "sr-only"}, 
        label
      )
    );
  }
});

module.exports = ProgressBar;

});

define('Row',['require','exports','module','react','./utils/joinClasses'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');

var Row = React.createClass({displayName: "Row",
  propTypes: {
    componentClass: React.PropTypes.node.isRequired
  },

  getDefaultProps: function () {
    return {
      componentClass: 'div'
    };
  },

  render: function () {
    var ComponentClass = this.props.componentClass;

    return (
      React.createElement(ComponentClass, React.__spread({},  this.props, {className: joinClasses(this.props.className, 'row')}), 
        this.props.children
      )
    );
  }
});

module.exports = Row;
});

define('SplitButton',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./WebSkinMixin','./DropdownStateMixin','./Button','./ButtonGroup','./DropdownMenu'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var WebSkinMixin = require('./WebSkinMixin');
var DropdownStateMixin = require('./DropdownStateMixin');
var Button = require('./Button');
var ButtonGroup = require('./ButtonGroup');
var DropdownMenu = require('./DropdownMenu');

var SplitButton = React.createClass({displayName: "SplitButton",
  mixins: [WebSkinMixin, DropdownStateMixin],

  propTypes: {
    /// Floats Button parent right using `pull-right` CSS class,
    /// and adds `dropdown-menu-right` CSS class to DropDownMenu
    /// unless `menuPullLeft` prop is set
    pullRight:       React.PropTypes.bool,
    /// Adds `dropdown-menu-right` CSS class to `DropdownMenu`
    /// to right-align the menu without floating the parent
    /// `ButtonGroup`
    menuPullRight:   React.PropTypes.bool,
    /// Adds `dropdown-menu-left` CSS class to `DropdownMenu`,
    /// which can be used in combination with the `pullRight`
    /// prop to left-align a menu triggered from a
    /// right-aligned `ButtonGroup`
    menuPullLeft:  React.PropTypes.bool,
    title:         React.PropTypes.node,
    href:          React.PropTypes.string,
    target:        React.PropTypes.string,
    dropdownTitle: React.PropTypes.node,
    onClick:       React.PropTypes.func,
    onSelect:      React.PropTypes.func,
    disabled:      React.PropTypes.bool,
    /// Add a custom CSS class to the `.caret`
    indicatorClassName: React.PropTypes.string
  },

  getDefaultProps: function () {
    return {
      dropdownTitle: 'Toggle dropdown'
    };
  },

  render: function () {
    var indicatorClasses = {
      'caret': true,
      'caret-sm': this.props.wsSize === 'xsmall'
    };

    indicatorClasses[this.props.indicatorClassName] = this.props.indicatorClassName;

    var groupClasses = {
      'dropdown': true,
      'dropup': this.props.dropup,
      'open': this.state.open,
      'pull-right': this.props.pullRight
    };

    var button = (
      React.createElement(Button, React.__spread({}, 
        this.props, 
        {ref: "button", 
        onClick: this.handleButtonClick, 
        pullRight: null, 
        title: null, 
        id: null}), 
        this.props.title
      )
    );

    var dropdownButton = (
      React.createElement(Button, React.__spread({}, 
        this.props, 
        {ref: "dropdownButton", 
        className: joinClasses(this.props.className, 'dropdown-toggle'), 
        onClick: this.handleDropdownClick, 
        pullRight: null, 
        title: null, 
        href: null, 
        target: null, 
        id: null}), 
        React.createElement("span", {className: "sr-only"}, this.props.dropdownTitle), 
        React.createElement("i", {className: classSet(indicatorClasses), "aria-hidden": "true"})
      )
    );

    return (
      React.createElement(ButtonGroup, {
        wsSize: this.props.wsSize, 
        className: classSet(groupClasses), 
        id: this.props.id}, 
        button, 
        dropdownButton, 
        React.createElement(DropdownMenu, {
          ref: "menu", 
          onSelect: this.handleOptionSelect, 
          "aria-labelledby": this.props.id, 
          pullRight: !this.props.menuPullLeft && (this.props.pullRight || this.props.menuPullRight), 
          pullLeft: this.props.menuPullLeft}, 
          this.props.children
        )
      )
    );
  },

  handleButtonClick: function (e) {
    if (this.state.open) {
      this.setDropdownState(false);
    }

    if (this.props.onClick) {
      this.props.onClick(e, this.props.href, this.props.target);
    }
  },

  handleDropdownClick: function (e) {
    e.preventDefault();

    this.setDropdownState(!this.state.open);
  },

  handleOptionSelect: function (key) {
    if (this.props.onSelect) {
      this.props.onSelect(key);
    }

    this.setDropdownState(false);
  }
});

module.exports = SplitButton;

});

define('SubNav',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./utils/cloneWithProps','./utils/ValidComponentChildren','./utils/createChainedFunction','./WebSkinMixin'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var cloneWithProps = require('./utils/cloneWithProps');

var ValidComponentChildren = require('./utils/ValidComponentChildren');
var createChainedFunction = require('./utils/createChainedFunction');
var WebSkinMixin = require('./WebSkinMixin');


var SubNav = React.createClass({displayName: "SubNav",
  mixins: [WebSkinMixin],

  propTypes: {
    onSelect: React.PropTypes.func,
    active: React.PropTypes.bool,
    disabled: React.PropTypes.bool,
    href: React.PropTypes.string,
    title: React.PropTypes.string,
    text: React.PropTypes.node,
    target: React.PropTypes.string
  },

  getDefaultProps: function () {
    return {
      wsClass: 'nav'
    };
  },

  handleClick: function (e) {
    if (this.props.onSelect) {
      e.preventDefault();

      if (!this.props.disabled) {
        this.props.onSelect(this.props.eventKey, this.props.href, this.props.target);
      }
    }
  },

  isActive: function () {
    return this.isChildActive(this);
  },

  isChildActive: function (child) {
    if (child.props.active) {
      return true;
    }

    if (this.props.activeKey != null && this.props.activeKey === child.props.eventKey) {
      return true;
    }

    if (this.props.activeHref != null && this.props.activeHref === child.props.href) {
      return true;
    }

    if (child.props.children) {
      var isActive = false;

      ValidComponentChildren.forEach(
        child.props.children,
        function (child) {
          if (this.isChildActive(child)) {
            isActive = true;
          }
        },
        this
      );

      return isActive;
    }

    return false;
  },

  getChildActiveProp: function (child) {
    if (child.props.active) {
      return true;
    }
    if (this.props.activeKey != null) {
      if (child.props.eventKey == this.props.activeKey) {
        return true;
      }
    }
    if (this.props.activeHref != null) {
      if (child.props.href === this.props.activeHref) {
        return true;
      }
    }

    return child.props.active;
  },

  render: function () {
    var classes = {
      'nav-item': true,
      'active': this.isActive()
    };

    var hitareaClasses = {
      'hitarea': true,
      'disabled': this.props.disabled
    };

    return (
      React.createElement("li", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes))}), 
        React.createElement("a", {
          href: this.props.href, 
          title: this.props.title, 
          target: this.props.target, 
          onClick: this.handleClick, 
          ref: "anchor", 
          className: classSet(hitareaClasses)}, 
          this.props.text
        ), 
        React.createElement("ul", {className: "nav"}, 
          ValidComponentChildren.map(this.props.children, this.renderNavItem)
        )
      )
    );
  },

  renderNavItem: function (child, index) {
    return cloneWithProps(
      child,
      {
        active: this.getChildActiveProp(child),
        onSelect: createChainedFunction(child.props.onSelect, this.props.onSelect),
        ref: child.ref,
        key: child.key ? child.key : index
      }
    );
  }
});

module.exports = SubNav;

});

define('TabbedArea',['require','exports','module','react','./WebSkinMixin','./utils/cloneWithProps','./utils/ValidComponentChildren','./Nav','./NavItem'],function (require, exports, module) {var React = require('react');
var WebSkinMixin = require('./WebSkinMixin');
var cloneWithProps = require('./utils/cloneWithProps');

var ValidComponentChildren = require('./utils/ValidComponentChildren');
var Nav = require('./Nav');
var NavItem = require('./NavItem');

function getDefaultActiveKeyFromChildren(children) {
  var defaultActiveKey;

  ValidComponentChildren.forEach(children, function(child) {
    if (defaultActiveKey == null) {
      defaultActiveKey = child.props.eventKey;
    }
  });

  return defaultActiveKey;
}

var TabbedArea = React.createClass({displayName: "TabbedArea",
  mixins: [WebSkinMixin],

  propTypes: {
    wsStyle: React.PropTypes.oneOf(['tabs','pills']),
    animation: React.PropTypes.bool,
    onSelect: React.PropTypes.func
  },

  getDefaultProps: function () {
    return {
      wsStyle: "tabs",
      animation: true
    };
  },

  getInitialState: function () {
    var defaultActiveKey = this.props.defaultActiveKey != null ?
      this.props.defaultActiveKey : getDefaultActiveKeyFromChildren(this.props.children);

    // TODO: In __DEV__ mode warn via `console.warn` if no `defaultActiveKey` has
    // been set by this point, invalid children or missing key properties are likely the cause.

    return {
      activeKey: defaultActiveKey,
      previousActiveKey: null
    };
  },

  componentWillReceiveProps: function (nextProps) {
    if (nextProps.activeKey != null && nextProps.activeKey !== this.props.activeKey) {
      this.setState({
        previousActiveKey: this.props.activeKey
      });
    }
  },

  handlePaneAnimateOutEnd: function () {
    this.setState({
      previousActiveKey: null
    });
  },

  render: function () {
    var activeKey =
      this.props.activeKey != null ? this.props.activeKey : this.state.activeKey;

    function renderTabIfSet(child) {
      return child.props.tab != null ? this.renderTab(child) : null;
    }

    var nav = (
      React.createElement(Nav, React.__spread({},  this.props, {activeKey: activeKey, onSelect: this.handleSelect, ref: "tabs"}), 
        ValidComponentChildren.map(this.props.children, renderTabIfSet, this)
      )
    );

    return (
      React.createElement("div", null, 
        nav, 
        React.createElement("div", {id: this.props.id, className: "tab-content", ref: "panes"}, 
          ValidComponentChildren.map(this.props.children, this.renderPane)
        )
      )
    );
  },

  getActiveKey: function () {
    return this.props.activeKey != null ? this.props.activeKey : this.state.activeKey;
  },

  renderPane: function (child, index) {
    var activeKey = this.getActiveKey();

    return cloneWithProps(
        child,
        {
          active: (child.props.eventKey === activeKey &&
            (this.state.previousActiveKey == null || !this.props.animation)),
          ref: child.ref,
          key: child.key ? child.key : index,
          animation: this.props.animation,
          onAnimateOutEnd: (this.state.previousActiveKey != null &&
            child.props.eventKey === this.state.previousActiveKey) ? this.handlePaneAnimateOutEnd: null
        }
      );
  },

  renderTab: function (child) {
    var key = child.props.eventKey;
    return (
      React.createElement(NavItem, {
        ref: 'tab' + key, 
        eventKey: key}, 
        child.props.tab
      )
    );
  },

  shouldComponentUpdate: function() {
    // Defer any updates to this component during the `onSelect` handler.
    return !this._isChanging;
  },

  handleSelect: function (key) {
    if (this.props.onSelect) {
      this._isChanging = true;
      this.props.onSelect(key);
      this._isChanging = false;
    } else if (key !== this.getActiveKey()) {
      this.setState({
        activeKey: key,
        previousActiveKey: this.getActiveKey()
      });
    }
  }
});

module.exports = TabbedArea;

});

define('Table',['require','exports','module','react','./utils/joinClasses','./utils/classSet'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');

var Table = React.createClass({displayName: "Table",
  propTypes: {
    striped: React.PropTypes.bool,
    bordered: React.PropTypes.bool,
    condensed: React.PropTypes.bool,
    hover: React.PropTypes.bool,
    responsive: React.PropTypes.bool
  },

  render: function () {
    var classes = {
      'table': true,
      'table-striped': this.props.striped,
      'table-bordered': this.props.bordered,
      'table-condensed': this.props.condensed,
      'table-hover': this.props.hover
    };
    var table = (
      React.createElement("table", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes))}), 
        this.props.children
      )
    );

    return this.props.responsive ? (
      React.createElement("div", {className: "table-responsive"}, 
        table
      )
    ) : table;
  }
});

module.exports = Table;
});

define('TabPane',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./utils/TransitionEvents'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var TransitionEvents = require('./utils/TransitionEvents');

var TabPane = React.createClass({displayName: "TabPane",
  getDefaultProps: function () {
    return {
      animation: true
    };
  },

  getInitialState: function () {
    return {
      animateIn: false,
      animateOut: false
    };
  },

  componentWillReceiveProps: function (nextProps) {
    if (this.props.animation) {
      if (!this.state.animateIn && nextProps.active && !this.props.active) {
        this.setState({
          animateIn: true
        });
      } else if (!this.state.animateOut && !nextProps.active && this.props.active) {
        this.setState({
          animateOut: true
        });
      }
    }
  },

  componentDidUpdate: function () {
    if (this.state.animateIn) {
      setTimeout(this.startAnimateIn, 0);
    }
    if (this.state.animateOut) {
      TransitionEvents.addEndEventListener(
        this.getDOMNode(),
        this.stopAnimateOut
      );
    }
  },

  startAnimateIn: function () {
    if (this.isMounted()) {
      this.setState({
        animateIn: false
      });
    }
  },

  stopAnimateOut: function () {
    if (this.isMounted()) {
      this.setState({
        animateOut: false
      });

      if (typeof this.props.onAnimateOutEnd === 'function') {
        this.props.onAnimateOutEnd();
      }
    }
  },

  render: function () {
    var classes = {
      'tab-pane': true,
      'fade': true,
      'active': this.props.active || this.state.animateOut,
      'in': this.props.active && !this.state.animateIn
    };

    return (
      React.createElement("div", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes))}), 
        this.props.children
      )
    );
  }
});

module.exports = TabPane;
});

define('Tooltip',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./WebSkinMixin'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var WebSkinMixin = require('./WebSkinMixin');


var Tooltip = React.createClass({displayName: "Tooltip",
  mixins: [WebSkinMixin],

  propTypes: {
    placement: React.PropTypes.oneOf(['top','right', 'bottom', 'left']),
    positionLeft: React.PropTypes.number,
    positionTop: React.PropTypes.number,
    arrowOffsetLeft: React.PropTypes.number,
    arrowOffsetTop: React.PropTypes.number
  },

  getDefaultProps: function () {
    return {
      wsClass: 'tooltip',
      placement: 'right'
    };
  },

  render: function () {
    var classes = this.getWsClassSet();
    classes['tooltip'] = true;
    classes[this.props.placement] = true;
    classes['in'] = this.props.positionLeft != null || this.props.positionTop != null;

    var style = {};
    style['left'] = this.props.positionLeft;
    style['top'] = this.props.positionTop;

    var arrowStyle = {};
    arrowStyle['left'] = this.props.arrowOffsetLeft;
    arrowStyle['top'] = this.props.arrowOffsetTop;

    return (
        React.createElement("div", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes)), style: style}), 
          React.createElement("div", {className: "arrow", style: arrowStyle}), 
          React.createElement("div", {className: "inner"}, 
            this.props.children
          )
        )
      );
  }
});

module.exports = Tooltip;

});

define('Well',['require','exports','module','react','./utils/joinClasses','./utils/classSet','./WebSkinMixin'],function (require, exports, module) {var React = require('react');
var joinClasses = require('./utils/joinClasses');
var classSet = require('./utils/classSet');
var WebSkinMixin = require('./WebSkinMixin');

var Well = React.createClass({displayName: "Well",
  mixins: [WebSkinMixin],

  getDefaultProps: function () {
    return {
      wsClass: 'well'
    };
  },

  render: function () {
    var classes = this.getWsClassSet();

    return (
      React.createElement("div", React.__spread({},  this.props, {className: joinClasses(this.props.className, classSet(classes))}), 
        this.props.children
      )
    );
  }
});

module.exports = Well;

});

/*global define */

define('web-skin-react',['require','./Accordion','./Affix','./AffixMixin','./Alert','./WebSkinMixin','./WebSkinAlertStyles','./WebSkinAlertMixin','./Badge','./Button','./ButtonGroup','./ButtonToolbar','./Carousel','./CarouselItem','./Col','./CollapsibleNav','./CollapsibleMixin','./DropdownButton','./DropdownMenu','./DropdownStateMixin','./FadeMixin','./Glyphicon','./Grid','./Input','./Interpolate','./Jumbotron','./Label','./ListGroup','./ListGroupItem','./MenuItem','./Modal','./Nav','./Navbar','./NavItem','./ModalTrigger','./OverlayTrigger','./OverlayMixin','./PageHeader','./Panel','./PanelGroup','./PageItem','./Pager','./Popover','./ProgressBar','./Row','./SplitButton','./SubNav','./TabbedArea','./Table','./TabPane','./Tooltip','./Well'],function (require) {
  

  return {
    Accordion: require('./Accordion'),
    Affix: require('./Affix'),
    AffixMixin: require('./AffixMixin'),
    Alert: require('./Alert'),
    WebSkinMixin: require('./WebSkinMixin'),
    WebSkinAlertStyles: require('./WebSkinAlertStyles'),
    WebSkinAlertMixin: require('./WebSkinAlertMixin'),
    Badge: require('./Badge'),
    Button: require('./Button'),
    ButtonGroup: require('./ButtonGroup'),
    ButtonToolbar: require('./ButtonToolbar'),
    Carousel: require('./Carousel'),
    CarouselItem: require('./CarouselItem'),
    Col: require('./Col'),
    CollapsibleNav: require('./CollapsibleNav'),
    CollapsibleMixin: require('./CollapsibleMixin'),
    DropdownButton: require('./DropdownButton'),
    DropdownMenu: require('./DropdownMenu'),
    DropdownStateMixin: require('./DropdownStateMixin'),
    FadeMixin: require('./FadeMixin'),
    Glyphicon: require('./Glyphicon'),
    Grid: require('./Grid'),
    Input: require('./Input'),
    Interpolate: require('./Interpolate'),
    Jumbotron: require('./Jumbotron'),
    Label: require('./Label'),
    ListGroup: require('./ListGroup'),
    ListGroupItem: require('./ListGroupItem'),
    MenuItem: require('./MenuItem'),
    Modal: require('./Modal'),
    Nav: require('./Nav'),
    Navbar: require('./Navbar'),
    NavItem: require('./NavItem'),
    ModalTrigger: require('./ModalTrigger'),
    OverlayTrigger: require('./OverlayTrigger'),
    OverlayMixin: require('./OverlayMixin'),
    PageHeader: require('./PageHeader'),
    Panel: require('./Panel'),
    PanelGroup: require('./PanelGroup'),
    PageItem: require('./PageItem'),
    Pager: require('./Pager'),
    Popover: require('./Popover'),
    ProgressBar: require('./ProgressBar'),
    Row: require('./Row'),
    SplitButton: require('./SplitButton'),
    SubNav: require('./SubNav'),
    TabbedArea: require('./TabbedArea'),
    Table: require('./Table'),
    TabPane: require('./TabPane'),
    Tooltip: require('./Tooltip'),
    Well: require('./Well')
  };
});

    //Register in the values from the outer closure for common dependencies
    //as local almond modules
    define('react', function () {
        return React;
    });

    //Use almond's special top-level, synchronous require to trigger factory
    //functions, get the final module value, and export it as the public
    //value.
    return require('web-skin-react');
}));
