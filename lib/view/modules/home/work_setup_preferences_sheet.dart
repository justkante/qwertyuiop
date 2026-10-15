import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/requests/update_availability_req.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/update_availability_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WorkSetupPreferencesSheet extends ConsumerStatefulWidget {
  const WorkSetupPreferencesSheet({super.key});

  @override
  ConsumerState<WorkSetupPreferencesSheet> createState() => _WorkSetupPreferencesSheetState();
}

class _WorkSetupPreferencesSheetState extends ConsumerState<WorkSetupPreferencesSheet> {
  Set<String> selectedWorkModes = {};
  bool _initialized = false;

  static final List<String> kWorkSetupOptions = [
    'On-site',
    'Remote',
    'Hybrid',
    'Project-based',
    'Long-term',
    'Flexible',
    'Part-time',
  ];

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      final savedWorkSetup = SharedPrefManager.recruiterWorkSetup;
      if (savedWorkSetup.isNotEmpty) {
        selectedWorkModes = savedWorkSetup.toSet();
      } else {
        selectedWorkModes = {'On-site', 'Remote', 'Project-based', 'Long-term'};
      }
      _initialized = true;
    }

    final updatingAvailability = ref.watch(updateAvailabilityProvider).isLoading;

    return AbsorbPointer(
      absorbing: updatingAvailability,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            12.0.height,

            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Work Setup',
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black2,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.grey100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.body,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            6.0.height,
            Text(
              'Select how you prefer to work with talent.',
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.body,
                fontSize: 12,
              ),
            ),
            20.0.height,

            // Options list
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kWorkSetupOptions.map((option) {
                    final isSelected = selectedWorkModes.contains(option);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedWorkModes.remove(option);
                          } else {
                            selectedWorkModes.add(option);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.grey300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              const Icon(Icons.check, size: 14, color: Colors.white),
                              6.0.width,
                            ] else ...[
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: AppColors.grey400),
                                ),
                              ),
                              8.0.width,
                            ],
                            Text(
                              option,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: isSelected ? Colors.white : AppColors.subHeading,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            16.0.height,

            // Save button
            MainButton(
              color: AppColors.primary,
              isLoading: updatingAvailability,
              text: 'Save ${selectedWorkModes.length} selections',
              onPressed: () {
                SharedPrefManager.recruiterWorkSetup = selectedWorkModes.toList();
                if (selectedWorkModes.isNotEmpty) {
                  ref.read(updateAvailabilityProvider.notifier).updateAvailability(
                    UpdateAvailabilityReq(workMode: selectedWorkModes.first.toLowerCase()),
                  );
                }
                ToastDialog.showSuccess('Work Setup updated successfully', context);
                Navigator.of(context).pop(true);
              },
            ),
            16.0.height,
          ],
        ),
      ),
    );
  }
}
