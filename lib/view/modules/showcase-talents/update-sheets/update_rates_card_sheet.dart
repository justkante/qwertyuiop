import 'dart:developer';

import 'package:creatify_mobile/data/models/requests/rates_card_req.dart';
import 'package:creatify_mobile/data/models/requests/save_payout_details_req.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart' as creator;
import 'package:creatify_mobile/data/models/responses/niche_item_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/creator_niches_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/rate_card_vm.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_dropdown.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/thousands_formatter.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class UpdateRatesCardSheet extends ConsumerStatefulWidget {
  final List<creator.Category> exisitingNiches;
  const UpdateRatesCardSheet({super.key, required this.exisitingNiches});

  @override
  ConsumerState<UpdateRatesCardSheet> createState() => _UpdateRatesCardSheetState();
}

class _UpdateRatesCardSheetState extends ConsumerState<UpdateRatesCardSheet> {
  final GlobalKey<State> _pricingTypeKey = GlobalKey<FormState>();

  final creatorNiche = TextEditingController();
  final pricingType = TextEditingController();
  final serviceName = TextEditingController();
  final servicePrice = TextEditingController();

  NicheItemDto? selectedNiche;
  List<CreatorCategory> selectedCreatorNiches = [];

  // To store niche ID to name mapping
  Map<String, String> nicheNamesMap = {};

  // Filled Categoty Virtual Rate Card List
  List<Category>? categories = [];

  // List to store services for the current niche being entered
  List<Service> currentServices = [];

  // Track which niche is being edited (null means adding new, index means editing existing)
  int? editingNicheIndex;

  @override
  void initState() {
    super.initState();
    _prefillExistingNiches();
  }

  void _prefillExistingNiches() {
    // Convert existing niches to the format used in the form
    for (var existingNiche in widget.exisitingNiches) {
      // Store the niche name for display
      if (existingNiche.id != null && existingNiche.name != null) {
        nicheNamesMap[existingNiche.id!] = existingNiche.name!;
      }

      // Get the pricing type from the first service (all services in a category should have the same pricing type)
      final pricingType = existingNiche.services?.firstOrNull?.pricingType;

      // Convert the services from creator.Service to Service
      final services = existingNiche.services
              ?.map((service) => Service(
                    serviceName: service.serviceName,
                    price: service.price,
                  ))
              .toList() ??
          [];

      // Add to categories list
      categories!.add(
        Category(
          categoryId: existingNiche.id,
          pricingType: pricingType,
          services: services,
        ),
      );
    }
  }

  @override
  void dispose() {
    creatorNiche.dispose();
    pricingType.dispose();
    serviceName.dispose();
    servicePrice.dispose();
    super.dispose();
  }

  // Check if current niche entry is complete (has niche, pricing type, and at least 1 2service)
  bool isCurrentNicheComplete() {
    // When editing, we already have a category ID, so just check other fields
    if (editingNicheIndex != null) {
      return pricingType.text.isNotEmpty && currentServices.isNotEmpty;
    }
    // When adding new, need to have selected a niche
    return selectedNiche != null && pricingType.text.isNotEmpty && currentServices.isNotEmpty;
  }

  // Check if current service fields are filled
  bool isCurrentServiceValid() {
    return serviceName.text.trim().isNotEmpty &&
        servicePrice.text.trim().isNotEmpty &&
        num.tryParse(servicePrice.text.removeCommas()) != null &&
        num.parse(servicePrice.text.removeCommas()) >= 1 &&
        num.parse(servicePrice.text.removeCommas()) <= 10000000;
  }

  // Check if we can add another service (max 3 per niche)
  bool canAddAnotherService() {
    return currentServices.length < 3;
  }

  // Get service name validation error
  String? getServiceNameError() {
    if (serviceName.text.isEmpty) return null;
    if (serviceName.text.trim().isEmpty) {
      return 'Service name is required';
    }
    return null;
  }

