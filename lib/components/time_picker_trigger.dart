import 'package:cinch/providers/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimePickerTrigger extends StatelessWidget {
  const TimePickerTrigger({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<AddTransactionScreenProvider>(
      builder: (context, provider, _) {
        final selected = provider.selectedTime;
        return Material(
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _pickDateTime(context, provider),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  if (selected != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      _formatDateTime(selected),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDateTime(
    BuildContext context,
    AddTransactionScreenProvider provider,
  ) async {
    final now = DateTime.now();
    final initial = provider.selectedTime ?? now;
    final firstDate = DateTime(now.year - 5);
    final lastDate = DateTime(now.year + 5, 12, 31);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (pickedDate == null) return;
    if (!context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null) return;

    provider.setSelectedTime(
      DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}
