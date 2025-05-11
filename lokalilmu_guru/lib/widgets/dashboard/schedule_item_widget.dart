import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lokalilmu_guru/model/schedule_item.dart';

class ScheduleItemWidget extends StatelessWidget {
  final ScheduleItem schedule;

  const ScheduleItemWidget({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calendar_today, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatScheduleTime(schedule.startDate, schedule.endDate),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Format schedule time (e.g., "21 Apr 2023 12:00 - 15:00")
  String _formatScheduleTime(DateTime start, DateTime end) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    return '${dateFormat.format(start)} ${timeFormat.format(start)} - ${timeFormat.format(end)}';
  }
}