import 'package:navand/navand.dart';

import 'widgets/greeting.dart';
import 'widgets/logo.dart';

// The main widget of your Navand application.
final class App extends StatelessWidget {
  const App({super.key, super.ref});

  @override
  Widget build(final BuildContext context) {
    // You can use `Container` to wrap multiple widgets.
    return const Container(
      [Logo(), Greeting()],
      // You can use `Style` to style your painted widgets.
      style: Style({
        'display': 'flex',
        'flex-flow': 'column',
        'justify-content': 'center',
        'text-align': 'center',
        'align-items': 'center',
        'gap': '16px',
        'padding': '16px',
        'width': '100%',
        'min-height': '100vh',
        'background': '#0d1117',
        'color': '#ffffff',
        'font-family': 'system-ui',
        'user-select': 'none',
      }),
    );
  }
}