  // Get service price validation error
  String? getServicePriceError() {
    final text = servicePrice.text.removeCommas();
    log(text);

    if (text.isEmpty) return null;

    final price = num.tryParse(text);
    if (price == null) {
      return 'Please enter a valid number';
    }
    if (price > 0 && price < 500) {
      return 'Price must be at least ${1.amountWithCurrency(ref.watch(userControllerProvider).primaryCurrency ?? '')}';
    }
    if (price > 10000000) {
      return 'Price cannot exceed ${10000000.amountWithCurrency(ref.watch(userControllerProvider).primaryCurrency ?? '')}';
    }
    return null;
  }

  // Add current service to the list
  void addService() {
    if (!isCurrentServiceValid()) {
      ToastDialog.showError('Please enter valid service name and price', context);
      return;
    }

    if (!canAddAnotherService()) {
      ToastDialog.showError('Maximum 3 services per niche', context);
      return;
    }

    setState(() {
      currentServices.add(
        Service(
          serviceName: serviceName.text.trim(),
          price: num.parse(servicePrice.text.removeCommas()),
        ),
      );
      // Clear service fields
      serviceName.clear();
      servicePrice.clear();
    });
  }

  // Remove a service from current services
  void removeService(int index) {
    setState(() {
      currentServices.removeAt(index);
    });
  }

  // Add current niche to categories list or update existing
  void addNiche() {
    if (!isCurrentNicheComplete()) {
      ToastDialog.showError(
        'Please complete the current niche (select niche, pricing type, and add at least 1 service)',
        context,
      );
      return;
    }

    if (editingNicheIndex == null && categories!.length >= 5) {
      ToastDialog.showError('Maximum 5 niches allowed', context);
      return;
    }

    setState(() {
      final category = Category(
        categoryId: editingNicheIndex != null
            ? categories![editingNicheIndex!].categoryId // Use existing categoryId when editing
            : selectedNiche!.id, // Use new selected niche when adding
        pricingType: pricingType.text.addUnderscoreLowercase(),
        services: List.from(currentServices),
      );

      if (editingNicheIndex != null) {
        // Update existing niche
        categories![editingNicheIndex!] = category;
      } else {
        // Add new niche
        categories!.add(category);
        // Store the niche name for display
        nicheNamesMap[selectedNiche!.id!] = selectedNiche!.name ?? '';
      }

      // Clear all fields for next niche
      editingNicheIndex = null;
      selectedNiche = null;
      creatorNiche.clear();
      pricingType.clear();
      currentServices.clear();
      serviceName.clear();
      servicePrice.clear();
    });
  }

  // Remove a niche from categories
  void removeNiche(int index) {
    setState(() {
      // If currently editing this niche, clear the form
      if (editingNicheIndex == index) {
        editingNicheIndex = null;
        selectedNiche = null;
        creatorNiche.clear();
        pricingType.clear();
        currentServices.clear();
        serviceName.clear();
        servicePrice.clear();
      } else if (editingNicheIndex != null && editingNicheIndex! > index) {
        // Adjust editing index if removing a niche before it
        editingNicheIndex = editingNicheIndex! - 1;
      }
      categories!.removeAt(index);
    });
  }

