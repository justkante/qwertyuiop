import 'dart:developer';
import 'dart:io';

import 'package:creatify_mobile/view/modules/showcase-talents/portfolio_upload_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/portfolio_vm.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/widgets/upload_card.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/widgets/uploaded_image_with_cancel.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/file_and_image_picker.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/linear_loading.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AdjustPortfolioSheet extends ConsumerStatefulWidget {
  const AdjustPortfolioSheet({super.key});

  @override
  ConsumerState<AdjustPortfolioSheet> createState() => _AdjustPortfolioSheetState();
}

class _AdjustPortfolioSheetState extends ConsumerState<AdjustPortfolioSheet> {
  final selectedType = TextEditingController();

  String? uploadFilePath;
  bool openingGallery = false;

  @override
  void dispose() {
    selectedType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolioItems = ref.watch(fetchPortfolioProvider);
    final uploading = ref.watch(uploadToPortfolioProvider).isLoading;
    final deleting = ref.watch(deletePortfolioItemProvider).isLoading;

    ref.listen(uploadToPortfolioProvider, (_, value) {
      if (value is AsyncData) {
        ToastDialog.showSuccess('Portfolio Item Uploaded Successfully', context);
        setState(() {
          // Clear the selected file path after successful upload
          uploadFilePath = null;
          selectedType.clear();
        });
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    ref.listen(deletePortfolioItemProvider, (_, value) {
      if (value is AsyncData) {
        ToastDialog.showSuccess('Portfolio Item Deleted Successfully', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: uploading || deleting,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            LineLoadingIndicator(loading: uploading || deleting),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    12.0.height,
                    // MARK: Title
                    Row(
                      children: [
                        Text(
                          'Adjust Portfolio',
                          style: context.textTheme.headlineSmall?.copyWith(fontSize: 23),
                        ),
                        6.0.width,
                        SvgPicture.asset(
                          AppImages.suitcaseLine,
                        )
                      ],
                    ),
                    6.0.height,
                    Text(
                      "Showcase your best work so recruiters can see your skills at a glance. Upload images, videos or documents by category",
                      style: context.textTheme.bodySmall,
                    ),
                    21.0.height,

                    // // Form
                    // TextInputField(
                    //   controller: selectedType,
                    //   header: 'Select Type',
                    //   hint: 'Select Type',
                    //   inputType: TextInputType.text,
                    //   readOnly: true,
                    //   suffixIcon: const Icon(
                    //     Icons.keyboard_arrow_down,
                    //     color: AppColors.body,
                    //     size: 18,
                    //   ),
                    //   onPressed: () async {
                    //     final result = await AppBottomSheet.showBottomSheet(
                    //       context,
                    //       widget: const UploadItemSheet(),
                    //     );

                    //     if (result != null) {
                    //       selectedType.text = result;
                    //     }
                    //   },
                    //   validator: null,
                    // ),
                    // 16.0.height,

                    Text(
                      "Upload",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppColors.subHeading,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    6.0.height,

                    GestureDetector(
                      onTap: () async {
                        final result = await AppBottomSheet.showBottomSheet(
                          context,
                          widget: const UploadItemSheet(),
                        );

                        if (result != null) {
                          selectedType.text = result;
                        }

                        // Pick file based on selected type
                        File? uploadFile;

                        if (!context.mounted) return;

                        if (portfolioItems.hasValue && (portfolioItems.value?.totalCount ?? 0) >= 9) {
                          ToastDialog.showError(
                              'You have uploaded the maximum number of files (9)', context);
                        } else {
                          setState(() {
                            openingGallery = true;
                          });

                          try {
                            // Handle file picking based on selected type
                            switch (selectedType.text) {
                              case 'Image':
                                uploadFile = await pickImageFromGallery();
                                setState(() {
                                  uploadFilePath = uploadFile?.path;
                                });
                                break;
                              case 'Video':
                                uploadFile = await pickVideoFromGallery();
                                setState(() {
                                  uploadFilePath = uploadFile?.path;
                                });
                                break;
                              case 'Others':
                                uploadFile = await pickFileFromPlatform();
                                setState(() {
                                  uploadFilePath = uploadFile?.path;
                                });
                                break;
                            }
                          } catch (e) {
                            log(e.toString());
                            if (!context.mounted) return;
                            ToastDialog.showError('Failed to pick file: $e', context);
                          } finally {
                            setState(() {
                              openingGallery = false;
                            });
                          }

                          if (uploadFile != null) {
                            // Upload the file to portfolio
                            await ref.read(uploadToPortfolioProvider.notifier).uploadToPortfolio(
                              {
                                'file': await MultipartFile.fromFile(
                                  uploadFile.path,
                                  filename: uploadFile.path.split('/').last,
                                ),
                              },
                            );
                          }
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2), style: BorderStyle.solid),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              child: const Icon(Icons.add, color: Colors.white, size: 24),
                            ),
                            12.0.height,
                            const Text('Click here to upload', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            const Text('Images, Videos or Documents (Max 9)', style: TextStyle(fontSize: 10, color: AppColors.body)),
                          ],
                        ),
                      ),
                    ),
                    24.0.height,

                    // Uploaded Items in GridView
                    portfolioItems.when(
                      data: (items) {
                        if ((items.portfolioItems?.isEmpty ?? true)) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: AppColors.grey300, style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(16),
                              color: AppColors.grey50,
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(AppImages.report),
                                12.0.width,
                                Expanded(
                                  child: Text(
                                    'No portfolio items uploaded yet. Upload items to showcase your work.',
                                    style: context.textTheme.bodySmall?.copyWith(
                                      color: AppColors.body,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            0.0.height,
                            Text(
                              "Uploaded Files (${items.totalCount ?? 0}/9)",
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: AppColors.subHeading,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            10.0.height,
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: items.portfolioItems?.length,
                              itemBuilder: (context, index) {
                                final item = items.portfolioItems?[index];
                                return UploadedImageWithDelete(
                                  portfolioItem: item,
                                  expandMedia: true,
                                  onDelete: () {
                                    ref
                                        .read(deletePortfolioItemProvider.notifier)
                                        .deletePortfolioItem(
                                          item?.id ?? '',
                                        );
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                      error: (error, stackTrace) => Text(error.toString()),
                      loading: () => Center(
                        child: CircularProgressIndicator.adaptive(
                          constraints: BoxConstraints.tight(const Size(16, 16)),
                          padding: const EdgeInsets.all(12.0),
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    24.0.height,
                  ],
                ),
              ),
            ),
            12.0.height,
            MainButton(
              text: 'Continue',
              width: 180, // Reduced size as requested
              onPressed: () {
                context.pop();
              },
            ),
            12.0.height,
          ],
        ),
      ),
    );
  }
}
