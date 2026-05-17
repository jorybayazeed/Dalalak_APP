// Sprint 2 – Package Search & Filter Logic Unit Tests
//
// Verifies the search and filter behaviour described in Sprint 2:
//   "The system shall allow tourists to browse and search for tourist packages."
//
// The filter/search logic lives in ExploreController.filteredTours.
// Because ExploreController requires live Firebase services, the predicate
// functions are replicated here as standalone helpers so they can be tested
// deterministically without any Firebase dependency.

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Filter predicates (mirrors ExploreController logic)
// ---------------------------------------------------------------------------

/// Returns true when [tour] destination matches the [selectedRegion].
bool matchesRegionFilter(Map<String, dynamic> tour, String selectedRegion) {
  if (selectedRegion == 'All Regions') return true;
  final dest = (tour['destination'] as String? ?? '').toLowerCase();
  return dest == selectedRegion.toLowerCase();
}

/// Returns true when [tour] activity type matches the [selectedActivityType].
bool matchesActivityFilter(
    Map<String, dynamic> tour, String selectedActivityType) {
  if (selectedActivityType == 'All Activities') return true;
  final actType = (tour['activityType'] as String? ?? '').toLowerCase();
  return actType == selectedActivityType.toLowerCase();
}

/// Returns true when [tour] price satisfies the [selectedPriceRange].
bool matchesPriceFilter(Map<String, dynamic> tour, String selectedPriceRange) {
  if (selectedPriceRange == 'Any Price') return true;
  final priceStr = tour['price'] as String?;
  if (priceStr == null || priceStr.isEmpty) return false;
  final price = double.tryParse(priceStr) ?? 0;

  switch (selectedPriceRange) {
    case 'Under 300 SAR':
      return price < 300;
    case '300 - 500 SAR':
      return price >= 300 && price <= 500;
    case 'Above 500 SAR':
      return price > 500;
    default:
      return true;
  }
}

/// Returns true when [tour] title or destination contains the [query].
bool matchesSearchQuery(Map<String, dynamic> tour, String query) {
  if (query.isEmpty) return true;
  final q = query.toLowerCase();
  final title = (tour['tourTitle'] as String? ?? '').toLowerCase();
  final dest = (tour['destination'] as String? ?? '').toLowerCase();
  return title.contains(q) || dest.contains(q);
}

/// Applies all active filters and the search query to [tours].
List<Map<String, dynamic>> applyFilters({
  required List<Map<String, dynamic>> tours,
  String selectedRegion = 'All Regions',
  String selectedActivityType = 'All Activities',
  String selectedPriceRange = 'Any Price',
  String searchQuery = '',
}) {
  return tours
      .where((t) => matchesRegionFilter(t, selectedRegion))
      .where((t) => matchesActivityFilter(t, selectedActivityType))
      .where((t) => matchesPriceFilter(t, selectedPriceRange))
      .where((t) => matchesSearchQuery(t, searchQuery))
      .toList();
}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

