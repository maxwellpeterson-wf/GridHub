library ContentLoading;

import 'package:react/react.dart' as react;


var ContentLoading = react.registerComponent(() => new _ContentLoading());
class _ContentLoading extends react.Component {

    render() {
        return react.div({'className': 'empty-results'}, [
            react.i({'className': 'progress-spinner progress-spinner-huge'})
        ]);
    }
}
