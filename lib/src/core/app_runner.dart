import 'package:js/js.dart';

import '../navigator/back_event.dart';
import '../widgets/widget.dart';

@JS('__navandAppNode__')
external Node? _appNode;

/// Attaches the given [app] to the document's body by initializing it.
void runApp(final Widget app) {
  // ignore: avoid_print
  print(r'''
  _   _                            _ 
 | \ | |                          | |
 |  \| | __ ___   ____ _ _ __   __| |
 | . ` |/ _` \ \ / / _` | '_ \ / _` |
 | |\  | (_| |\ V / (_| | | | | (_| |
 |_| \_|\__,_| \_/ \__,_|_| |_|\__,_|
                                                       
''');

  addBackEventScript();

  if (_appNode != null && app.matches(_appNode!.widget)) {
    _appNode!.widget = app;
  } else {
    _appNode?.dispose();

    _appNode = app.createNode()
      ..parentNode = null
      ..initialize();
  }
}
