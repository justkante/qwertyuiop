import 'package:creatify_mobile/data/models/responses/countries_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../showcase-talents/vm/creator_providers.dart';
import 'vm/job_controller.dart';
import 'package:intl/intl.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'post_job_success_view.dart';

class UploadJobView extends ConsumerStatefulWidget {
  const UploadJobView({super.key});

  @override
  ConsumerState<UploadJobView> createState() => _UploadJobViewState();
}

class _UploadJobViewState extends ConsumerState<UploadJobView> {
  final _formKey = GlobalKey<FormState>();
  String _jobType = 'Time Based';
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController(text: '0');
  final _hourController = TextEditingController();
  final _minuteController = TextEditingController();

  String? _selectedService;
  String? _selectedWorkMode;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  String _durationUnit = 'Days';
  String _period = 'AM';

  @override
  void initState() {
    super.initState();
    _hourController.addListener(_onTimeChanged);
    _minuteController.addListener(_onTimeChanged);
  }

  void _onTimeChanged() {
    final hourText = _hourController.text;
    final minuteText = _minuteController.text;

    if (hourText.isEmpty || minuteText.isEmpty) return;

    final hour = int.tryParse(hourText);
    final minute = int.tryParse(minuteText);

    if (hour != null && minute != null) {
      // Validate bounds
      if (hour < 1 || hour > 12 || minute < 0 || minute > 59) return;

      int finalHour = hour;
      if (_period == 'PM' && hour != 12) finalHour += 12;
      if (_period == 'AM' && hour == 12) finalHour = 0;

      setState(() {
        _startTime = TimeOfDay(hour: finalHour, minute: minute);
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Upload a Job', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1EF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'When the creator marks this booking as complete, you\'ll have 72 hours to review or raise a dispute. If no action is taken, payment will be released automatically.',
                  style: TextStyle(color: Color(0xFFFF6F61), fontSize: 10),
                ),
              ),
              24.0.height,

              // Job Type
              const Text('Job Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              12.0.height,
              Row(
                children: [
                  _buildRadioButton('Time Based'),
                  24.0.width,
                  _buildRadioButton('Deliverable Based'),
                ],
              ),
              24.0.height,

              // Describe Job
              const Text('Describe Job', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              8.0.height,
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                validator: (val) => val == null || val.isEmpty ? 'Description is required' : null,
                decoration: InputDecoration(
                  hintText: 'Enter description here',
                  hintStyle: context.textTheme.bodySmall?.copyWith(fontSize: 15),
                  fillColor: AppColors.grey50,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              24.0.height,

              // Service
              const Text('Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              8.0.height,
              ref.watch(fetchCreatorNichesProvider).when(
                data: (categories) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedService,
                      hint: const Text('Select Service', style: TextStyle(fontSize: 15, color: AppColors.body)),
                      items: categories.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name ?? '', style: const TextStyle(fontSize: 15)))).toList(),
                      onChanged: (val) => setState(() => _selectedService = val),
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.body),
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const Text('Error loading services', style: TextStyle(color: Colors.red, fontSize: 14)),
              ),
              24.0.height,

              // Work Mode
              _buildDropdownField(
                'Work Mode',
                ['Remote', 'On-site', 'Hybrid'],
                (val) => setState(() => _selectedWorkMode = val),
                initialValue: _selectedWorkMode,
              ),
              24.0.height,

              // Start Date
              const Text('Start Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // Increased
              8.0.height,
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => _startDate = date);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_startDate?.toFormattedDate() ?? 'Select Date', style: const TextStyle(fontSize: 16, color: AppColors.body)), // Increased
                      const Icon(Icons.keyboard_arrow_down, color: AppColors.body),
                    ],
                  ),
                ),
              ),
              24.0.height,

              // Start Time
              const Text('Start Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // Increased
              8.0.height,
              Row(
                children: [
                  // Time Input Group
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Hour
                        SizedBox(
                          width: 45,
                          child: TextFormField(
                            controller: _hourController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 2,
                            enableInteractiveSelection: true,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500), // Increased
                            decoration: const InputDecoration(
                              counterText: "",
                              hintText: '12',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const Text(':', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)), // Increased
                        // Minute
                        SizedBox(
                          width: 45,
                          child: TextFormField(
                            controller: _minuteController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 2,
                            enableInteractiveSelection: true,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500), // Increased
                            decoration: const InputDecoration(
                              counterText: "",
                              hintText: '00',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        12.0.width,
                        // AM/PM
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _period,
                            icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.body), // Increased
                            items: ['AM', 'PM']
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Increased
                                    ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _period = val!;
                                _onTimeChanged();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.0.width,
                  // Quick Clock Picker
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _startTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          _startTime = time;
                          int displayHour = time.hourOfPeriod;
                          if (displayHour == 0) displayHour = 12;
                          _hourController.text = displayHour.toString().padLeft(2, '0');
                          _minuteController.text = time.minute.toString().padLeft(2, '0');
                          _period = time.period == DayPeriod.am ? 'AM' : 'PM';
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.access_time, color: AppColors.primary, size: 30), // Increased
                    ),
                  ),
                ],
              ),
              24.0.height,

              // Duration
              const Text('Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // Increased
              8.0.height,
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Amount', style: TextStyle(fontSize: 14, color: AppColors.body)), // Increased
                        4.0.height,
                        TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          decoration: InputDecoration(
                            hintText: 'e.g. 5',
                            hintStyle: context.textTheme.bodySmall?.copyWith(fontSize: 14),
                            fillColor: AppColors.grey50,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(fontSize: 18), // Increased
                        ),
                      ],
                    ),
                  ),
                  16.0.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Unit', style: TextStyle(fontSize: 14, color: AppColors.body)), // Increased
                        4.0.height,
                        _buildDropdownField(
                          '',
                          ['Days', 'Hours', 'Weeks'],
                          (val) => setState(() => _durationUnit = val!),
                          initialValue: _durationUnit,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              24.0.height,

              // Location
              const Text('Location (optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // Increased
              8.0.height,
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Enter Location here',
                  hintStyle: context.textTheme.bodySmall?.copyWith(fontSize: 15),
                  fillColor: AppColors.grey50,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                style: const TextStyle(fontSize: 18), // Increased
              ),
              24.0.height,

              // Price
              const Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // Increased
              8.0.height,
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Price is required' : null,
                decoration: InputDecoration(
                  prefixText: '${ref.watch(userControllerProvider).primaryCurrency ?? 'NGN'} ',
                  prefixStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18), // Increased
                  hintText: '0.00',
                  hintStyle: context.textTheme.bodySmall?.copyWith(fontSize: 15),
                  fillColor: AppColors.grey50,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(fontSize: 20), // Increased
              ),
              40.0.height,

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _submitJob(isDraft: true),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF009688)),
                        padding: const EdgeInsets.symmetric(vertical: 18), // Increased
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Draft', style: TextStyle(color: Color(0xFF009688), fontWeight: FontWeight.bold, fontSize: 18)), // Increased
                    ),
                  ),
                  16.0.width,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _submitJob(isDraft: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009688),
                        padding: const EdgeInsets.symmetric(vertical: 18), // Increased
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: ref.watch(jobControllerProvider).isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Post Job', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), // Increased
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioButton(String label) {
    final isSelected = _jobType == label;
    return InkWell(
      onTap: () => setState(() => _jobType = label),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? const Color(0xFF009688) : AppColors.grey300, width: 2),
            ),
            child: isSelected ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF009688)))) : null,
          ),
          8.0.width,
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.body)),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, Function(String?) onChanged, {String? initialValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          8.0.height,
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: initialValue,
              hint: const Text('Select', style: TextStyle(fontSize: 12, color: AppColors.body)),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: onChanged,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.body),
            ),
          ),
        ),
      ],
    );
  }

  void _submitJob({bool isDraft = false}) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedService == null) {
        ToastDialog.showError('Please select a service', context);
        return;
      }
      if (_selectedWorkMode == null) {
        ToastDialog.showError('Please select a work mode', context);
        return;
      }
      if (_startDate == null) {
        ToastDialog.showError('Please select a start date', context);
        return;
      }
      if (_hourController.text.trim().isEmpty || _minuteController.text.trim().isEmpty) {
        ToastDialog.showError('Please enter a start time', context);
        return;
      }
      if (_selectedWorkMode != 'Remote' && _locationController.text.trim().isEmpty) {
        ToastDialog.showError('Location is required for non-remote jobs', context);
        return;
      }

      final error = await ref.read(jobControllerProvider.notifier).createJob({
        'title': _descriptionController.text.truncate(30),
        'description': _descriptionController.text,
        'category_id': _selectedService,
        'location': _locationController.text.isEmpty ? 'Remote' : _locationController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'type': _jobType,
        'work_mode': _selectedWorkMode,
        'status': isDraft ? 'draft' : 'active',
        'currency': ref.read(userControllerProvider).primaryCurrency ?? 'NGN',
        'start_date': DateFormat('yyyy-MM-dd').format(_startDate!),
        'start_time': _startTime != null ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}' : null,
        'duration': '${_durationController.text} $_durationUnit',
      });

      if (error == null && mounted) {
        if (isDraft) {
          ToastDialog.showSuccess('Draft saved successfully', context);
          Navigator.pop(context);
        } else {
          NavigationService.instance.pushReplacement(const PostJobSuccessView());
        }
      } else if (mounted) {
        ToastDialog.showError(error ?? 'Failed to process job. Please try again.', context);
      }
    }
  }
}
