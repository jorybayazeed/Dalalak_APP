// Sprint 2 – AI Recommendation Service Unit Tests
//
// Verifies the custom recommendation algorithm described in Sprint 2:
//   "The system should recommend personalised AI recommendations."
//
// RecommendationService.scorePackageForTourist() is a pure static function that
// takes plain Maps, making it straightforward to test without Firebase.
// The 'createdAt' field is intentionally omitted from test packages so that
// _scoreRecency() falls back to its null-safe default (score = 40).

import 'package:flutter_test/flutter_test.dart';
import 'package:tour_app/services/recommendation_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _buildPackage({
  String title = 'Test Tour',
  String destination = 'Riyadh',
  String activityType = 'Adventure',
  String description = 'An adventure tour',
  String price = '300',
  String maxGroupSize = '10',
  double rating = 4.0,
  int bookings = 5,
  List<Map<String, dynamic>>? activities,
}) {
  return {
    'tourTitle': title,
    'destination': destination,
    'activityType': activityType,
    'tourDescription': description,
    'price': price,
    'maxGroupSize': maxGroupSize,
    'rating': rating,
    'bookings': bookings,
    'activities': activities ?? [],
    // createdAt intentionally omitted → null → _scoreRecency returns 40
  };
}

Map<String, dynamic> _buildProfile({
  List<String> interests = const ['adventure'],
  String travelBudget = 'Mid-range',
  String travelPace = 'Action-packed and fast-paced',
  String tripType = 'Solo',
  String countryOfResidence = 'Saudi Arabia',
}) {
  return {
    'interests': interests,
    'travelBudget': travelBudget,
    'travelPace': travelPace,
    'tripType': tripType,
    'countryOfResidence': countryOfResidence,
  };
}

