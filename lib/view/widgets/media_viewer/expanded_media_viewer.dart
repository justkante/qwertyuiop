import 'dart:ui';
import 'package:creatify_mobile/data/models/responses/portfolio_dto.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/widgets/media_viewer/widgets/audio_player_widget.dart';
import 'package:creatify_mobile/view/widgets/media_viewer/widgets/document_viewer_widget.dart';
import 'package:creatify_mobile/view/widgets/media_viewer/widgets/video_player_widget.dart';
import 'package:flutter/material.dart';

/// A comprehensive media viewer that displays images, videos, audio, and documents
/// in a full-screen overlay with blur and darkened background
class ExpandedMediaViewer extends StatelessWidget {
  final PortfolioItem portfolioItem;
  final VoidCallback onClose;

  const ExpandedMediaViewer({
    super.key,
    required this.portfolioItem,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Darkened and blurred background
          GestureDetector(
            onTap: onClose,
            child: Container(
              color: Colors.black.withOpacity(0.85),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
          ),

          // Media content
          SafeArea(
            child: Column(
              children: [
                // Top bar with close button
                _buildTopBar(context),

                // Media content
                Expanded(
                  child: Center(
                    child: _buildMediaContent(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Filename (if available)
          if (portfolioItem.fileName != null)
            Expanded(
              child: Text(
                switch (portfolioItem.mediaType) {
                  MediaType.image => 'Portfolio Image',
                  MediaType.video => 'Portfolio Video',
                  MediaType.document => portfolioItem.fileName!,
                  MediaType.audio => portfolioItem.fileName!,
                  _ => 'File',
                },
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),

          const SizedBox(width: 16),

          // Close button
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent(BuildContext context) {
    switch (portfolioItem.mediaType) {
      case MediaType.image:
        return _buildImageViewer(context);
      case MediaType.video:
        return _buildVideoViewer(context);
      case MediaType.document:
        return _buildDocumentViewer(context);
      case MediaType.audio:
        return _buildDocumentViewer(context);
      default:
        return _buildUnsupportedMedia(context);
    }
  }

  Widget _buildImageViewer(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            portfolioItem.filePath ?? '',
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load image',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVideoViewer(BuildContext context) {
    return VideoPlayerWidget(
      videoUrl: portfolioItem.filePath ?? '',
    );
  }

  Widget _buildDocumentViewer(BuildContext context) {
    // Determine if it's audio or document based on extension
    final fileName = portfolioItem.fileName?.toLowerCase() ?? '';
    final mimeType = portfolioItem.mimeType?.toLowerCase() ?? '';

    // Check for audio files
    if (_isAudioFile(fileName, mimeType)) {
      return AudioPlayerWidget(
        audioUrl: portfolioItem.filePath ?? '',
        fileName: portfolioItem.fileName ?? 'Audio File',
      );
    }

    // Otherwise, treat as document
    return DocumentViewerWidget(
      documentUrl: portfolioItem.filePath ?? '',
      fileName: portfolioItem.fileName ?? 'Document',
      mimeType: portfolioItem.mimeType,
    );
  }

  bool _isAudioFile(String fileName, String mimeType) {
    // Check by extension
    final audioExtensions = ['.mp3', '.wav', '.m4a', '.aac', '.ogg', '.flac'];
    final hasAudioExtension = audioExtensions.any((ext) => fileName.endsWith(ext));

    // Check by mime type
    final isAudioMimeType = mimeType.startsWith('audio/');

    return hasAudioExtension || isAudioMimeType;
  }

  Widget _buildUnsupportedMedia(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Unsupported media type',
            style: context.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This media format is not supported',
            style: context.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
