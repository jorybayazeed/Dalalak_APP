/// Constants and enums for Dalalak App
/// This file serves as the single source of truth for all enum values
/// to ensure consistency across the entire app

class AppConstants {
  // ==================== Saudi Destinations ====================
  static const List<String> saudiDestinations = [
    'Riyadh',
    'Jeddah',
    'AlUla',
    'Dammam',
    'Abha',
    'Taif',
    'Makkah',
    'Madinah',
    'Diriyah',
  ];

  // ==================== Budget Types ====================
  static const String budgetBudgetFriendly = 'Budget-friendly';
  static const String budgetMidRange = 'Mid-range';
  static const String budgetLuxury = 'Luxury';

  static const List<String> budgetTypes = [
    budgetBudgetFriendly,
    budgetMidRange,
    budgetLuxury,
  ];

  // ==================== Travel Pace ====================
  static const String paceRelaxed = 'Relaxed and slow-paced';
  static const String paceFastPaced = 'Action-packed and fast-paced';
  static const String paceMixed = 'A bit of both';

  static const List<String> travelPaceTypes = [
    paceRelaxed,
    paceFastPaced,
    paceMixed,
  ];

  // ==================== Trip Types ====================
  static const String tripTypeSolo = 'Solo';
  static const String tripTypeFriends = 'Friends';
  static const String tripTypeFamily = 'Family';
  static const String tripTypeCouple = 'Couple';

  static const List<String> tripTypes = [
    tripTypeSolo,
    tripTypeFriends,
    tripTypeFamily,
    tripTypeCouple,
  ];

  // ==================== Interests ====================
  static const String interestAdventure = 'Adventure';
  static const String interestHistoryCulture = 'History & Culture';
  static const String interestFoodCulinary = 'Food & Culinary';
  static const String interestNatureWildlife = 'Nature & Wildlife';
  static const String interestRelaxation = 'Relaxation';
  static const String interestNightlifeEntertainment = 'Nightlife & Entertainment';
  static const String interestShopping = 'Shopping';

  static const List<String> interestTypes = [
    interestAdventure,
    interestHistoryCulture,
    interestFoodCulinary,
    interestNatureWildlife,
    interestRelaxation,
    interestNightlifeEntertainment,
    interestShopping,
  ];

  // ==================== Activity Types ====================
  static const String activityAdventure = 'Adventure';
  static const String activityCulturalHeritage = 'Cultural Heritage';
  static const String activityNatureWildlife = 'Nature & Wildlife';
  static const String activityReligious = 'Religious';
  static const String activityBeach = 'Beach';
  static const String activityEntertainment = 'Entertainment';
  static const String activityHistorical = 'Historical';
  static const String activityPhotography = 'Photography';
  static const String activityFoodCulinary = 'Food & Culinary';
  static const String activityRelaxation = 'Relaxation';

  static const List<String> activityTypes = [
    activityAdventure,
    activityCulturalHeritage,
    activityNatureWildlife,
    activityReligious,
    activityBeach,
    activityEntertainment,
    activityHistorical,
    activityPhotography,
    activityFoodCulinary,
    activityRelaxation,
  ];

  // ==================== Helper Methods ====================
  
  /// Normalize budget type to lowercase standard format
  static String normalizeBudget(String budget) {
    final lower = budget.toLowerCase();
    if (lower.contains('budget') || lower.contains('cheap') || lower.contains('low')) {
      return 'low';
    } else if (lower.contains('mid') || lower.contains('moderate') || lower.contains('range')) {
      return 'medium';
    } else if (lower.contains('luxury') || lower.contains('high') || lower.contains('premium')) {
      return 'high';
    }
    return 'medium'; // default
  }

  /// Normalize travel pace to lowercase standard format
  static String normalizePace(String pace) {
    final lower = pace.toLowerCase();
    if (lower.contains('relax') || lower.contains('slow')) {
      return 'relaxed';
    } else if (lower.contains('fast') || lower.contains('action') || lower.contains('adventurous')) {
      return 'adventurous';
    } else if (lower.contains('bit') || lower.contains('mixed') || lower.contains('both')) {
      return 'moderate';
    }
    return 'moderate'; // default
  }
}
