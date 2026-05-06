import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tour_guide/rewards/controllers/guide_rewards_controller.dart';

class CreateRewardView extends StatefulWidget {
  const CreateRewardView({super.key});

  @override
  State<CreateRewardView> createState() => _CreateRewardViewState();
}

class _CreateRewardViewState extends State<CreateRewardView> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _discountCtrl = TextEditingController(text: '10');
  final _partnerNameCtrl = TextEditingController();
  final _partnerLocationCtrl = TextEditingController();
  final _redemptionCodeCtrl = TextEditingController();

  String _type = 'tour_discount';
  int _requiredLevel = 1;
  String _partnerCategory = 'Restaurant';
  DateTime? _validUntil;
  final Set<String> _selectedTours = {};

  static const Map<int, String> _levelNames = {
    1: 'Starter',
    2: 'Explorer',
    3: 'Traveler',
    4: 'Adventurer',
    5: 'Guide',
    6: 'Expert',
    7: 'Master',
  };

  static const List<String> _partnerCategories = [
    'Restaurant',
    'Cafe',
    'Shop',
    'Hotel',
    'Activity',
    'Other',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _discountCtrl.dispose();
    _partnerNameCtrl.dispose();
    _partnerLocationCtrl.dispose();
    _redemptionCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickValidUntil() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _validUntil ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      setState(() => _validUntil = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTours.isEmpty) {
      Get.snackbar(
        'Select tours',
        'Please select at least one tour to attach this reward to',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final controller = Get.find<GuideRewardsController>();
    try {
      await controller.createReward(
        type: _type,
        title: _titleCtrl.text,
        description: _descCtrl.text,
        discountPercent: int.tryParse(_discountCtrl.text.trim()) ?? 0,
        requiredLevel: _requiredLevel,
        applicableTours: _selectedTours.toList(),
        partnerName: _partnerNameCtrl.text,
        partnerCategory: _partnerCategory,
        partnerLocation: _partnerLocationCtrl.text,
        redemptionCode: _redemptionCodeCtrl.text,
        validUntil: _validUntil,
      );
      if (!mounted) return;
      Get.back();
      Get.snackbar(
        'Reward Created',
        'Your reward is now active',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideRewardsController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Create Reward',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Reward Type'),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: _typeChip(
                      label: 'Tour Discount',
                      icon: Icons.local_offer,
                      value: 'tour_discount',
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _typeChip(
                      label: 'Partner Coupon',
                      icon: Icons.card_giftcard,
                      value: 'partner_coupon',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              _sectionTitle('Title'),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _titleCtrl,
                decoration: _inputDeco('e.g. 15% off AlUla Tour'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: 14.h),
              _sectionTitle('Description (optional)'),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: _inputDeco('Add a short description'),
              ),
              SizedBox(height: 14.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Discount %'),
                        SizedBox(height: 6.h),
                        TextFormField(
                          controller: _discountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDeco('1 – 100'),
                          validator: (v) {
                            final n = int.tryParse(v?.trim() ?? '');
                            if (n == null || n < 1 || n > 100) {
                              return '1 – 100';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Required Level'),
                        SizedBox(height: 6.h),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          value: _requiredLevel,
                          decoration: _inputDeco(''),
                          items: _levelNames.entries
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text('L${e.key} • ${e.value}'),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _requiredLevel = v);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              _sectionTitle('Attach to Tours'),
              SizedBox(height: 6.h),
              Obx(() {
                if (controller.myTours.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'You have no tours yet. Create a tour first.',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF8D4B00),
                      ),
                    ),
                  );
                }
                return Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: controller.myTours.map((t) {
                    final id = (t['id'] ?? '').toString();
                    final title = (t['title'] ?? '').toString();
                    final selected = _selectedTours.contains(id);
                    return GestureDetector(
                      onTap: () => setState(() {
                        selected
                            ? _selectedTours.remove(id)
                            : _selectedTours.add(id);
                      }),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF00A86B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF00A86B)
                                : const Color(0xFFE5E5E5),
                          ),
                        ),
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            color: selected ? Colors.white : Colors.black87,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
              if (_type == 'partner_coupon') ...[
                SizedBox(height: 18.h),
                _sectionTitle('Partner Information'),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _partnerNameCtrl,
                  decoration: _inputDeco('Partner name'),
                ),
                SizedBox(height: 10.h),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _partnerCategory,
                  decoration: _inputDeco('Category'),
                  items: _partnerCategories
                      .map(
                        (c) => DropdownMenuItem(value: c, child: Text(c)),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _partnerCategory = v);
                  },
                ),
                SizedBox(height: 10.h),
                TextFormField(
                  controller: _partnerLocationCtrl,
                  decoration: _inputDeco('Location (e.g. Riyadh)'),
                ),
                SizedBox(height: 10.h),
                TextFormField(
                  controller: _redemptionCodeCtrl,
                  decoration: _inputDeco('Redemption Code (e.g. DLK20)'),
                  textCapitalization: TextCapitalization.characters,
                ),
              ],
              SizedBox(height: 14.h),
              _sectionTitle('Valid Until (optional)'),
              SizedBox(height: 6.h),
              GestureDetector(
                onTap: _pickValidUntil,
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE5E5E5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 18.sp, color: const Color(0xFF666666)),
                      SizedBox(width: 10.w),
                      Text(
                        _validUntil == null
                            ? 'No expiry'
                            : '${_validUntil!.year}-${_validUntil!.month.toString().padLeft(2, '0')}-${_validUntil!.day.toString().padLeft(2, '0')}',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      if (_validUntil != null)
                        GestureDetector(
                          onTap: () => setState(() => _validUntil = null),
                          child: Icon(Icons.close,
                              size: 18.sp, color: const Color(0xFF999999)),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: Obx(() {
                  return ElevatedButton(
                    onPressed: controller.isSaving.value ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A86B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      controller.isSaving.value ? 'Saving...' : 'Save Reward',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF333333),
      ),
    );
  }

  Widget _typeChip({
    required String label,
    required IconData icon,
    required String value,
  }) {
    final selected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF00A86B) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? const Color(0xFF00A86B) : const Color(0xFFE5E5E5),
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? Colors.white : const Color(0xFF666666),
                size: 22.sp),
            SizedBox(height: 6.h),
            Text(
              label,
              style: GoogleFonts.inter(
                color: selected ? Colors.white : Colors.black87,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFF00A86B)),
      ),
    );
  }
}