List<Map<String, dynamic>> _sampleTours() => [
      {
        'id': '1',
        'tourTitle': 'AlUla Desert Adventure',
        'destination': 'AlUla',
        'activityType': 'Adventure',
        'price': '450',
        'status': 'Published',
      },
      {
        'id': '2',
        'tourTitle': 'Riyadh Heritage Walk',
        'destination': 'Riyadh',
        'activityType': 'Cultural Heritage',
        'price': '150',
        'status': 'Published',
      },
      {
        'id': '3',
        'tourTitle': 'Jeddah Beach Escape',
        'destination': 'Jeddah',
        'activityType': 'Beach',
        'price': '600',
        'status': 'Published',
      },
      {
        'id': '4',
        'tourTitle': 'Abha Nature Trail',
        'destination': 'Abha',
        'activityType': 'Nature & Wildlife',
        'price': '350',
        'status': 'Published',
      },
      {
        'id': '5',
        'tourTitle': 'Diriyah Historical Tour',
        'destination': 'Diriyah',
        'activityType': 'Historical',
        'price': '200',
        'status': 'Published',
      },
    ];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Browse – no filters applied
  // -------------------------------------------------------------------------
  group('Package browsing – no filters', () {
    test('returns all packages when no filters are applied', () {
      final tours = _sampleTours();
      final result = applyFilters(tours: tours);
      expect(result.length, equals(tours.length));
    });

    test('returns empty list when input is empty', () {
      final result = applyFilters(tours: []);
      expect(result, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Search by title / destination
  // -------------------------------------------------------------------------
  group('Package search – text query', () {
    test('finds package by partial title (case-insensitive)', () {
      final result =
          applyFilters(tours: _sampleTours(), searchQuery: 'desert');
      expect(result.length, equals(1));
      expect(result.first['id'], equals('1'));
    });

    test('finds package by exact destination name', () {
      final result =
          applyFilters(tours: _sampleTours(), searchQuery: 'jeddah');
      expect(result.length, equals(1));
      expect(result.first['id'], equals('3'));
    });

    test('search is case-insensitive for titles', () {
      final lower =
          applyFilters(tours: _sampleTours(), searchQuery: 'heritage');
      final upper =
          applyFilters(tours: _sampleTours(), searchQuery: 'HERITAGE');
      expect(lower.length, equals(upper.length));
    });

    test('search by destination partial match', () {
      final result = applyFilters(tours: _sampleTours(), searchQuery: 'alu');
      expect(result.length, equals(1));
      expect(result.first['destination'], equals('AlUla'));
    });

    test('search with no match returns empty list', () {
      final result =
          applyFilters(tours: _sampleTours(), searchQuery: 'zzznomatch');
      expect(result, isEmpty);
    });

    test('empty search query returns all packages', () {
      final result = applyFilters(tours: _sampleTours(), searchQuery: '');
      expect(result.length, equals(_sampleTours().length));
    });
  });

  // -------------------------------------------------------------------------
  // Filter by region
  // -------------------------------------------------------------------------
  group('Package filter – region', () {
    test('"All Regions" returns all packages', () {
      final result =
          applyFilters(tours: _sampleTours(), selectedRegion: 'All Regions');
      expect(result.length, equals(_sampleTours().length));
    });

    test('filter by "Riyadh" returns only Riyadh packages', () {
      final result =
          applyFilters(tours: _sampleTours(), selectedRegion: 'Riyadh');
      expect(result.every((t) =>
              (t['destination'] as String).toLowerCase() == 'riyadh'),
          isTrue);
    });

    test('filter by "Jeddah" returns exactly one result', () {
      final result =
          applyFilters(tours: _sampleTours(), selectedRegion: 'Jeddah');
      expect(result.length, equals(1));
      expect(result.first['id'], equals('3'));
    });

    test('filter by region with no match returns empty list', () {
      final result =
          applyFilters(tours: _sampleTours(), selectedRegion: 'Makkah');
      expect(result, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Filter by activity type
  // -------------------------------------------------------------------------
  group('Package filter – activity type', () {
    test('"All Activities" returns all packages', () {
      final result = applyFilters(
          tours: _sampleTours(), selectedActivityType: 'All Activities');
      expect(result.length, equals(_sampleTours().length));
    });

    test('filter by "Adventure" returns only adventure packages', () {
      final result = applyFilters(
          tours: _sampleTours(), selectedActivityType: 'Adventure');
      expect(result.length, equals(1));
      expect(result.first['activityType'], equals('Adventure'));
    });

    test('filter by "Beach" returns only beach packages', () {
      final result =
          applyFilters(tours: _sampleTours(), selectedActivityType: 'Beach');
      expect(result.length, equals(1));
      expect(result.first['id'], equals('3'));
    });

    test('activity type filter is case-insensitive', () {
      final lower = applyFilters(
          tours: _sampleTours(), selectedActivityType: 'adventure');
      final upper = applyFilters(
          tours: _sampleTours(), selectedActivityType: 'ADVENTURE');
      expect(lower.length, equals(upper.length));
    });
  });

  // -------------------------------------------------------------------------
  // Filter by price range
  // -------------------------------------------------------------------------
  group('Package filter – price range', () {
    test('"Any Price" returns all packages', () {
      final result =
          applyFilters(tours: _sampleTours(), selectedPriceRange: 'Any Price');
      expect(result.length, equals(_sampleTours().length));
    });

    test('"Under 300 SAR" returns packages priced below 300', () {
      final result = applyFilters(
          tours: _sampleTours(), selectedPriceRange: 'Under 300 SAR');
      for (final t in result) {
        final price = double.parse(t['price'] as String);
        expect(price, lessThan(300));
      }
    });

    test('"300 - 500 SAR" returns packages in that range (inclusive)', () {
      final result = applyFilters(
          tours: _sampleTours(), selectedPriceRange: '300 - 500 SAR');
      for (final t in result) {
        final price = double.parse(t['price'] as String);
        expect(price, greaterThanOrEqualTo(300));
        expect(price, lessThanOrEqualTo(500));
      }
      expect(result.length, greaterThan(0));
    });

    test('"Above 500 SAR" returns packages priced above 500', () {
      final result = applyFilters(
          tours: _sampleTours(), selectedPriceRange: 'Above 500 SAR');
      for (final t in result) {
        final price = double.parse(t['price'] as String);
        expect(price, greaterThan(500));
      }
      expect(result.length, equals(1));
      expect(result.first['id'], equals('3'));
    });

    test('package with empty price is excluded from price filter', () {
      final toursWithEmptyPrice = [
        {'id': '99', 'tourTitle': 'Unknown Price', 'price': '', 'destination': 'Riyadh'},
        ..._sampleTours(),
      ];
      final result = applyFilters(
          tours: toursWithEmptyPrice, selectedPriceRange: 'Under 300 SAR');
      expect(result.every((t) => t['id'] != '99'), isTrue);
    });

    test('package with null price field is excluded from price filter', () {
      final toursWithNullPrice = [
        {'id': '98', 'tourTitle': 'Null Price Tour', 'destination': 'Riyadh'},
        // price key is absent → null when accessed
        ..._sampleTours(),
      ];
      final result = applyFilters(
          tours: toursWithNullPrice, selectedPriceRange: 'Under 300 SAR');
      expect(result.every((t) => t['id'] != '98'), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // Combined filters
  // -------------------------------------------------------------------------
  group('Package filter – combined filters', () {
    test('region + activity type combination narrows results correctly', () {
      final result = applyFilters(
        tours: _sampleTours(),
        selectedRegion: 'AlUla',
        selectedActivityType: 'Adventure',
      );
      expect(result.length, equals(1));
      expect(result.first['id'], equals('1'));
    });

    test('region + price range excludes packages outside both criteria', () {
      final result = applyFilters(
        tours: _sampleTours(),
        selectedRegion: 'Riyadh',
        selectedPriceRange: 'Under 300 SAR',
      );
      expect(result.length, equals(1));
      expect(result.first['id'], equals('2'));
    });

    test('search + activity type filters together', () {
      final result = applyFilters(
        tours: _sampleTours(),
        selectedActivityType: 'Cultural Heritage',
        searchQuery: 'riyadh',
      );
      expect(result.length, equals(1));
      expect(result.first['id'], equals('2'));
    });

    test('conflicting filters produce empty result', () {
      // AlUla packages are Adventure, not Beach
      final result = applyFilters(
        tours: _sampleTours(),
        selectedRegion: 'AlUla',
        selectedActivityType: 'Beach',
      );
      expect(result, isEmpty);
    });

    test('all filters applied simultaneously', () {
      final result = applyFilters(
        tours: _sampleTours(),
        selectedRegion: 'Jeddah',
        selectedActivityType: 'Beach',
        selectedPriceRange: 'Above 500 SAR',
        searchQuery: 'escape',
      );
      expect(result.length, equals(1));
      expect(result.first['id'], equals('3'));
    });
  });

  // -------------------------------------------------------------------------
  // Package details display
  // -------------------------------------------------------------------------
  group('Package details – data accessors', () {
    // Mirror the getters defined in PackageDetailsController
    Map<String, dynamic> buildPackageData() => {
          'tourTitle': 'AlUla Desert Adventure',
          'destination': 'AlUla',
          'price': '450',
          'durationValue': '3',
          'durationUnit': 'Days',
          'maxGroupSize': '12',
          'tourDescription': 'Explore the stunning desert landscapes of AlUla.',
          'activityType': 'Adventure',
          'availableDates': '01/06/2025 - 30/09/2025',
          'status': 'Published',
          'views': 120,
          'bookings': 8,
          'image': 'https://example.com/alula.jpg',
          'activities': [
            {'name': 'Camel Ride', 'activityType': 'Adventure'},
          ],
        };

    test('title accessor returns tourTitle', () {
      final data = buildPackageData();
      final title = data['tourTitle'] ?? '';
      expect(title, equals('AlUla Desert Adventure'));
    });

    test('destination accessor returns destination', () {
      final data = buildPackageData();
      expect(data['destination'] ?? '', equals('AlUla'));
    });

    test('price accessor returns formatted string with SAR', () {
      final data = buildPackageData();
      final price = '${data['price'] ?? ''} SAR';
      expect(price, equals('450 SAR'));
    });

    test('duration accessor combines durationValue and durationUnit', () {
      final data = buildPackageData();
      final duration =
          '${data['durationValue'] ?? ''} ${data['durationUnit'] ?? ''}';
      expect(duration, equals('3 Days'));
    });

    test('maxGroupSize accessor prefixes with "Max"', () {
      final data = buildPackageData();
      final maxGroupSize = 'Max ${data['maxGroupSize'] ?? ''}';
      expect(maxGroupSize, equals('Max 12'));
    });

    test('description accessor returns tourDescription', () {
      final data = buildPackageData();
      expect(
        data['tourDescription'] ?? '',
        equals('Explore the stunning desert landscapes of AlUla.'),
      );
    });

    test('status defaults to "Published"', () {
      final data = buildPackageData();
      expect(data['status'] ?? 'Published', equals('Published'));
    });

    test('activities list is parsed correctly', () {
      final data = buildPackageData();
      final activities = (data['activities'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      expect(activities.length, equals(1));
      expect(activities.first['name'], equals('Camel Ride'));
    });

    test('missing price field falls back to empty SAR string', () {
      final data = <String, dynamic>{};
      final price = '${data['price'] ?? ''} SAR';
      expect(price, equals(' SAR'));
    });
  });

  // -------------------------------------------------------------------------
  // Tour guide – package update data integrity
  // -------------------------------------------------------------------------
  group('Tour guide – package update data preparation', () {
    // Mirror the data map constructed in PackagesService.updatePackage()
    Map<String, dynamic> buildUpdatePayload({
      required String tourTitle,
      required String destination,
      required String region,
      required String durationValue,
      required String durationUnit,
      required String price,
      required String maxGroupSize,
      required String tourDescription,
      String activityType = '',
      String availableDates = '',
      List<Map<String, dynamic>> activities = const [],
    }) {
      return {
        'tourTitle': tourTitle,
        'destination': destination,
        'region': region,
        'durationValue': durationValue,
        'durationUnit': durationUnit,
        'price': price,
        'maxGroupSize': maxGroupSize,
        'tourDescription': tourDescription,
        'activityType': activityType,
        'availableDates': availableDates,
        'activities': activities,
      };
    }

    test('update payload contains all required fields', () {
      final payload = buildUpdatePayload(
        tourTitle: 'Updated Tour',
        destination: 'Jeddah',
        region: 'Western',
        durationValue: '5',
        durationUnit: 'Days',
        price: '800',
        maxGroupSize: '20',
        tourDescription: 'An updated tour description.',
      );

      expect(payload.containsKey('tourTitle'), isTrue);
      expect(payload.containsKey('destination'), isTrue);
      expect(payload.containsKey('region'), isTrue);
      expect(payload.containsKey('durationValue'), isTrue);
      expect(payload.containsKey('durationUnit'), isTrue);
      expect(payload.containsKey('price'), isTrue);
      expect(payload.containsKey('maxGroupSize'), isTrue);
      expect(payload.containsKey('tourDescription'), isTrue);
    });

    test('update payload title is correctly stored', () {
      final payload = buildUpdatePayload(
        tourTitle: 'New Title',
        destination: 'Riyadh',
        region: 'Central',
        durationValue: '2',
        durationUnit: 'Days',
        price: '300',
        maxGroupSize: '8',
        tourDescription: 'Description here.',
      );
      expect(payload['tourTitle'], equals('New Title'));
    });

    test('update payload price change is reflected', () {
      final originalPayload = buildUpdatePayload(
        tourTitle: 'Tour',
        destination: 'AlUla',
        region: 'Northern',
        durationValue: '3',
        durationUnit: 'Days',
        price: '500',
        maxGroupSize: '10',
        tourDescription: 'Desc.',
      );
      final updatedPayload = Map<String, dynamic>.from(originalPayload);
      updatedPayload['price'] = '650';

      expect(updatedPayload['price'], equals('650'));
      expect(originalPayload['price'], equals('500')); // original unchanged
    });

    test('activities list is preserved in update payload', () {
      final activities = [
        {'name': 'Hiking', 'activityType': 'Adventure'},
        {'name': 'Cooking Class', 'activityType': 'Food & Culinary'},
      ];
      final payload = buildUpdatePayload(
        tourTitle: 'Multi-Activity Tour',
        destination: 'Abha',
        region: 'Southern',
        durationValue: '4',
        durationUnit: 'Days',
        price: '700',
        maxGroupSize: '15',
        tourDescription: 'Description.',
        activities: activities,
      );
      expect((payload['activities'] as List).length, equals(2));
    });

    test('optional fields default to empty string when omitted', () {
      final payload = buildUpdatePayload(
        tourTitle: 'Tour',
        destination: 'Riyadh',
        region: 'Central',
        durationValue: '1',
        durationUnit: 'Day',
        price: '100',
        maxGroupSize: '5',
        tourDescription: 'Desc.',
      );
      expect(payload['activityType'], equals(''));
      expect(payload['availableDates'], equals(''));
    });
  });
}
