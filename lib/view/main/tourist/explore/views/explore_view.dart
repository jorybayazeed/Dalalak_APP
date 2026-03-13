import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tourist/explore/controllers/explore_controller.dart';
import 'package:tour_app/view/main/tourist/shared/widgets/bottom_navigation_bar.dart';
import 'package:tour_app/view/main/tourist/home/controllers/home_controller.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExploreController(), permanent: false);
    final homeController = Get.find<TouristHomeController>();
    if (homeController.currentBottomNavIndex.value != 1) {
      homeController.currentBottomNavIndex.value = 1;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: TextField(
                        controller: controller.searchController,
                        decoration: InputDecoration(
                          hintText: 'Search tours, destinations...',
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFF999999),
                            fontSize: 14.sp,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: const Color(0xFF666666),
                            size: 20.sp,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: controller.toggleFilters,
                    child: Container(
                      height: 48.h,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A86B),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_list,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Filters',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => controller.isFiltersVisible.value
                  ? Container(
                      margin: EdgeInsets.symmetric(horizontal: 18.w),
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter Tours',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          _buildFilterDropdown(
                            label: 'Region',
                            icon: Icons.location_on,
                            value: controller.selectedRegion.value,
                            onTap: () => _showRegionDialog(context, controller),
                          ),
                          SizedBox(height: 16.h),
                          _buildFilterDropdown(
                            label: 'Available Date',
                            icon: Icons.calendar_today,
                            value: controller.selectedDate.value,
                            onTap: () => _showDateDialog(context, controller),
                          ),
                          SizedBox(height: 16.h),
                          _buildFilterDropdown(
                            label: '\$ Price Range',
                            icon: Icons.attach_money,
                            value: controller.selectedPriceRange.value,
                            onTap: () => _showPriceDialog(context, controller),
                          ),
                          SizedBox(height: 16.h),
                          _buildFilterDropdown(
                            label: '☆ Activity Type',
                            icon: Icons.star,
                            value: controller.selectedActivityType.value,
                            onTap: () =>
                                _showActivityDialog(context, controller),
                          ),
                          SizedBox(height: 20.h),
                          Column(
                            children: [
                              Obx(
                                () => GestureDetector(
                                  onTap: controller.toggleAIRecommendations,
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color:
                                          controller.isAIRecommendations.value
                                          ? const Color(0xFF9C27B0)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: const Color(0xFF9C27B0),
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          controller.isAIRecommendations.value
                                              ? Icons.check_box
                                              : Icons.check_box_outline_blank,
                                          color:
                                              controller
                                                  .isAIRecommendations
                                                  .value
                                              ? Colors.white
                                              : const Color(0xFF9C27B0),
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Icon(
                                          Icons.auto_awesome,
                                          color:
                                              controller
                                                  .isAIRecommendations
                                                  .value
                                              ? Colors.white
                                              : const Color(0xFF9C27B0),
                                          size: 18.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'AI Recommendations',
                                          style: GoogleFonts.inter(
                                            color:
                                                controller
                                                    .isAIRecommendations
                                                    .value
                                                ? Colors.white
                                                : const Color(0xFF9C27B0),
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Obx(
                                () => GestureDetector(
                                  onTap: controller.toggleNearMe,
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: controller.isNearMe.value
                                          ? const Color(0xFF2196F3)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: const Color(0xFF2196F3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          controller.isNearMe.value
                                              ? Icons.check_box
                                              : Icons.check_box_outline_blank,
                                          color: controller.isNearMe.value
                                              ? Colors.white
                                              : const Color(0xFF2196F3),
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Icon(
                                          Icons.location_on,
                                          color: controller.isNearMe.value
                                              ? Colors.white
                                              : const Color(0xFF2196F3),
                                          size: 18.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'Near Me (< 10km)',
                                          style: GoogleFonts.inter(
                                            color: controller.isNearMe.value
                                                ? Colors.white
                                                : const Color(0xFF2196F3),
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: Obx(() {
                final toursList = controller.tours;
                final _ = toursList.length;
                final isAIRecommendations =
                    controller.isAIRecommendations.value;
                final isNearMe = controller.isNearMe.value;
                final searchText = controller.searchText.value;

                final filteredTours = toursList.where((tour) {
                  if (isAIRecommendations && !(tour['isAIPick'] ?? false)) {
                    return false;
                  }
                  if (isNearMe && tour['distance'] == null) {
                    return false;
                  }
                  if (searchText.isNotEmpty) {
                    final query = searchText.toLowerCase();
                    if (!(tour['tourTitle'] as String).toLowerCase().contains(
                          query,
                        ) &&
                        !(tour['destination'] as String).toLowerCase().contains(
                          query,
                        )) {
                      return false;
                    }
                  }
                  return true;
                }).toList();

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${filteredTours.length} tours found',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF666666),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: filteredTours.isEmpty
                          ? Center(
                              child: Text(
                                'No tours found',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF999999),
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: Column(
                                children: [
                                  ...filteredTours.map(
                                    (tour) => _buildTourCard(tour, controller),
                                  ),
                                  SizedBox(height: 24.h),
                                ],
                              ),
                            ),
                    ),
                  ],
                );
              }),
            ),
            TouristBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF666666), size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF666666),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: const Color(0xFF666666),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showRegionDialog(BuildContext context, ExploreController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Region',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            _buildOptionItem(
              'All Regions',
              controller.selectedRegion.value,
              () {
                controller.selectRegion('All Regions');
                Navigator.pop(context);
              },
            ),
            _buildOptionItem('AlUla', controller.selectedRegion.value, () {
              controller.selectRegion('AlUla');
              Navigator.pop(context);
            }),
            _buildOptionItem('Riyadh', controller.selectedRegion.value, () {
              controller.selectRegion('Riyadh');
              Navigator.pop(context);
            }),
            _buildOptionItem('Jeddah', controller.selectedRegion.value, () {
              controller.selectRegion('Jeddah');
              Navigator.pop(context);
            }),
            _buildOptionItem('Diriyah', controller.selectedRegion.value, () {
              controller.selectRegion('Diriyah');
              Navigator.pop(context);
            }),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showDateDialog(BuildContext context, ExploreController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Date',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            _buildOptionItem('Any Date', controller.selectedDate.value, () {
              controller.selectDate('Any Date');
              Navigator.pop(context);
            }),
            _buildOptionItem('Today', controller.selectedDate.value, () {
              controller.selectDate('Today');
              Navigator.pop(context);
            }),
            _buildOptionItem('This Week', controller.selectedDate.value, () {
              controller.selectDate('This Week');
              Navigator.pop(context);
            }),
            _buildOptionItem('This Month', controller.selectedDate.value, () {
              controller.selectDate('This Month');
              Navigator.pop(context);
            }),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showPriceDialog(BuildContext context, ExploreController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Price Range',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            _buildOptionItem(
              'Any Price',
              controller.selectedPriceRange.value,
              () {
                controller.selectPriceRange('Any Price');
                Navigator.pop(context);
              },
            ),
            _buildOptionItem(
              'Under 300 SAR',
              controller.selectedPriceRange.value,
              () {
                controller.selectPriceRange('Under 300 SAR');
                Navigator.pop(context);
              },
            ),
            _buildOptionItem(
              '300 - 500 SAR',
              controller.selectedPriceRange.value,
              () {
                controller.selectPriceRange('300 - 500 SAR');
                Navigator.pop(context);
              },
            ),
            _buildOptionItem(
              'Above 500 SAR',
              controller.selectedPriceRange.value,
              () {
                controller.selectPriceRange('Above 500 SAR');
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showActivityDialog(BuildContext context, ExploreController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Activity Type',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            _buildOptionItem(
              'All Activities',
              controller.selectedActivityType.value,
              () {
                controller.selectActivityType('All Activities');
                Navigator.pop(context);
              },
            ),
            _buildOptionItem(
              'Cultural Heritage',
              controller.selectedActivityType.value,
              () {
                controller.selectActivityType('Cultural Heritage');
                Navigator.pop(context);
              },
            ),
            _buildOptionItem(
              'Adventure',
              controller.selectedActivityType.value,
              () {
                controller.selectActivityType('Adventure');
                Navigator.pop(context);
              },
            ),
            _buildOptionItem(
              'Photography',
              controller.selectedActivityType.value,
              () {
                controller.selectActivityType('Photography');
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    String option,
    String selectedValue,
    VoidCallback onTap,
  ) {
    final isSelected = option == selectedValue;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: GoogleFonts.inter(
                  color: isSelected ? const Color(0xFF00A86B) : Colors.black,
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: const Color(0xFF00A86B), size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildTourCard(
    Map<String, dynamic> tour,
    ExploreController controller,
  ) {
    final isFavorite = tour['isFavorite'] ?? false;
    final isAIPick = tour['isAIPick'] ?? false;
    final distance = tour['distance'];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 200.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
                child: tour['image'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.r),
                          topRight: Radius.circular(12.r),
                        ),
                        child: Image.asset(
                          tour['image'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFE0E0E0),
                              child: Icon(
                                Icons.image,
                                size: 48.sp,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      )
                    : Icon(Icons.image, size: 48.sp, color: Colors.grey),
              ),
              if (isAIPick)
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'AI Pick',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (distance != null)
                Positioned(
                  bottom: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      distance,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 12.h,
                right: 12.w,
                child: GestureDetector(
                  onTap: () => controller.toggleFavorite(tour['id'] as String),
                  child: Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : const Color(0xFF666666),
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tour['tourTitle'] ?? '',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: const Color(0xFF666666),
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      tour['destination'] ?? '',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF666666),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.access_time,
                      color: const Color(0xFF666666),
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "${tour['durationValue']} ${tour['durationUnit']}",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF666666),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '${tour['rating'] ?? 0} (${tour['reviews'] ?? 0})',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${tour['price']} SAR" ,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF00A86B),
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                     'Guide',
                      style: GoogleFonts.inter(
                      color: const Color(0xFF666666),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                     ),
                   ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
