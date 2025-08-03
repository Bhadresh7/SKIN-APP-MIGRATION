import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skin_app_migration/core/constants/app_assets.dart';
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

    Future.delayed(Duration(seconds: 1), () {
      Provider.of<MyAuthProvider>(context, listen: false).initialize(context);
      final chatProvider = context.read<ChatProvider>();

      // Initialize sharing intent and intent handling
      chatProvider.initializeSharingIntent(context);
      chatProvider.initIntentHandling();

      // Load messages from local DB first
      chatProvider.loadMessages();

      // Start Firestore listener for real-time updates
      chatProvider.startFirestoreListener();

      // Sync any new messages from Firestore
      chatProvider.syncNewMessagesFromFirestore();

    });




  }

  @override
  Widget build(BuildContext context) {
    return KBackgroundScaffold(
      body: Center(child: Image.asset(AppAssets.logo)),
    );
  }
}
