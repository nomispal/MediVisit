import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hams/firebase_options.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:hams/users/auth/view/login_page.dart';
import 'package:hams/users/home/view/home.dart';

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

  chekIfLogin() async {
    auth.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        setState(() {
          isLogin = true;
        });
      }
    });
  }

  @override
  void initState() {
    chekIfLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Adjust based on your design specs
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
          home: isLogin ? const Home() : const LoginView(),
        );
      },
    );
  }
}