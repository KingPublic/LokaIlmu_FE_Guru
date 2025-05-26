import 'package:flutter_test/flutter_test.dart';

import 'model/loginregis_model_test.dart' as loginregis_tests;
import 'model/book_model_test.dart' as book_tests;
import 'model/auth_model_test.dart' as auth_tests;
import 'model/mentor_model_test.dart' as mentor_tests;
import 'model/training_item_test.dart' as training_tests;
import 'model/schedule_item_test.dart' as schedule_tests;

void main() {
  group('All Model Tests', () {
    group('LoginRegis Model Tests', loginregis_tests.main);
    group('Book Model Tests', book_tests.main);
    group('Auth Response Tests', auth_tests.main);
    group('Mentor Model Tests', mentor_tests.main);
    group('Training Item Tests', training_tests.main);
    group('Schedule Item Tests', schedule_tests.main);
  });
}