import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tour_app/models/constants.dart';

/// Recommendation Service with Custom Algorithm
/// 
/// Advanced recommendation approach combining:
/// 1. Rule-based filtering (region, date, price, activity type)
/// 2. Multi-factor scoring (interests, budget, pace, trip type, group size, rating, recency)
/// 3. Personality-based ranking (matching tourist profile with package attributes)
/// 4. Negative scoring for mismatches (avoiding unsuitable packages)
/// 
/// Scoring Weights:
/// - Interest Matching (35%) - Highest priority for satisfaction
/// - Trip Type Matching (15%) - Group compatibility
/// - Budget Matching (15%) - Financial fit
/// - Travel Pace (12%) - Activity intensity match
/// - Group Size (10%) - Party size compatibility
/// - Rating & Popularity (8%) - Quality indicator
/// - Destination Relevance (5%) - Location preference
/// - Recency Bonus (3%) - Freshness of package
/// - Negative Penalties - Unsuitable matches reduce score
class RecommendationService {
  /// Score a single package against a tourist profile
  /// Returns a score from 0 to 100 (higher is better match)
  static double scorePackageForTourist({
    required Map<String, dynamic> package,
    required Map<String, dynamic> touristProfile,
    required String selectedInterest, // Currently active interest filter (if any)
  }) {
    double score = 50; // baseline score

    // ========== EXTRACT PACKAGE DATA ==========
    final String packageActivityType =
        (package['activityType'] as String? ?? '').toLowerCase();
    final String packageDescription =
        (package['tourDescription'] as String? ?? '').toLowerCase();
    final String packageTitle = (package['tourTitle'] as String? ?? '').toLowerCase();
    final String? priceStr = package['price'] as String?;
    final double packagePrice = _parsePrice(priceStr) ?? 0;
    final String packageDest = (package['destination'] as String? ?? '').toLowerCase();
    final String? maxGroupSizeStr = package['maxGroupSize'] as String?;
    final int packageMaxGroupSize = _parseIntSafe(maxGroupSizeStr) ?? 10;
    final double packageRating = (package['rating'] as num?)?.toDouble() ?? 0.0;
    final int packageBookings = (package['bookings'] as num?)?.toInt() ?? 0;
    final List<dynamic> activities = package['activities'] as List<dynamic>? ?? [];
    final Timestamp? createdAt = package['createdAt'];

    // ========== EXTRACT TOURIST PROFILE DATA ==========
    final String touristBudget =
        (touristProfile['travelBudget'] as String? ?? '').toLowerCase();
    final String touristBudgetNormalized = AppConstants.normalizeBudget(touristBudget);
    final List<String> touristInterests =
        (touristProfile['interests'] as List<dynamic>?)
                ?.map((e) => e.toString().toLowerCase())
                .toList() ??
            [];
    final String touristTravelPace =
        (touristProfile['travelPace'] as String? ?? '').toLowerCase();
    final String touristTravelPaceNormalized =
        AppConstants.normalizePace(touristTravelPace);
    final String touristTripType =
        (touristProfile['tripType'] as String? ?? '').toLowerCase();
    final String touristCountry =
        (touristProfile['countryOfResidence'] as String? ?? '').toLowerCase();

    // ========== APPLY WEIGHTED SCORING ==========

    // 1. Interest Matching (35%) - HIGHEST PRIORITY
    score += _scoreInterestMatch(
      packageActivityType,
      packageDescription,
      packageTitle,
      activities,
      touristInterests,
      selectedInterest,
    ) * 0.35;

    // 2. Trip Type Matching (15%)
    score += _scoreTripTypeMatch(
      packageDescription,
      packageTitle,
      touristTripType,
      packageActivityType,
    ) * 0.15;

    // 3. Budget Matching (15%)
    score += _scoreBudgetMatch(packagePrice, touristBudgetNormalized) * 0.15;

    // 4. Travel Pace Matching (12%)
    score += _scoreTravelPaceMatch(
      packageDescription,
      packageTitle,
      touristTravelPaceNormalized,
    ) * 0.12;

    // 5. Group Size Compatibility (10%)
    score += _scoreGroupSizeMatch(packageMaxGroupSize, touristTripType) * 0.10;

    // 6. Rating & Popularity Boost (8%)
    score += _scoreRatingAndPopularity(packageRating, packageBookings) * 0.08;

    // 7. Destination Relevance (5%)
    score += _scoreDestinationBoost(packageDest, touristCountry) * 0.05;

    // 8. Recency Bonus (3%)
    score += _scoreRecency(createdAt) * 0.03;

    // 9. Apply Negative Penalties for Major Mismatches
    score += _applyNegativePenalties(
      packagePrice,
      touristBudgetNormalized,
      packageActivityType,
      touristInterests,
      packageMaxGroupSize,
      touristTripType,
    );

    // 10. Selected Interest Boost
    if (selectedInterest.isNotEmpty &&
        (packageActivityType.contains(selectedInterest.toLowerCase()) ||
            packageDescription.contains(selectedInterest.toLowerCase()))) {
      score += 10;
    }

    // Clamp score to 0-100
    return max(0, min(100, score));
  }

  // ============================================================================
  // SCORING COMPONENTS
  // ============================================================================

