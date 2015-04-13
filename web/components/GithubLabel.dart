library GithubLabel;

import 'package:react/react.dart' as react;


var GithubLabel = react.registerComponent(() => new _GithubLabel());

class _GithubLabel extends react.Component {

    render() {
        var name = this.props['label']['name'];
        var color = this.props['label']['color'];
        return react.span({
            'className': 'github-label',
            'style': {'background-color': '#${color}', 'color': _getContrastYIQ(color)}
        }, name);
    }

    _getContrastYIQ(String hexcolor){
        int r = int.parse('0x${hexcolor.substring(0, 2)}');
        int g = int.parse('0x${hexcolor.substring(2, 4)}');
        int b = int.parse('0x${hexcolor.substring(4, 6)}');
        int yiq = (((r * 299) + (g * 587) + (b * 114)) / 1000).floor();
        return (yiq >= 128) ? '#333333' : '#FFFFFF';
    }
}
