import 'package:creatify_mobile/data/models/responses/creator_availabiity_dto.dart';
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
  final dynamic creatorProfile;
  final bool? isOnSiteBooking;
  const StateSheet({super.key, this.creatorProfile, this.isOnSiteBooking});

  @override
  ConsumerState<StateSheet> createState() => _BankSheetState();
}

class _BankSheetState extends ConsumerState<StateSheet> {
  final searchController = TextEditingController();

  String _searchQuery = '';

  static final List<StatesItemDto> _globalCitiesFallback = [
    // Nigeria
    StatesItemDto(id: 'Lagos, Nigeria', name: 'Lagos, Nigeria'),
    StatesItemDto(id: 'Abuja, Nigeria', name: 'Abuja, Nigeria'),
    StatesItemDto(id: 'Port Harcourt, Nigeria', name: 'Port Harcourt, Nigeria'),
    StatesItemDto(id: 'Ibadan, Nigeria', name: 'Ibadan, Nigeria'),
    StatesItemDto(id: 'Kano, Nigeria', name: 'Kano, Nigeria'),
    StatesItemDto(id: 'Enugu, Nigeria', name: 'Enugu, Nigeria'),
    StatesItemDto(id: 'Benin City, Nigeria', name: 'Benin City, Nigeria'),
    StatesItemDto(id: 'Kaduna, Nigeria', name: 'Kaduna, Nigeria'),
    StatesItemDto(id: 'Jos, Nigeria', name: 'Jos, Nigeria'),
    StatesItemDto(id: 'Ilorin, Nigeria', name: 'Ilorin, Nigeria'),
    StatesItemDto(id: 'Aba, Nigeria', name: 'Aba, Nigeria'),
    StatesItemDto(id: 'Onitsha, Nigeria', name: 'Onitsha, Nigeria'),
    StatesItemDto(id: 'Warri, Nigeria', name: 'Warri, Nigeria'),
    StatesItemDto(id: 'Calabar, Nigeria', name: 'Calabar, Nigeria'),
    StatesItemDto(id: 'Uyo, Nigeria', name: 'Uyo, Nigeria'),
    StatesItemDto(id: 'Abeokuta, Nigeria', name: 'Abeokuta, Nigeria'),
    StatesItemDto(id: 'Owerri, Nigeria', name: 'Owerri, Nigeria'),
    StatesItemDto(id: 'Asaba, Nigeria', name: 'Asaba, Nigeria'),
    StatesItemDto(id: 'Akure, Nigeria', name: 'Akure, Nigeria'),
    // United Kingdom (GB)
    StatesItemDto(id: 'London, United Kingdom', name: 'London, United Kingdom'),
    StatesItemDto(id: 'Manchester, United Kingdom', name: 'Manchester, United Kingdom'),
    StatesItemDto(id: 'Birmingham, United Kingdom', name: 'Birmingham, United Kingdom'),
    StatesItemDto(id: 'Edinburgh, United Kingdom', name: 'Edinburgh, United Kingdom'),
    StatesItemDto(id: 'Glasgow, United Kingdom', name: 'Glasgow, United Kingdom'),
    StatesItemDto(id: 'Cambridge, United Kingdom', name: 'Cambridge, United Kingdom'),
    StatesItemDto(id: 'Oxford, United Kingdom', name: 'Oxford, United Kingdom'),
    StatesItemDto(id: 'Bristol, United Kingdom', name: 'Bristol, United Kingdom'),
    StatesItemDto(id: 'Liverpool, United Kingdom', name: 'Liverpool, United Kingdom'),
    StatesItemDto(id: 'Leeds, United Kingdom', name: 'Leeds, United Kingdom'),
    StatesItemDto(id: 'Sheffield, United Kingdom', name: 'Sheffield, United Kingdom'),
    StatesItemDto(id: 'Cardiff, United Kingdom', name: 'Cardiff, United Kingdom'),
    StatesItemDto(id: 'Belfast, United Kingdom', name: 'Belfast, United Kingdom'),
    StatesItemDto(id: 'Newcastle, United Kingdom', name: 'Newcastle, United Kingdom'),
    // United States (US)
    StatesItemDto(id: 'New York, USA', name: 'New York, USA'),
    StatesItemDto(id: 'Los Angeles, USA', name: 'Los Angeles, USA'),
    StatesItemDto(id: 'Chicago, USA', name: 'Chicago, USA'),
    StatesItemDto(id: 'Houston, USA', name: 'Houston, USA'),
    StatesItemDto(id: 'Miami, USA', name: 'Miami, USA'),
    StatesItemDto(id: 'San Francisco, USA', name: 'San Francisco, USA'),
    StatesItemDto(id: 'Seattle, USA', name: 'Seattle, USA'),
    StatesItemDto(id: 'Boston, USA', name: 'Boston, USA'),
    StatesItemDto(id: 'Atlanta, USA', name: 'Atlanta, USA'),
    StatesItemDto(id: 'Austin, USA', name: 'Austin, USA'),
    StatesItemDto(id: 'Las Vegas, USA', name: 'Las Vegas, USA'),
    StatesItemDto(id: 'Washington D.C., USA', name: 'Washington D.C., USA'),
    // Canada (CA)
    StatesItemDto(id: 'Toronto, Canada', name: 'Toronto, Canada'),
    StatesItemDto(id: 'Vancouver, Canada', name: 'Vancouver, Canada'),
    StatesItemDto(id: 'Montreal, Canada', name: 'Montreal, Canada'),
    StatesItemDto(id: 'Calgary, Canada', name: 'Calgary, Canada'),
    StatesItemDto(id: 'Ottawa, Canada', name: 'Ottawa, Canada'),
    StatesItemDto(id: 'Edmonton, Canada', name: 'Edmonton, Canada'),
    // Ghana (GH)
    StatesItemDto(id: 'Accra, Ghana', name: 'Accra, Ghana'),
    StatesItemDto(id: 'Kumasi, Ghana', name: 'Kumasi, Ghana'),
    StatesItemDto(id: 'Tamale, Ghana', name: 'Tamale, Ghana'),
    StatesItemDto(id: 'Takoradi, Ghana', name: 'Takoradi, Ghana'),
    StatesItemDto(id: 'Tema, Ghana', name: 'Tema, Ghana'),
    // Kenya (KE)
    StatesItemDto(id: 'Nairobi, Kenya', name: 'Nairobi, Kenya'),
    StatesItemDto(id: 'Mombasa, Kenya', name: 'Mombasa, Kenya'),
    StatesItemDto(id: 'Kisumu, Kenya', name: 'Kisumu, Kenya'),
    StatesItemDto(id: 'Nakuru, Kenya', name: 'Nakuru, Kenya'),
    StatesItemDto(id: 'Eldoret, Kenya', name: 'Eldoret, Kenya'),
    // South Africa (ZA)
    StatesItemDto(id: 'Johannesburg, South Africa', name: 'Johannesburg, South Africa'),
    StatesItemDto(id: 'Cape Town, South Africa', name: 'Cape Town, South Africa'),
    StatesItemDto(id: 'Durban, South Africa', name: 'Durban, South Africa'),
    StatesItemDto(id: 'Pretoria, South Africa', name: 'Pretoria, South Africa'),
    StatesItemDto(id: 'Port Elizabeth, South Africa', name: 'Port Elizabeth, South Africa'),
    // Brazil (BR)
    StatesItemDto(id: 'São Paulo, Brazil', name: 'São Paulo, Brazil'),
    StatesItemDto(id: 'Rio de Janeiro, Brazil', name: 'Rio de Janeiro, Brazil'),
    StatesItemDto(id: 'Brasília, Brazil', name: 'Brasília, Brazil'),
    StatesItemDto(id: 'Salvador, Brazil', name: 'Salvador, Brazil'),
    StatesItemDto(id: 'Belo Horizonte, Brazil', name: 'Belo Horizonte, Brazil'),
    // Australia (AU)
    StatesItemDto(id: 'Sydney, Australia', name: 'Sydney, Australia'),
    StatesItemDto(id: 'Melbourne, Australia', name: 'Melbourne, Australia'),
    StatesItemDto(id: 'Brisbane, Australia', name: 'Brisbane, Australia'),
    StatesItemDto(id: 'Perth, Australia', name: 'Perth, Australia'),
    StatesItemDto(id: 'Adelaide, Australia', name: 'Adelaide, Australia'),
    // UAE (AE)
    StatesItemDto(id: 'Dubai, UAE', name: 'Dubai, UAE'),
    StatesItemDto(id: 'Abu Dhabi, UAE', name: 'Abu Dhabi, UAE'),
    StatesItemDto(id: 'Sharjah, UAE', name: 'Sharjah, UAE'),
    // Europe (FR, DE, IT, ES, NL, IE)
    StatesItemDto(id: 'Paris, France', name: 'Paris, France'),
    StatesItemDto(id: 'Berlin, Germany', name: 'Berlin, Germany'),
    StatesItemDto(id: 'Rome, Italy', name: 'Rome, Italy'),
    StatesItemDto(id: 'Madrid, Spain', name: 'Madrid, Spain'),
    StatesItemDto(id: 'Amsterdam, Netherlands', name: 'Amsterdam, Netherlands'),
    StatesItemDto(id: 'Dublin, Ireland', name: 'Dublin, Ireland'),
  ];

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

