import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hams/doctors/all%20reviews/all_reviews.dart';
import 'package:hams/doctors/settings/view/setting_view.dart';
import 'package:hams/doctors/total_appintment/view/total_appointment_view.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../users/notification details/notification_details.dart';

class DoctorHome extends StatefulWidget {
  const DoctorHome({super.key});

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  int selectedIndex = 0;
  List<Widget> screenList = [
    const TotalAppointment(),
    const AllReviewsScreen(),
    const SettingsView(),
  ];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    _initializeNotifications();

    messaging
        .requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      criticalAlert: true,
    )
        .then((NotificationSettings settings) async {
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        String? deviceToken = await messaging.getToken();
        submitData(deviceToken.toString());
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.notification?.title}');
      _showNotification(
        message.notification?.title,
        message.notification?.body,
        message.data,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked! Opened app from background or terminated.');
      _navigateToDetails(message);
    });

    _checkForInitialMessage();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationDetailsPage(
                title: 'Notification Tapped',
                body: response.payload.toString(),
              ),
            ),
          );
        }
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showNotification(
      String? title, String? body, Map<String, dynamic> data) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: body,
    );
  }

  void _navigateToDetails(RemoteMessage message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailsPage(
          title: message.notification?.title ?? 'No Title',
          body: message.notification?.body ?? 'No Body',
        ),
      ),
    );
  }

  Future<void> _checkForInitialMessage() async {
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _navigateToDetails(initialMessage);
    }
  }

  void submitData(String token) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      print("User is not authenticated");
      return;
    }

    try {
      DocumentReference doctorRef =
      FirebaseFirestore.instance.collection('doctors').doc(uid);
      DocumentSnapshot doctorDoc = await doctorRef.get();

      if (doctorDoc.exists) {
        var data = doctorDoc.data() as Map<String, dynamic>;
        String? currentDeviceToken = data['deviceToken'];

        if (currentDeviceToken == null || currentDeviceToken.isEmpty) {
          await doctorRef.update({'deviceToken': token});
          print("Token updated: $token");
        } else if (currentDeviceToken == token) {
          print("Token is already up-to-date");
        } else {
          await doctorRef.update({'deviceToken': token});
          print("Token updated: $token");
        }
      } else {
        print("Doctor document does not exist");
      }
    } catch (e) {
      print("Failed to update token: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primeryColor.withOpacity(0.9),
              AppColors.greenColor.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Doctor's Name
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.whiteColor,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primeryColor,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    10.widthBox,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        "Welcome, Doctor"
                            .text
                            .size(AppFontSize.size18)
                            .fontWeight(FontWeight.bold)
                            .color(AppColors.primeryColor)
                            .make(),
                        5.heightBox,
                        "Manage your appointments and reviews"
                            .text
                            .size(AppFontSize.size14)
                            .color(AppColors.secondaryTextColor)
                            .make(),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 800.ms),
              // Main Content
              Expanded(
                child: screenList.elementAt(selectedIndex),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primeryColor,
        unselectedItemColor: AppColors.secondaryTextColor,
        backgroundColor: AppColors.whiteColor,
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        elevation: 10,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: AppFontSize.size14,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppFontSize.size12,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.date_range, size: 28)
                .animate()
                .scale(duration: 300.ms)
                .then()
                .shake(duration: 500.ms, hz: 2),
            activeIcon: Icon(Icons.date_range, size: 28, color: AppColors.primeryColor),
            label: "Appointments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reviews, size: 28)
                .animate()
                .scale(duration: 300.ms)
                .then()
                .shake(duration: 500.ms, hz: 2),
            activeIcon: Icon(Icons.reviews, size: 28, color: AppColors.primeryColor),
            label: "Reviews",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 28)
                .animate()
                .scale(duration: 300.ms)
                .then()
                .shake(duration: 500.ms, hz: 2),
            activeIcon: Icon(Icons.settings, size: 28, color: AppColors.primeryColor),
            label: "Settings",
          ),
        ],
      ).animate().slideY(begin: 0.3, duration: 800.ms),
    );
  }
}