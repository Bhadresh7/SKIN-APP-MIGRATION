import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skin_app_migration/core/constants/app_assets.dart';
import 'package:skin_app_migration/core/service/local_db_service.dart';
import 'package:skin_app_migration/core/widgets/k_background_scaffold.dart';
import 'package:skin_app_migration/features/auth/providers/my_auth_provider.dart';
import 'package:skin_app_migration/features/message/provider/chat_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 1), () async {
      Provider.of<MyAuthProvider>(context, listen: false).initialize(context);
      final chatProvider = context.read<ChatProvider>();

      // Wait for DB to finish initializing
      await LocalDBService().init();

      // Now it's safe to call DB-related methods
      chatProvider.initializeSharingIntent(context);
      chatProvider.initIntentHandling();
      await chatProvider.loadMessages(); // await is optional here unless needed
      chatProvider.startFirestoreListener();
      await chatProvider.syncNewMessagesFromFirestore(); // optional await
    });
  }

  @override
  Widget build(BuildContext context) {
    return KBackgroundScaffold(
      body: Center(child: Image.asset(AppAssets.logo)),
    );
  }
}
