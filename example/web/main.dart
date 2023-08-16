import 'package:navand/navand.dart';

void main() => runApp(const App());

// The main widget of your Navand application.
final class App extends StatelessWidget {
  const App({super.key, super.ref});

  @override
  Widget build(final BuildContext context) {
    return const Container(
      [Logo(), Greeting()],
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

final class Logo extends StatelessWidget {
  const Logo({super.key, super.ref});

  @override
  Widget build(final BuildContext context) {
    return const Image(
      'https://raw.githubusercontent.com/Hawmex/Hawmex/main/assets/icon.svg',
      style: Style({'width': '128px', 'height': '128px'}),
      animation: Animation(
        keyframes: [
          Keyframe(offset: 0, style: Style({'transform': 'translateY(0px)'})),
          Keyframe(offset: 1, style: Style({'transform': 'translateY(8px)'})),
        ],
        duration: Duration(seconds: 1),
        easing: Easing(0.2, 0, 0.4, 1),
        direction: AnimationDirection.alternate,
        iterations: double.infinity,
      ),
    );
  }
}

final class Greeting extends StatelessWidget {
  const Greeting({super.key, super.ref});

  @override
  Widget build(final BuildContext context) {
    // Tip: You can use `'display': 'contents'` with `Container` to render
    // multiple children without a wrapper.
    return const Container(
      [
        Text(
          'Welcome to Navand!',
          style: Style({
            'font-size': '24px',
            'font-weight': 'bold',
            'color': '#00e690',
          }),
        ),
        Container([
          Text('To get started, edit '),
          Text(
            'web/main.dart',
            style: Style({
              'font-family': 'monospace',
              'background': '#212121',
              'border-radius': '4px',
              'padding': '4px',
            }),
          ),
          Text(' and save to reload.'),
        ])
      ],
      style: Style({'display': 'contents'}),
    );
  }
}
