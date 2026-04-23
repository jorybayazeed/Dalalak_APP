import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tourist/home/controllers/home_controller.dart';

class TouristRewardsView extends StatelessWidget {
  const TouristRewardsView({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<TouristHomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back<void>(),
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back, size: 20.sp),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Rewards',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              _PointsCard(home: home),
              SizedBox(height: 16.h),

              const _PointsReportSection(),
              SizedBox(height: 16.h),

              Text('Your Badges'),
              SizedBox(height: 12.h),
              _BadgesGrid(),

              SizedBox(height: 16.h),

              _HowToEarnPointsSection(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({required this.home});

  final TouristHomeController home;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final points = home.totalPoints.value;
      final levelName = home.levelName.value;
      final levelDescription = home.levelDescription.value;
      final levelNumber = home.levelNumber.value;
      final nextLevelName = home.nextLevelName.value;
      final remaining = home.remainingPointsToNextLevel.value;
      final progress = home.levelProgress.value.clamp(0.0, 1.0);
      final badges = home.badgesCount.value;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA000), Color(0xFFF57C00)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(31),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 58.w,
                  height: 58.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(46),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Total Points',
                        style: GoogleFonts.inter(
                          color: Colors.white.withAlpha(230),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$points',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 40.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Current Level',
                      style: GoogleFonts.inter(
                        color: Colors.white.withAlpha(230),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      levelName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Level $levelNumber',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        color: Colors.white.withAlpha(217),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              levelDescription,
              style: GoogleFonts.inter(
                color: Colors.white.withAlpha(230),
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(46),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Text(
                    levelName,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(46),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified, color: Colors.white, size: 14.sp),
                      SizedBox(width: 6.w),
                      Text(
                        '$badges Badges',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nextLevelName.isEmpty
                      ? 'Maximum level reached'
                      : '$remaining pts to $nextLevelName',
                  style: GoogleFonts.inter(
                    color: Colors.white.withAlpha(230),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: GoogleFonts.inter(
                    color: Colors.white.withAlpha(230),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12.h,
                backgroundColor: Colors.white.withAlpha(64),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _PointsReportSection extends StatelessWidget {
  const _PointsReportSection();

  String _labelForType(String type) {
    switch (type) {
      case 'booking':
        return 'booking';
      case 'save':
        return 'save';
      case 'quiz':
        return 'quiz';
      case 'rating':
        return 'rating';
      case 'tour_completion':
        return 'tour completion';
      default:
        return type.isEmpty ? 'points' : type;
    }
  }

  DateTime? _asDateTime(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final eventsQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('points_events')
        .orderBy('createdAt', descending: true)
        .limit(30);

    final quizQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('quiz_attempts')
        .orderBy('createdAt', descending: true)
        .limit(30);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFECECEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Points Report',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10.h),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: eventsQuery.snapshots(),
            builder: (context, eventsSnap) {
              if (eventsSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: quizQuery.snapshots(),
                builder: (context, quizSnap) {
                  if (quizSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final merged = <Map<String, dynamic>>[];

                  final eventDocs = eventsSnap.data?.docs ?? const [];
                  for (final d in eventDocs) {
                    final data = d.data();
                    merged.add({
                      'type': (data['type'] ?? '').toString(),
                      'packageId': (data['packageId'] ?? '').toString(),
                      'activityId': (data['activityId'] ?? '').toString(),
                      'points': (data['pointsEarned'] as num?)?.toInt() ?? 0,
                      'createdAt': data['createdAt'],
                    });
                  }

                  final quizDocs = quizSnap.data?.docs ?? const [];
                  for (final d in quizDocs) {
                    final data = d.data();
                    merged.add({
                      'type': 'quiz',
                      'packageId': (data['packageId'] ?? '').toString(),
                      'activityId': (data['activityId'] ?? '').toString(),
                      'points': (data['pointsEarned'] as num?)?.toInt() ?? 0,
                      'createdAt': data['createdAt'],
                    });
                  }

                  merged.sort((a, b) {
                    final at = _asDateTime(a['createdAt']);
                    final bt = _asDateTime(b['createdAt']);
                    if (at == null && bt == null) return 0;
                    if (at == null) return 1;
                    if (bt == null) return -1;
                    return bt.compareTo(at);
                  });

                  final top = merged.take(30).toList(growable: false);
                  if (top.isEmpty) {
                    return Text(
                      'No points events yet',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }

                  return Column(
                    children: top.map((row) {
                      final points = (row['points'] as int?) ?? 0;
                      final type = (row['type'] ?? '').toString();
                      final label = _labelForType(type);
                      final leftText = '${points >= 0 ? '+' : ''}$points';
                      final rightText = 'for $label';

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                leftText,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF00A86B),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                rightText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HowToEarnPointsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = <Map<String, dynamic>>[
      {
        'icon': Icons.check_circle,
        'title': 'Complete a tour',
        'points': '+100 points',
      },
      {'icon': Icons.star, 'title': 'Write a review', 'points': '+50 points'},
      {
        'icon': Icons.photo_camera,
        'title': 'Share photos',
        'points': '+25 points',
      },
      {'icon': Icons.group, 'title': 'Refer a friend', 'points': '+200 points'},
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE38B2C),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to Earn Points',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 14.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, index) {
              final it = items[index];

              return Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(31),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(46),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        it['icon'] as IconData,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            (it['title'] ?? '').toString(),
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            (it['points'] ?? '').toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: Colors.white.withAlpha(230),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
class _BadgesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final badges = List<String>.from(data['badges'] ?? []);

        final booking = data['bookingCount'] ?? 0;
        final reviews = data['reviewsCount'] ?? 0;
        final quiz = data['quizCount'] ?? 0;
        final completed = data['completedTours'] ?? 0;

        final badgeList = [
          _badgeData(
            key: 'first_booking',
            title: 'First Booking',
            subtitle: 'Book your first tour',
            icon: Icons.flight_takeoff,
            current: booking,
            required: 1,
          ),
          _badgeData(
            key: 'reviewer',
            title: 'Reviewer',
            subtitle: 'Write 3 reviews',
            icon: Icons.rate_review,
            current: reviews,
            required: 3,
          ),
          _badgeData(
            key: 'quiz_starter',
            title: 'Quiz Starter',
            subtitle: 'Complete 3 quiz',
            icon: Icons.quiz,
            current: quiz,
            required: 3,
          ),
          _badgeData(
            key: 'explorer',
            title: 'Explorer',
            subtitle: 'Complete 5 tour',
            icon: Icons.explore,
            current: completed,
            required: 5,
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: badgeList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final badge = badgeList[index];
            final unlocked = badges.contains(badge['key']);

            return _BadgeCard(
              title: badge['title'],
              subtitle: badge['subtitle'],
              icon: badge['icon'],
              locked: !unlocked,
              current: badge['current'],
              required: badge['required'],
            );
          },
        );
      },
    );
  }
}
Map<String, dynamic> _badgeData({
  required String key,
  required String title,
  required String subtitle,
  required IconData icon,
  required int current,
  required int required,
}) {
  return {
    'key': key,
    'title': title,
    'subtitle': subtitle,
    'icon': icon,
    'current': current,
    'required': required,
  };
}
class _BadgeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool locked;
  final int current;
  final int required;

  const _BadgeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.locked,
    required this.current,
    required this.required,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / required).clamp(0.0, 1.0);
    final displayCurrent = current > required ? required : current;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        Icon(
          icon,
          color: locked ? Colors.grey : const Color(0xFF00A86B),
        ),
        const Spacer(),
        if (locked)
          const Icon(Icons.lock, size: 16, color: Colors.grey),
      ],
    ),

    SizedBox(height: 8.h),

    Text(
      title,
      style: GoogleFonts.inter(fontWeight: FontWeight.w800),
    ),

    SizedBox(height: 2.h),

    Text(
      subtitle,
      maxLines: 2, 
      overflow: TextOverflow.ellipsis, 
      style: GoogleFonts.inter(
        fontSize: 12.sp,
        color: Colors.grey,
      ),
    ),

    const Spacer(), 

    LinearProgressIndicator(
      value: progress,
      minHeight: 6,
      backgroundColor: Colors.grey.shade200,
      valueColor: AlwaysStoppedAnimation(
        locked ? Colors.grey : const Color(0xFF00A86B),
      ),
    ),

    SizedBox(height: 6.h),



Text(
  locked
      ? '$displayCurrent / $required'
      : 'Completed',
  style: GoogleFonts.inter(
    fontSize: 11.sp,
    fontWeight: FontWeight.w600,
    color: locked ? Colors.grey : const Color(0xFF00A86B),
  ),
),
  ],
),
    );
  }
}
