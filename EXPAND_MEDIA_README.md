# Media Viewer Widget

A comprehensive media viewer system for displaying images, videos, audio files, and documents in a full-screen overlay with blur and darkened background.

## Features

- **Image Viewer**: Interactive image viewing with pinch-to-zoom support
- **Video Player**: Video playback with play/pause controls and progress bar
- **Audio Player**: Audio playback with seek controls and time display
- **Document Viewer**: PDF and document viewing using Google Docs Viewer
- **Responsive Design**: Adapts to different screen sizes
- **Blur Background**: Beautiful darkened and blurred background
- **Close Button**: Easy-to-use close button in the top-right corner

## Components

### 1. ExpandedMediaViewer
Main widget that handles all media types and displays them in a full-screen overlay.

### 2. VideoPlayerWidget
Handles video playback with controls.

### 3. AudioPlayerWidget
Displays audio files with playback controls and progress tracking.

### 4. DocumentViewerWidget
Renders documents (PDFs) using WebView and Google Docs Viewer.

## Usage

### Basic Usage

```dart
import 'package:creatify_mobile/view/widgets/media_viewer/expanded_media_viewer.dart';

// In your widget
void _showMediaViewer(BuildContext context, PortfolioItem item) {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    useSafeArea: false,
    builder: (context) => ExpandedMediaViewer(
      portfolioItem: item,
      onClose: () => Navigator.of(context).pop(),
    ),
  );
}
```

### Integration with UploadedImageWithDelete

The `UploadedImageWithDelete` widget has been updated to support expandable media:

```dart
UploadedImageWithDelete(
  portfolioItem: portfolioItem,
  expandMedia: true, // Enable click-to-expand
  onDelete: () {
    // Handle deletion
  },
)
```

## Media Type Detection

The viewer automatically detects media types based on:
1. Portfolio item's `mediaType` property
2. File extension (for audio files)
3. MIME type (as fallback)

### Supported Formats

#### Images
- All formats supported by Flutter's Image.network

#### Videos
- Currently shows a placeholder with play button
- For production: Install `video_player` or `chewie` package

#### Audio
- .mp3, .wav, .m4a, .aac, .ogg, .flac
- For production: Install `audioplayers` or `just_audio` package

#### Documents
- PDF files using Google Docs Viewer
- For better PDF viewing: Install `flutter_pdfview` or `pdfx` package

## Production Recommendations

### For Video Support
```yaml
dependencies:
  video_player: ^2.8.1
  # or
  chewie: ^1.7.4
```

### For Audio Support
```yaml
dependencies:
  audioplayers: ^5.2.1
  # or
  just_audio: ^0.9.36
```

### For Better PDF Viewing
```yaml
dependencies:
  flutter_pdfview: ^1.3.2
  # or
  pdfx: ^2.6.0
```

## Customization

### Changing Background Opacity

In `expanded_media_viewer.dart`, modify:
```dart
Container(
  color: Colors.black.withValues(alpha: 0.85), // Change this value
  ...
)
```

### Changing Close Button Style

In `_buildTopBar` method:
```dart
Container(
  padding: const EdgeInsets.all(8), // Adjust padding
  decoration: BoxDecoration(
    color: Colors.white.withValues(alpha: 0.2), // Change color
    shape: BoxShape.circle,
    ...
  ),
  ...
)
```

## Design System Compliance

This widget system follows the app's design system:
- Uses `AppColors` constants for consistent theming
- Applies `context.textTheme` for typography
- Uses extension methods like `.height` and `.width` for spacing
- Follows the QuickIcon pattern for icon containers
- Maintains consistent border radius (12px) throughout

## Error Handling

All viewers include error states:
- **Images**: Shows broken image icon with error message
- **Videos**: Shows error state with retry option (when implemented)
- **Audio**: Displays error message and file info
- **Documents**: Shows fallback UI with download option

## Accessibility

- All interactive elements have proper tap targets (minimum 48x48)
- Text contrast meets WCAG standards
- Icons include semantic meaning
- Loading states provide visual feedback

## Performance Considerations

- Images use `InteractiveViewer` for smooth zooming
- Loading indicators prevent blank states
- Network images show loading progress
- Large media files are handled gracefully

## Future Enhancements

1. Download functionality for all media types
2. Share media capability
3. Fullscreen video mode
4. Video quality selection
5. Audio playlist support
6. Document page navigation
7. Bookmark/favorite media
8. Media metadata display
