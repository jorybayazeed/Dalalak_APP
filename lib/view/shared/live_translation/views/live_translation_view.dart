import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/services/live_translation_service.dart';
import 'package:tour_app/view/shared/live_translation/controllers/live_translation_controller.dart';

class LiveTranslationView extends StatelessWidget {
  final String role;

  const LiveTranslationView({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final tag = 'live_translation_$role';
    final controller = Get.isRegistered<LiveTranslationController>(tag: tag)
        ? Get.find<LiveTranslationController>(tag: tag)
        : Get.put(LiveTranslationController(), tag: tag);

    final title = role == 'guide'
        ? 'Guide Live Translation'
        : 'Tourist Live Translation';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLanguageSelectors(controller),
              SizedBox(height: 14.h),
              _buildLiveMicCard(controller),
              SizedBox(height: 14.h),
              _buildQuickPhrases(controller, role),
              SizedBox(height: 14.h),
              _buildTextsCard(controller),
              SizedBox(height: 14.h),
              _buildHistoryCard(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelectors(LiveTranslationController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildLangDropdown(
                    label: 'From',
                    value: controller.sourceLang.value,
                    languages: controller.languages,
                    onChanged: controller.setSourceLang,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildLangDropdown(
                    label: 'To',
                    value: controller.targetLang.value,
                    languages: controller.languages,
                    onChanged: controller.setTargetLang,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangDropdown({
    required String label,
    required String value,
    required List<SupportedLanguage> languages,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          value: value,
          items: languages
              .map(
                (l) => DropdownMenuItem<String>(
                  value: l.code,
                  child: Text(l.label),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveMicCard(LiveTranslationController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D8A6A), Color(0xFF18A27F)],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Live Speech Translation',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              controller.isSpeechReady.value
                  ? 'Press microphone and start speaking.'
                  : 'Speech recognition is not ready on this device/browser.',
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.95),
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.toggleListening,
                    icon: Icon(
                      controller.isListening.value ? Icons.stop : Icons.mic,
                    ),
                    label: Text(
                      controller.isListening.value
                          ? 'Stop Listening'
                          : 'Start Listening',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0D8A6A),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  onPressed: controller.clearCurrent,
                  color: Colors.white,
                  icon: const Icon(Icons.clear_all),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPhrases(
    LiveTranslationController controller,
    String role,
  ) {
    final phrases = controller.quickPhrases(role);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Phrases',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: phrases
                .map(
                  (p) => ActionChip(
                    label: Text(p),
                    onPressed: () => controller.useQuickPhrase(p),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextsCard(LiveTranslationController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Original',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                controller.liveText.value.isEmpty
                    ? 'Live speech text will appear here...'
                    : controller.liveText.value,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Text(
                  'Translation',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (controller.isTranslating.value)
                  SizedBox(
                    width: 14.w,
                    height: 14.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                IconButton(
                  onPressed: controller.speakTranslation,
                  icon: const Icon(Icons.volume_up_outlined),
                  tooltip: 'Play translated voice',
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                controller.translatedText.value.isEmpty
                    ? 'Translated text will appear here...'
                    : controller.translatedText.value,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(LiveTranslationController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Obx(
        () {
          if (controller.history.isEmpty) {
            return Text(
              'No translation history yet.',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFF777777),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Translations',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              ...controller.history.take(5).map(
                (row) => Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row['original'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        row['translated'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
