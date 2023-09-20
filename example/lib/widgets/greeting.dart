import 'package:navand/navand.dart';

final class Greeting extends StatelessWidget {
  const Greeting({super.key, super.ref});

  @override
  Widget build(final BuildContext context) {
    return const Fragment(
      [
        DomWidget(
          'span',
          style: Style({
            'font-size': '24px',
            'font-weight': 'bold',
            'color': '#00e690',
          }),
          children: [
            Text('Welcome to Navand!'),
          ],
        ),
        DomWidget(
          'div',
          children: [
            Text('To get started, edit '),
            DomWidget(
              'span',
              style: Style({
                'font-family': 'monospace',
                'background': '#212121',
                'border-radius': '4px',
                'padding': '4px',
              }),
              children: [
                Text('web/main.dart'),
              ],
            ),
            Text(' and save to reload.'),
          ],
        )
      ],
    );
  }
}
