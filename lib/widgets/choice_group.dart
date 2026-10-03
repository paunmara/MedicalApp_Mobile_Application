import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChoiceGroup extends StatelessWidget {
  const ChoiceGroup({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final Map<String, String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: options.entries.map((entry) {
              final displayText = entry.key;
              final storedValue = entry.value;
              final isSelected = storedValue == selected;
              return ChoiceChip(
                label: Text(
                  displayText,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.choiceUnselectedText,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => onSelected(storedValue),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}