import 'dart:io';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/edit_profile_image_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ImagePreviewScreen extends ConsumerStatefulWidget {
  final File imageFile;
  final String fileName;

  static const routeName = 'image-preview-view';

  const ImagePreviewScreen({
    super.key,
    required this.imageFile,
    required this.fileName,
  });

  @override
  ConsumerState<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends ConsumerState<ImagePreviewScreen> {
  @override
  Widget build(BuildContext context) {
    final editingProfileImage = ref.watch(editProfileImageProvider).isLoading;

    ref.listen(editProfileImageProvider, (_, value) {
      if (value is AsyncData) {
        context.pop();
        ToastDialog.showSuccess('Profile Image Updated', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: editingProfileImage,
      child: Scaffold(
        backgroundColor: AppColors.black2,
        appBar: AppBar(
          backgroundColor: AppColors.black2,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              context.pop();
            },
            child: const Icon(
              Icons.close,
              size: 24,
              color: AppColors.grey50,
            ),
          ),
          title: Text(
            'Upload Image',
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.grey50,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              12.0.height,
              // Main content - Image preview
              Expanded(
                child: Image.file(
                  widget.imageFile,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

              // Bottom actions
            ],
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              color: AppColors.black2,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  // Upload button
                  MainButton(
                    text: 'Upload',
                    isLoading: editingProfileImage,
                    onPressed: () {
                      ref.read(editProfileImageProvider.notifier).editProfileImage(widget.imageFile.path);
                    },
                  ).animate().fadeIn(delay: 600.ms).slideY(delay: 600.ms),
                  24.0.height,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
