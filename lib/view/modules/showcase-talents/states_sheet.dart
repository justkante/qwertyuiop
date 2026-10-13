import 'package:creatify_mobile/data/models/responses/creator_availabiity_dto.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/onboarding/widgets/search_input_field.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StateSheet extends ConsumerStatefulWidget {
  final CreatorProfileDto? creatorProfile;
  final bool isOnSiteBooking;
  const StateSheet({
    super.key,
    this.creatorProfile,
    this.isOnSiteBooking = false,
  });

  @override
  ConsumerState<StateSheet> createState() => _BankSheetState();
}

class _BankSheetState extends ConsumerState<StateSheet> {
  final searchController = TextEditingController();

  String _searchQuery = '';

  static final Map<String, List<StatesItemDto>> _countryCitiesMap = {
    // Nigeria (NG)
    'NG': [
      StatesItemDto(id: 'Lagos', name: 'Lagos'),
      StatesItemDto(id: 'Abuja', name: 'Abuja'),
      StatesItemDto(id: 'Port Harcourt', name: 'Port Harcourt'),
      StatesItemDto(id: 'Ibadan', name: 'Ibadan'),
      StatesItemDto(id: 'Kano', name: 'Kano'),
      StatesItemDto(id: 'Enugu', name: 'Enugu'),
      StatesItemDto(id: 'Benin City', name: 'Benin City'),
      StatesItemDto(id: 'Kaduna', name: 'Kaduna'),
      StatesItemDto(id: 'Aba', name: 'Aba'),
      StatesItemDto(id: 'Onitsha', name: 'Onitsha'),
      StatesItemDto(id: 'Calabar', name: 'Calabar'),
      StatesItemDto(id: 'Warri', name: 'Warri'),
      StatesItemDto(id: 'Abeokuta', name: 'Abeokuta'),
      StatesItemDto(id: 'Ilorin', name: 'Ilorin'),
      StatesItemDto(id: 'Jos', name: 'Jos'),
      StatesItemDto(id: 'Owerri', name: 'Owerri'),
      StatesItemDto(id: 'Uyo', name: 'Uyo'),
      StatesItemDto(id: 'Asaba', name: 'Asaba'),
      StatesItemDto(id: 'Akure', name: 'Akure'),
    ],

    // Brazil (BR)
    'BR': [
      StatesItemDto(id: 'São Paulo', name: 'São Paulo'),
      StatesItemDto(id: 'Rio de Janeiro', name: 'Rio de Janeiro'),
      StatesItemDto(id: 'Brasília', name: 'Brasília'),
      StatesItemDto(id: 'Salvador', name: 'Salvador'),
      StatesItemDto(id: 'Fortaleza', name: 'Fortaleza'),
      StatesItemDto(id: 'Belo Horizonte', name: 'Belo Horizonte'),
      StatesItemDto(id: 'Curitiba', name: 'Curitiba'),
      StatesItemDto(id: 'Manaus', name: 'Manaus'),
      StatesItemDto(id: 'Recife', name: 'Recife'),
      StatesItemDto(id: 'Porto Alegre', name: 'Porto Alegre'),
      StatesItemDto(id: 'Belém', name: 'Belém'),
      StatesItemDto(id: 'Goiânia', name: 'Goiânia'),
    ],

    // United States (US)
    'US': [
      StatesItemDto(id: 'New York', name: 'New York'),
      StatesItemDto(id: 'Los Angeles', name: 'Los Angeles'),
      StatesItemDto(id: 'Chicago', name: 'Chicago'),
      StatesItemDto(id: 'Houston', name: 'Houston'),
      StatesItemDto(id: 'Phoenix', name: 'Phoenix'),
      StatesItemDto(id: 'Philadelphia', name: 'Philadelphia'),
      StatesItemDto(id: 'San Antonio', name: 'San Antonio'),
      StatesItemDto(id: 'San Diego', name: 'San Diego'),
      StatesItemDto(id: 'Dallas', name: 'Dallas'),
      StatesItemDto(id: 'San Jose', name: 'San Jose'),
      StatesItemDto(id: 'Austin', name: 'Austin'),
      StatesItemDto(id: 'San Francisco', name: 'San Francisco'),
      StatesItemDto(id: 'Seattle', name: 'Seattle'),
      StatesItemDto(id: 'Denver', name: 'Denver'),
      StatesItemDto(id: 'Miami', name: 'Miami'),
      StatesItemDto(id: 'Atlanta', name: 'Atlanta'),
      StatesItemDto(id: 'Boston', name: 'Boston'),
      StatesItemDto(id: 'Las Vegas', name: 'Las Vegas'),
      StatesItemDto(id: 'Washington D.C.', name: 'Washington D.C.'),
    ],

    // United Kingdom (GB)
    'GB': [
      StatesItemDto(id: 'London', name: 'London'),
      StatesItemDto(id: 'Manchester', name: 'Manchester'),
      StatesItemDto(id: 'Birmingham', name: 'Birmingham'),
      StatesItemDto(id: 'Glasgow', name: 'Glasgow'),
      StatesItemDto(id: 'Leeds', name: 'Leeds'),
      StatesItemDto(id: 'Liverpool', name: 'Liverpool'),
      StatesItemDto(id: 'Edinburgh', name: 'Edinburgh'),
      StatesItemDto(id: 'Bristol', name: 'Bristol'),
      StatesItemDto(id: 'Belfast', name: 'Belfast'),
      StatesItemDto(id: 'Cardiff', name: 'Cardiff'),
    ],

    // Canada (CA)
    'CA': [
      StatesItemDto(id: 'Toronto', name: 'Toronto'),
      StatesItemDto(id: 'Vancouver', name: 'Vancouver'),
      StatesItemDto(id: 'Montreal', name: 'Montreal'),
      StatesItemDto(id: 'Calgary', name: 'Calgary'),
      StatesItemDto(id: 'Ottawa', name: 'Ottawa'),
      StatesItemDto(id: 'Edmonton', name: 'Edmonton'),
    ],

    // Australia (AU)
    'AU': [
      StatesItemDto(id: 'Sydney', name: 'Sydney'),
      StatesItemDto(id: 'Melbourne', name: 'Melbourne'),
      StatesItemDto(id: 'Brisbane', name: 'Brisbane'),
      StatesItemDto(id: 'Perth', name: 'Perth'),
      StatesItemDto(id: 'Adelaide', name: 'Adelaide'),
    ],

    // Germany (DE)
    'DE': [
      StatesItemDto(id: 'Berlin', name: 'Berlin'),
      StatesItemDto(id: 'Hamburg', name: 'Hamburg'),
      StatesItemDto(id: 'Munich', name: 'Munich'),
      StatesItemDto(id: 'Cologne', name: 'Cologne'),
      StatesItemDto(id: 'Frankfurt', name: 'Frankfurt'),
    ],

    // France (FR)
    'FR': [
      StatesItemDto(id: 'Paris', name: 'Paris'),
      StatesItemDto(id: 'Marseille', name: 'Marseille'),
      StatesItemDto(id: 'Lyon', name: 'Lyon'),
      StatesItemDto(id: 'Toulouse', name: 'Toulouse'),
      StatesItemDto(id: 'Nice', name: 'Nice'),
    ],

    // Spain (ES)
    'ES': [
      StatesItemDto(id: 'Madrid', name: 'Madrid'),
      StatesItemDto(id: 'Barcelona', name: 'Barcelona'),
      StatesItemDto(id: 'Valencia', name: 'Valencia'),
      StatesItemDto(id: 'Seville', name: 'Seville'),
    ],

    // Italy (IT)
    'IT': [
      StatesItemDto(id: 'Rome', name: 'Rome'),
      StatesItemDto(id: 'Milan', name: 'Milan'),
      StatesItemDto(id: 'Naples', name: 'Naples'),
      StatesItemDto(id: 'Turin', name: 'Turin'),
    ],

    // Japan (JP)
    'JP': [
      StatesItemDto(id: 'Tokyo', name: 'Tokyo'),
      StatesItemDto(id: 'Yokohama', name: 'Yokohama'),
      StatesItemDto(id: 'Osaka', name: 'Osaka'),
    ],

    // Mexico (MX)
    'MX': [
      StatesItemDto(id: 'Mexico City', name: 'Mexico City'),
      StatesItemDto(id: 'Guadalajara', name: 'Guadalajara'),
      StatesItemDto(id: 'Monterrey', name: 'Monterrey'),
    ],

    // Netherlands (NL)
    'NL': [
      StatesItemDto(id: 'Amsterdam', name: 'Amsterdam'),
      StatesItemDto(id: 'Rotterdam', name: 'Rotterdam'),
    ],

    // Singapore (SG)
    'SG': [
      StatesItemDto(id: 'Singapore', name: 'Singapore'),
    ],

    // UAE (AE)
    'AE': [
      StatesItemDto(id: 'Dubai', name: 'Dubai'),
      StatesItemDto(id: 'Abu Dhabi', name: 'Abu Dhabi'),
    ],

    // Ghana (GH)
    'GH': [
      StatesItemDto(id: 'Accra', name: 'Accra'),
      StatesItemDto(id: 'Kumasi', name: 'Kumasi'),
    ],

    // Kenya (KE)
    'KE': [
      StatesItemDto(id: 'Nairobi', name: 'Nairobi'),
      StatesItemDto(id: 'Mombasa', name: 'Mombasa'),
    ],

    // South Africa (ZA)
    'ZA': [
      StatesItemDto(id: 'Johannesburg', name: 'Johannesburg'),
      StatesItemDto(id: 'Cape Town', name: 'Cape Town'),
    ],
  };

