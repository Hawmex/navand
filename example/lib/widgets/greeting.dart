import 'package:navand/navand.dart';

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
