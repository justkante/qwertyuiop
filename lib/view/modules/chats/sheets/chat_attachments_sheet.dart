import 'dart:developer';
import 'dart:io';

import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/responses/conversation_message_dto.dart';
import 'package:creatify_mobile/view/modules/chats/sheets/attachment_preview_sheet.dart';
import 'package:creatify_mobile/view/modules/chats/vm/chat_providers.dart';
import 'package:creatify_mobile/view/modules/chats/vm/conversation_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/file_and_image_picker.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChatAttachmentSheet extends ConsumerStatefulWidget {
  final bool isCreator;
  final String? conversationId, bookingId;
  const ChatAttachmentSheet({
    super.key,
    required this.isCreator,
    this.conversationId,
    this.bookingId,
  });

  @override
  ConsumerState<ChatAttachmentSheet> createState() => _ChatAttachmentSheetState();
}

class _ChatAttachmentSheetState extends ConsumerState<ChatAttachmentSheet> {
  // Selected attachment file
  File? _attachment;
  String? _attachmentType; // 'image', 'video', 'audio', 'file'

  // Loading states for each attachment type
  bool _isLoadingImage = false;
  bool _isLoadingVideo = false;
  bool _isLoadingAudio = false;
  bool _isLoadingFile = false;

  void _sendMessageWithAttachment() {
    if (_attachment == null || widget.conversationId == null) return;

    log('Sending message with attachment: ${_attachment!.path}');

    // Create a temporary pending message with attachment
    final pendingMessage = ConversationMessageDto(
      id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversationId!,
      senderId: SharedPrefManager.userId,
      senderName: 'You',
      message: '',
      createdAt: DateTime.now(),
      type: 'pending',
      attachment: Attachment(
        fileName: _attachment!.path.split('/').last,
        filePath: _attachment!.path,
        mimeType: _getMimeType(_attachmentType ?? 'file'),
      ),
    );

    // Add pending message to the list
    final currentPending = ref.read(pendingMessagesProvider(widget.conversationId!));
    ref.read(pendingMessagesProvider(widget.conversationId!).notifier).state = [
      ...currentPending,
      pendingMessage,
    ];

    // Close the preview
    context.pop();

    // Send the actual message
    ref.read(sendMessageWithAttachmentNotifier.notifier).sendMessageWithAttachment(
          conversationId: widget.conversationId!,
          message: '',
          filePath: _attachment!.path,
        );
  }

  String _getMimeType(String type) {
    switch (type) {
      case 'image':
        return 'image/jpeg';
      case 'video':
        return 'video/mp4';
      case 'audio':
        return 'audio/mpeg';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show preview if attachment is selected
    if (_attachment != null) {
      return AttachmentPreview(
        file: _attachment!,
        attachmentType: _attachmentType ?? 'file',
        onSend: _sendMessageWithAttachment,
        onCancel: () {
          setState(() {
            _attachment = null;
            _attachmentType = null;
          });
        },
      );
    }

    // Show attachment options
    return Column(
      spacing: 32,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        .0.height,
        AttachmentItem(
          icon: AppImages.photo,
          title: 'Add Image',
          isLoading: _isLoadingImage,
          onTap: () async {
            try {
              setState(() {
                _isLoadingImage = true;
              });

              final file = await pickImageFromGallery();

              if (file != null) {
                // Keep loading while processing the selection
                setState(() {
                  _attachment = file;
                  _attachmentType = 'image';
                });
              }
            } catch (e) {
              if (!context.mounted) return;
              ToastDialog.showError(e.toString(), context);
            } finally {
              if (mounted) {
                setState(() {
                  _isLoadingImage = false;
                });
              }
            }
          },
        ),
        AttachmentItem(
          icon: AppImages.video,
          title: 'Add Video',
          isLoading: _isLoadingVideo,
          onTap: () async {
            try {
              setState(() {
                _isLoadingVideo = true;
              });

              final file = await pickVideoFromGallery();

              if (file != null) {
                // Keep loading while processing the selection
                setState(() {
                  _attachment = file;
                  _attachmentType = 'video';
                });
              }
            } catch (e) {
              if (!context.mounted) return;
              ToastDialog.showError(e.toString(), context);
            } finally {
              if (mounted) {
                setState(() {
                  _isLoadingVideo = false;
                });
              }
            }
          },
        ),
        AttachmentItem(
          icon: AppImages.audio,
          title: 'Add Audio',
          isLoading: _isLoadingAudio,
          onTap: () async {
            try {
              setState(() {
                _isLoadingAudio = true;
              });

              final file = await pickAudioFromPlatform();

              if (file != null) {
                // Keep loading while processing the selection
                setState(() {
                  _attachment = file;
                  _attachmentType = 'audio';
                });
              }
            } catch (e) {
              if (!context.mounted) return;
              ToastDialog.showError(e.toString(), context);
            } finally {
              if (mounted) {
                setState(() {
                  _isLoadingAudio = false;
                });
              }
            }
          },
        ),
        AttachmentItem(
          icon: AppImages.document,
          title: 'Add File',
          isLoading: _isLoadingFile,
          onTap: () async {
            try {
              setState(() {
                _isLoadingFile = true;
              });

              final file = await pickFileFromPlatform();

              if (file != null) {
                // Keep loading while processing the selection
                setState(() {
                  _attachment = file;
                  _attachmentType = 'file';
                });
              }
            } catch (e) {
              if (!context.mounted) return;
              ToastDialog.showError(e.toString(), context);
            } finally {
              if (mounted) {
                setState(() {
                  _isLoadingFile = false;
                });
              }
            }
          },
        ),
        0.0.height,
      ],
    );
  }
}

class AttachmentItem extends StatelessWidget {
  final String title, icon;
  final Function()? onTap;
  final bool isLoading;
  const AttachmentItem({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            width: 24,
            height: 24,
            colorFilter: AppColors.black2.colorFilterMode(),
          ),
          12.0.width,
          Text(
            title,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.subHeading,
            ),
          ),
          const Spacer(),
          isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                )
              : SvgPicture.asset(
                  AppImages.chevronRight,
                  width: 24,
                  height: 24,
                )
        ],
      ),
    );
  }
}
