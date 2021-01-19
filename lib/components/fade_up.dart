import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

enum AnimationType { opacity, translateX }

class FadeUp extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeUp(this.delay, this.child);

  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<AnimationType>()
      ..add(
        AnimationType.opacity,
        Tween(begin: 0.0, end: 1.0),
        Duration(milliseconds: 500),
      )
      ..add(AnimationType.translateX, Tween(begin: 130.0, end: 0.0),
          Duration(milliseconds: 800), Curves.easeOut);

    /*final tween = MultiTrackTween([
      Track("opacity")
          .add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0)),
      Track("translateX").add(
          Duration(milliseconds: 800), Tween(begin: 130.0, end: 0.0),
          curve: Curves.easeOut)
    ]);*/

    return PlayAnimation<MultiTweenValues<AnimationType>>(
      delay: Duration(milliseconds: (300 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builder: (context, child, value) => Opacity(
        opacity: value.get(AnimationType.opacity),
        child: Transform.translate(
            offset: Offset(0, value.get(AnimationType.translateX)),
            child: child),
      ),
    );

    /*return ControlledAnimation(
      delay: Duration(milliseconds: (300 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation["opacity"],
        child: Transform.translate(
            offset: Offset(0, animation["translateX"]), child: child),
      ),
    );*/
  }
}
