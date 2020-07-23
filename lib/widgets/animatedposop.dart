
import 'package:flutter/cupertino.dart';

class AnimatedPosOp extends StatelessWidget {
  double top, left, right, bottom;
  double opacity;
  Duration duration;
  Curve curve;
  Widget child;
  bool hidden;

  AnimatedPosOp({this.top, this.left, this.right, this.bottom, this.opacity, this.duration, this.curve, this.child, this.hidden});

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,

      duration: duration,
      curve: curve,
      
      child: AnimatedOpacity(
        opacity: opacity,
        duration: duration,
        curve: curve,

        child: IgnorePointer(
          ignoring: hidden,

          child: child,
        ),
      ),
    );
  }
}