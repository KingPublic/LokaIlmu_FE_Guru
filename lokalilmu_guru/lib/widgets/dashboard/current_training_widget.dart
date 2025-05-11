import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lokalilmu_guru/model/training_item.dart';

class CurrentTrainingWidget extends StatelessWidget {
  final TrainingItem training;

  const CurrentTrainingWidget({
    Key? key,
    required this.training,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = training.progressPercentage.clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.book, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    training.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTrainingDates(training.startDate, training.endDate) +
                    ' (${training.completedSessions} sesi)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Format training dates (e.g., "19/04/2023 - 03/05/2023")
  String _formatTrainingDates(DateTime start, DateTime end) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
  }
}