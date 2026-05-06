import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tour_guide/dashboard/controllers/dashboard_controller.dart';
import 'package:tour_app/view/main/tour_guide/rewards/controllers/guide_rewards_controller.dart';
import 'package:tour_app/view/main/tour_guide/rewards/views/create_reward_view.dart';
import 'package:tour_app/view/main/tour_guide/shared/widgets/bottom_navigation_bar.dart';

class GuideRewardsView extends StatelessWidget {
  const GuideRewardsView({super.key});

  static const Map<int, String> _levelNames = {
    1: 'Starter',
    2: 'Explorer',
    3: 'Traveler',
    4: 'Adventurer',
    5: 'Guide',
    6: 'Expert',
    7: 'Master',
  };

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GuideRewardsController());
    final dashboardController = Get.find<DashboardController>();
    dashboardController.currentBottomNavIndex.value = 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      bottomNavigationBar: const TourGuideBottomNavigationBar(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rewards',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => const CreateRewardView()),
                    icon: Icon(Icons.add, size: 18.sp, color: Colors.white),
                    label: Text(
                      'Create',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A86B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.rewards.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.rewards.isEmpty) {
                  return _buildEmpty();
                }
                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 24.h),
                  itemCount: controller.rewards.length,
                  itemBuilder: (_, i) =>
                      _buildRewardCard(controller, controller.rewards[i]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.card_giftcard,
              size: 64.sp,
              color: const Color(0xFFBDBDBD),
            ),
            SizedBox(height: 14.h),
            Text(
              'No rewards yet',
              style: GoogleFonts.inter(
                color: const Color(0xFF666666),
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Create discounts on your tours or coupons for partner restaurants and shops to attract more tourists.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF999999),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(
    GuideRewardsController controller,
    Map<String, dynamic> r,
  ) {
    final id = (r['id'] ?? '').toString();
    final type = (r['type'] ?? 'tour_discount').toString();
    final isPartner = type == 'partner_coupon';
    final title = (r['title'] ?? 'Untitled').toString();
    final description = (r['description'] ?? '').toString();
    final discount = (r['discountPercent'] as num?)?.toInt() ?? 0;
    final requiredLevel = (r['requiredLevel'] as num?)?.toInt() ?? 1;
    final isActive = (r['isActive'] as bool?) ?? true;
    final tours = (r['applicableTours'] as List?)?.cast<dynamic>() ?? const [];
    final partnerName = (r['partnerName'] ?? '').toString();
    final code = (r['redemptionCode'] ?? '').toString();
    final validUntil = r['validUntil'];
    final usedCount = (r['totalAppliedCount'] as num?)?.toInt() ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isActive
              ? const Color(0xFFE5E5E5)
              : const Color(0xFFFFDADA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isPartner
                      ? const Color(0xFFE3F2FD)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  isPartner ? 'Partner Coupon' : 'Tour Discount',
                  style: GoogleFonts.inter(
                    color: isPartner
                        ? const Color(0xFF1565C0)
                        : const Color(0xFF2E7D32),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: GoogleFonts.inter(
                    color: isActive
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'toggle') {
                    await controller.setActive(id, !isActive);
                  } else if (action == 'delete') {
                    await _confirmDelete(controller, id);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(isActive ? 'Deactivate' : 'Activate'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (description.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFF666666),
              ),
            ),
          ],
          SizedBox(height: 10.h),
          Wrap(
            spacing: 14.w,
            runSpacing: 6.h,
            children: [
              _stat(Icons.local_offer, '$discount% off'),
              _stat(Icons.star, 'L$requiredLevel • '
                  '${_levelNames[requiredLevel] ?? "?"}'),
              _stat(Icons.tour, '${tours.length} tour${tours.length == 1 ? '' : 's'}'),
              if (usedCount > 0)
                _stat(Icons.check_circle_outline, 'Used $usedCount'),
            ],
          ),
          if (isPartner && (partnerName.isNotEmpty || code.isNotEmpty)) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.storefront,
                      size: 14.sp, color: const Color(0xFF666666)),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      partnerName,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (code.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A86B),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        code,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (validUntil is Timestamp) ...[
            SizedBox(height: 6.h),
            Text(
              'Valid until ${validUntil.toDate().year}-${validUntil.toDate().month.toString().padLeft(2, '0')}-${validUntil.toDate().day.toString().padLeft(2, '0')}',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: const Color(0xFF999999),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.sp, color: const Color(0xFF666666)),
        SizedBox(width: 4.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: const Color(0xFF333333),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    GuideRewardsController controller,
    String id,
  ) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete reward?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await controller.deleteReward(id);
    }
  }
}
