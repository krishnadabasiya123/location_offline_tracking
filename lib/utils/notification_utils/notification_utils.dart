import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

/// Configuration class for setting up the primary notification channel
class NotificationConfig {
  const NotificationConfig({
    this.channelKey = 'default_channel',
    this.channelName = 'General Notifications',
    this.channelDescription = 'General notifications for the application',
    this.importance = NotificationImportance.High,
    this.ledColor = Colors.white,
  });
  final String channelKey;
  final String channelName;
  final String channelDescription;
  final NotificationImportance importance;
  final Color ledColor;
}

/// A fully customizable notification service for Flutter
/// Combines local notifications (Awesome) and push notifications (FCM).
@pragma('vm:entry-point')
class NotificationService {
  // Singleton instance
  @pragma('vm:entry-point')
  NotificationService._internal();
  @pragma('vm:entry-point')
  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final AwesomeNotifications _awesome = AwesomeNotifications();

  // Streams for cleanup
  late StreamSubscription<RemoteMessage> _foregroundSubscription;
  late StreamSubscription<RemoteMessage> _onMessageOpenSubscription;

  // --- Configuration & Initialization ---

  /// Default configuration used if none is provided
  @pragma('vm:entry-point')
  static const NotificationConfig defaultConfig = NotificationConfig();

  /// Initialize all notification systems
  Future<void> init({NotificationConfig config = defaultConfig}) async {
    _log('Initializing Notification Service...');

    // 1. Initialize Local Notifications (Awesome) - Do this first so channels exist
    await _initializeAwesome(config: config);

    // 2. Request permissions (Fire and forget, don't block app startup)
    // On iOS, this might wait for user input, so we deliberately don't await it here.
    _requestPermissions().then((_) => _log('Permission request sequence completed.'));

    // 3. Register FCM listeners
    await _registerFCMListeners();
    _registerAwesomeListeners();

    _log('Notification Service initialized successfully.');
  }

