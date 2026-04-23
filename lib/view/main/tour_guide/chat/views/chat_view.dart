import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tour_guide/chat/controllers/chat_controller.dart';
import 'package:tour_app/view/main/tour_guide/shared/widgets/bottom_navigation_bar.dart';
import 'package:tour_app/view/main/tour_guide/dashboard/controllers/dashboard_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BroadcastController());
    final dashboardController = Get.find<DashboardController>();
    dashboardController.currentBottomNavIndex.value = 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back, size: 24.sp),
                  ),
                  SizedBox(width: 12.w),
                  Image.asset(
                    "images/onboarding_logo.png",
                    height: 32.w,
                    width: 32.w,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Broadcast',
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            /// BUTTON for new broadcast
            Padding(
              padding: EdgeInsets.all(16.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A86B),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () {
                    _openBroadcastDialog(context);
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'New Broadcast',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            /// LIST
            Expanded(
              child: Obx(() {
                final list = controller.broadcasts;

                if (list.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];

                    return Container(
                      margin: EdgeInsets.only(bottom: 14.h),
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['tourName'] ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500, // 👈 هذا المهم
                            ),
                          ),
                          SizedBox(height: 4),

                          /// Title + Icon
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00A86B,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.campaign,
                                  size: 16.sp,
                                  color: const Color(0xFF00A86B),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  item['title'] ?? '',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10.h),

                          /// Message
                          Text(
                            item['message'] ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),

                          SizedBox(height: 12.h),

                          /// Footer (Date)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sent to ${item['recipientsCount'] ?? 0} users',
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                _formatDate(item['createdAt']),
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),

            const TourGuideBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  /// Dialog for creating new broadcast
  void _openBroadcastDialog(BuildContext context) {
    final controller = Get.find<BroadcastController>();

    String selectedTourId = '';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'New Broadcast',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),

                /// Dropdown
                Obx(
                  () => DropdownButtonFormField<String>(
                    hint: const Text('Select Tour'),
                    items: controller.tours.map((tour) {
                      return DropdownMenuItem<String>(
                        value: tour['id'],
                        child: Text(tour['name']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      selectedTourId = val!;
                    },
                  ),
                ),

                SizedBox(height: 12.h),

                TextField(
                  controller: controller.titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 12.h),

                TextField(
                  controller: controller.messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 20.h),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedTourId.isEmpty) {
                            Get.snackbar('Error', 'Select a tour');
                            return;
                          }

                          controller.sendBroadcast(selectedTourId);
                          Get.back();
                        },
                        child: const Text('Send'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDate(dynamic timestamp) {
  if (timestamp == null || timestamp is! Timestamp) return '';

  final date = timestamp.toDate();

  return '${date.day}/${date.month} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}