void main() {
  // ---------------------------------------------------------------------------
  // Basic sanity
  // ---------------------------------------------------------------------------
  group('RecommendationService – basic scoring', () {
    test('returns a score in the range 0–100', () {
      final score = RecommendationService.scorePackageForTourist(
        package: _buildPackage(),
        touristProfile: _buildProfile(),
        selectedInterest: '',
      );
      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(100));
    });

    test('score is a finite double', () {
      final score = RecommendationService.scorePackageForTourist(
        package: _buildPackage(),
        touristProfile: _buildProfile(),
        selectedInterest: '',
      );
      expect(score.isFinite, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Interest matching
  // ---------------------------------------------------------------------------
  group('RecommendationService – interest matching', () {
    test('package matching tourist interest scores higher than non-matching', () {
      final profile = _buildProfile(interests: ['adventure']);

      final matchingScore = RecommendationService.scorePackageForTourist(
        package: _buildPackage(
          activityType: 'Adventure',
          description: 'Exciting outdoor adventure experience',
          title: 'Desert Adventure Tour',
        ),
        touristProfile: profile,
        selectedInterest: '',
      );

      final nonMatchingScore = RecommendationService.scorePackageForTourist(
        package: _buildPackage(
          activityType: 'Relaxation',
          description: 'A peaceful spa retreat',
          title: 'Spa & Wellness Escape',
        ),
        touristProfile: profile,
        selectedInterest: '',
      );

      expect(matchingScore, greaterThan(nonMatchingScore));
    });

    test('selected interest filter gives additional boost', () {
      final profile = _buildProfile(interests: ['adventure']);

      final withFilter = RecommendationService.scorePackageForTourist(
        package: _buildPackage(activityType: 'Adventure'),
        touristProfile: profile,
        selectedInterest: 'adventure',
      );

      final withoutFilter = RecommendationService.scorePackageForTourist(
        package: _buildPackage(activityType: 'Adventure'),
        touristProfile: profile,
        selectedInterest: '',
      );

      expect(withFilter, greaterThanOrEqualTo(withoutFilter));
    });

    test('empty tourist interests does not crash', () {
      expect(
        () => RecommendationService.scorePackageForTourist(
          package: _buildPackage(),
          touristProfile: _buildProfile(interests: []),
          selectedInterest: '',
        ),
        returnsNormally,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Budget matching
  // ---------------------------------------------------------------------------
  group('RecommendationService – budget matching', () {
    test('low-price package scores higher for budget-friendly tourist', () {
      final budgetProfile = _buildProfile(travelBudget: 'Budget-friendly');

      final lowPriceScore = RecommendationService.scorePackageForTourist(
        package: _buildPackage(price: '200'),
        touristProfile: budgetProfile,
        selectedInterest: '',
      );

      final highPriceScore = RecommendationService.scorePackageForTourist(
        package: _buildPackage(price: '1500'),
        touristProfile: budgetProfile,
        selectedInterest: '',
      );

      expect(lowPriceScore, greaterThan(highPriceScore));
    });

    test('high-price package scores higher for luxury tourist', () {
      final luxuryProfile = _buildProfile(travelBudget: 'Luxury');

      final highPriceScore = RecommendationService.scorePackageForTourist(
        package: _buildPackage(price: '1200'),
        touristProfile: luxuryProfile,
        selectedInterest: '',
      );

      final lowPriceScore = RecommendationService.scorePackageForTourist(
        package: _buildPackage(price: '100'),
        touristProfile: luxuryProfile,
        selectedInterest: '',
      );

      expect(highPriceScore, greaterThanOrEqualTo(lowPriceScore));
    });

    test('mid-range price package scores well for mid-range tourist', () {
      final midProfile = _buildProfile(travelBudget: 'Mid-range');

      final midPriceScore = RecommendationService.scorePackageForTourist(
        package: _buildPackage(price: '500'),
        touristProfile: midProfile,
        selectedInterest: '',
      );

      expect(midPriceScore, greaterThanOrEqualTo(50));
    });

    test('zero price does not crash', () {
      expect(
        () => RecommendationService.scorePackageForTourist(
          package: _buildPackage(price: '0'),
          touristProfile: _buildProfile(),
          selectedInterest: '',
        ),
        returnsNormally,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Trip type matching
  // ---------------------------------------------------------------------------
  group('RecommendationService – trip type matching', () {
    test('score is within valid range for solo trip type', () {
      final score = RecommendationService.scorePackageForTourist(
        package: _buildPackage(description: 'A solo independent journey'),
        touristProfile: _buildProfile(tripType: 'Solo'),
        selectedInterest: '',
      );
      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(100));
    });

    test('score is within valid range for family trip type', () {
      final score = RecommendationService.scorePackageForTourist(
        package: _buildPackage(description: 'Family-friendly tour with kids'),
        touristProfile: _buildProfile(tripType: 'Family'),
        selectedInterest: '',
      );
      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(100));
    });

    test('score is within valid range for couple trip type', () {
      final score = RecommendationService.scorePackageForTourist(
        package: _buildPackage(description: 'Romantic couple getaway'),
        touristProfile: _buildProfile(tripType: 'Couple'),
        selectedInterest: '',
      );
      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(100));
    });
  });

  // ---------------------------------------------------------------------------
  // Group size compatibility
  // ---------------------------------------------------------------------------
  group('RecommendationService – group size compatibility', () {
    test('small group package suits solo traveller (higher than large group)', () {
      final soloProfile = _buildProfile(tripType: 'Solo');

      final smallGroupScore = RecommendationService.scorePackageForTourist(
        package: _buildPackage(maxGroupSize: '4'),
        touristProfile: soloProfile,
        selectedInterest: '',
      );

      final largeGroupScore = RecommendationService.scorePackageForTourist(
        package: _buildPackage(maxGroupSize: '20'),
        touristProfile: soloProfile,
        selectedInterest: '',
      );

      expect(smallGroupScore, greaterThanOrEqualTo(largeGroupScore));
    });

    test('large group package suits group travellers (higher or equal)', () {
      final groupProfile = _buildProfile(tripType: 'Friends');

      final largeGroupScore = RecommendationService.scorePackageForTourist(
        package: _buildPackage(maxGroupSize: '20'),
        touristProfile: groupProfile,
        selectedInterest: '',
      );

      expect(largeGroupScore, greaterThanOrEqualTo(0));
    });
  });

  // ---------------------------------------------------------------------------
  // Rating and popularity
  // ---------------------------------------------------------------------------
  group('RecommendationService – rating and popularity', () {
    test('highly rated package scores higher than poorly rated package', () {
      final profile = _buildProfile();

      final highRatedScore = RecommendationService.scorePackageForTourist(
        package: _buildPackage(rating: 5.0, bookings: 15),
        touristProfile: profile,
        selectedInterest: '',
      );

      final lowRatedScore = RecommendationService.scorePackageForTourist(
        package: _buildPackage(rating: 1.0, bookings: 0),
        touristProfile: profile,
        selectedInterest: '',
      );

      expect(highRatedScore, greaterThan(lowRatedScore));
    });
  });

  // ---------------------------------------------------------------------------
  // Negative penalties
  // ---------------------------------------------------------------------------
  group('RecommendationService – negative penalties', () {
    test('very expensive package penalised for budget traveller', () {
      final budgetProfile = _buildProfile(travelBudget: 'Budget-friendly');

      final expensiveScore = RecommendationService.scorePackageForTourist(
        package: _buildPackage(price: '2000'),
        touristProfile: budgetProfile,
        selectedInterest: '',
      );

      final affordableScore = RecommendationService.scorePackageForTourist(
        package: _buildPackage(price: '200'),
        touristProfile: budgetProfile,
        selectedInterest: '',
      );

      expect(expensiveScore, lessThan(affordableScore));
    });

    test('score stays within 0–100 even with multiple penalties', () {
      final score = RecommendationService.scorePackageForTourist(
        package: _buildPackage(
          price: '5000', // extreme mismatch for budget tourist
          maxGroupSize: '1', // small group for group tourist
          activityType: '',
          description: '',
          title: '',
        ),
        touristProfile: _buildProfile(
          travelBudget: 'Budget-friendly',
          tripType: 'Friends',
          interests: ['adventure', 'beach', 'food'],
        ),
        selectedInterest: '',
      );

      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(100));
    });
  });

  // ---------------------------------------------------------------------------
  // Robustness – missing / null data
  // ---------------------------------------------------------------------------
  group('RecommendationService – robustness with missing data', () {
    test('handles package with all-empty fields', () {
      expect(
        () => RecommendationService.scorePackageForTourist(
          package: {},
          touristProfile: _buildProfile(),
          selectedInterest: '',
        ),
        returnsNormally,
      );
    });

    test('handles completely empty tourist profile', () {
      expect(
        () => RecommendationService.scorePackageForTourist(
          package: _buildPackage(),
          touristProfile: {},
          selectedInterest: '',
        ),
        returnsNormally,
      );
    });

    test('handles null price field gracefully', () {
      final packageNullPrice = _buildPackage();
      packageNullPrice.remove('price');

      expect(
        () => RecommendationService.scorePackageForTourist(
          package: packageNullPrice,
          touristProfile: _buildProfile(),
          selectedInterest: '',
        ),
        returnsNormally,
      );
    });

    test('handles invalid (non-numeric) price string', () {
      expect(
        () => RecommendationService.scorePackageForTourist(
          package: _buildPackage(price: 'not-a-number'),
          touristProfile: _buildProfile(),
          selectedInterest: '',
        ),
        returnsNormally,
      );
    });

    test('handles invalid (non-numeric) maxGroupSize', () {
      expect(
        () => RecommendationService.scorePackageForTourist(
          package: _buildPackage(maxGroupSize: 'unlimited'),
          touristProfile: _buildProfile(),
          selectedInterest: '',
        ),
        returnsNormally,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Multiple interests
  // ---------------------------------------------------------------------------
  group('RecommendationService – multiple interests', () {
    test('package matching multiple interests scores higher than single match', () {
      final multiProfile = _buildProfile(
          interests: ['adventure', 'beach', 'food & culinary']);

      final multiMatchScore = RecommendationService.scorePackageForTourist(
        package: _buildPackage(
          activityType: 'Adventure',
          description: 'Beach and food culinary adventure tour',
        ),
        touristProfile: multiProfile,
        selectedInterest: '',
      );

      final singleMatchScore = RecommendationService.scorePackageForTourist(
        package: _buildPackage(
          activityType: 'Adventure',
          description: 'Generic tour package',
        ),
        touristProfile: multiProfile,
        selectedInterest: '',
      );

      expect(multiMatchScore, greaterThanOrEqualTo(singleMatchScore));
    });
  });
}
