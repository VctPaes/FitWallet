import 'package:flutter/material.dart';

class DotsIndicator extends StatelessWidget {
  final int count;
  final int index;
  const DotsIndicator({super.key, required this.count, required this.index});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: i==index ? 12 : 8,
        height: i==index ? 12 : 8,
        decoration: BoxDecoration(
          color: i==index ? Theme.of(context).colorScheme.primary : Colors.grey,
          shape: BoxShape.circle,
        ),
      )),
    );
  }
}
