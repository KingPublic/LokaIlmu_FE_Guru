import 'package:flutter_test/flutter_test.dart';
import 'package:lokalilmu_guru/model/schedule_item.dart';

void main() {
  group('ScheduleItem Tests', () {
    late ScheduleItem scheduleItem;
    late Map<String, dynamic> validJson;
    late DateTime startDate;
    late DateTime endDate;

    setUp(() {
      startDate = DateTime(2024, 5, 15, 9, 0); // 9:00 AM
      endDate = DateTime(2024, 5, 15, 11, 0);   // 11:00 AM

      validJson = {
        'id': 'schedule_001',
        'title': 'Mathematics Class',
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

      scheduleItem = ScheduleItem(
        id: 'schedule_001',
        title: 'Mathematics Class',
        startDate: startDate,
        endDate: endDate,
      );
    });

    test('should create ScheduleItem with valid data', () {
      expect(scheduleItem.id, equals('schedule_001'));
      expect(scheduleItem.title, equals('Mathematics Class'));
      expect(scheduleItem.startDate, equals(startDate));
      expect(scheduleItem.endDate, equals(endDate));
    });

    test('should create ScheduleItem from JSON', () {
      final item = ScheduleItem.fromJson(validJson);

      expect(item.id, equals('schedule_001'));
      expect(item.title, equals('Mathematics Class'));
      expect(item.startDate, equals(startDate));
      expect(item.endDate, equals(endDate));
    });

    test('should convert ScheduleItem to JSON', () {
      final json = scheduleItem.toJson();

      expect(json['id'], equals('schedule_001'));
      expect(json['title'], equals('Mathematics Class'));
      expect(json['startDate'], equals(startDate.toIso8601String()));
      expect(json['endDate'], equals(endDate.toIso8601String()));
    });

    test('should handle same start and end date', () {
      final sameDateTime = DateTime(2024, 5, 15, 10, 0);
      final sameTimeSchedule = ScheduleItem(
        id: 'schedule_002',
        title: 'Quick Meeting',
        startDate: sameDateTime,
        endDate: sameDateTime,
      );

      expect(sameTimeSchedule.startDate, equals(sameTimeSchedule.endDate));
    });

    test('should handle multi-day schedule', () {
      final multiDayStart = DateTime(2024, 5, 15, 9, 0);
      final multiDayEnd = DateTime(2024, 5, 17, 17, 0);
      
      final multiDaySchedule = ScheduleItem(
        id: 'schedule_003',
        title: 'Workshop',
        startDate: multiDayStart,
        endDate: multiDayEnd,
      );

      expect(multiDaySchedule.startDate.day, equals(15));
      expect(multiDaySchedule.endDate.day, equals(17));
      expect(multiDaySchedule.endDate.isAfter(multiDaySchedule.startDate), isTrue);
    });

    test('should handle invalid date format in JSON', () {
      final invalidJson = {
        'id': 'schedule_001',
        'title': 'Mathematics Class',
        'startDate': 'invalid-date-format',
        'endDate': 'invalid-date-format',
      };

      expect(() => ScheduleItem.fromJson(invalidJson), throwsA(isA<FormatException>()));
    });

    test('should handle null values in JSON', () {
      final nullJson = <String, dynamic>{
        'id': null,
        'title': null,
        'startDate': null,
        'endDate': null,
      };

      expect(() => ScheduleItem.fromJson(nullJson), throwsA(isA<TypeError>()));
    });

    test('should handle empty strings in JSON', () {
      final emptyJson = {
        'id': '',
        'title': '',
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

      final item = ScheduleItem.fromJson(emptyJson);
      expect(item.id, equals(''));
      expect(item.title, equals(''));
      expect(item.startDate, equals(startDate));
      expect(item.endDate, equals(endDate));
    });

    test('should handle timezone in dates', () {
      final utcStart = DateTime.utc(2024, 5, 15, 9, 0);
      final utcEnd = DateTime.utc(2024, 5, 15, 11, 0);
      
      final utcJson = {
        'id': 'schedule_utc',
        'title': 'UTC Schedule',
        'startDate': utcStart.toIso8601String(),
        'endDate': utcEnd.toIso8601String(),
      };

      final item = ScheduleItem.fromJson(utcJson);
      expect(item.startDate.isUtc, isTrue);
      expect(item.endDate.isUtc, isTrue);
    });

    test('should preserve milliseconds in dates', () {
      final preciseStart = DateTime(2024, 5, 15, 9, 0, 0, 123);
      final preciseEnd = DateTime(2024, 5, 15, 11, 0, 0, 456);
      
      final preciseSchedule = ScheduleItem(
        id: 'schedule_precise',
        title: 'Precise Schedule',
        startDate: preciseStart,
        endDate: preciseEnd,
      );

      final json = preciseSchedule.toJson();
      final recreated = ScheduleItem.fromJson(json);
      
      expect(recreated.startDate.millisecond, equals(123));
      expect(recreated.endDate.millisecond, equals(456));
    });
  });
}