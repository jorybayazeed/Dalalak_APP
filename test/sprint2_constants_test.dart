// Sprint 2 – AppConstants Unit Tests
//
// Tests the helper methods and constant values used throughout the app:
//   • normalizeBudget() – mapping user-entered budget strings to 'low', 'medium', 'high'
//   • normalizePace()   – mapping travel-pace strings to 'relaxed', 'moderate', 'adventurous'
//   • List contents     – verifying expected values are present in the constant lists

import 'package:flutter_test/flutter_test.dart';
import 'package:tour_app/models/constants.dart';

void main() {
  // ---------------------------------------------------------------------------
  // normalizeBudget
  // ---------------------------------------------------------------------------
  group('AppConstants.normalizeBudget', () {
    test('returns "low" for "Budget-friendly"', () {
      expect(AppConstants.normalizeBudget('Budget-friendly'), 'low');
    });

    test('returns "low" for "budget" (case-insensitive)', () {
      expect(AppConstants.normalizeBudget('budget'), 'low');
    });

    test('returns "low" for "cheap"', () {
      expect(AppConstants.normalizeBudget('cheap'), 'low');
    });

    test('returns "low" for "low"', () {
      expect(AppConstants.normalizeBudget('low'), 'low');
    });

    test('returns "medium" for "Mid-range"', () {
      expect(AppConstants.normalizeBudget('Mid-range'), 'medium');
    });

    test('returns "medium" for "mid"', () {
      expect(AppConstants.normalizeBudget('mid'), 'medium');
    });

    test('returns "medium" for "moderate"', () {
      expect(AppConstants.normalizeBudget('moderate'), 'medium');
    });

    test('returns "medium" for empty / unknown string (default)', () {
      expect(AppConstants.normalizeBudget(''), 'medium');
      expect(AppConstants.normalizeBudget('unknown'), 'medium');
    });

    test('returns "high" for "Luxury"', () {
      expect(AppConstants.normalizeBudget('Luxury'), 'high');
    });

    test('returns "high" for "luxury" (case-insensitive)', () {
      expect(AppConstants.normalizeBudget('luxury'), 'high');
    });

    test('returns "high" for "premium"', () {
      expect(AppConstants.normalizeBudget('premium'), 'high');
    });

    test('returns "high" for "high"', () {
      expect(AppConstants.normalizeBudget('high'), 'high');
    });
  });

  // ---------------------------------------------------------------------------
  // normalizePace
  // ---------------------------------------------------------------------------
  group('AppConstants.normalizePace', () {
    test('returns "relaxed" for "Relaxed and slow-paced"', () {
      expect(AppConstants.normalizePace('Relaxed and slow-paced'), 'relaxed');
    });

    test('returns "relaxed" for "relax"', () {
      expect(AppConstants.normalizePace('relax'), 'relaxed');
    });

    test('returns "relaxed" for "slow"', () {
      expect(AppConstants.normalizePace('slow'), 'relaxed');
    });

    test('returns "adventurous" for "Action-packed and fast-paced"', () {
      expect(
          AppConstants.normalizePace('Action-packed and fast-paced'), 'adventurous');
    });

    test('returns "adventurous" for "fast"', () {
      expect(AppConstants.normalizePace('fast'), 'adventurous');
    });

    test('returns "adventurous" for "action"', () {
      expect(AppConstants.normalizePace('action'), 'adventurous');
    });

    test('returns "adventurous" for "adventurous"', () {
      expect(AppConstants.normalizePace('adventurous'), 'adventurous');
    });

    test('returns "moderate" for "A bit of both"', () {
      expect(AppConstants.normalizePace('A bit of both'), 'moderate');
    });

    test('returns "moderate" for "mixed"', () {
      expect(AppConstants.normalizePace('mixed'), 'moderate');
    });

    test('returns "moderate" for "both"', () {
      expect(AppConstants.normalizePace('both'), 'moderate');
    });

    test('returns "moderate" for empty / unknown string (default)', () {
      expect(AppConstants.normalizePace(''), 'moderate');
      expect(AppConstants.normalizePace('unknown'), 'moderate');
    });
  });

  // ---------------------------------------------------------------------------
  // Constant list values
  // ---------------------------------------------------------------------------
  group('AppConstants constant lists', () {
    test('saudiDestinations contains key cities', () {
      expect(AppConstants.saudiDestinations, contains('Riyadh'));
      expect(AppConstants.saudiDestinations, contains('Jeddah'));
      expect(AppConstants.saudiDestinations, contains('AlUla'));
    });

    test('budgetTypes contains all three budget levels', () {
      expect(AppConstants.budgetTypes, contains(AppConstants.budgetBudgetFriendly));
      expect(AppConstants.budgetTypes, contains(AppConstants.budgetMidRange));
      expect(AppConstants.budgetTypes, contains(AppConstants.budgetLuxury));
    });

    test('travelPaceTypes contains all three pace options', () {
      expect(AppConstants.travelPaceTypes, contains(AppConstants.paceRelaxed));
      expect(AppConstants.travelPaceTypes, contains(AppConstants.paceFastPaced));
      expect(AppConstants.travelPaceTypes, contains(AppConstants.paceMixed));
    });

    test('tripTypes contains expected values', () {
      expect(AppConstants.tripTypes, contains(AppConstants.tripTypeSolo));
      expect(AppConstants.tripTypes, contains(AppConstants.tripTypeFriends));
      expect(AppConstants.tripTypes, contains(AppConstants.tripTypeFamily));
      expect(AppConstants.tripTypes, contains(AppConstants.tripTypeCouple));
    });

    test('interestTypes contains key interests', () {
      expect(AppConstants.interestTypes, contains(AppConstants.interestAdventure));
      expect(AppConstants.interestTypes,
          contains(AppConstants.interestHistoryCulture));
      expect(AppConstants.interestTypes, contains(AppConstants.interestRelaxation));
    });

    test('activityTypes contains key activity types', () {
      expect(AppConstants.activityTypes, contains(AppConstants.activityAdventure));
      expect(
          AppConstants.activityTypes, contains(AppConstants.activityCulturalHeritage));
      expect(AppConstants.activityTypes, contains(AppConstants.activityBeach));
    });
  });
}
