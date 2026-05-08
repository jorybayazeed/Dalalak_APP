import 'package:cloud_firestore/cloud_firestore.dart';

/// نتيجة تطابق مرشد واحد مع السائح
class GuideMatch {
  final String guideId;
  final String guideName;
  final double rating;
  final int reviews;
  final int yearsOfExperience;
  final List<String> languages;
  final List<String> specializations;
  final double price; // average package price
  final double matchScore; // 0–100
  final List<String> matchReasons;

  const GuideMatch({
    required this.guideId,
    required this.guideName,
    required this.rating,
    required this.reviews,
    required this.yearsOfExperience,
    required this.languages,
    required this.specializations,
    required this.price,
    required this.matchScore,
    required this.matchReasons,
  });
}

/// طلب مطابقة مرشد من قبل السائح
class GuideMatchRequest {
  final String tourId; // Package being booked
  final String destination;
  final String activityType;
  final double budget; // per person
  final String tripType; // solo, couple, family, group
  final List<String> preferredLanguages;
  final String guideId; // current guide offering this package

  const GuideMatchRequest({
    required this.tourId,
    required this.destination,
    required this.activityType,
    required this.budget,
    required this.tripType,
    required this.preferredLanguages,
    required this.guideId,
  });
}

/// خدمة Smart Guide Matching
///
/// خوارزمية تسجيل نقاط المرشد (0–100):
///   - تطابق اللغة       (30%)
///   - التقييم والمراجعات (25%)
///   - سنوات الخبرة      (20%)
///   - تخصص النشاط       (15%)
///   - الميزانية          (10%)
class GuideMatchingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// البحث عن أفضل 3 مرشدين يتطابقون مع طلب الرحلة
  Future<List<GuideMatch>> findBestGuides(GuideMatchRequest request) async {
    try {
      // جلب كل المرشدين (المستخدمون بدور tour_guide)
      final snapshot = await _db
          .collection('users')
          .where('userType', isEqualTo: 'tourGuide')
          .limit(60)
          .get();

      if (snapshot.docs.isEmpty) return [];

      final List<GuideMatch> matches = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final guideId = doc.id;

        // تجاهل المرشد الحالي صاحب الباقة
        if (guideId == request.guideId) continue;

        try {
          final match = await _scoreGuide(
            guideId: guideId,
            data: data,
            request: request,
          );
          if (match != null) {
            matches.add(match);
          }
        } catch (_) {
          continue;
        }
      }

      // ترتيب تنازلي حسب النقاط ثم إرجاع أفضل 3
      matches.sort((a, b) => b.matchScore.compareTo(a.matchScore));
      return matches.take(3).toList();
    } catch (_) {
      return [];
    }
  }

  Future<GuideMatch?> _scoreGuide({
    required String guideId,
    required Map<String, dynamic> data,
    required GuideMatchRequest request,
  }) async {
    final name = (data['fullName'] ?? data['name'] ?? 'Guide').toString().trim();
    if (name.isEmpty || name == 'Guide') return null;

    final languages = _toStringList(data['languages'] ?? data['languagesSpoken']);
    final specializations = _toStringList(
      data['specializations'] ?? data['specialization'],
    );
    final yearsRaw = data['yearsOfExperience'];
    final years = yearsRaw is num
        ? yearsRaw.toInt()
        : int.tryParse(yearsRaw?.toString() ?? '') ?? 0;

    // جلب متوسط تقييم باقاته
    double avgRating = 0;
    int totalReviews = 0;
    double avgPrice = 0;
    try {
      final packages = await _db
          .collection('tourPackages')
          .where('guideId', isEqualTo: guideId)
          .limit(10)
          .get();

      if (packages.docs.isEmpty) return null; // مرشد بدون باقات لا يُعرض

      double ratingSum = 0;
      double priceSum = 0;
      int ratedCount = 0;
      for (final p in packages.docs) {
        final pd = p.data();
        final r = (pd['rating'] as num?)?.toDouble() ?? 0;
        if (r > 0) {
          ratingSum += r;
          ratedCount++;
        }
        totalReviews += (pd['reviews'] as num?)?.toInt() ?? 0;
        priceSum += _parsePrice(pd['price']);
      }
      avgRating = ratedCount > 0 ? ratingSum / ratedCount : 0;
      avgPrice = priceSum / packages.docs.length;
    } catch (_) {
      return null;
    }

    double score = 0;
    final List<String> reasons = [];

    // 1. تطابق اللغة (30%)
    final langScore = _scoreLang(languages, request.preferredLanguages);
    score += langScore * 30;
    if (langScore > 0.8) {
      reasons.add('Speaks your language');
    }

    // 2. التقييم (25%)
    final ratingScore = avgRating / 5.0;
    score += ratingScore * 25;
    if (avgRating >= 4.5) {
      reasons.add('Top-rated guide (${avgRating.toStringAsFixed(1)}★)');
    } else if (avgRating >= 4.0) {
      reasons.add('Highly rated (${avgRating.toStringAsFixed(1)}★)');
    }

    // 3. سنوات الخبرة (20%)
    final expScore = (years.clamp(0, 15) / 15.0);
    score += expScore * 20;
    if (years >= 5) {
      reasons.add('$years years of experience');
    }

    // 4. تخصص النشاط (15%)
    final specScore = _scoreSpec(specializations, request.activityType);
    score += specScore * 15;
    if (specScore > 0.7) {
      reasons.add('Specialises in ${request.activityType}');
    }

    // 5. الميزانية (10%)
    final budgetScore = _scoreBudget(avgPrice, request.budget);
    score += budgetScore * 10;
    if (budgetScore > 0.8) {
      reasons.add('Fits your budget');
    }

    if (reasons.isEmpty) {
      reasons.add('Good overall match');
    }

    return GuideMatch(
      guideId: guideId,
      guideName: name,
      rating: avgRating,
      reviews: totalReviews,
      yearsOfExperience: years,
      languages: languages,
      specializations: specializations,
      price: avgPrice,
      matchScore: score.clamp(0, 100),
      matchReasons: reasons,
    );
  }

  // ────────── Helpers ──────────

  double _scoreLang(List<String> guideLangs, List<String> preferred) {
    if (preferred.isEmpty) return 0.5;
    if (guideLangs.isEmpty) return 0.2;
    final gl = guideLangs.map((e) => e.toLowerCase()).toSet();
    final pl = preferred.map((e) => e.toLowerCase()).toSet();
    final overlap = gl.intersection(pl).length;
    return overlap > 0 ? (overlap / pl.length).clamp(0.0, 1.0) : 0.1;
  }

  double _scoreSpec(List<String> specs, String activityType) {
    if (activityType.isEmpty) return 0.5;
    if (specs.isEmpty) return 0.3;
    final act = activityType.toLowerCase();
    for (final s in specs) {
      if (s.toLowerCase().contains(act) || act.contains(s.toLowerCase())) {
        return 1.0;
      }
    }
    return 0.2;
  }

  double _scoreBudget(double guideAvgPrice, double touristBudget) {
    if (touristBudget <= 0) return 0.5;
    if (guideAvgPrice <= 0) return 0.5;
    final ratio = guideAvgPrice / touristBudget;
    if (ratio <= 1.0) return 1.0; // within budget
    if (ratio <= 1.2) return 0.7;
    if (ratio <= 1.5) return 0.4;
    return 0.1; // well over budget
  }

  List<String> _toStringList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw is String && raw.isNotEmpty) return [raw];
    return [];
  }

  double _parsePrice(dynamic v) {
    if (v is num) return v.toDouble();
    final raw = (v ?? '').toString().trim();
    if (raw.isEmpty) return 0;
    final cleaned = raw.replaceAll(RegExp(r'[^0-9\.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }
}
