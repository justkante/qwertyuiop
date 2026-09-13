import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/responses/countries_dto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final getCountriesProvider = FutureProvider<List<CountriesItemDto>>((ref) async {
  final authRepo = ref.read(authRepository);
  return await authRepo.getCountries();
});