  // Edit an existing niche
  void editNiche(int index) {
    final category = categories![index];
    setState(() {
      editingNicheIndex = index;
      // Don't allow changing the niche itself, just show the name
      creatorNiche.text = nicheNamesMap[category.categoryId] ?? '';
      // Set pricing type (convert from snake_case to display format)
      final pricingTypeDisplay = category.pricingType
          ?.replaceAll('_', ' ')
          .split(' ')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
      pricingType.text = pricingTypeDisplay ?? '';
      // Load services
      currentServices = List.from(category.services ?? []);
      // Clear service input fields
      serviceName.clear();
      servicePrice.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final savingRateCard = ref.watch(saveVirtualRateCardProvider).isLoading;
    final userData = ref.watch(userControllerProvider);

    ref.listen(saveVirtualRateCardProvider, (_, value) {
      if (value is AsyncData<String>) {
        Navigator.of(context).pop(true);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: savingRateCard,
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              12.0.height,
              Row(
                children: [
                  Text(
                    'Virtual Rates Card',
                    style: context.textTheme.headlineSmall?.copyWith(fontSize: 23),
                  ),
                  6.0.width,
                  SvgPicture.asset(
                    AppImages.clipboard,
                    width: 24,
                    height: 24,
                  )
                ],
              ),
              6.0.height,
              Text(
                "Set your rates for each niche. This ensures recruiters set accurate pricing.",
                style: context.textTheme.bodySmall,
              ),
              21.0.height,

              // MARK: Rate Cards List
              // Creator Niche
              TextInputField(
                header: "Creator Niche",
                controller: creatorNiche,
                hint: "Select Niche",
                inputType: TextInputType.text,
                onPressed: editingNicheIndex == null
                    ? () async {
                        // final excludedIds = selectedCreatorNiches
                        //     .map((category) => category.categoryId)
                        //     .where((id) => id != null)
                        //     .cast<String>()
                        //     .toList();

                        final niche = await AppBottomSheet.showBottomSheet(
                          context,
                          widget: const CreatorNicheSheet(),
                        ) as NicheItemDto?;

                        if (niche != null) {
                          setState(() {
                            selectedNiche = niche;
                            creatorNiche.text = niche.name ?? '';
                          });
                        }
                      }
                    : null,
                readOnly: true,
                suffixIcon: editingNicheIndex == null
                    ? const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.body,
                        size: 18,
                      )
                    : null,
                validator: null,
              ),
              12.0.height,

              // Pricing Type
              TextInputField(
                key: _pricingTypeKey,
                header: 'Pricing Type',
                controller: pricingType,
                hint: 'Select Pricing Type',
                inputType: TextInputType.text,
                onPressed: () async {
                  await platformSpecificDropdown(
                    context: context,
                    items: [
                      'Per Hour',
                      'Per Day',
                      'Per Session',
                      'Per Event',
                      'Per Project',
                      'Per Deliverable',
                      'Per Package'
                    ],
                    value: pricingType.text,
                    onChanged: (value) {
                      setState(() {
                        pricingType.text = value ?? '';
                      });
                    },
                    key: _pricingTypeKey,
                  );
                },
                readOnly: true,
                suffixIcon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.body,
                  size: 18,
                ),
                validator: null,
              ),
              12.0.height,

              // Service Name and Price (Max of 3)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextInputField(
                              header: 'Service Name',
                              controller: serviceName,
                              textCapitalization: TextCapitalization.sentences,
                              hint: 'Enter',
                              inputType: TextInputType.text,
                              validator: null,
                            ),
                            ListenableBuilder(
                              listenable: serviceName,
                              builder: (context, child) {
                                final error = getServiceNameError();
                                if (error == null) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    error,
                                    style: context.textTheme.bodySmall?.copyWith(
                                      color: AppColors.kErrorColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      12.0.width,
                      Expanded(
                        child: TextInputField(
                          header: 'Service Price',
                          controller: servicePrice,
                          hint: '0.00',
                          inputType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                            LengthLimitingTextInputFormatter(17),
                            ThousandsFormatter(
                              allowFraction: true,
                              formatter: NumberFormat.decimalPattern(),
                            ),
                          ],
                          validator: null,
                        ),
                      ),
                    ],
                  ),
                  ListenableBuilder(
                    listenable: servicePrice,
                    builder: (context, child) {
                      final error = getServicePriceError();
                      if (error == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          error,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.kErrorColor,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              12.0.height,

              // Add Service Button
              if (currentServices.length < 3)
                ListenableBuilder(
                    listenable: Listenable.merge([
                      serviceName,
                      servicePrice,
                    ]),
                    builder: (context, child) {
                      return InkWell(
                        onTap: isCurrentServiceValid() ? addService : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: isCurrentServiceValid()
                                ? AppColors.highlightCoral
                                : AppColors.btnInactive,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add,
                                color: isCurrentServiceValid() ? Colors.white : AppColors.body,
                                size: 14,
                              ),
                              4.0.width,
                              Text(
                                "Add Service (${currentServices.length}/3)",
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: isCurrentServiceValid() ? Colors.white : AppColors.body,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              12.0.height,

              // Display current services
              if (currentServices.isNotEmpty)
                ...currentServices.asMap().entries.map((entry) {
                  final index = entry.key;
                  final service = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.grey150,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.serviceName ?? '',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                2.0.height,
                                Text(
                                  service.price
                                          ?.amountWithCurrency(userData.primaryCurrency ?? '') ??
                                      "0",
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.spot500,
                                    fontFamily: FontFamily.inter,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => removeService(index),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              // Display added niches
              if (categories!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Added Niches (${categories!.length}/5)',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    12.0.height,
                    ...categories!.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      final nicheName = nicheNamesMap[category.categoryId] ?? 'Unknown';
                      final isBeingEdited = editingNicheIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => editNiche(index),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isBeingEdited ? AppColors.highlightCoral : AppColors.grey150,
                                width: isBeingEdited ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: isBeingEdited
                                  ? AppColors.highlightCoral.withValues(alpha: .05)
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  nicheName,
                                                  style: context.textTheme.bodyMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: isBeingEdited
                                                        ? AppColors.highlightCoral
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                              if (isBeingEdited)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.highlightCoral,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    'Editing',
                                                    style: context.textTheme.bodySmall?.copyWith(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          1.0.height,
                                          Text(
                                            category.pricingType?.removeUnderscoreLowercase() ?? '',
                                            style: context.textTheme.bodySmall?.copyWith(
                                              color: AppColors.subHeading,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () => removeNiche(index),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                ...?category.services?.map((service) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          size: 6,
                                          color: AppColors.body,
                                        ),
                                        8.0.width,
                                        Expanded(
                                          child: Text(
                                            service.serviceName ?? '',
                                            style: context.textTheme.bodySmall,
                                          ),
                                        ),
                                        Text(
                                          service.price?.amountWithCurrency(
                                                  userData.primaryCurrency ?? '') ??
                                              "0",
                                          style: context.textTheme.bodySmall?.copyWith(
                                            color: AppColors.spot500,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: FontFamily.inter,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              if (categories!.isNotEmpty && editingNicheIndex == null) 8.0.height,

              12.0.height,

              // Add Another Niche Button (only show if less than 5 niches or editing)
              if (editingNicheIndex != null || categories!.length < 5)
                InkWell(
                  onTap: isCurrentNicheComplete() ? addNiche : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCurrentNicheComplete()
                          ? AppColors.highlightCoral
                          : AppColors.btnInactive,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          editingNicheIndex != null ? Icons.check : Icons.add,
                          color: isCurrentNicheComplete() ? Colors.white : AppColors.body,
                          size: 14,
                        ),
                        4.0.width,
                        Text(
                          editingNicheIndex != null
                              ? "Update Niche"
                              : "Add Another Niche (${categories!.length}/5)",
                          style: context.textTheme.bodySmall?.copyWith(
                            color: isCurrentNicheComplete() ? Colors.white : AppColors.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              24.0.height,
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListenableBuilder(
                listenable: Listenable.merge([
                  creatorNiche,
                  pricingType,
                  serviceName,
                  servicePrice,
                ]),
                builder: (context, child) {
                  // Enable button if:
                  // 1. At least one complete niche has been added to categories, OR
                  // 2. Current niche being entered is complete
                  final isValid = categories!.isNotEmpty || isCurrentNicheComplete();

                  return MainButton(
                    text: 'Save & Continue',
                    isLoading: savingRateCard,
                    onPressed: isValid
                        ? () {
                            // If there's a complete current niche that hasn't been added, add it first
                            if (isCurrentNicheComplete()) {
                              addNiche();
                            }

                            // Ensure we have at least one category before saving
                            if (categories!.isNotEmpty) {
                              ref.read(saveVirtualRateCardProvider.notifier).createVirtualRateCard(
                                    RatesCardReq(
                                      categories: categories,
                                    ),
                                  );
                            }
                          }
                        : null,
                  );
                },
              ),
              24.0.height,
            ],
          ),
        ),
      ),
    );
  }
}
