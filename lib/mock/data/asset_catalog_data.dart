// Selectable asset catalog: real, well-known instruments with one year of
// generated daily prices (random walk with a fixed seed per asset).
// Prices are simulated, not market data.

import 'dart:math';

import '../date_utils.dart';
import '../models/asset.dart';
import '../models/price_point.dart';

class _Seed {
  const _Seed(
    this.asset, {
    required this.startPrice,
    required this.yearReturn,
    required this.volatility,
  });

  final Asset asset;

  /// Price one year ago.
  final double startPrice;

  /// Total change over the year (0.18 = +18%); the walk is bent to end there.
  final double yearReturn;

  /// Annualized volatility.
  final double volatility;
}

const _etfSector = 'Diversified';

const _seeds = [
  // ETFs
  _Seed(
    Asset(
      id: 'ast_vwce',
      type: AssetType.etf,
      name: 'Vanguard FTSE All-World UCITS ETF Acc',
      isin: 'IE00BK5BQT80',
      ticker: 'VWCE',
      exchange: 'Xetra',
      currency: 'EUR',
      sector: _etfSector,
      region: 'Global',
    ),
    startPrice: 112,
    yearReturn: 0.18,
    volatility: 0.14,
  ),
  _Seed(
    Asset(
      id: 'ast_swda',
      type: AssetType.etf,
      name: 'iShares Core MSCI World UCITS ETF Acc',
      isin: 'IE00B4L5Y983',
      ticker: 'SWDA',
      exchange: 'Borsa Italiana',
      currency: 'EUR',
      sector: _etfSector,
      region: 'Developed markets',
    ),
    startPrice: 92,
    yearReturn: 0.16,
    volatility: 0.14,
  ),
  _Seed(
    Asset(
      id: 'ast_csspx',
      type: AssetType.etf,
      name: 'iShares Core S&P 500 UCITS ETF Acc',
      isin: 'IE00B5BMR087',
      ticker: 'CSSPX',
      exchange: 'Borsa Italiana',
      currency: 'EUR',
      sector: _etfSector,
      region: 'North America',
    ),
    startPrice: 520,
    yearReturn: 0.2,
    volatility: 0.16,
  ),
  _Seed(
    Asset(
      id: 'ast_eimi',
      type: AssetType.etf,
      name: 'iShares Core MSCI EM IMI UCITS ETF Acc',
      isin: 'IE00BKM4GZ66',
      ticker: 'EIMI',
      exchange: 'Borsa Italiana',
      currency: 'EUR',
      sector: _etfSector,
      region: 'Emerging markets',
    ),
    startPrice: 33,
    yearReturn: -0.12,
    volatility: 0.17,
  ),
  _Seed(
    Asset(
      id: 'ast_vusa',
      type: AssetType.etf,
      name: 'Vanguard S&P 500 UCITS ETF Dist',
      isin: 'IE00B3XXRP09',
      ticker: 'VUSA',
      exchange: 'Borsa Italiana',
      currency: 'EUR',
      sector: _etfSector,
      region: 'North America',
    ),
    startPrice: 95,
    yearReturn: 0.19,
    volatility: 0.16,
  ),
  _Seed(
    Asset(
      id: 'ast_aggh',
      type: AssetType.etf,
      name: 'iShares Core Global Aggregate Bond UCITS ETF EUR Hedged Acc',
      isin: 'IE00BDBRDM35',
      ticker: 'AGGH',
      exchange: 'Borsa Italiana',
      currency: 'EUR',
      sector: 'Bonds',
      region: 'Global',
    ),
    startPrice: 4.6,
    yearReturn: 0.02,
    volatility: 0.04,
  ),
  _Seed(
    Asset(
      id: 'ast_ibgs',
      type: AssetType.etf,
      name: 'iShares € Govt Bond 1-3yr UCITS ETF Dist',
      isin: 'IE00B14X4Q57',
      ticker: 'IBGS',
      exchange: 'Borsa Italiana',
      currency: 'EUR',
      sector: 'Government bonds',
      region: 'Eurozone',
    ),
    startPrice: 141,
    yearReturn: 0.025,
    volatility: 0.02,
  ),
  _Seed(
    Asset(
      id: 'ast_xdwt',
      type: AssetType.etf,
      name: 'Xtrackers MSCI World Information Technology UCITS ETF',
      isin: 'IE00BM67HT60',
      ticker: 'XDWT',
      exchange: 'Xetra',
      currency: 'EUR',
      sector: 'Technology',
      region: 'Developed markets',
    ),
    startPrice: 78,
    yearReturn: 0.24,
    volatility: 0.22,
  ),
  _Seed(
    Asset(
      id: 'ast_inrg',
      type: AssetType.etf,
      name: 'iShares Global Clean Energy UCITS ETF',
      isin: 'IE00B1XNHC34',
      ticker: 'INRG',
      exchange: 'Borsa Italiana',
      currency: 'EUR',
      sector: 'Energy',
      region: 'Global',
    ),
    startPrice: 7.9,
    yearReturn: -0.1,
    volatility: 0.25,
  ),
  // Stocks
  _Seed(
    Asset(
      id: 'ast_aapl',
      type: AssetType.stock,
      name: 'Apple Inc.',
      isin: 'US0378331005',
      ticker: 'AAPL',
      exchange: 'NASDAQ',
      currency: 'USD',
      sector: 'Technology',
      region: 'North America',
    ),
    startPrice: 195,
    yearReturn: 0.2,
    volatility: 0.25,
  ),
  _Seed(
    Asset(
      id: 'ast_msft',
      type: AssetType.stock,
      name: 'Microsoft Corp.',
      isin: 'US5949181045',
      ticker: 'MSFT',
      exchange: 'NASDAQ',
      currency: 'USD',
      sector: 'Technology',
      region: 'North America',
    ),
    startPrice: 410,
    yearReturn: 0.15,
    volatility: 0.22,
  ),
  _Seed(
    Asset(
      id: 'ast_nvda',
      type: AssetType.stock,
      name: 'NVIDIA Corp.',
      isin: 'US67066G1040',
      ticker: 'NVDA',
      exchange: 'NASDAQ',
      currency: 'USD',
      sector: 'Technology',
      region: 'North America',
    ),
    startPrice: 110,
    yearReturn: 0.6,
    volatility: 0.45,
  ),
  _Seed(
    Asset(
      id: 'ast_amzn',
      type: AssetType.stock,
      name: 'Amazon.com Inc.',
      isin: 'US0231351067',
      ticker: 'AMZN',
      exchange: 'NASDAQ',
      currency: 'USD',
      sector: 'Consumer discretionary',
      region: 'North America',
    ),
    startPrice: 182,
    yearReturn: 0.12,
    volatility: 0.3,
  ),
  _Seed(
    Asset(
      id: 'ast_googl',
      type: AssetType.stock,
      name: 'Alphabet Inc. Class A',
      isin: 'US02079K3059',
      ticker: 'GOOGL',
      exchange: 'NASDAQ',
      currency: 'USD',
      sector: 'Communication services',
      region: 'North America',
    ),
    startPrice: 165,
    yearReturn: 0.1,
    volatility: 0.28,
  ),
  _Seed(
    Asset(
      id: 'ast_tsla',
      type: AssetType.stock,
      name: 'Tesla Inc.',
      isin: 'US88160R1014',
      ticker: 'TSLA',
      exchange: 'NASDAQ',
      currency: 'USD',
      sector: 'Consumer discretionary',
      region: 'North America',
    ),
    startPrice: 240,
    yearReturn: -0.08,
    volatility: 0.55,
  ),
  _Seed(
    Asset(
      id: 'ast_eni',
      type: AssetType.stock,
      name: 'Eni S.p.A.',
      isin: 'IT0003132476',
      ticker: 'ENI',
      exchange: 'Borsa Italiana',
      currency: 'EUR',
      sector: 'Energy',
      region: 'Europe',
    ),
    startPrice: 14.8,
    yearReturn: -0.15,
    volatility: 0.2,
  ),
  _Seed(
    Asset(
      id: 'ast_enel',
      type: AssetType.stock,
      name: 'Enel S.p.A.',
      isin: 'IT0003128367',
      ticker: 'ENEL',
      exchange: 'Borsa Italiana',
      currency: 'EUR',
      sector: 'Utilities',
      region: 'Europe',
    ),
    startPrice: 6.7,
    yearReturn: 0.08,
    volatility: 0.18,
  ),
  _Seed(
    Asset(
      id: 'ast_isp',
      type: AssetType.stock,
      name: 'Intesa Sanpaolo S.p.A.',
      isin: 'IT0000072618',
      ticker: 'ISP',
      exchange: 'Borsa Italiana',
      currency: 'EUR',
      sector: 'Financials',
      region: 'Europe',
    ),
    startPrice: 3.6,
    yearReturn: 0.22,
    volatility: 0.24,
  ),
  _Seed(
    Asset(
      id: 'ast_race',
      type: AssetType.stock,
      name: 'Ferrari N.V.',
      isin: 'NL0011585146',
      ticker: 'RACE',
      exchange: 'Borsa Italiana',
      currency: 'EUR',
      sector: 'Consumer discretionary',
      region: 'Europe',
    ),
    startPrice: 395,
    yearReturn: 0.05,
    volatility: 0.22,
  ),
  _Seed(
    Asset(
      id: 'ast_asml',
      type: AssetType.stock,
      name: 'ASML Holding N.V.',
      isin: 'NL0010273215',
      ticker: 'ASML',
      exchange: 'Euronext Amsterdam',
      currency: 'EUR',
      sector: 'Technology',
      region: 'Europe',
    ),
    startPrice: 820,
    yearReturn: -0.05,
    volatility: 0.35,
  ),
  _Seed(
    Asset(
      id: 'ast_mc',
      type: AssetType.stock,
      name: 'LVMH Moët Hennessy Louis Vuitton SE',
      isin: 'FR0000121014',
      ticker: 'MC',
      exchange: 'Euronext Paris',
      currency: 'EUR',
      sector: 'Consumer discretionary',
      region: 'Europe',
    ),
    startPrice: 700,
    yearReturn: -0.07,
    volatility: 0.28,
  ),
  _Seed(
    Asset(
      id: 'ast_nesn',
      type: AssetType.stock,
      name: 'Nestlé S.A.',
      isin: 'CH0038863350',
      ticker: 'NESN',
      exchange: 'SIX Swiss Exchange',
      currency: 'CHF',
      sector: 'Consumer staples',
      region: 'Europe',
    ),
    startPrice: 92,
    yearReturn: -0.04,
    volatility: 0.16,
  ),
  _Seed(
    Asset(
      id: 'ast_ulvr',
      type: AssetType.stock,
      name: 'Unilever PLC',
      isin: 'GB00BVZK7T90',
      ticker: 'ULVR',
      exchange: 'London Stock Exchange',
      currency: 'GBP',
      sector: 'Consumer staples',
      region: 'Europe',
    ),
    startPrice: 44,
    yearReturn: 0.06,
    volatility: 0.16,
  ),
  // Bonds (prices as % of face value)
  _Seed(
    Asset(
      id: 'ast_btp_valore_27',
      type: AssetType.bond,
      name: 'BTP Valore Giugno 2027',
      isin: 'IT0005547408',
      ticker: 'BTPVAL27',
      exchange: 'Borsa Italiana MOT',
      currency: 'EUR',
    ),
    startPrice: 100.6,
    yearReturn: 0.015,
    volatility: 0.025,
  ),
  _Seed(
    Asset(
      id: 'ast_btp_italia_28',
      type: AssetType.bond,
      name: 'BTP Italia Novembre 2028',
      isin: 'IT0005517195',
      ticker: 'BTPIT28',
      exchange: 'Borsa Italiana MOT',
      currency: 'EUR',
    ),
    startPrice: 101.2,
    yearReturn: 0.02,
    volatility: 0.03,
  ),
];

