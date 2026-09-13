import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

// Constants for file size limits
const int _maxImageSizeBytes = 10 * 1024 * 1024; // 5MB
const int _maxVideoSizeBytes = 20 * 1024 * 1024; // 20MB
const int _maxChatVideoSizeBytes = 10 * 1024 * 1024; // 10MB

/// Validates file size based on type
void _validateFileSize(File file, bool isVideo, {bool isChat = false}) {
  final fileSizeBytes = file.lengthSync();
  final maxSizeBytes = (isVideo && isChat)
      ? _maxChatVideoSizeBytes
      : isVideo
          ? _maxVideoSizeBytes
          : _maxImageSizeBytes;
  final maxSizeMB = (isVideo && isChat)
      ? 10
      : isVideo
          ? 20
          : 10;

  log('File size: ${(fileSizeBytes / 1024 / 1024).toStringAsFixed(2)}MB bytes, Max allowed: ${(maxSizeBytes / 1024 / 1024).toStringAsFixed(2)}MB bytes');

  if (fileSizeBytes > maxSizeBytes) {
    throw 'File size exceeds the maximum allowed limit of ${maxSizeMB}MB. Current file size: ${(fileSizeBytes / 1024 / 1024).toStringAsFixed(2)}MB';
  }
}

Future<XFile> getCompressedFile(XFile originalFile) async {
  final String extension = originalFile.path.split('.').last.toLowerCase();

  // Video formats
  if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
    return await _compressVideo(originalFile);
  }

  // Image formats
  if (['jpg', 'jpeg', 'png', 'heic', 'webp'].contains(extension)) {
    return await _compressImage(originalFile);
  }

  // Fallback: return original (rare)
  return originalFile;
}

Future<XFile> _compressVideo(XFile file) async {
  // This shows a nice progress dialog on screen automatically on iOS/Android
  final MediaInfo? info = await VideoCompress.compressVideo(
    file.path,
    quality: VideoQuality.MediumQuality, // ← crucial! Default is Highest
    deleteOrigin: false, // keep original
    includeAudio: true,
  );

  if (info == null || info.path == null) {
    throw Exception("Video compression failed");
  }

  // Usually reduces 100 MB → 8–15 MB while still looking great
  log("Original: ${(await file.length()) / 1024 / 1024} MB");
  log("Compressed: ${info.filesize! / 1024 / 1024} MB");

  return XFile(info.path!);
}

Future<XFile> _compressImage(XFile file) async {
  final bytes = await file.readAsBytes();

  final compressed = await FlutterImageCompress.compressWithList(
    bytes,
    minHeight: 1920,
    minWidth: 1080,
    quality: 85,
    format: CompressFormat.jpeg,
  );

  final dir = await getTemporaryDirectory();
  final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final compressedFile = await File(targetPath).writeAsBytes(compressed);

  return XFile(compressedFile.path);
}

/// Select/Upload an Image from Device Gallery
Future<File?> pickImageFromGallery() async {
  try {
    final returnImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) {
      return null;
    }

    final compressedImage = await getCompressedFile(returnImage);

    File imagePath = File(compressedImage.path);
    _validateFileSize(imagePath, false);
    return imagePath;
  } catch (e) {
    throw e.toString().contains('exceeds limit')
        ? 'File exceeds the limit size'
        : e.toString().contains('Cannot load representation')
            ? "Image did not load properly. Please try again."
            : e.toString();
  }
}

/// Select/Upload an Image Using Device Camera
Future<File?> pickImageFromCamera({CameraDevice? cameraSide}) async {
  try {
    final returnImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: cameraSide ?? CameraDevice.rear,
    );
    if (returnImage == null) {
      return null;
    }

    File imagePath = File(returnImage.path);
    _validateFileSize(imagePath, false);
    return imagePath;
  } catch (e) {
    throw e.toString().contains('exceeds limit') ? 'File exceeds the limit size' : e.toString();
  }
}

/// Select/Upload a File From Target Platform Files
Future<File?> pickFileFromPlatform() async {
  try {
    File? docFile;

    final result = await FilePicker.platform.pickFiles(
      withData: true,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'mp3', 'wav', 'm4a', 'aac'],
      type: FileType.custom,
    );
    if (result == null) {
      return null;
    }

    docFile = File(result.files.single.path ?? '');
    _validateFileSize(docFile, false);
    return docFile;
  } catch (e) {
    throw e.toString();
  }
}

/// Select/Upload an Audio From Target Platform Files
Future<File?> pickAudioFromPlatform() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac'],
      type: FileType.custom,
    );
    if (result == null) {
      return null;
    }

    File docFile = File(result.files.single.path ?? '');
    _validateFileSize(docFile, false);
    return docFile;
  } catch (e) {
    throw e.toString();
  }
}

Future<File?> pickVideoFromGallery({bool isChat = false}) async {
  try {
    final returnVideo = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 10),
    );
    if (returnVideo == null) {
      return null;
    }

    final compressedImage = await getCompressedFile(returnVideo);

    File videoPath = File(compressedImage.path);

    _validateFileSize(
      videoPath,
      true,
      isChat: isChat,
    );
    return videoPath;
  } catch (e) {
    log(e.toString());
    throw e.toString().contains('exceeds limit')
        ? 'File exceeds the limit size'
        : e.toString().contains('Cannot load representation')
            ? "Video did not load properly. Please try again."
            : e.toString();
  }
}

Future<File?> pickVideoFromFile() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      allowedExtensions: ['mp4', 'avi'],
      type: FileType.custom,
    );
    if (result == null) {
      return null;
    }

    File videoFile = File(result.files.single.path ?? '');
    _validateFileSize(videoFile, true);
    return videoFile;
  } catch (e) {
    throw e.toString();
  }
}