  @override
  Widget build(BuildContext context) {
    final getStatesList = ref.watch(fetchStatesProvider);

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
                  child: getStatesList.when(
                    data: (states) {
                      final combinedList = [...states, ..._globalCitiesFallback];
                      final uniqueMap = <String, StatesItemDto>{};
                      for (var item in combinedList) {
                        if (item.name != null && item.name!.isNotEmpty && item.name!.contains(',')) {
                          uniqueMap[item.name!.toLowerCase()] = item;
                        }
                      }
                      var filteredStates = uniqueMap.values
                          .where((state) => state.name != null && state.name!.contains(',') && state.name!.toLowerCase().contains(_searchQuery))
                          .toList();

                      // If booking is on-site, combine and restrict strictly to Recruiter country AND Creator country
                      if (widget.isOnSiteBooking == true && widget.creatorProfile != null) {
                        final creatorCountry = (widget.creatorProfile?.countryCode ?? '').toLowerCase();
                        final creatorProfileCurrency = (widget.creatorProfile?.primaryCurrency ?? '').toLowerCase();
                        
                        final userData = ref.watch(userControllerProvider);
                        final recruiterCountry = (userData.countryCode ?? '').toLowerCase();
                        final recruiterCurrency = (userData.primaryCurrency ?? '').toLowerCase();

                        filteredStates = filteredStates.where((s) {
                          final name = (s.name ?? '').toLowerCase();
                          
                          bool matchesCreator = (creatorCountry.isNotEmpty && name.contains(creatorCountry)) ||
                                                (creatorProfileCurrency.contains('gbp') && name.contains('united kingdom')) ||
                                                (creatorProfileCurrency.contains('usd') && (name.contains('usa') || name.contains('united states'))) ||
                                                (creatorProfileCurrency.contains('eur') && (name.contains('france') || name.contains('germany') || name.contains('italy') || name.contains('spain') || name.contains('netherlands') || name.contains('ireland'))) ||
                                                (creatorProfileCurrency.contains('cad') && name.contains('canada')) ||
                                                (creatorProfileCurrency.contains('ghs') && name.contains('ghana')) ||
                                                (creatorProfileCurrency.contains('kes') && name.contains('kenya')) ||
                                                (creatorProfileCurrency.contains('zar') && name.contains('south africa')) ||
                                                (creatorProfileCurrency.contains('ngn') && name.contains('nigeria'));

                          bool matchesRecruiter = (recruiterCountry.isNotEmpty && name.contains(recruiterCountry)) ||
                                                  (recruiterCurrency.contains('gbp') && name.contains('united kingdom')) ||
                                                  (recruiterCurrency.contains('usd') && (name.contains('usa') || name.contains('united states'))) ||
                                                  (recruiterCurrency.contains('eur') && (name.contains('france') || name.contains('germany') || name.contains('italy') || name.contains('spain') || name.contains('netherlands') || name.contains('ireland'))) ||
                                                  (recruiterCurrency.contains('cad') && name.contains('canada')) ||
                                                  (recruiterCurrency.contains('ghs') && name.contains('ghana')) ||
                                                  (recruiterCurrency.contains('kes') && name.contains('kenya')) ||
                                                  (recruiterCurrency.contains('zar') && name.contains('south africa')) ||
                                                  (recruiterCurrency.contains('ngn') && name.contains('nigeria'));

                          return matchesCreator || matchesRecruiter;
                        }).toList();
                      } else if (_searchQuery.isEmpty) {
                        filteredStates = filteredStates.where((s) {
                          final n = (s.name ?? '').toLowerCase();
                          return n.contains(',') && (n.contains('nigeria') || n.contains('united kingdom') || n.contains('usa') || n.contains('canada') || n.contains('ghana') || n.contains('kenya') || n.contains('south africa') || n.contains('dubai'));
                        }).toList();
                      }

                      filteredStates.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

                      return _buildStateList(filteredStates);
                    },
                    error: (_, __) => _buildStateList(
                      _globalCitiesFallback
                          .where((s) => s.name != null && s.name!.contains(',') && s.name!.toLowerCase().contains(_searchQuery))
                          .toList(),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                  ),
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
                    ? 'No matching locations found.'
                    : 'Search or type your city and country (e.g. Cambridge, United Kingdom)',
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

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              state.name ?? '',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.subHeading,
              ),
            ),
            onTap: () {
              context.pop(state);
            },
          );
        },
      ),
    );
  }
}
