import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String statName;
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;
  final VoidCallback onRandomize;

  const StatCard({
    super.key,
    required this.statName,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    required this.onRandomize,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.medievalCream,
              AppTheme.medievalCream.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: ListTile(
          leading: Icon(Icons.star, color: AppTheme.medievalGold, size: 24),
          title: Text(
            statName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.medievalDarkBrown,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.medievalBronze,
                    width: 2,
                  ),
                ),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: TextEditingController(text: value.toString()),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                  onChanged: (value) {
                    final intValue = int.tryParse(value);
                    if (intValue != null && intValue >= minValue && intValue <= maxValue) {
                      onChanged(intValue);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.medievalGold,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.medievalGold.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.casino, size: 20, color: AppTheme.medievalDarkBrown),
                  onPressed: onRandomize,
                  tooltip: 'Tirer au sort',
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
