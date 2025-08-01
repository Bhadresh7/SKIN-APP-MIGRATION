import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skin_app_migration/core/constants/app_status.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // login with email and password
  Future<String> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return AppStatus.kSuccess;
  }

  // register with email and password
  Future<String> registerWithEmailAndPassword({
    required String username,
    required String password,
    required String email,
  }) async {
    return AppStatus.kSuccess;
  }

  // google authentication
  Future<String> googleAuthentication() async {
    return AppStatus.kSuccess;
  }

  // send email to the user after registeration
  Future<String> sendEmailVerification() async {
    return AppStatus.kSuccess;
  }

  // resend email if the user changes the email
  Future<String> resendEmailVerification() async {
    return AppStatus.kSuccess;
  }

  /// cancel the email verification when the user goes back to
  /// registeration screen to change the email
  Future<void> cancelEmailVerification() async {}
}
