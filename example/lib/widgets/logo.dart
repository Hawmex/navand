import 'package:navand/navand.dart';

final class Logo extends StatelessWidget {
  const Logo({super.key, super.ref});

  @override
  Widget build(final BuildContext context) {
    return const DomWidget(
      'img',
      attributes: {
        'src':
            'https://raw.githubusercontent.com/Hawmex/Hawmex/main/assets/icon.svg'
      },
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
