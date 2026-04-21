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
              Text(
                'Milestones',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 12.h),
              Obx(() {
                final points = home.totalPoints.value;
                return _MilestonesGrid(points: points);
              }),
              SizedBox(height: 16.h),
              _EarnedBadgesSection(home: home),
              SizedBox(height: 16.h),
              _LockedBadgesSection(),
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
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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

class _MilestonesGrid extends StatelessWidget {
  const _MilestonesGrid({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, dynamic>>[
      {'points': 500, 'title': '10% discount'},
      {'points': 1000, 'title': 'Free tour upgrade'},
      {'points': 2000, 'title': 'VIP guide access'},
      {'points': 5000, 'title': 'Premium membership'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 1.4,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final m = items[index];
        final p = (m['points'] as int?) ?? 0;
        final title = (m['title'] ?? '').toString();
        final unlocked = points >= p;

        return Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: unlocked ? const Color(0xFFE9F7F2) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: unlocked ? const Color(0xFF00A86B) : const Color(0xFFE5E5E5),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$p',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF666666),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (unlocked)
                Container(
                  width: 26.w,
                  height: 26.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00A86B),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 16.sp),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EarnedBadgesSection extends StatelessWidget {
  const _EarnedBadgesSection({required this.home});

  final TouristHomeController home;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = home.badgesCount.value;

      final earned = <Map<String, dynamic>>[
        {
          'title': 'First Explorer',
          'subtitle': 'Completed your first tour',
          'points': 100,
          'date': '2024-11-01',
          'icon': Icons.star,
          'bg': const Color(0xFFFFF3E0),
        },
        {
          'title': 'Heritage Hunter',
          'subtitle': 'Visited 5 cultural heritage sites',
          'points': 250,
          'date': '2024-11-10',
          'icon': Icons.location_on,
          'bg': const Color(0xFFE8F5E9),
        },
        {
          'title': 'Photo Pro',
          'subtitle': 'Shared 10 tour photos',
          'points': 150,
          'date': '2024-11-12',
          'icon': Icons.photo_camera,
          'bg': const Color(0xFFE3F2FD),
        },
      ];

      final visible = earned.take(count.clamp(0, earned.length)).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Earned Badges',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A86B),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Text(
                  '${visible.length} Earned',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.25,
            ),
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final b = visible[index];
              return _BadgeCard(
                title: (b['title'] ?? '').toString(),
                subtitle: (b['subtitle'] ?? '').toString(),
                points: (b['points'] as int?) ?? 0,
                date: (b['date'] ?? '').toString(),
                icon: (b['icon'] as IconData?) ?? Icons.star,
                iconBg: (b['bg'] as Color?) ?? const Color(0xFFF5F5F5),
                locked: false,
                progress: null,
              );
            },
          ),
        ],
      );
    });
  }
}

class _LockedBadgesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locked = <Map<String, dynamic>>[
      {
        'title': 'Tour Master',
        'subtitle': 'Complete 10 tours',
        'points': 500,
        'icon': Icons.emoji_events,
        'progressText': '3 / 10',
        'progress': 0.30,
      },
      {
        'title': 'Review Expert',
        'subtitle': 'Write 20 detailed reviews',
        'points': 300,
        'icon': Icons.verified,
        'progressText': '8 / 20',
        'progress': 0.40,
      },
      {
        'title': 'Adventure Seeker',
        'subtitle': 'Try tours from 5 different categories',
        'points': 400,
        'icon': Icons.flash_on,
        'progressText': '2 / 5',
        'progress': 0.40,
      },
      {
        'title': 'Goal Getter',
        'subtitle': 'Complete 3 tours in one month',
        'points': 200,
        'icon': Icons.adjust,
        'progressText': '1 / 3',
        'progress': 0.33,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Locked Badges',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              'Complete challenges to unlock',
              style: GoogleFonts.inter(
                color: const Color(0xFF777777),
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 0.72,
          ),
          itemCount: locked.length,
          itemBuilder: (context, index) {
            final b = locked[index];
            return _BadgeCard(
              title: (b['title'] ?? '').toString(),
              subtitle: (b['subtitle'] ?? '').toString(),
              points: (b['points'] as int?) ?? 0,
              date: '',
              icon: (b['icon'] as IconData?) ?? Icons.lock,
              iconBg: const Color(0xFFF2F2F2),
              locked: true,
              progress: {
                'text': (b['progressText'] ?? '').toString(),
                'value': (b['progress'] as num?)?.toDouble() ?? 0.0,
              },
            );
          },
        ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.date,
    required this.icon,
    required this.iconBg,
    required this.locked,
    required this.progress,
  });

  final String title;
  final String subtitle;
  final int points;
  final String date;
  final IconData icon;
  final Color iconBg;
  final bool locked;
  final Map<String, dynamic>? progress;

 @override
Widget build(BuildContext context) {
  final progressValue = (progress?['value'] as num?)?.toDouble();
  final progressText = (progress?['text'] ?? '').toString();

  return Container(
    padding: EdgeInsets.all(8.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      border: Border.all(color: const Color(0xFFEDEDED)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18.sp,
                color: locked ? const Color(0xFF8E8E93) : const Color(0xFFF2994A),
              ),
            ),
            const Spacer(),
            if (locked)
              const Icon(Icons.lock_outline, size: 16, color: Color(0xFF8E8E93)),
          ],
        ),
        SizedBox(height: 10.h),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: const Color(0xFF1C1C1E),
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: const Color(0xFF6B6B6B),
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
        SizedBox(height: 4.h),
        if (!locked && date.isNotEmpty)
          Text(
            date,
            style: GoogleFonts.inter(
              color: const Color(0xFF8E8E93),
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (progressValue != null) ...[
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progressText,
                style: GoogleFonts.inter(
                  color: const Color(0xFF1C1C1E),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progressValue * 100).round()}%',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B6B6B),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 6.h,
              backgroundColor: const Color(0xFFEAEAEA),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFE85D75)),
            ),
          ),
        ],
        SizedBox(height: 8.h),
        Text(
          '+$points pts',
          style: GoogleFonts.inter(
            color: const Color(0xFFF2994A),
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
          ),
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
      {
        'icon': Icons.star,
        'title': 'Write a review',
        'points': '+50 points',
      },
      {
        'icon': Icons.photo_camera,
        'title': 'Share photos',
        'points': '+25 points',
      },
      {
        'icon': Icons.group,
        'title': 'Refer a friend',
        'points': '+200 points',
      },
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
)
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
