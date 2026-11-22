class CurrencyConverter {
  // Exchange rates relative to 1 NGN (Naira = 1.0)
  // Represents how many NGN equals 1 unit of the foreign currency.
  static const Map<String, double> _ratesToNgn = {
    'ngn': 1.0,
    'usd': 1500.0,
    'gbp': 1900.0,
    'eur': 1600.0,
    'cad': 1100.0,
    'aud': 1000.0,
    'ghs': 95.0,
    'kes': 12.0,
    'zar': 85.0,
    'sgd': 1100.0,
    'aed': 400.0,
    'inr': 18.0,
  };

  /// Convert an amount from NGN (base) to target currency
  static double convertFromNgn(num amountInNgn, String targetCurrency) {
    final currencyKey = targetCurrency.toLowerCase();
    final rate = _ratesToNgn[currencyKey] ?? 1500.0;
    if (rate <= 0) return amountInNgn.toDouble();
    return amountInNgn / rate;
  }

  /// Convert an amount from source currency to NGN (base)
  static double convertToNgn(num amountInSourceCurrency, String sourceCurrency) {
    final currencyKey = sourceCurrency.toLowerCase();
    final rate = _ratesToNgn[currencyKey] ?? 1500.0;
    return amountInSourceCurrency * rate;
  }

  /// Get the equivalent of a base NGN amount (e.g. 1000 NGN) in the target currency
  static double getEquivalent(num amountInNgn, String targetCurrency) {
    if (targetCurrency.toLowerCase() == 'ngn') {
      return amountInNgn.toDouble();
    }
    return convertFromNgn(amountInNgn, targetCurrency);
  }
}
