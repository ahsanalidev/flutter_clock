import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class Circle extends StatelessWidget {
  const Circle(this.clock);
  final Widget clock;
  static final rainbowColors = <Color>[
    Colors.lightBlue.shade900,
    Color(0xffD38312),
    Color(0xffA83279),
    Colors.blue.shade600,
  ];

  @override
  Widget build(BuildContext context) {
    final circleRadius = MediaQuery.of(context).size.width * 0.16;
    return ControlledAnimation(
      playback: Playback.MIRROR,
      duration: Duration(seconds: 10),
      tween: rainbowTween(),
      child: clock,
      builderWithChild: (context, child, color) {
        return Container(
          child: child,
          width: circleRadius * 2,
          height: circleRadius * 2,
          decoration: BoxDecoration(
              color: color,
              boxShadow: [
                BoxShadow(
                  spreadRadius: 2,
                  blurRadius: 30,
                  color: Theme.of(context).primaryColor,
                  //offset: Offset(-10, -10)
                )
              ],
              borderRadius: BorderRadius.all(Radius.circular(circleRadius))),
        );
      },
    );
  }

  TweenSequence rainbowTween() {
    final items = <TweenSequenceItem>[];
    for (int i = 0; i < rainbowColors.length - 1; i++) {
      items.add(TweenSequenceItem(
          tween: ColorTween(begin: rainbowColors[i], end: rainbowColors[i + 1]),
          weight: 1));
    }
    return TweenSequence(items);
  }
}
