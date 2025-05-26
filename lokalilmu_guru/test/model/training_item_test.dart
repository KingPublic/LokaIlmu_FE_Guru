import 'package:flutter_test/flutter_test.dart';
import 'package:lokalilmu_guru/model/training_item.dart';

void main() {
  group('TrainingItem Tests', () {
    late TrainingItem trainingItem;
    late Map<String, dynamic> validJson;
    late DateTime startDate;
    late DateTime endDate;

    setUp(() {
      startDate = DateTime(2024, 1, 1);
      endDate = DateTime(2024, 3, 31);

      validJson = {
        'id': 'training_001',
        'title': 'Flutter Development Bootcamp',
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'totalSessions': 10,
        'completedSessions': 7,
      };

      trainingItem = TrainingItem(
        id: 'training_001',
        title: 'Flutter Development Bootcamp',
        startDate: startDate,
        endDate: endDate,
        totalSessions: 10,
        completedSessions: 7,
      );
    });

    test('should create TrainingItem with valid data', () {
      expect(trainingItem.id, equals('training_001'));
      expect(trainingItem.title, equals('Flutter Development Bootcamp'));
      expect(trainingItem.startDate, equals(startDate));
      expect(trainingItem.endDate, equals(endDate));
      expect(trainingItem.totalSessions, equals(10));
      expect(trainingItem.completedSessions, equals(7));
    });

    test('should create TrainingItem from JSON', () {
      final item = TrainingItem.fromJson(validJson);

      expect(item.id, equals('training_001'));
      expect(item.title, equals('Flutter Development Bootcamp'));
      expect(item.startDate, equals(startDate));
      expect(item.endDate, equals(endDate));
      expect(item.totalSessions, equals(10));
      expect(item.completedSessions, equals(7));
    });

    test('should convert TrainingItem to JSON', () {
      final json = trainingItem.toJson();

      expect(json['id'], equals('training_001'));
      expect(json['title'], equals('Flutter Development Bootcamp'));
      expect(json['startDate'], equals(startDate.toIso8601String()));
      expect(json['endDate'], equals(endDate.toIso8601String()));
      expect(json['totalSessions'], equals(10));
      expect(json['completedSessions'], equals(7));
    });

    test('should calculate progress percentage correctly', () {
      expect(trainingItem.progressPercentage, equals(0.7)); // 7/10 = 0.7
    });

    test('should calculate progress percentage for completed training', () {
      final completedTraining = TrainingItem(
        id: 'training_002',
        title: 'Completed Training',
        startDate: startDate,
        endDate: endDate,
        totalSessions: 5,
        completedSessions: 5,
      );

      expect(completedTraining.progressPercentage, equals(1.0));
    });

    test('should calculate progress percentage for new training', () {
      final newTraining = TrainingItem(
        id: 'training_003',
        title: 'New Training',
        startDate: startDate,
        endDate: endDate,
        totalSessions: 8,
        completedSessions: 0,
      );

      expect(newTraining.progressPercentage, equals(0.0));
    });

    test('should handle division by zero in progress calculation', () {
      final invalidTraining = TrainingItem(
        id: 'training_004',
        title: 'Invalid Training',
        startDate: startDate,
        endDate: endDate,
        totalSessions: 0,
        completedSessions: 0,
      );

      expect(invalidTraining.progressPercentage, isNaN);
    });

    test('should handle invalid date format in JSON', () {
      final invalidJson = {
        'id': 'training_001',
        'title': 'Flutter Development Bootcamp',
        'startDate': 'invalid-date',
        'endDate': 'invalid-date',
        'totalSessions': 10,
        'completedSessions': 7,
      };

      expect(() => TrainingItem.fromJson(invalidJson), throwsA(isA<FormatException>()));
    });

    test('should handle null values in JSON', () {
      final nullJson = <String, dynamic>{
        'id': null,
        'title': null,
        'startDate': null,
        'endDate': null,
        'totalSessions': null,
        'completedSessions': null,
      };

      expect(() => TrainingItem.fromJson(nullJson), throwsA(isA<TypeError>()));
    });

    test('should handle edge case where completed sessions exceed total sessions', () {
      final edgeCaseTraining = TrainingItem(
        id: 'training_005',
        title: 'Edge Case Training',
        startDate: startDate,
        endDate: endDate,
        totalSessions: 5,
        completedSessions: 8, // More than total
      );

      expect(edgeCaseTraining.progressPercentage, equals(1.6)); // 8/5 = 1.6
    });
  });
}