import 'package:intl/intl.dart';

class CurrencyConverter {
  static const Map<String, double> ngnRates = {
    'ngn': 1.0,
    'usd': 0.00067568, // 1 USD = 1480 NGN
    'gbp': 0.00053191, // 1 GBP = 1880 NGN
    'eur': 0.00062500, // 1 EUR = 1600 NGN
    'cad': 0.00094340, // 1 CAD = 1060 NGN
    'aud': 0.00103093, // 1 AUD = 970 NGN
    'ghs': 0.00869565, // 1 GHS = 115 NGN
    'kes': 0.08695652, // 1 KES = 11.5 NGN
    'zar': 0.01219512, // 1 ZAR = 82 NGN
    'brl': 0.00384615, // 1 BRL = 260 NGN
    'mxn': 0.01388889, // 1 MXN = 72 NGN
    'sgd': 0.00090909, // 1 SGD = 1100 NGN
    'nzd': 0.00112360, // 1 NZD = 890 NGN
    'hkd': 0.00526316, // 1 HKD = 190 NGN
    'jpy': 0.10309278, // 1 JPY = 9.7 NGN
    'inr': 0.05714286, // 1 INR = 17.5 NGN
    'aed': 0.00248139, // 1 AED = 403 NGN
    'chf': 0.00059524, // 1 CHF = 1680 NGN
    'sek': 0.00704225, // 1 SEK = 142 NGN
    'nok': 0.00724638, // 1 NOK = 138 NGN
    'dkk': 0.00467290, // 1 DKK = 214 NGN
    'pln': 0.00270270, // 1 PLN = 370 NGN
    'xof': 0.40983607, // 1 XOF = 2.44 NGN
  };

  /// Convert amount from baseCurrency to targetCurrency
  static double convert(num amount, {required String from, required String to}) {
    final fromKey = from.toLowerCase();
    final toKey = to.toLowerCase();

    final fromRate = ngnRates[fromKey] ?? 1.0;
    final toRate = ngnRates[toKey] ?? 1.0;

    if (fromRate == 0) return amount.toDouble();
    final amountInNgn = amount / fromRate;
    return amountInNgn * toRate;
  }

  /// Convert NGN amount to target currency
  static double fromNgn(num amountInNgn, String targetCurrency) {
    final key = targetCurrency.toLowerCase();
    final rate = ngnRates[key] ?? 1.0;
    return (amountInNgn * rate).toDouble();
  }

  /// Alias for fromNgn to maintain backward compatibility across filter sheets
  static double getEquivalent(num amountInNgn, String targetCurrency) {
    return fromNgn(amountInNgn, targetCurrency);
  }

  /// Convert target currency amount back to NGN
  static double toNgn(num amountInTarget, String sourceCurrency) {
    final key = sourceCurrency.toLowerCase();
    final rate = ngnRates[key] ?? 1.0;
    if (rate == 0) return amountInTarget.toDouble();
    return (amountInTarget / rate).toDouble();
  }

  /// Format an NGN amount directly converted and symbol-formatted for target currency
  static String formatNgnAsCurrency(num amountInNgn, String targetCurrency) {
    final currencySymbols = {
      'ngn': '₦',
      'ghs': 'GH₵',
      'kes': 'KSh',
      'zar': 'R',
      'xof': 'CFA',
      'usd': '\$',
      'cad': 'CA\$',
      'mxn': '\$',
      'brl': 'R\$',
      'gbp': '£',
      'eur': '€',
      'sek': 'kr',
      'nok': 'kr',
      'dkk': 'kr',
      'bgn': 'лв',
      'czk': 'Kč',
      'gip': '£',
      'huf': 'Ft',
      'chf': 'Fr',
      'pln': 'zł',
      'ron': 'lei',
      'aud': 'A\$',
      'nzd': 'NZ\$',
      'sgd': 'S\$',
      'hkd': 'HK\$',
      'jpy': '¥',
      'inr': '₹',
      'idr': 'Rp',
      'myr': 'RM',
      'thb': '฿',
      'aed': 'AED',
    };

    final key = targetCurrency.toLowerCase();
    final symbol = currencySymbols[key] ?? '';
    final converted = fromNgn(amountInNgn, key);

    var formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: key == 'ngn' ? 0 : 2,
    );
    return formatter.format(converted);
  }
}
