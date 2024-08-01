// notification_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

// FirebaseMessaging instance
FirebaseMessaging messaging = FirebaseMessaging.instance;

// Request permissions for notifications
Future<void> requestPermissions() async {
  // Requesting multiple permissions
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
    Permission.mediaLibrary, // Note: READ_MEDIA_VISUAL_USER_SELECTED is not directly supported, mediaLibrary might cover it
    Permission.notification, // Add this line to request notification permissions
  ].request();

  // Check the statuses
  statuses.forEach((permission, status) {
    if (status.isDenied) {
      // You can show a dialog or take other actions here
      print('$permission is denied.');
    } else {
      print('$permission is granted.');
    }
  });
}

// Firebase Cloud Messaging background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized before handling background messages
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  // Implement your background message handling logic here
}

// Set up Firebase Messaging
void setupFirebaseMessaging() {
  print('Setting up Firebase Messaging...');
  
  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground message received: ${message.messageId}');
    if (message.notification != null) {
      print('Notification title: ${message.notification!.title}');
      print('Notification body: ${message.notification!.body}');
      // You can show a dialog or update the UI here
    } else {
      print('No notification data.');
    }
  });

  // Handle messages when the app is in the background or terminated
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Message clicked! ${message.messageId}');
    // Navigate to the appropriate screen based on the message
  });
}

Future<void> initializeFCM(String userId) async {
  print('Initializing FCM...');
  
  // Request permissions if necessary
  await requestPermissions();

  // Get the token
  String? token = await messaging.getToken();
  if (token != null) {
    print('FCM Token: $token');
    // Send the token to your server and associate it with the user ID
    await _sendTokenToServer(userId, token);
  } else {
    print('Failed to get FCM token.');
  }

  // Handle token refresh
  messaging.onTokenRefresh.listen((newToken) async {
    print('Token refreshed: $newToken');
    await _sendTokenToServer(userId, newToken);
  });
}

Future<void> _sendTokenToServer(String userId, String token) async {
  print('Sending token to server...');
  print('User ID: $userId');
  print('FCM Token: $token');
  final url = Uri.parse(dotenv.env['LOCALHOST_URL']!);
  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'user_id': userId,
      'fcm_token': token,
    }),
  );

  if (response.statusCode == 200) {
    print('Token sent successfully');
  } else {
    print('Failed to send token: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}

// Export the background message handler
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) => _firebaseMessagingBackgroundHandler(message);
