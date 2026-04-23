import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tour_guide/profile/controllers/profile_controller.dart';

class EditGuideProfileView extends StatefulWidget {
  const EditGuideProfileView({super.key});

  @override
  State<EditGuideProfileView> createState() => _EditGuideProfileViewState();
}

class _EditGuideProfileViewState extends State<EditGuideProfileView> {
  final controller = Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  String selectedCountryCode = '+966';

  String? selectedExperience;
  String? selectedSpecialization;
  List<String> selectedLanguages = [];

  final List<String> experienceOptions = List.generate(21, (i) => i.toString());

  final List<String> specializationOptions = [
    'Historical Tours',
    'Adventure',
    'Cultural',
    'Nature & Wildlife',
  ];

  final List<String> languageOptions = [
    'Arabic',
    'English',
    'French',
    'Spanish',
  ];

  final List<String> countryCodes = [
    '+966',
    '+971',
    '+965',
    '+973',
    '+974',
    '+968',
  ];

  @override
  void initState() {
    super.initState();

    final data = controller.profileData;

    nameController = TextEditingController(text: data['name'] ?? '');
    emailController = TextEditingController(text: data['email'] ?? '');
    phoneController = TextEditingController(text: data['phone'] ?? '');

    selectedExperience = (data['yearsOfExperience'] ?? 0).toString();

    final specs = List<String>.from(data['specializations'] ?? []);
    selectedSpecialization = specs.isNotEmpty ? specs[0] : null;

    selectedLanguages = List<String>.from(data['languages'] ?? []);
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
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget buildLanguageChips() {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: languageOptions.map((lang) {
        final selected = selectedLanguages.contains(lang);

        return GestureDetector(
          onTap: () {
            setState(() {
              selected
                  ? selectedLanguages.remove(lang)
                  : selectedLanguages.add(lang);
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF00A86B).withOpacity(0.12)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: selected
                    ? const Color(0xFF00A86B)
                    : const Color(0xFFE5E5E5),
              ),
            ),
            child: Text(
              lang,
              style: GoogleFonts.inter(
                color: selected ? const Color(0xFF00A86B) : Colors.black87,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
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
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// ACCOUNT INFO
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
                    ),

                    SizedBox(height: 14.h),

                    TextFormField(
                      controller: emailController,
                      decoration: inputStyle('Email'),
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
                      children: [
                        SizedBox(
                          width: 110.w,
                          child: DropdownButtonFormField<String>(
                            value: selectedCountryCode,
                            decoration: inputStyle('Code'),
                            items: countryCodes
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                selectedCountryCode = v!;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TextFormField(
                            controller: phoneController,
                            decoration: inputStyle('Phone'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18.h),

              /// GUIDE SECTION
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSectionTitle('Guide Information'),

                    buildDropdown(
                      label: 'Years of Experience',
                      value: selectedExperience,
                      items: experienceOptions,
                      onChanged: (v) {
                        setState(() {
                          selectedExperience = v;
                        });
                      },
                    ),

                    SizedBox(height: 14.h),

                    buildDropdown(
                      label: 'Specialization',
                      value: selectedSpecialization,
                      items: specializationOptions,
                      onChanged: (v) {
                        setState(() {
                          selectedSpecialization = v;
                        });
                      },
                    ),

                    SizedBox(height: 18.h),

                    Text(
                      'Languages Spoken',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 14.h),

                    buildLanguageChips(),
                  ],
                ),
              ),

              SizedBox(height: 22.h),

              ///  SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: () {
                    final rawPhone = phoneController.text.trim();
                    final cleanedPhone = rawPhone.replaceAll(
                      RegExp(r'^\+\d+'),
                      '',
                    );
                    controller.saveProfile(
                      fullName: nameController.text.trim(),
                      email: emailController.text.trim(),
                      phone: cleanedPhone,
                      yearsOfExperience: selectedExperience ?? '',
                      specialization: selectedSpecialization ?? '',
                      languages: selectedLanguages,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A86B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
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