  /// Request notification permissions (required for iOS and Android 13+)
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      // Request provisional permission for iOS
      await _firebaseMessaging.requestPermission(
        announcement: true,
        provisional: true,
      );
    }

    // Check and request Awesome Notifications permission (especially for Android 13+)
    final allowed = await _awesome.isNotificationAllowed();
    if (!allowed) {
      _log('Requesting permission to send notifications...');
      await _awesome.requestPermissionToSendNotifications();
    }
  }

  /// Initialize Awesome Notifications with customizable channel settings
  Future<void> _initializeAwesome({required NotificationConfig config}) async {
    await _awesome.initialize(
      'resource://drawable/ic_stat_omkar_logo', // Default icon for status bar
      [
        NotificationChannel(
          channelKey: config.channelKey,
          channelName: config.channelName,
          channelDescription: config.channelDescription,
          importance: config.importance,
          playSound: true,
          ledColor: config.ledColor,
          enableVibration: true,
        ),
      ],
      debug: true, // Enable Awesome Notifications debug logs for analysis
    );
  }

  // --- FCM Listener Registration ---

  /// Register notification listeners for all states
  Future<void> _registerFCMListeners() async {
    // 1. Terminated state (App opened via notification tap)
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _log('Terminated State Message Received: ${message.data}');
        //  _handleMessage(message, isTapped: true);
      }
    });

    // 2. Foreground notifications (App is open)
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      _log('Foreground Message Received: ${message.toMap()}');
      // Trigger local notification via Awesome
      if (Platform.isIOS) {
        return;
      }

      _handleMessage(message);
    });

    // 3. Notification tapped (App in background or foreground)
    _onMessageOpenSubscription = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _log('Tapped Message (Background/Foreground): ${message.toMap()}');
      // _handleMessage(message, isTapped: true);
    });

    // 4. Background handler setup
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    instance.log('_firebaseBackgroundHandler called ${message.toMap()}');
    // IMPORTANT: Only trigger AwesomeNotifications if the payload is DATA-ONLY.
    // If message.notification is NOT null, Firebase has already shown a notification.
    if (message.notification == null) {
      await instance._handleMessage(message);
    } else {
      print('[NOTIFY_SERVICE] System already handled notification display.');
    }
  }

  @pragma('vm:entry-point')
  Future<void> _handleMessage(RemoteMessage message) async {
    final data = message.data;

    // Logic from your reference: prioritize data fields to avoid system-auto-display duplicates
    final title = data['title']?.toString() ?? message.notification?.title ?? 'Notification';
    final body = data['body']?.toString() ?? message.notification?.body ?? '';
    final imageUrl = data['image']?.toString();

    final payloadMap = Map<String, String>.from(data.map((key, value) => MapEntry(key, value.toString())));

    await _showAwesomeNotification(
      title: title,
      body: body,
      imageUrl: imageUrl,
      payload: payloadMap,
      channelKey: defaultConfig.channelKey,
    );
  }

  // /// Background handler (Must be a top-level function)
  // @pragma('vm:entry-point')
  // static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  //   // Initialize Firebase for the background isolate
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );

  //   // --- Detailed Background Logging for Analysis ---
  //   final title = message.notification?.title ?? message.data['title'] ?? 'N/A';
  //   final body = message.notification?.body ?? message.data['body'] ?? 'N/A';
  //   final messageId = message.messageId ?? 'N/A';

  //   print('====================================================');
  //   print('[BACKGROUND_HANDLER] Message ${message.toMap()}');
  //   print('[BACKGROUND_HANDLER] Message ID: $messageId');
  //   print('[BACKGROUND_HANDLER] Title: $title');
  //   print('[BACKGROUND_HANDLER] Body: $body');
  //   print('[BACKGROUND_HANDLER] Data Keys: ${message.data.keys.join(', ')}');
  //   print('====================================================');

  //   // Proceed to handle the message (display local notification)
  //   // We must use the static instance here
  //   await instance._handleMessage(message, isTapped: false);
  // }

  // // --- Core Message Handling ---

  // /// Handle a notification from any state (FCM)
  // @pragma('vm:entry-point')
  // Future<void> _handleMessage(RemoteMessage message, {required bool isTapped}) async {
  //   // Data payload is always Map<String, dynamic> from Firebase
  //   final data = message.data;

  //   // 1. Extract Title: Safely extract and default to 'Notification'
  //   final title = message.notification?.title ?? data['title']?.toString() ?? 'Notification';

  //   // 2. Extract Body: Safely extract and default to empty string
  //   final body = message.notification?.body ?? data['body']?.toString() ?? '';

  //   // 3. Extract Image URL (optional)
  //   final imageUrl = data['image']?.toString();

  //   // Log the action for analytics/debugging
  //   _log('Handling message (Tapped: $isTapped) - Title: $title');

  //   // Convert data payload to Map<String, String> ensuring all values are strings
  //   final payloadMap = Map<String, String>.from(data.map((key, value) => MapEntry(key, value.toString())));

  //   await _showAwesomeNotification(
  //     title: title,
  //     body: body,
  //     imageUrl: imageUrl, // Can be null
  //     payload: payloadMap,
  //     channelKey: defaultConfig.channelKey,
  //     isTapped: isTapped,
  //   );
  // }

  // --- Unified Awesome Notification Creator (The Customization Hub) ---

  /// Central method to display a notification using Awesome Notifications
  Future<void> _showAwesomeNotification({
    required String title,
    required String body,
    required Map<String, String> payload,
    required String channelKey,
    String? imageUrl,
    bool locked = false,
    bool isTapped = false,
  }) async {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final layout = hasImage ? NotificationLayout.BigPicture : NotificationLayout.Default;

    // Log the type of notification being created for analytics
    _log('Creating Awesome Notification (Layout: $layout, Tapped: $isTapped)');

    await _awesome.createNotification(
      content: NotificationContent(
        id: Random().nextInt(5000) + 1, // Ensure ID > 0
        channelKey: channelKey,
        title: title,
        body: body,
        payload: payload,
        locked: locked,
        wakeUpScreen: true,
        autoDismissible: !locked,

        // Customization based on layout
        notificationLayout: layout,
        bigPicture: hasImage ? imageUrl : null,
        // Use ic_launcher as the large icon for the overlay if no specific image is provided
        largeIcon: hasImage ? imageUrl : 'resource://mipmap/ic_launcher',
      ),
      // Action buttons can be added here for further customization
    );
  }

  // --- Public Local Notification Helpers (Easy Way) ---

  /// Helper to manually show a simple local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, String>? payload,
    bool locked = false,
  }) async {
    await _showAwesomeNotification(
      title: title,
      body: body,
      payload: payload ?? {},
      channelKey: defaultConfig.channelKey,
      locked: locked,
    );
  }

  /// Helper to show local notification with image URL
  Future<void> showLocalImageNotification({
    required String title,
    required String body,
    required String imageUrl,
    Map<String, String>? payload,
    bool locked = false,
  }) async {
    await _showAwesomeNotification(
      title: title,
      body: body,
      imageUrl: imageUrl,
      payload: payload ?? {},
      channelKey: defaultConfig.channelKey,
      locked: locked,
    );
  }

  // --- Awesome Notifications Listener Hooks ---

  /// Register listeners for Awesome Notifications events
  void _registerAwesomeListeners() {
    _awesome.setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
    );
  }

  /// Use this method to detect when a new notification is created
  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    instance._log('Awesome Notification Created: ${receivedNotification.id}');
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    instance._log('Awesome Notification Displayed: ${receivedNotification.title}');
    // Analytics point: Log notification delivery success
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma('vm:entry-point')
  static Future<void> _onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    instance._log('Awesome Notification Dismissed: ${receivedAction.id}');
    // Analytics point: Log notification dismissal
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma('vm:entry-point')
  static Future<void> _onActionReceivedMethod(ReceivedAction receivedAction) async {
    instance._log('Awesome Notification Tapped/Action Received: ${receivedAction.payload}');

    // --- Centralized Analytics & Navigation Point ---
    if (receivedAction.payload != null) {
      // Example: Log payload contents to Firebase Analytics or a custom service
      print('[NOTIFY_SERVICE_ANALYTICS] User Interaction: ${receivedAction.payload}');

      // Example Navigation (must be handled within your UI context):
      // if (receivedAction.payload!['route'] != null) {
      //   MyApp.navigatorKey.currentState?.pushNamed(receivedAction.payload!['route']!);
      // }
    }
  }

  // --- Cleanup and Logging ---

  /// Dispose notification streams
  void dispose() {
    _log('Disposing Notification streams...');
    _foregroundSubscription.cancel();
    _onMessageOpenSubscription.cancel();
  }

  /// Consistent logging function for easy analysis
  void _log(String message) {
    // This prefix allows easy filtering in IDE console for analytics/debugging
    print('[NOTIFY_SERVICE] $message');
  }
}
