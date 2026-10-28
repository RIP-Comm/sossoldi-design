import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/features/accounts/account_form_controller.dart';

void main() {
  group('parseAmount', () {
    test('a point or a comma is the decimal separator', () {
      expect(parseAmount('1000.20', 'en'), 1000.2);
      expect(parseAmount('1000,20', 'en'), 1000.2);
      expect(parseAmount('1000,20', 'it'), 1000.2);
      expect(parseAmount('0,5', 'en'), 0.5);
      expect(parseAmount('.5', 'en'), isNull);
    });

    test('the separator of thousands of the language is ignored', () {
      expect(parseAmount('1.500,00', 'it'), 1500);
      expect(parseAmount('1,500.00', 'en'), 1500);
      expect(parseAmount('1.500', 'it'), 1500);
      expect(parseAmount('1,500', 'en'), 1500);
      expect(parseAmount('1.234.567', 'it'), 1234567);
      expect(parseAmount('1,234,567.89', 'en'), 1234567.89);
    });

    test('a separator that is not the language\'s thousands is decimal', () {
      expect(parseAmount('1.500', 'en'), 1.5);
      expect(parseAmount('1,500', 'it'), 1.5);
      expect(parseAmount('12.5', 'it'), 12.5);
    });

    test('zero, negatives and spaces', () {
      expect(parseAmount('0', 'en'), 0);
      expect(parseAmount('-250.5', 'en'), -250.5);
      expect(parseAmount('-250,5', 'it'), -250.5);
      expect(parseAmount(' 1 000 ', 'en'), 1000);
    });

    test('not numbers', () {
      for (final text in ['', '   ', 'abc', '12a', '--5', '1.2.3,4,', '€5']) {
        expect(parseAmount(text, 'en'), isNull, reason: text);
      }
    });
  });
}
