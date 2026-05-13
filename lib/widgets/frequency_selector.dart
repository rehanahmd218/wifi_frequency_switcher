import 'package:flutter/material.dart';

class FrequencySelector extends StatelessWidget {
  final bool is5GHzSelected;
  final Function(bool) onFrequencyChanged;

  const FrequencySelector({
    super.key,
    required this.is5GHzSelected,
    required this.onFrequencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 30), // Adjust spacing as needed
            _buildFrequencyTab('5GHz', true),
            const SizedBox(width: 40), // Adjust spacing as needed
            _buildFrequencyTab('2.4GHz', false),
          ],
        ),
       
        Container(
          // width: MediaQuery.sizeOf(context).width*0.6,
          width: double.infinity,
          height: 1,
          color: Colors.white.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildFrequencyTab(String text, bool is5GHz) {
    final isSelected = is5GHz ? is5GHzSelected : !is5GHzSelected;

    return GestureDetector(
      onTap: () => onFrequencyChanged(is5GHz),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF38B2AC) : Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          // Indicator bar - only shown when selected
          Container(
            width: 100, // Adjust width to match your design
            height: 4,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF38B2AC) : Colors.transparent,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? const Color(0xFF38B2AC).withOpacity(0.6) : Colors.transparent,
                  blurRadius: 16,
                  spreadRadius: 4,
                  offset: const Offset(0, -4),
                ),
              ]
            ),
          ),
        ],
      ),
    );
  }
}
