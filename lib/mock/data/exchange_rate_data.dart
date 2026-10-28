import '../models/exchange_rate.dart';

/// Fixed rates to EUR for every currency the selectors offer besides EUR,
/// "refreshed" two hours before [now].
List<ExchangeRate> buildExchangeRates(DateTime now) {
  final updatedAt = now.subtract(const Duration(hours: 2));
  return [
    ExchangeRate(currency: 'USD', toEur: 0.9234, updatedAt: updatedAt),
    ExchangeRate(currency: 'GBP', toEur: 1.1705, updatedAt: updatedAt),
    ExchangeRate(currency: 'CHF', toEur: 1.0612, updatedAt: updatedAt),
    ExchangeRate(currency: 'BRL', toEur: 0.1650, updatedAt: updatedAt),
    ExchangeRate(currency: 'AED', toEur: 0.2514, updatedAt: updatedAt),
    ExchangeRate(currency: 'JPY', toEur: 0.00588, updatedAt: updatedAt),
    ExchangeRate(currency: 'CAD', toEur: 0.6708, updatedAt: updatedAt),
  ];
}