  /// Interest Matching: Compare package activity type and description
  /// with tourist interests
  static double _scoreInterestMatch(
    String packageActivityType,
    String packageDescription,
    String packageTitle,
    List<dynamic> activities,
    List<String> touristInterests,
    String selectedInterest,
  ) {
    if (touristInterests.isEmpty) return 50;

    int matchCount = 0;
    final text = '$packageActivityType $packageDescription $packageTitle';

    for (final interest in touristInterests) {
      if (text.contains(interest)) {
        matchCount++;
      }
    }

    // Bonus for activities in package
    if (activities.isNotEmpty) {
      matchCount++;
    }

    // Bonus for selected interest
    if (selectedInterest.isNotEmpty && text.contains(selectedInterest.toLowerCase())) {
      matchCount++;
    }

    return min(100, (matchCount / (touristInterests.length + 2)) * 100);
  }

  /// Trip Type Matching
  static double _scoreTripTypeMatch(
    String packageDescription,
    String packageTitle,
    String touristTripType,
    String packageActivityType,
  ) {
    final text = '$packageDescription $packageTitle $packageActivityType';

    switch (touristTripType) {
      case 'solo':
        if (text.contains('solo') || text.contains('independent')) return 80;
        return 60;
      case 'couple':
        if (text.contains('romantic') || text.contains('couple')) return 80;
        return 65;
      case 'family':
        if (text.contains('family') || text.contains('kids')) return 80;
        return 70;
      case 'group':
        if (text.contains('group') || text.contains('tour')) return 80;
        return 75;
      default:
        return 50;
    }
  }

  /// Budget Matching
  static double _scoreBudgetMatch(double packagePrice, String touristBudgetNormalized) {
    if (packagePrice == 0) return 50;

    switch (touristBudgetNormalized) {
      case 'low':
        if (packagePrice <= 300) return 100;
        if (packagePrice <= 500) return 70;
        return 30;
      case 'medium':
        if (packagePrice >= 300 && packagePrice <= 800) return 100;
        if (packagePrice <= 200 || packagePrice <= 1000) return 70;
        return 40;
      case 'high':
        if (packagePrice >= 800) return 100;
        if (packagePrice >= 500) return 80;
        return 60;
      default:
        return 50;
    }
  }

  /// Travel Pace Matching
  static double _scoreTravelPaceMatch(
    String packageDescription,
    String packageTitle,
    String touristTravelPaceNormalized,
  ) {
    final text = '$packageDescription $packageTitle';

    switch (touristTravelPaceNormalized) {
      case 'relaxed':
        if (text.contains('relaxing') || text.contains('leisure')) return 80;
        return 50;
      case 'moderate':
        if (text.contains('balanced') || text.contains('tour')) return 80;
        return 60;
      case 'adventurous':
        if (text.contains('adventure') || text.contains('active')) return 80;
        return 50;
      default:
        return 50;
    }
  }

  /// Group Size Matching
  static double _scoreGroupSizeMatch(int packageMaxGroupSize, String touristTripType) {
    switch (touristTripType) {
      case 'solo':
        return packageMaxGroupSize <= 5 ? 90 : 70;
      case 'couple':
        return packageMaxGroupSize <= 8 ? 90 : 75;
      case 'family':
        return packageMaxGroupSize >= 8 ? 90 : 70;
      case 'group':
        return packageMaxGroupSize >= 15 ? 90 : 75;
      default:
        return 70;
    }
  }

  /// Rating and Popularity Boost
  static double _scoreRatingAndPopularity(double packageRating, int packageBookings) {
    double score = packageRating * 10; // 0-50 from rating (0-5 stars)
    if (packageBookings > 10) {
      score += 30;
    } else if (packageBookings > 5) {
      score += 15;
    }
    return min(100, score);
  }

  /// Destination Relevance (Saudi Arabia cities)
  static double _scoreDestinationBoost(String packageDest, String touristCountry) {
    if (touristCountry.contains('saudi') ||
        touristCountry.contains('ksa') ||
        touristCountry.contains('المملكة')) {
      // Tourist is in Saudi Arabia - all destinations are relevant
      return 80;
    }
    // Tourist is from abroad - all packages in Saudi Arabia are relevant
    return 75;
  }

  /// Recency Bonus (newer packages > older packages)
  static double _scoreRecency(Timestamp? createdAt) {
    if (createdAt == null) return 40;

    final diff = DateTime.now().difference(createdAt.toDate()).inDays;
    if (diff <= 7) return 80;
    if (diff <= 30) return 60;
    if (diff <= 90) return 40;
    return 20;
  }

  /// Negative Penalties for Major Mismatches
  static double _applyNegativePenalties(
    double packagePrice,
    String touristBudgetNormalized,
    String packageActivityType,
    List<String> touristInterests,
    int packageMaxGroupSize,
    String touristTripType,
  ) {
    double penalty = 0;

    // Penalty for severe budget mismatch
    if (touristBudgetNormalized == 'low' && packagePrice > 1000) {
      penalty -= 30;
    } else if (touristBudgetNormalized == 'high' && packagePrice < 100) {
      penalty -= 10;
    }

    // Penalty for severe group size mismatch
    if (touristTripType == 'solo' && packageMaxGroupSize < 2) {
      penalty -= 20;
    } else if (touristTripType == 'group' && packageMaxGroupSize < 10) {
      penalty -= 15;
    }

    // Penalty for no interest match
    if (touristInterests.isNotEmpty && packageActivityType.isEmpty) {
      penalty -= 10;
    }

    return penalty;
  }

  // ============================================================================
  // UTILITY FUNCTIONS
  // ============================================================================

  static double? _parsePrice(String? priceStr) {
    if (priceStr == null || priceStr.isEmpty) return null;
    return double.tryParse(priceStr);
  }

  static int? _parseIntSafe(String? valueStr) {
    if (valueStr == null || valueStr.isEmpty) return null;
    return int.tryParse(valueStr);
  }
}
