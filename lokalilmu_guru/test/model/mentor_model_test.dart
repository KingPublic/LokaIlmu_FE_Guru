import 'package:flutter_test/flutter_test.dart';
import 'package:lokalilmu_guru/model/mentor_model.dart';

void main() {
  group('MentorModel Tests', () {
    late MentorModel mentorModel;
    late Map<String, dynamic> validJson;

    setUp(() {
      validJson = {
        'id': 'mentor_001',
        'name': 'Dr. Jane Smith',
        'expertise': 'Mathematics Education',
        'imageUrl': 'https://example.com/mentor.jpg',
        'rating': 4.8,
        'reviewCount': 150,
        'description': 'Experienced mathematics teacher with 15 years of experience',
        'categories': ['Mathematics', 'Statistics', 'Algebra'],
        'pricePerSession': 100000,
      };

      mentorModel = MentorModel(
        id: 'mentor_001',
        name: 'Dr. Jane Smith',
        institution: 'Mathematics Education',
        imageUrl: 'https://example.com/mentor.jpg',
        rating: 4.8,
        reviewCount: 150,
        description: 'Experienced mathematics teacher with 15 years of experience',
        categories: ['Mathematics', 'Statistics', 'Algebra'],
        pricePerSession: 100000,
      );
    });

    test('should create MentorModel with valid data', () {
      expect(mentorModel.id, equals('mentor_001'));
      expect(mentorModel.name, equals('Dr. Jane Smith'));
      expect(mentorModel.institution, equals('Mathematics Education'));
      expect(mentorModel.imageUrl, equals('https://example.com/mentor.jpg'));
      expect(mentorModel.rating, equals(4.8));
      expect(mentorModel.reviewCount, equals(150));
      expect(mentorModel.description, equals('Experienced mathematics teacher with 15 years of experience'));
      expect(mentorModel.categories, equals(['Mathematics', 'Statistics', 'Algebra']));
      expect(mentorModel.pricePerSession, equals(100000));
    });

    test('should create MentorModel from JSON', () {
      final model = MentorModel.fromJson(validJson);

      expect(model.id, equals('mentor_001'));
      expect(model.name, equals('Dr. Jane Smith'));
      expect(model.institution, equals('Mathematics Education'));
      expect(model.imageUrl, equals('https://example.com/mentor.jpg'));
      expect(model.rating, equals(4.8));
      expect(model.reviewCount, equals(150));
      expect(model.description, equals('Experienced mathematics teacher with 15 years of experience'));
      expect(model.categories, equals(['Mathematics', 'Statistics', 'Algebra']));
      expect(model.pricePerSession, equals(100000));
    });

    test('should convert MentorModel to JSON', () {
      final json = mentorModel.toJson();

      expect(json['id'], equals('mentor_001'));
      expect(json['name'], equals('Dr. Jane Smith'));
      expect(json['institution'], equals('Mathematics Education'));
      expect(json['imageUrl'], equals('https://example.com/mentor.jpg'));
      expect(json['rating'], equals(4.8));
      expect(json['reviewCount'], equals(150));
      expect(json['description'], equals('Experienced mathematics teacher with 15 years of experience'));
      expect(json['categories'], equals(['Mathematics', 'Statistics', 'Algebra']));
      // Note: pricePerSession is not included in toJson method
    });

    test('should handle empty or null values in JSON', () {
      final emptyJson = <String, dynamic>{};
      final model = MentorModel.fromJson(emptyJson);

      expect(model.id, equals(''));
      expect(model.name, equals(''));
      expect(model.institution, equals(''));
      expect(model.imageUrl, equals(''));
      expect(model.rating, equals(0.0));
      expect(model.reviewCount, equals(0));
      expect(model.description, equals(''));
      expect(model.categories, equals([]));
      expect(model.pricePerSession, equals(0));
    });

    test('should handle integer rating in JSON', () {
      final jsonWithIntRating = {
        ...validJson,
        'rating': 5, // integer instead of double
      };

      final model = MentorModel.fromJson(jsonWithIntRating);
      expect(model.rating, equals(5.0));
    });

    test('should handle empty categories list', () {
      final jsonWithEmptyCategories = {
        ...validJson,
        'categories': [],
      };

      final model = MentorModel.fromJson(jsonWithEmptyCategories);
      expect(model.categories, equals([]));
    });

    test('should handle null categories in JSON', () {
      final jsonWithNullCategories = {
        ...validJson,
        'categories': null,
      };

      final model = MentorModel.fromJson(jsonWithNullCategories);
      expect(model.categories, equals([]));
    });
  });
}