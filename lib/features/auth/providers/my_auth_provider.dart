import 'package:flutter/cupertino.dart';
import 'package:skin_app_migration/features/auth/services/auth_service.dart';

class MyAuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  bool _isLoading = false;

  void _setLoadingState(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // login with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoadingState(true);
      notifyListeners();

      final result = await _service.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _setLoadingState(false);
      notifyListeners();
    }
  }

  // google authentication
  Future<void> signInWithGoogle() async {}

  // registeration using email and password
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {}
}
