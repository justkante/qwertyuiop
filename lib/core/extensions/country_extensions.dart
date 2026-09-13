import 'dart:convert';

import 'package:flutter/services.dart';

Future<List<Map<String, dynamic>>>? _countriesCache;
List<Map<String, dynamic>>? _countriesDataCache;

Future<List<Map<String, dynamic>>> loadCountriesFromAsset() async {
  _countriesCache ??= _loadCountriesFromAsset();
  return _countriesCache!;
}

Future<List<Map<String, dynamic>>> _loadCountriesFromAsset() async {
  final jsonString = await rootBundle.loadString('assets/countries.json');
  final decoded = json.decode(jsonString) as List<dynamic>;
  final countries = decoded.cast<Map<String, dynamic>>();

  _countriesDataCache = countries;
  return countries;
}

Future<Map<String, dynamic>?> countryFromCode(String code) async {
  final countries = await loadCountriesFromAsset();
  final normalizedCode = code.trim().toUpperCase();

  for (final country in countries) {
    if ((country['code'] as String?)?.trim().toUpperCase() == normalizedCode) {
      return country;
    }
  }

  return null;
}

extension CountryJsonListLookup on List<Map<String, dynamic>> {
  Map<String, dynamic>? countryForCode(String code) {
    final normalizedCode = code.trim().toUpperCase();

    for (final country in this) {
      if ((country['code'] as String?)?.trim().toUpperCase() == normalizedCode) {
        return country;
      }
    }

    return null;
  }

  String? flagForCode(String code) => countryForCode(code)?['flag'] as String?;
}

extension CountryCodeLookup on String {
  Future<String?> flagFromCode() async {
    return (await countryFromCode(this))?['flag'] as String?;
  }

  String flagFromCodeSync() {
    _loadCountriesFromAsset();
    final countries = _countriesDataCache;
    if (countries == null) {
      return '';
    }

    final normalizedCode = trim().toUpperCase();

    for (final country in countries) {
      if ((country['code'] as String?)?.trim().toUpperCase() == normalizedCode) {
        return (country['flag'] as String?) ?? '';
      }
    }

    return '';
  }
}
