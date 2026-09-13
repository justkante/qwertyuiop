import 'dart:developer';
import 'dart:io';

import 'package:creatify_mobile/core/utils/app_func_utils.dart';
import 'package:creatify_mobile/data/models/responses/conversation_message_dto.dart';
import 'package:dio/dio.dart';
import 'package:creatify_mobile/view/modules/chats/widgets/chat_input_field.dart';
import 'package:creatify_mobile/view/modules/chats/widgets/realtime_status_widget.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/cache_media_image_handler.dart';
import 'package:creatify_mobile/view/widgets/media_viewer/expanded_chat_media_view.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class MessageBubble extends StatelessWidget {
  final ConversationMessageDto message;
  final bool isMe;
  final String? currentUserId;
  final Function(String messageId, String newMessage)? onEdit;
  final VoidCallback? onMarkAsRead;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.currentUserId,
    this.onEdit,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildMessageContainer(context),
                if (message.createdAt != null) ...[
                  4.0.height,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.isEdited == true) ...[
                        Text(
                          '(Edited)',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: isMe ? AppColors.black2 : AppColors.black2,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        4.0.width,
                      ],
                      _buildTimestamp(context),
                      if (isMe) ...[
                        4.0.width,
                        // Show clock icon for pending messages
                        if (message.type == 'pending')
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.caption,
                          )
                        else if (message.readAt != null)
                          MessageStatusIndicator(
                            isSent: true,
                            isDelivered: true,
                            isRead: message.readAt != null,
                          )
                        else
                          MessageStatusIndicator(
                            isSent: message.id != null,
                            isDelivered: false,
                            isRead: false,
                          ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContainer(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMe ? 16 : 4),
            topRight: Radius.circular(isMe ? 0 : 16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
          border: !isMe ? Border.all(color: AppColors.grey100, width: 1) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.attachment != null) ...[
              _buildAttachment(context),
              if (message.message?.isNotEmpty == true) 8.0.height,
            ],
            // Always show message text OR a placeholder for attachment-only messages
            if (message.message?.isNotEmpty == true)
              Text(
                message.message ?? 'Loading...',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isMe ? Colors.white : AppColors.subHeading,
                  fontSize: 14,
                ),
              )
            else if (message.attachment == null)
              // Show loading indicator if no attachment and no message
              SizedBox(
                height: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.transparent,
                        ),
                        backgroundColor: isMe ? Colors.white : AppColors.primary,
                      ),
                    ),
                    8.0.width,
                    Text(
                      'Sending...',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: isMe ? Colors.white70 : AppColors.caption,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachment(BuildContext context) {
    final attachment = message.attachment;
    if (attachment == null) return const SizedBox.shrink();

    // Handle different file types
    if (attachment.mimeType?.startsWith('image/') == true) {
      return _buildImageAttachment(context, attachment);
    } else {
      return _buildFileAttachment(context, attachment);
    }

    //return _buildFileAttachment(context, attachment);
  }

  Widget _buildImageAttachment(BuildContext context, Attachment attachment) {
    // Don't allow opening/viewing pending attachments
    final isPending = message.type == 'pending';

    return InkWell(
      onTap: isPending
          ? null
          : () {
              showDialog(
                context: context,
                barrierColor: Colors.transparent,
                barrierDismissible: true,
                useSafeArea: false,
                builder: (context) => ExpandedChatMediaViewer(
                  attachment: attachment,
                  onClose: () => Navigator.of(context).pop(),
                ),
              );
            },
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 200,
          maxHeight: 200,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.grey200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: attachment.filePath != null
              ? Stack(
                  children: [
                    CachedMediaImageHandler(
                      imageUrl: attachment.filePath,
                    ),
                    if (isPending)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.3),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : Container(
                  height: 100,
                  color: AppColors.grey100,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                        8.0.height,
                        Text(
                          'Loading...',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.caption,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildFileAttachment(BuildContext context, Attachment attachment) {
    // Don't allow opening/viewing pending attachments
    final isPending = message.type == 'pending';

    return InkWell(
      onTap: isPending
          ? null
          : () {
              showDialog(
                context: context,
                barrierColor: Colors.transparent,
                barrierDismissible: true,
                useSafeArea: false,
                builder: (context) => ExpandedChatMediaViewer(
                  attachment: attachment,
                  onClose: () => Navigator.of(context).pop(),
                ),
              );
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withValues(alpha: 0.1) : AppColors.grey50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(
                  _getFileIcon(attachment.mimeType),
                  color: isMe ? Colors.white : AppColors.primary,
                  size: 48,
                ),
                if (isPending)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: (isMe ? Colors.white : AppColors.primary).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isMe ? Colors.white : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            8.0.height,
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    attachment.filePath != null
                        ? '${attachment.mimeType?.split('/').last.toUpperCase() ?? ''} File'
                        : 'Uploading...',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: isMe ? Colors.white : AppColors.subHeading,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (attachment.fileSizeMb != null)
                    Text(
                      '${attachment.fileSizeMb!.toStringAsFixed(2)} MB',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: isMe ? Colors.white70 : AppColors.caption,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;

    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.startsWith('video/')) return Icons.video_file;
    if (mimeType.startsWith('audio/')) return Icons.audio_file;
    if (mimeType.contains('pdf')) return Icons.description;
    if (mimeType.contains('document') || mimeType.contains('msword')) return Icons.description;
    if (mimeType.contains('spreadsheet') || mimeType.contains('excel')) return Icons.table_chart;
    if (mimeType.contains('presentation') || mimeType.contains('powerpoint')) {
      return Icons.slideshow;
    }

    return Icons.insert_drive_file;
  }

  Widget _buildTimestamp(BuildContext context) {
    if (message.createdAt == null) return const SizedBox.shrink();

    final timestamp = DateFormat('hh:mm a').format(message.createdAt!.toLocal());

    return Text(
      timestamp,
      style: context.textTheme.bodySmall?.copyWith(
        color: AppColors.caption,
        fontSize: 11,
      ),
    );
  }

  void _showMessageOptions(BuildContext context) async {
    // Don't allow options for pending messages
    if (message.type == 'pending') return;

    bool canEdit = isMe && message.isEditable == true && onEdit != null;
    bool otherUserHasAttachment = message.attachment != null && !isMe;
    bool meHasAttachment = message.attachment != null && isMe;

    await HapticFeedback.heavyImpact();

    if (!context.mounted) return;
    AppBottomSheet.showBottomSheet(
      context,
      widget: _MessageOptionsSheet(
        canEdit: canEdit,
        otherUserHasAttachment: otherUserHasAttachment,
        meHasAttachment: meHasAttachment,
        message: message,
        onEdit: onEdit!,
      ),
    );
  }
}

class _MessageOptionsSheet extends StatefulWidget {
  final ConversationMessageDto message;
  final bool canEdit, otherUserHasAttachment, meHasAttachment;
  final Function(String messageId, String newMessage) onEdit;

  const _MessageOptionsSheet({
    required this.message,
    required this.onEdit,
    this.canEdit = true,
    this.otherUserHasAttachment = false,
    this.meHasAttachment = false,
  });

  @override
  State<_MessageOptionsSheet> createState() => _MessageOptionsSheetState();
}

class _MessageOptionsSheetState extends State<_MessageOptionsSheet> {
  late TextEditingController _editController;
  bool _isEditing = false;

  // Track Downloads
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.message.message ?? '');
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _saveEdit() {
    final newMessage = _editController.text.trim();
    if (newMessage.isNotEmpty && newMessage != widget.message.message) {
      widget.onEdit(widget.message.id!, newMessage);
    }
    Navigator.of(context).pop();
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _editController.text = widget.message.message ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.grey300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        16.0.height,
        if (!_isEditing) ...[
          Text(
            'Message Options',
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          12.0.height,
          for (var options in [
            if (widget.canEdit) (Icons.edit_rounded, 'Edit Message', _startEditing),
            if (widget.otherUserHasAttachment || widget.meHasAttachment) ...[
              (
                Icons.download_rounded,
                'Download Attachment',
                () async {
                  setState(() {
                    isDownloading = true;
                  });

                  final attachment = widget.message.attachment;
                  final mimeType = attachment?.mimeType ?? '';
                  final fileUrl = attachment?.filePath ?? '';
                  final isImage = mimeType.startsWith('image/');
                  final isVideo = mimeType.startsWith('video/');
                  final isMediaFile = isImage || isVideo;

                  // Save images and videos to gallery/photos
                  if (isMediaFile) {
                    try {
                      bool? result;

                      if (isVideo) {
                        // For videos, save directly from URL
                        result = await GallerySaver.saveVideo(
                          fileUrl,
                          albumName: 'Creatify',
                        );
                      } else {
                        // For images, save directly from URL
                        result = await GallerySaver.saveImage(
                          fileUrl,
                          albumName: 'Creatify',
                        );
                      }

                      if (!context.mounted) return;
                      setState(() {
                        isDownloading = false;
                      });

                      context.pop();
                      if (result == true) {
                        ToastDialog.showSuccess(
                          '${isImage ? 'Image' : 'Video'} saved to Gallery',
                          context,
                        );
                      } else {
                        ToastDialog.showError('Download Failed', context);
                      }
                    } catch (error) {
                      if (!context.mounted) return;
                      setState(() {
                        isDownloading = false;
                      });

                      log(error.toString());
                      context.pop();
                      ToastDialog.showError('Download Failed', context);
                    }
                  } else {
                    // Save files and audio to Downloads (Android) or Files App (iOS)
                    if (Platform.isAndroid) {
                      FileDownloader.downloadFile(
                          url: fileUrl,
                          name:
                              'creatify_${widget.message.senderName?.toLowerCase().replaceAll(' ', '_')}_attachment',
                          onDownloadCompleted: (String path) {
                            if (!context.mounted) return;
                            setState(() {
                              isDownloading = false;
                            });

                            context.pop();
                            ToastDialog.showSuccess('File Downloaded to Downloads', context);
                          },
                          onDownloadError: (String error) {
                            if (!context.mounted) return;
                            setState(() {
                              isDownloading = false;
                            });

                            context.pop();
                            ToastDialog.showError('Download Failed', context);
                          });
                    } else {
                      // iOS: Download to temp directory and share to Files
                      try {
                        final directory = await getTemporaryDirectory();
                        final fileName = attachment?.fileName ??
                            'creatify_${widget.message.senderName?.toLowerCase().replaceAll(' ', '_')}_attachment.${attachment?.fileName?.split('.').last ?? 'file'}';
                        final filePath = '${directory.path}/$fileName';

                        await Dio().download(
                          fileUrl,
                          filePath,
                        );

                        if (!context.mounted) return;
                        setState(() {
                          isDownloading = false;
                        });

                        context.pop();

                        if (!context.mounted) return;

                        await AppUtils.shareFile(File(filePath), context);
                      } catch (error) {
                        if (!context.mounted) return;
                        setState(() {
                          isDownloading = false;
                        });

                        log(error.toString());
                        context.pop();
                        ToastDialog.showError('Download Failed', context);
                      }
                    }
                  }
                }
              )
            ] else ...[
              (
                Icons.copy_rounded,
                'Copy Message',
                () {
                  Clipboard.setData(ClipboardData(text: widget.message.message ?? ''));
                  Navigator.of(context).pop();
                  ToastDialog.showSuccess('Message Copied to Clipboard', context);
                },
              ),
            ],
          ])
            ListTile(
              leading: Icon(options.$1, color: AppColors.primary),
              title: Text(
                options.$2,
                style: context.textTheme.bodyMedium?.copyWith(color: AppColors.black2),
              ),
              onTap: options.$3,
              trailing: options.$1 == Icons.download && isDownloading
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
                  : null,
            ),
        ] else ...[
          Text(
            'Edit Message',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          16.0.height,
          ChatTextField(
            controller: _editController,
            autofocus: true,
          ),
          16.0.height,
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _cancelEdit,
                  child: Text(
                    'Cancel',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.highlightRed,
                    ),
                  ),
                ),
              ),
              16.0.width,
              Expanded(
                child: MainButton(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  text: 'Save',
                  onPressed: _saveEdit,
                ),
              ),
            ],
          ),
        ],
        10.0.height,
      ],
    );
  }
}
