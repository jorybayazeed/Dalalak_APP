import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tour_guide/chat/controllers/chat_controller.dart';
import 'package:tour_app/view/main/tour_guide/shared/widgets/bottom_navigation_bar.dart';
import 'package:tour_app/view/main/tour_guide/dashboard/controllers/dashboard_controller.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController());
    final dashboardController = Get.find<DashboardController>();
    dashboardController.currentBottomNavIndex.value = 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Image.asset(
                    "images/onboarding_logo.png",
                    height: 32.w,
                    width: 32.w,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Messages',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final selectedId = controller.selectedConversationId.value;

                // If no conversation selected, show conversation list
                if (selectedId.isEmpty) {
                  return Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        // Search Bar
                        Container(
                          padding: EdgeInsets.all(16.w),
                          child: Container(
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search messages...',
                                hintStyle: GoogleFonts.inter(
                                  color: const Color(0xFF999999),
                                  fontSize: 14.sp,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: const Color(0xFF999999),
                                  size: 20.sp,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        // Conversation List
                        Expanded(
                          child: ListView.builder(
                            itemCount: controller.conversations.length,
                            itemBuilder: (context, index) {
                              final conversation =
                                  controller.conversations[index];
                              return GestureDetector(
                                onTap: () => controller.selectConversation(
                                  conversation['id'] as String,
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Profile Picture
                                      Container(
                                        width: 50.w,
                                        height: 50.h,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0E0E0),
                                          shape: BoxShape.circle,
                                        ),
                                        child: conversation['avatar'] != null
                                            ? ClipOval(
                                                child: Image.asset(
                                                  conversation['avatar']
                                                      as String,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Icon(
                                                          Icons.person,
                                                          size: 24.sp,
                                                          color: Colors.grey,
                                                        );
                                                      },
                                                ),
                                              )
                                            : Icon(
                                                Icons.person,
                                                size: 24.sp,
                                                color: Colors.grey,
                                              ),
                                      ),
                                      SizedBox(width: 12.w),
                                      // Name and Message
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              conversation['name'] as String,
                                              style: GoogleFonts.inter(
                                                color: Colors.black,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              conversation['lastMessage']
                                                  as String,
                                              style: GoogleFonts.inter(
                                                color: const Color(0xFF666666),
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Time and Badge
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            conversation['time'] as String,
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFF999999),
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          if (conversation['unreadCount'] !=
                                                  null &&
                                              (conversation['unreadCount']
                                                      as int) >
                                                  0) ...[
                                            SizedBox(height: 4.h),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6.w,
                                                vertical: 2.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF00A86B),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                '${conversation['unreadCount']}',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Show chat window when conversation is selected
                final conversation = controller.conversations.firstWhere(
                  (c) => c['id'] == selectedId,
                );
                final messages = controller.getMessages(selectedId);

                return Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Chat Header
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => controller.selectConversation(''),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            // Profile Picture
                            Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E0E0),
                                shape: BoxShape.circle,
                              ),
                              child: conversation['avatar'] != null
                                  ? ClipOval(
                                      child: Image.asset(
                                        conversation['avatar'] as String,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                Icons.person,
                                                size: 20.sp,
                                                color: Colors.grey,
                                              );
                                            },
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 20.sp,
                                      color: Colors.grey,
                                    ),
                            ),
                            SizedBox(width: 12.w),
                            // Name and Status
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    conversation['name'] as String,
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    conversation['status'] as String,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF00A86B),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Action Buttons
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.phone,
                                color: Colors.black,
                                size: 22.sp,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.videocam,
                                color: Colors.black,
                                size: 22.sp,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.black,
                                size: 22.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Messages List
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(16.w),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isSent = message['isSent'] as bool;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: Row(
                                mainAxisAlignment: isSent
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (!isSent) ...[
                                    Container(
                                      width: 32.w,
                                      height: 32.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0E0E0),
                                        shape: BoxShape.circle,
                                      ),
                                      child: conversation['avatar'] != null
                                          ? ClipOval(
                                              child: Image.asset(
                                                conversation['avatar']
                                                    as String,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Icon(
                                              Icons.person,
                                              size: 16.sp,
                                              color: Colors.grey,
                                            ),
                                    ),
                                    SizedBox(width: 8.w),
                                  ],
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: isSent
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                            vertical: 12.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSent
                                                ? const Color(0xFF00A86B)
                                                : const Color(0xFFF5F5F5),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(16.r),
                                              topRight: Radius.circular(16.r),
                                              bottomLeft: isSent
                                                  ? Radius.circular(16.r)
                                                  : Radius.circular(4.r),
                                              bottomRight: isSent
                                                  ? Radius.circular(4.r)
                                                  : Radius.circular(16.r),
                                            ),
                                          ),
                                          child: Text(
                                            message['text'] as String,
                                            style: GoogleFonts.inter(
                                              color: isSent
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              message['time'] as String,
                                              style: GoogleFonts.inter(
                                                color: const Color(0xFF999999),
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            if (isSent) ...[
                                              SizedBox(width: 4.w),
                                              Icon(
                                                Icons.done_all,
                                                color: const Color(0xFF00A86B),
                                                size: 16.sp,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSent) ...[
                                    SizedBox(width: 8.w),
                                    Container(
                                      width: 32.w,
                                      height: 32.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0E0E0),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        size: 16.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // Message Input
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.attach_file,
                                color: Colors.black,
                                size: 24.sp,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                                child: TextField(
                                  controller: controller.messageController,
                                  decoration: InputDecoration(
                                    hintText: 'Type a message...',
                                    hintStyle: GoogleFonts.inter(
                                      color: const Color(0xFF999999),
                                      fontSize: 14.sp,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    color: Colors.black,
                                  ),
                                  maxLines: null,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () => controller.sendMessage(),
                              child: Container(
                                width: 48.w,
                                height: 48.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00A86B),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            TourGuideBottomNavigationBar(),
          ],
        ),
      ),
    );
  }
}
