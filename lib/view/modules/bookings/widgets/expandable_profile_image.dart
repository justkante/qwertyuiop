import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ExpandableProfileImage extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final double size;
  final Widget? initialsFallback;
  final Widget Function(BuildContext context, GestureTapCallback onTap)? customImageBuilder;
  final BoxDecoration? imageDecoration;

  const ExpandableProfileImage({
    super.key,
    required this.imageUrl,
    required this.initials,
    this.size = 72,
    this.initialsFallback,
    this.customImageBuilder,
    this.imageDecoration,
  });

  void _showExpandedImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Expanded Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) => loadingProgress == null
                      ? child
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                        ),
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.error_outline, color: Colors.red),
                    ),
                  ),
                ),
              ),
              // Close button
              Positioned(
                top: -20,
                right: -10,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      void onTap() => _showExpandedImage(context);

      // If custom builder is provided, use it
      if (customImageBuilder != null) {
        return customImageBuilder!(context, onTap);
      }

      return Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: imageDecoration ?? _buildDefaultDecoration(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) => loadingProgress == null
                    ? child
                    : Container(
                        width: size,
                        height: size,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                      ),
                errorBuilder: (context, error, stackTrace) => Container(
                  width: size,
                  height: size,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.error_outline, color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return initialsFallback ?? const SizedBox.shrink();
  }

  BoxDecoration _buildDefaultDecoration() {
    return const BoxDecoration();
  }
}
