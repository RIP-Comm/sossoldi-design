import '../models/exchange_rate.dart';

/// Fixed rates to EUR, "refreshed" two hours before [now].
List<ExchangeRate> buildExchangeRates(DateTime now) {
  final updatedAt = now.subtract(const Duration(hours: 2));
  return [
    ExchangeRate(currency: 'USD', toEur: 0.9234, updatedAt: updatedAt),
    ExchangeRate(currency: 'GBP', toEur: 1.1705, updatedAt: updatedAt),
    ExchangeRate(currency: 'CHF', toEur: 1.0612, updatedAt: updatedAt),
  ];
}
