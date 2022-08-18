import 'package:flutter/material.dart';

late double _width;
late double _height;

class ScaleAssist extends StatelessWidget {
  static void setNewSize(Offset size) {
    _width = size.dx;
    _height = size.dy;
  }

  final Widget Function(BuildContext context, Offset maximumSize) builder;

  const ScaleAssist({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        _width = constraints.maxWidth;
        _height = constraints.maxHeight;

        return builder(
          ctx,
          Offset(_width, _height),
        );
      },
    );
  }
}

extension SAnum on num {
  double get w => this * _width / 100;
  double get h => this * _height / 100;
  double get sp => this * _width / 500;
}
