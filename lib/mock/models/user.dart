import 'package:flutter/foundation.dart';

@immutable
class User {
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mainCurrency,
    required this.language,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;

  /// ISO 4217 code, e.g. "EUR".
  final String mainCurrency;

  /// Language code, e.g. "it".
  final String language;
}
