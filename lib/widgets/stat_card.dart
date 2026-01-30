import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/stat_descriptions.dart';

class StatCard extends StatefulWidget {
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
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(StatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value.toString()) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          title: Tooltip(
            message: StatDescriptions.getTranslatedDescription(context, widget.statName),
            preferBelow: false,
            child: MouseRegion(
              cursor: SystemMouseCursors.help,
              child: Text(
                StatDescriptions.getTranslatedName(context, widget.statName),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.medievalDarkBrown,
                ),
              ),
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
                  controller: _controller,
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
                    if (intValue != null && intValue >= widget.minValue && intValue <= widget.maxValue) {
                      widget.onChanged(intValue);
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
                  onPressed: widget.onRandomize,
                  tooltip: AppLocalizations.trSafe(context, 'roll_draw'),
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