final List<Asset> mockAssetCatalog = [for (final s in _seeds) s.asset];

/// One year of closing prices on trading days (Mon-Fri), oldest first,
/// ending on the last trading day up to [today].
Map<String, List<PricePoint>> buildPriceHistories(DateTime today) {
  final days = <DateTime>[
    for (
      var d = today.subtract(const Duration(days: 365));
      !d.isAfter(today);
      d = DateTime(d.year, d.month, d.day + 1)
    )
      if (isTradingDay(d)) d,
  ];
  return {
    for (final (i, seed) in _seeds.indexed)
      seed.asset.id: _randomWalk(seed, days, Random(1000 + i)),
  };
}

List<PricePoint> _randomWalk(_Seed seed, List<DateTime> days, Random random) {
  final dailyVol = seed.volatility / sqrt(252);
  final logs = <double>[log(seed.startPrice)];
  for (var i = 1; i < days.length; i++) {
    logs.add(logs.last + dailyVol * _gaussian(random));
  }
  // Bend the walk so it ends exactly at the target yearly return.
  final targetEnd = log(seed.startPrice * (1 + seed.yearReturn));
  final correction = targetEnd - logs.last;
  final decimals = seed.startPrice < 10 ? 3 : 2;
  final factor = pow(10, decimals);
  return [
    for (var i = 0; i < days.length; i++)
      PricePoint(
        date: days[i],
        price:
            (exp(logs[i] + correction * i / (days.length - 1)) * factor)
                .round() /
            factor,
      ),
  ];
}

/// Standard normal sample (Box-Muller).
double _gaussian(Random random) {
  final u1 = 1 - random.nextDouble();
  final u2 = random.nextDouble();
  return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
}
