import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hams/doctors/home/view/home.dart'; // Import DoctorHome
import 'package:hams/firebase_options.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:hams/users/auth/view/role_selection_page.dart';
import 'package:hams/users/home/view/home.dart';
import 'onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showOnboarding = true;

  // Check if the user is logged in at app start
  bool get _isLoggedIn {
    final user = FirebaseAuth.instance.currentUser;
    print("Checking if user is logged in: ${user != null ? 'Yes, UID: ${user.uid}' : 'No'}");
    return user != null;
  }

  // Transition from onboarding to role selection screen
  void _completeOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  // Fetch the user's role and return the appropriate home screen
  Future<Widget> _getHomeScreen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in, navigating to RoleSelectionPage");
      return _showOnboarding
          ? OnboardingPage(onGetStarted: _completeOnboarding)
          : const RoleSelectionPage();
    }

    try {
      // Check the 'users' collection
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        String role = userDoc['role'] ?? 'user';
        print("User role: $role");
        if (role == 'user') {
          return const Home();
        }
      }

      // Check the 'doctors' collection
      DocumentSnapshot doctorDoc =
      await FirebaseFirestore.instance.collection('doctors').doc(user.uid).get();
      if (doctorDoc.exists) {
        String role = doctorDoc['role'] ?? 'doctor';
        print("Doctor role: $role");
        if (role == 'doctor') {
          return const DoctorHome();
        }
      }

      // If no role is found, default to RoleSelectionPage
      print("No role found for user, navigating to RoleSelectionPage");
      return const RoleSelectionPage();
    } catch (e) {
      print("Error fetching user role: $e");
      return const RoleSelectionPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'HAMS',
          theme: ThemeData(
            primaryColor: AppColors.primeryColor,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff4B2EAD)),
            useMaterial3: true,
          ),
          home: FutureBuilder<Widget>(
            future: _getHomeScreen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                print("Error in FutureBuilder: ${snapshot.error}");
                return const RoleSelectionPage();
              }
              return snapshot.data ?? const RoleSelectionPage();
            },
          ),
        );
      },
    );
  }
}