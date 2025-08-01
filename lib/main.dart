import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:skin_app_migration/core/provider/image_picker_provider.dart';
import 'package:skin_app_migration/core/provider/internet_provider.dart';
import 'package:skin_app_migration/features/auth/providers/my_auth_provider.dart';
import 'package:skin_app_migration/features/splash/screens/splash_screen.dart';

import 'core/theme/app_styles.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyAuthProvider()),
        ChangeNotifierProvider(create: (_) => InternetProvider()),
        ChangeNotifierProvider(create: (_) => ImagePickerProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          themeMode: ThemeMode.system,
          theme: ThemeData(
            brightness: Brightness.light,
            fontFamily: AppStyles.primaryFont,
            appBarTheme: AppBarTheme(color: Colors.white),
            scaffoldBackgroundColor: Colors.white,
          ),
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        );
      },
    );
  }
}
