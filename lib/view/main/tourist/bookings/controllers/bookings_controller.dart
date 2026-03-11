import 'package:get/get.dart';

class BookingsController extends GetxController {
  final RxString selectedTab = 'Upcoming'.obs;

  final RxList<Map<String, dynamic>> allBookings = [
    {
      'id': 'DLK-00123',
      'tourId': '1',
      'title': 'AlUla Heritage Tour',
      'guide': 'Ahmed Al-Rashid',
      'date': 'Dec 25, 2024',
      'time': '09:00 AM - 6 hours',
      'location': 'AlUla',
      'price': '900 SAR',
      'status': 'Upcoming',
      'image': 'images/tour_1.png',
    },
    {
      'id': 'DLK-00124',
      'tourId': '2',
      'title': 'Riyadh City Explorer',
      'guide': 'Fatima Al-Otaibi',
      'date': 'Dec 30, 2024',
      'time': '10:00 AM - 4 hours',
      'location': 'Riyadh',
      'price': '350 SAR',
      'status': 'Upcoming',
      'image': 'images/tour_2.png',
    },
    {
      'id': 'DLK-00125',
      'tourId': '3',
      'title': 'Jeddah Waterfront Experience',
      'guide': 'Mohammed Al-Zahrani',
      'date': 'Nov 15, 2024',
      'time': '02:00 PM - 3 hours',
      'location': 'Jeddah',
      'price': '280 SAR',
      'status': 'Completed',
      'image': 'images/tour_3.png',
    },
    {
      'id': 'DLK-00126',
      'tourId': '4',
      'title': 'Edge of the World Adventure',
      'guide': 'Salem Al-Qahtani',
      'date': 'Oct 10, 2024',
      'time': '08:00 AM - 8 hours',
      'location': 'Riyadh Region',
      'price': '520 SAR',
      'status': 'Cancelled',
      'image': 'images/tour_4.png',
    },
  ].obs;

  List<Map<String, dynamic>> get filteredBookings {
    if (selectedTab.value == 'All') {
      return allBookings;
    }
    return allBookings
        .where((booking) => booking['status'] == selectedTab.value)
        .toList();
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  void messageGuide(String bookingId) {
    // TODO: Navigate to chat/message page
    Get.snackbar(
      'Message Guide',
      'Messaging functionality not yet implemented.',
    );
  }

  void viewDetails(String bookingId) {
    // TODO: Navigate to booking details page
    Get.snackbar(
      'View Details',
      'Booking details functionality not yet implemented.',
    );
  }
}
