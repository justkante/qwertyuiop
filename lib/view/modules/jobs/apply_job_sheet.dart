import 'dart:io';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/responses/job_dto.dart';
import 'package:creatify_mobile/view/modules/jobs/vm/job_controller.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../bookings/fetched_recruiter_profile_view.dart';
import 'application_success_view.dart';

class ApplyJobSheet extends ConsumerStatefulWidget {
  final JobDto? job;
  const ApplyJobSheet({super.key, this.job});

  @override
  ConsumerState<ApplyJobSheet> createState() => _ApplyJobSheetState();
}

class _ApplyJobSheetState extends ConsumerState<ApplyJobSheet> {
  final _pitchController = TextEditingController();
  final _portfolioController = TextEditingController();
  File? _resumeFile;
  bool _isSubmitting = false;

  Future<void> _pickResume() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _resumeFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        ToastDialog.showError('Failed to pick file: $e', context);
      }
    }
  }

  @override
  void dispose() {
    _pitchController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 24),
              Text(
                'Job Application',
                style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Center(
            child: Text(
              'Applying for: ${widget.job?.title ?? "Job"}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.body,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          24.0.height,

          Text('Pitch yourself', style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          8.0.height,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey100)),
            child: TextField(
              controller: _pitchController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'State why you are the best fit for the job',
                hintStyle: TextStyle(fontSize: 12, color: AppColors.body),
                border: InputBorder.none,
              ),
            ),
          ),
          16.0.height,

          Text('Portfolio link (if any)', style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          8.0.height,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey100)),
            child: TextField(
              controller: _portfolioController,
              decoration: const InputDecoration(
                hintText: 'www.yourportfolio.com',
                hintStyle: TextStyle(fontSize: 12, color: AppColors.body),
                border: InputBorder.none,
              ),
            ),
          ),
          16.0.height,

          Text('Add CV or Resume (Optional)', style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          8.0.height,
          InkWell(
            onTap: _pickResume,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF009688), style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  if (_resumeFile != null) ...[
                    const Icon(Icons.description, color: Color(0xFF009688), size: 32),
                    8.0.height,
                    Text(
                      _resumeFile!.path.split('/').last,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFF009688), shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                  ],
                ],
              ),
            ),
          ),
          32.0.height,

          MainButton(
            text: 'Submit application',
            isLoading: _isSubmitting,
            onPressed: () async {
              if (widget.job?.id == null) return;

              if (_pitchController.text.trim().isEmpty) {
                ToastDialog.showError('Please pitch yourself before submitting', context);
                return;
              }

              setState(() => _isSubmitting = true);
              try {
                final Map<String, dynamic> data = {
                  'pitch': _pitchController.text,
                  'portfolio_link': _portfolioController.text,
                };

                if (_resumeFile != null) {
                  // If we had a dedicated upload service, we'd use it here.
                  // For now, we'll let the backend handle it or add it later if the API is updated to multipart.
                  // data['attachments'] = [_resumeFile!.path];
                }

                final error = await ref.read(jobControllerProvider.notifier).applyToJob(widget.job!.id!, data);

                if (error == null) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    context.push(const ApplicationSuccessView());
                  }
                } else {
                  if (context.mounted) {
                    ToastDialog.showError(error, context);
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ToastDialog.showError('Error: $e', context);
                }
              } finally {
                if (mounted) setState(() => _isSubmitting = false);
              }
            },
          ),
          24.0.height,

          InkWell(
            onTap: () {
              final jobLink = 'https://creatifyapp.com/job/${widget.job?.id}';
              Clipboard.setData(ClipboardData(text: jobLink));
              ToastDialog.showSuccess('Job link copied to clipboard', context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'share this recruiters profile',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.body,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                12.0.width,
                const Icon(Icons.share_outlined, size: 22, color: AppColors.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
