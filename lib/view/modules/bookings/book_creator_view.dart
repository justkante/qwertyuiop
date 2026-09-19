import 'dart:developer';

import 'package:creatify_mobile/core/utils/constants.dart';
import 'package:creatify_mobile/data/models/requests/book_creator_req.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/data/models/responses/draft_booking_item_dto.dart';
import 'package:creatify_mobile/data/models/responses/unavailability_time_item_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/creator_unavailabliity_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/request_sent_view.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/delivery_based_booking_vm.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/webview/app_webview.dart';

import 'package:creatify_mobile/view/modules/home/rating/star_rating.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class BookCreatorView extends ConsumerStatefulWidget {
  final CreatorProfileDto creatorProfile;
  final DraftingBookingItemDto? draftBooking;

  const BookCreatorView({
    super.key,
    required this.creatorProfile,
    this.draftBooking,
  });

  @override
  ConsumerState<BookCreatorView> createState() => _BookCreatorViewState();
}

class _BookCreatorViewState extends ConsumerState<BookCreatorView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController projectTitleController = TextEditingController();
  final TextEditingController projectDescriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();

  String? selectedProjectType;
  CreatorUnavailabilityItemDto? selectedStartDate;
  final List<String> projectTypes = ['UGC Video', 'Social Media Management', 'Content Creation', 'Other'];

  @override
  void dispose() {
    projectTitleController.dispose();
    projectDescriptionController.dispose();
    locationController.dispose();
    budgetController.dispose();
    startDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingCreatorLoading = ref.watch(deliveryBasedCreatorBookingProvider).isLoading;

    ref.listen(deliveryBasedCreatorBookingProvider, (_, value) {
      if (value is AsyncData) {
        NavigationService.instance.pushReplacement(
          isTransparent: true,
          RequestSentView(
            creatorName: widget.creatorProfile.name,
          ),
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Book Creator',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFB2DFDB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mail_outline, color: Color(0xFF00796B), size: 24),
                    ),
                    16.0.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Send a project invite',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B3131)),
                          ),
                          Text(
                            'Tell the creator about your project and see if they\'re available. They\'ll be notified in the app.',
                            style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              24.0.height,

              // Creator Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey200),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: widget.creatorProfile.profileImage != null
                          ? NetworkImage(widget.creatorProfile.profileImage!)
                          : const AssetImage(AppImages.dummyAvatar) as ImageProvider,
                    ),
                    16.0.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.creatorProfile.name ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            widget.creatorProfile.categories?.map((e) => e.name).join(', ') ?? 'No Category',
                            style: const TextStyle(color: Color(0xFFFF6F61), fontSize: 12),
                          ),
                          Row(
                            children: [
                              Text(
                                '(${widget.creatorProfile.ratingsAndReviews?.totalReviews ?? 0})',
                                style: const TextStyle(fontSize: 12, color: AppColors.body),
                              ),
                              4.0.width,
                              StarRating(rating: widget.creatorProfile.ratingsAndReviews?.averageRating ?? 0.0, starCount: 5, starSize: 12),
                            ],
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                         NavigationService.instance.pop();
                      },
                      child: Row(
                        children: [
                          const Text('View Profile', style: TextStyle(color: Color(0xFF00796B), fontSize: 12, fontWeight: FontWeight.bold)),
                          4.0.width,
                          const Icon(Icons.chevron_right, color: Color(0xFF00796B), size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              32.0.height,

              const Text('Project Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B3131))),
              24.0.height,

              // Project Title
              _buildLabel('Project Title'),
              8.0.height,
              _buildTextField(projectTitleController, 'e.g. Brand Shoot for Fashion Campaign'),
              20.0.height,

              // Project Type
              _buildLabel('Project Type'),
              8.0.height,
              _buildDropdownField(),
              20.0.height,

              // Project Description
              _buildLabel('Project Description'),
              8.0.height,
              _buildTextArea(projectDescriptionController),
              20.0.height,

              // Start Date & Location Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Proposed Start Date'),
                        8.0.height,
                        _buildDateField(),
                      ],
                    ),
                  ),
                  16.0.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Location'),
                        8.0.height,
                        _buildTextField(locationController, 'e.g. Lagos, Nigeria or Remote', icon: Icons.location_on_outlined),
                      ],
                    ),
                  ),
                ],
              ),
              20.0.height,

              // Budget
              _buildLabel('Budget (Optional)'),
              8.0.height,
              _buildTextField(
                budgetController,
                'e.g. 50,000',
                prefix: Text('${ref.watch(userControllerProvider).primaryCurrency ?? '₦'} ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black))
              ),
              20.0.height,

              // Attachments
              _buildLabel('Attachments (Optional)'),
              8.0.height,
              _buildAttachmentBox(),
              40.0.height,

              // Submit Button
              MainButton(
                text: 'Send Invite',
                isLoading: bookingCreatorLoading,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ref.read(deliveryBasedCreatorBookingProvider.notifier).bookCreator(
                      BookCreatorReq(
                        creatorId: widget.creatorProfile.id,
                        jobDescription: "${projectTitleController.text}\n\n${projectDescriptionController.text}",
                        location: locationController.text,
                        budget: num.tryParse(budgetController.text.replaceAll(',', '')) ?? 0,
                        bookingType: 'delivery_based', // Defaulting to delivery based as per provider
                      )
                    );
                  }
                },
              ),
              24.0.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1B3131)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {IconData? icon, Widget? prefix}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.body, fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, color: AppColors.body, size: 20) : prefix,
        fillColor: AppColors.grey50,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (val) => (val == null || val.isEmpty) && hint.contains('e.g.') && !hint.contains('50,000') ? 'Required' : null,
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedProjectType,
          hint: const Text('Select project type', style: TextStyle(fontSize: 13, color: AppColors.body)),
          items: projectTypes.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (val) => setState(() => selectedProjectType = val),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.body),
        ),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
          controller: controller,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Tell the creator about your project, goals, style, and any specific requirements...',
            hintStyle: const TextStyle(color: AppColors.body, fontSize: 13),
            fillColor: AppColors.grey50,
            filled: true,
            counterText: "",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: validateGeneric,
        ),
        4.0.height,
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, value, child) {
            return Text('${value.text.length}/500', style: const TextStyle(fontSize: 10, color: AppColors.body));
          },
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() {
            selectedStartDate = CreatorUnavailabilityItemDto(unavailableDate: date);
            startDateController.text = DateFormat('dd/MM/yyyy').format(date);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.body),
            12.0.width,
            Text(startDateController.text.isEmpty ? 'Select date' : startDateController.text,
              style: TextStyle(fontSize: 13, color: startDateController.text.isEmpty ? AppColors.body : Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FDFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.3), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF00796B),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
          12.0.height,
          const Text('Add files', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B3131))),
          const Text('Images, moodboard, brief, etc. (Max 5 files)', style: TextStyle(fontSize: 10, color: AppColors.body)),
        ],
      ),
    );
  }
}
