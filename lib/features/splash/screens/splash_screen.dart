import 'package:flutter/material.dart';
import 'package:skin_app_migration/core/router/app_router.dart';
import 'package:skin_app_migration/core/widgets/k_background_scaffold.dart';
import 'package:skin_app_migration/features/auth/screens/auth_login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KBackgroundScaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => AppRouter.replace(context, AuthLoginScreen()),
          child: Text("Go to Login"),
        ),
      ),
    );
  }
}
