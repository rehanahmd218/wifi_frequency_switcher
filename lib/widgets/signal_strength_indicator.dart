import 'package:flutter/material.dart';

class SignalStrengthIndicator extends StatelessWidget {
  final int strength; // 1-4 bars

  const SignalStrengthIndicator({
    super.key,
    required this.strength,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isActive = index < strength;
        return Container(
          margin: EdgeInsets.only(left: index > 0 ? 2 : 0),
          width: 4,
          height: 8 + (index * 3).toDouble(),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}