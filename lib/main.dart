import 'package:flutter/material.dart';
import 'package:docstagram_chat/chatpage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground message received: ${message.messageId}');
    if (message.notification != null) {
      print('Notification title: ${message.notification!.title}');
      print('Notification body: ${message.notification!.body}');
      // You can show a dialog or update the UI here
    }
  });

  // Handle messages when the app is in the background or terminated
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Message clicked! ${message.messageId}');
    // Navigate to the appropriate screen based on the message
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print("Dotenv loaded successfully.");
  } catch (e) {
    print("Error loading dotenv: $e");
  }

  await Firebase.initializeApp();

  // Set up Firebase Messaging
  setupFirebaseMessaging();

  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
  await requestPermissions();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system, // Use system theme mode
      theme: ThemeData( // Define light theme
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData( // Define dark theme
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatPage()),
                    );
                  },
                  child: const Text('User 1'),
                ),
              ),
              const SizedBox(height: 20),
              Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatPage()),
                    );
                  },
                  child: const Text('User 2'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
