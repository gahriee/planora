import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DueDateChip extends StatelessWidget {
  final DateTime date;

  const DueDateChip({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final isOverdue = date.isBefore(DateTime.now()) && 
        !DateUtils.isSameDay(date, DateTime.now());
    
    final color = isOverdue ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          DateFormat('MMM d, yyyy').format(date),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
