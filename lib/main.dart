import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hams/firebase_options.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:hams/users/auth/view/login_page.dart';
import 'package:hams/users/home/view/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  var isLogin = false;
  var auth = FirebaseAuth.instance;
  bool _showOnboarding = true; // Flag to determine if onboarding should be shown

  @override
  void initState() {
    super.initState();
    _checkIfFirstLaunch();
  }

  // Check if this is the first launch of the app
  Future<void> _checkIfFirstLaunch() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (hasSeenOnboarding) {
      setState(() {
        _showOnboarding = false;
      });
      _checkIfLogin(); // Proceed to check login state
    }
  }

  // Mark onboarding as seen and proceed to login/home screen
  Future<void> _completeOnboarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    setState(() {
      _showOnboarding = false;
    });
    _checkIfLogin(); // Check login state after onboarding
  }

  // Check if the user is logged in
  void _checkIfLogin() {
    auth.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        setState(() {
          isLogin = true;
        });
      }
    });
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
          title: 'Smadical',
          theme: ThemeData(
            primaryColor: AppColors.primeryColor,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff4B2EAD)),
            useMaterial3: true,
          ),
          home: _showOnboarding
              ? OnboardingPage(onGetStarted: _completeOnboarding)
              : (isLogin ? const Home() : const LoginView()),
        );
      },
    );
  }
}