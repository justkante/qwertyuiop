import 'dart:developer';
import 'dart:io';

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
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PortfolioUploadView extends ConsumerStatefulWidget {
  const PortfolioUploadView({super.key});

  @override
  ConsumerState<PortfolioUploadView> createState() => _PortfolioUploadViewState();
}

class _PortfolioUploadViewState extends ConsumerState<PortfolioUploadView> {
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
    final skipping = ref.watch(skipPortfolioProvider).isLoading;
    final deleting = ref.watch(deletePortfolioItemProvider).isLoading;

    ref.listen(skipPortfolioProvider, (_, value) {
      if (value is AsyncData) {
        Navigator.of(context).pop();
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

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
      absorbing: uploading || skipping || deleting,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (portfolioItems.hasValue &&
                portfolioItems.asData?.value.portfolioItems == null &&
                portfolioItems.asData!.value.portfolioItems!.isEmpty) ...[
              InkWell(
                onTap: () {
                  ref.read(skipPortfolioProvider.notifier).skipPortfolio();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.btnTertiary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Skip',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((uploading || skipping || deleting)) ...[
                const LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],
              14.0.height,

              // MARK: Title
              Row(
                children: [
                  Text(
                    'Portfolio Upload',
                    style: context.textTheme.headlineSmall?.copyWith(fontSize: 23),
                  ),
                  6.0.width,
                  SvgPicture.asset(
                    AppImages.suitcaseLine,
                    height: 20,
                    width: 20,
                  )
                ],
              ),
              6.0.height,
              Text(
                "Showcase your best work so recruiters can see your skills at a glance. Upload images, videos or documents by category",
                style: context.textTheme.bodySmall,
              ),
              21.0.height,

              Text(
                "Upload",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.subHeading,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              6.0.height,
              UploadMediaCard(
                isLoading: openingGallery,
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

                  if (portfolioItems.hasValue && portfolioItems.value?.totalCount == 9) {
                    ToastDialog.showError('You have uploaded the maximum number of files', context);
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
                          'file': await MultipartFile.fromFile(uploadFile.path),
                        },
                      );
                    }
                  }
                },
              ),
              24.0.height,

              // Uploaded Items in GridView
              portfolioItems.when(
                data: (items) {
                  if ((items.portfolioItems?.isEmpty ?? true)) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300, style: BorderStyle.solid),
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
                              ref.read(deletePortfolioItemProvider.notifier).deletePortfolioItem(
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
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            12.0.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ListenableBuilder(
                listenable: Listenable.merge([]),
                builder: (context, child) {
                  bool isValid = portfolioItems.hasValue &&
                      portfolioItems.asData?.value.portfolioItems != null &&
                      portfolioItems.asData!.value.portfolioItems!.isNotEmpty;
                  return MainButton(
                    text: 'Continue',
                    onPressed: isValid
                        ? () {
                            context.pop();
                          }
                        : null,
                  );
                },
              ),
            ),
            24.0.height,
          ],
        ),
      ),
    );
  }
}

class UploadItemSheet extends StatefulWidget {
  const UploadItemSheet({
    super.key,
  });

  @override
  State<UploadItemSheet> createState() => _UploadItemSheetState();
}

class _UploadItemSheetState extends State<UploadItemSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // MARK: Upload Item Title
        Text(
          'Upload Item',
          style: context.textTheme.headlineSmall?.copyWith(fontSize: 20),
        ),

        6.0.height,
        Text(
          "Choose the type of file you want to add to your portfolio",
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        32.0.height,
        ListView.separated(
          shrinkWrap: true,
          itemCount: const [
            'Image',
            'Video',
            'Others',
          ].length,
          separatorBuilder: (_, __) => 12.0.height,
          itemBuilder: (context, index) {
            final item = const [
              'Image',
              'Video',
              'Others',
            ][index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SvgPicture.asset(
                colorFilter: AppColors.black2.colorFilterMode(),
                item == 'Image'
                    ? AppImages.photo
                    : item == 'Video'
                        ? AppImages.video
                        : AppImages.document,
                height: 24,
                width: 24,
              ),
              title: Text(
                item,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.subHeading,
                ),
              ),
              trailing: const Icon(
                Icons.keyboard_arrow_right,
                color: AppColors.body,
                size: 24,
              ),
              onTap: () {
                context.pop(item);
              },
            );
          },
        ),
        24.0.height,
      ],
    );
  }
}
