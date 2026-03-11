import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final TextEditingController messageController = TextEditingController();

  final RxString selectedConversationId = ''.obs;

  // Sample conversations data
  final RxList<Map<String, dynamic>> conversations = [
    {
      'id': '1',
      'name': 'Ahmed Al-Rashid',
      'avatar': null,
      'lastMessage': 'Looking forward to showing you AlUla!',
      'time': '2h ago',
      'unreadCount': 2,
      'status': 'Online',
    },
    {
      'id': '2',
      'name': 'Fatima Al-Otaibi',
      'avatar': null,
      'lastMessage': 'The tour starts at 9 AM sharp',
      'time': '1d ago',
      'unreadCount': 0,
      'status': 'Offline',
    },
    {
      'id': '3',
      'name': 'Sarah Johnson',
      'avatar': null,
      'lastMessage': 'Can we reschedule to next week?',
      'time': '2d ago',
      'unreadCount': 1,
      'status': 'Offline',
    },
  ].obs;

  // Sample messages data
  final Map<String, List<Map<String, dynamic>>> _messages = {
    '1': [
      {
        'id': 'm1',
        'text': 'Hello! I have a question about the AlUla tour.',
        'isSent': false,
        'time': '10:30 AM',
      },
      {
        'id': 'm2',
        'text': 'Hi Ahmed! Sure, what would you like to know?',
        'isSent': true,
        'time': '10:32 AM',
      },
      {
        'id': 'm3',
        'text': 'What should I bring for the tour? Is it suitable for kids?',
        'isSent': false,
        'time': '10:33 AM',
      },
      {
        'id': 'm4',
        'text':
            'Great questions! Please bring comfortable walking shoes, sunscreen, and a hat. The tour is family-friendly and perfect for kids aged 6 and above.',
        'isSent': true,
        'time': '10:35 AM',
      },
      {
        'id': 'm5',
        'text': 'Perfect! We have two kids, 8 and 10. They will love it.',
        'isSent': false,
        'time': '10:36 AM',
      },
    ],
    '2': [
      {
        'id': 'm6',
        'text': 'The tour starts at 9 AM sharp',
        'isSent': false,
        'time': 'Yesterday',
      },
    ],
    '3': [
      {
        'id': 'm7',
        'text': 'Can we reschedule to next week?',
        'isSent': false,
        'time': '2 days ago',
      },
    ],
  };

  void selectConversation(String conversationId) {
    selectedConversationId.value = conversationId;
  }

  List<Map<String, dynamic>> getMessages(String conversationId) {
    return _messages[conversationId] ?? [];
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    final conversationId = selectedConversationId.value;
    if (conversationId.isEmpty) return;

    final newMessage = {
      'id': 'm${DateTime.now().millisecondsSinceEpoch}',
      'text': messageController.text.trim(),
      'isSent': true,
      'time': _getCurrentTime(),
    };

    if (_messages.containsKey(conversationId)) {
      _messages[conversationId]!.add(newMessage);
    } else {
      _messages[conversationId] = [newMessage];
    }

    // Update last message in conversation
    final conversationIndex = conversations.indexWhere(
      (c) => c['id'] == conversationId,
    );
    if (conversationIndex != -1) {
      conversations[conversationIndex]['lastMessage'] = newMessage['text'];
      conversations[conversationIndex]['time'] = 'Just now';
      conversations.refresh();
    }

    messageController.clear();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
