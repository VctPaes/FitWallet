import 'package:flutter/material.dart';

class DotsIndicator extends StatelessWidget {
  final int count;
  final int index;
  final double size;
  DotsIndicator({required this.count, required this.index, this.size = 10});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 6),
          width: active ? size * 1.8 : size,
          height: size,
          decoration: BoxDecoration(
            color: active ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