  static const Map<String, String> _countryNames = {
    'NG': 'Nigeria',
    'BR': 'Brazil',
    'US': 'United States',
    'GB': 'United Kingdom',
    'CA': 'Canada',
    'AU': 'Australia',
    'DE': 'Germany',
    'FR': 'France',
    'ES': 'Spain',
    'IT': 'Italy',
    'JP': 'Japan',
    'MX': 'Mexico',
    'NL': 'Netherlands',
    'SG': 'Singapore',
    'AE': 'UAE',
    'GH': 'Ghana',
    'KE': 'Kenya',
    'ZA': 'South Africa',
  };

  String _getCountryName(String code) {
    return _countryNames[code.toUpperCase()] ?? code.toUpperCase();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = searchController.text.toLowerCase();
    });
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  String _cleanCityName(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    if (raw.contains(',')) {
      return raw.split(',').first.trim();
    }
    return raw.trim();
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final recruiterCountryCode = (userData.countryCode ?? 'NG').toUpperCase();

    List<StatesItemDto> countryStates = [];

    if (widget.isOnSiteBooking && widget.creatorProfile != null) {
      final creatorCountryCode = (widget.creatorProfile?.countryCode ?? recruiterCountryCode).toUpperCase();
      final isSameCountry = recruiterCountryCode == creatorCountryCode;

      final recruiterCities = _countryCitiesMap[recruiterCountryCode] ?? _countryCitiesMap['NG']!;
      final creatorCities = _countryCitiesMap[creatorCountryCode] ?? _countryCitiesMap['NG']!;

      final uniqueMap = <String, StatesItemDto>{};

      if (isSameCountry) {
        final combined = [...recruiterCities, ...creatorCities];
        if (widget.creatorProfile?.location != null && widget.creatorProfile!.location!.isNotEmpty) {
          combined.add(StatesItemDto(id: widget.creatorProfile!.location!, name: widget.creatorProfile!.location!));
        }
        for (var item in combined) {
          if (item.name != null && item.name!.isNotEmpty) {
            final cName = _cleanCityName(item.name);
            uniqueMap[cName.toLowerCase()] = StatesItemDto(id: cName, name: cName);
          }
        }
        countryStates = uniqueMap.values.toList();
      } else {
        final recruiterCountryName = _getCountryName(recruiterCountryCode);
        final creatorCountryName = _getCountryName(creatorCountryCode);

        for (var item in recruiterCities) {
          if (item.name != null && item.name!.isNotEmpty) {
            final cName = _cleanCityName(item.name);
            final displayName = '$cName, $recruiterCountryName';
            uniqueMap[displayName.toLowerCase()] = StatesItemDto(id: displayName, name: displayName);
          }
        }

        for (var item in creatorCities) {
          if (item.name != null && item.name!.isNotEmpty) {
            final cName = _cleanCityName(item.name);
            final displayName = '$cName, $creatorCountryName';
            uniqueMap[displayName.toLowerCase()] = StatesItemDto(id: displayName, name: displayName);
          }
        }

        if (widget.creatorProfile?.location != null && widget.creatorProfile!.location!.isNotEmpty) {
          final loc = _cleanCityName(widget.creatorProfile!.location!);
          final displayName = loc.contains(',') ? loc : '$loc, $creatorCountryName';
          uniqueMap[displayName.toLowerCase()] = StatesItemDto(id: displayName, name: displayName);
        }

        countryStates = uniqueMap.values.toList();
      }
    } else {
      final defaultCities = _countryCitiesMap[recruiterCountryCode] ?? _countryCitiesMap['NG']!;
      final uniqueMap = <String, StatesItemDto>{};
      for (var item in defaultCities) {
        if (item.name != null && item.name!.isNotEmpty) {
          final cName = _cleanCityName(item.name);
          uniqueMap[cName.toLowerCase()] = StatesItemDto(id: cName, name: cName);
        }
      }
      countryStates = uniqueMap.values.toList();
    }

    if (_searchQuery.isNotEmpty) {
      countryStates = countryStates
          .where((state) => (state.name ?? '').toLowerCase().contains(_searchQuery))
          .toList();
    }

    countryStates.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          12.0.height,

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose a Location',
                style: context.textTheme.headlineSmall?.copyWith(fontSize: 18),
              ),
              6.0.width,
              SvgPicture.asset(
                AppImages.bank,
                width: 24,
                height: 24,
              ),
            ],
          ),

          20.0.height,
          Expanded(
            child: Column(
              children: [
                // Search Field
                SearchTextInputField(
                  hintText: 'Search location',
                  controller: searchController,
                ),
                12.0.height,
                Expanded(
                  child: _buildStateList(countryStates),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateList(List<StatesItemDto> filteredStates) {
    final customName = searchController.text.trim();

    if (filteredStates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_city_outlined, size: 44, color: AppColors.body),
              12.0.height,
              Text(
                customName.isNotEmpty
                    ? 'No matching predefined states.'
                    : 'Search or type your city or state',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1B3131)),
              ),
              16.0.height,
              if (customName.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () {
                    context.pop(StatesItemDto(name: customName, id: customName));
                  },
                  icon: const Icon(Icons.check, size: 18, color: Colors.white),
                  label: Text('Select "$customName"', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Scrollbar(
      interactive: true,
      thickness: 2,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: filteredStates.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.grey100),
        itemBuilder: (context, index) {
          final state = filteredStates[index];
          final displayName = _cleanCityName(state.name);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              displayName,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.subHeading,
              ),
            ),
            onTap: () {
              context.pop(StatesItemDto(id: displayName, name: displayName));
            },
          );
        },
      ),
    );
  }
}
