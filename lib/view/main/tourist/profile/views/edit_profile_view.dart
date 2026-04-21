import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tourist/profile/controllers/profile_controller.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final controller = Get.find<TouristProfileController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController countryController;

  final List<String> ageRanges = [
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55-64',
    '65+',
  ];

  final List<String> budgetOptions = [
    'Budget-friendly',
    'Mid-range',
    'Luxury',
  ];

  final List<String> paceOptions = [
    'Relaxed and slow-paced',
    'Action-packed and fast-paced',
    'A bit of both',
  ];

  final List<String> interestOptions = [
    'Adventure',
    'Cultural Heritage',
    'Nature & Wildlife',
    'Religious',
    'Beach',
    'Entertainment',
    'Historical',
    'Photography',
    'Food & Culinary',
    'Relaxation',
  ];

  String? selectedAgeRange;
  String? selectedBudget;
  String? selectedPace;
  List<String> selectedInterests = [];

  String selectedCountryCode = '+966';

  final List<String> countryCodes = [
    '+966',
    '+971',
    '+965',
    '+973',
    '+974',
    '+968',
    '+20',
    '+962',
    '+961',
    '+1',
    '+44',
  ];

  @override
  void initState() {
    super.initState();

    final data = controller.userData;

    nameController = TextEditingController(
      text: (data['fullName'] ?? '').toString(),
    );
    emailController = TextEditingController(
      text: (data['email'] ?? '').toString(),
    );

    final savedPhone = (data['phone'] ?? '').toString().trim();
    if (savedPhone.startsWith('+')) {
      final matchedCode = countryCodes.firstWhere(
        (code) => savedPhone.startsWith(code),
        orElse: () => '+966',
      );
      selectedCountryCode = matchedCode;
      phoneController = TextEditingController(
        text: savedPhone.replaceFirst(matchedCode, '').trim(),
      );
    } else {
      phoneController = TextEditingController(text: savedPhone);
    }

    countryController = TextEditingController(
      text: (data['countryOfResidence'] ?? '').toString(),
    );

    final savedAgeRange =
        (data['ageRange'] ?? data['age'] ?? '').toString().trim();
    selectedAgeRange = ageRanges.contains(savedAgeRange) ? savedAgeRange : null;

    final savedBudget = (data['travelBudget'] ?? '').toString().trim();
    selectedBudget = budgetOptions.contains(savedBudget) ? savedBudget : null;

    final savedPace = (data['travelPace'] ?? '').toString().trim();
    selectedPace = paceOptions.contains(savedPace) ? savedPace : null;

    selectedInterests = List<String>.from(data['interests'] ?? []);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    countryController.dispose();
    super.dispose();
  }

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(
        color: const Color(0xFF777777),
        fontSize: 14.sp,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFF00A86B)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: inputStyle(label),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.black,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }

  Widget buildInterestChips() {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: interestOptions.map((interest) {
        final isSelected = selectedInterests.contains(interest);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedInterests.remove(interest);
              } else {
                selectedInterests.add(interest);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF00A86B).withOpacity(0.12)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00A86B)
                    : const Color(0xFFE5E5E5),
              ),
            ),
            child: Text(
              interest,
              style: GoogleFonts.inter(
                color: isSelected
                    ? const Color(0xFF00A86B)
                    : Colors.black87,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String? interestsValidator() {
    if (selectedInterests.isEmpty) {
      return 'Please select at least one interest';
    }
    return null;
  }

  String? nameValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your full name';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) {
      return 'Name must contain letters only';
    }
    return null;
  }

  String? emailValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your email';
    if (!GetUtils.isEmail(text)) return 'Enter a valid email';
    return null;
  }

  String? phoneValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your phone number';
    if (!RegExp(r'^[0-9]+$').hasMatch(text)) {
      return 'Phone must contain numbers only';
    }
    if (text.length < 7 || text.length > 12) {
      return 'Phone number must be between 7 and 12 digits';
    }
    return null;
  }

  String? countryValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your country of residence';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) {
      return 'Country must contain letters only';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F4EE),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSectionTitle('Account Information'),
                    TextFormField(
                      controller: nameController,
                      decoration: inputStyle('Full Name'),
                      validator: nameValidator,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: inputStyle('Email'),
                      validator: emailValidator,
                    ),
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'If you change your email, you will need to verify the new email before signing in with it.',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: const Color.fromARGB(255, 235, 4, 4),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 110.w,
                          child: DropdownButtonFormField<String>(
                            value: selectedCountryCode,
                            decoration: inputStyle('Code'),
                            items: countryCodes
                                .map(
                                  (code) => DropdownMenuItem<String>(
                                    value: code,
                                    child: Text(
                                      code,
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCountryCode = value ?? '+966';
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.number,
                            decoration: inputStyle('Phone'),
                            validator: phoneValidator,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(12),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 14.h),
                    TextFormField(
                      controller: countryController,
                      decoration: inputStyle('Country of Residence'),
                      validator: countryValidator,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSectionTitle('Help us personalize your experience'),
                    buildDropdown(
                      label: 'Your Age',
                      value: selectedAgeRange,
                      items: ageRanges,
                      onChanged: (value) {
                        setState(() {
                          selectedAgeRange = value;
                        });
                      },
                    ),
                    SizedBox(height: 14.h),
                    buildDropdown(
                      label: "What's your travel budget?",
                      value: selectedBudget,
                      items: budgetOptions,
                      onChanged: (value) {
                        setState(() {
                          selectedBudget = value;
                        });
                      },
                    ),
                    SizedBox(height: 14.h),
                    buildDropdown(
                      label: "What's your preferred travel pace?",
                      value: selectedPace,
                      items: paceOptions,
                      onChanged: (value) {
                        setState(() {
                          selectedPace = value;
                        });
                      },
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'What are your interests?',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Select the interests that match your travel style.',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: const Color(0xFF777777),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    buildInterestChips(),
                    if (interestsValidator() != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        interestsValidator()!,
                        style: GoogleFonts.inter(
                          color: Colors.redAccent,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 22.h),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: controller.isSavingProfile.value
                        ? null
                        : () {
                            if (!_formKey.currentState!.validate()) return;
                            if (selectedInterests.isEmpty) {
                              setState(() {});
                              return;
                            }

                            final fullPhone =
                                '$selectedCountryCode${phoneController.text.trim()}';

                            controller.saveProfile(
                              fullName: nameController.text.trim(),
                              email: emailController.text.trim(),
                              phone: fullPhone,
                              countryOfResidence: countryController.text.trim(),
                              ageRange: selectedAgeRange ?? '',
                              travelBudget: selectedBudget ?? '',
                              travelPace: selectedPace ?? '',
                              interests: selectedInterests,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A86B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isSavingProfile.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}