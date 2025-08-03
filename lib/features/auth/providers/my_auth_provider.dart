import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:skin_app_migration/core/constants/app_status.dart';
import 'package:skin_app_migration/core/router/app_router.dart';
import 'package:skin_app_migration/features/auth/screens/auth_login_screen.dart';
import 'package:skin_app_migration/features/auth/screens/email_verification_screen.dart';
import 'package:skin_app_migration/features/message/provider/chat_provider.dart';
import 'package:skin_app_migration/features/message/screens/chat_screen.dart';
import 'package:skin_app_migration/features/profile/models/user_model.dart';
import 'package:skin_app_migration/features/profile/screens/basic_user_details_form_screen.dart';
import 'package:skin_app_migration/features/profile/screens/image_setup_screen.dart';

class MyAuthProvider extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  User? user;
  UsersModel? userData;

  void _setLoadingState(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void initialize(context) async {
    _setLoadingState(true);
    notifyListeners();

    try {
      // Get current user without network call first
      user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {
          // Try to reload user data to get fresh auth state
          await user!.reload();
          // Update user reference after reload
          user = FirebaseAuth.instance.currentUser;
          print("User reloaded successfully");
        } catch (e) {
          print("Network error during user reload: $e");
          // Continue with cached user data if network fails
          print("Continuing with cached user data");
        }
      }

      print("Current user: $user");

      if (user == null) {
        AppRouter.replace(context, AuthLoginScreen());
      } else if (!user!.emailVerified) {
        // Check email verification with network fallback
        try {
          await user!.reload();
          user = FirebaseAuth.instance.currentUser;
          if (!user!.emailVerified) {
            AppRouter.replace(context, EmailVerificationScreen());
          } else {
            // Email was verified, continue to next step
            await _proceedToUserDataCheck(context);
          }
        } catch (e) {
          print("Network error checking email verification: $e");
          // If network fails, assume email needs verification based on cached state
          AppRouter.replace(context, EmailVerificationScreen());
        }
      } else {
        await _proceedToUserDataCheck(context);
      }
    } catch (e) {
      print("Error during initialization: $e");
      // Fallback to login screen if initialization fails completely
      AppRouter.replace(context, AuthLoginScreen());
    } finally {
      _setLoadingState(false);
      notifyListeners();
    }
  }

  Future<void> _proceedToUserDataCheck(context) async {
    try {
      // Try to get user data from Firestore
      DocumentSnapshot tempData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (!tempData.exists) {
        print("User data does not exist");
        AppRouter.replace(context, BasicUserDetailsFormScreen());
      } else {
        userData = UsersModel.fromFirestore(tempData.data()! as Map<String, dynamic>);

        if (!userData!.isGoogle! && userData!.imageUrl == null) {
          AppRouter.replace(context, ImageSetupScreen());
        } else {
          // Initialize chat provider only after successful auth
          try {
            final chatProvider = Provider.of<ChatProvider>(context, listen: false);
            chatProvider.initializeSharingIntent(context);
            chatProvider.initIntentHandling();
          } catch (e) {
            print("Error initializing chat provider: $e");
          }
          AppRouter.replace(context, ChatScreen());
        }
      }
    } catch (e) {
      print("Error accessing user data: $e");
      // If Firestore fails, go to basic user details to ensure user can proceed
      AppRouter.replace(context, BasicUserDetailsFormScreen());
    }
  }

  // login with email and password
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
    context,
  }) async {
    try {
      _setLoadingState(true);
      notifyListeners();

      var userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        user = userCredential.user;

        if (!user!.emailVerified) {
          _setLoadingState(false);
          AppRouter.replace(context, EmailVerificationScreen());
          return AppStatus.kSuccess;
        }

        try {
          // Try to get user data from Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();

          if (userDoc.exists) {
            userData = UsersModel.fromFirestore(userDoc.data()! as Map<String, dynamic>);
          }
        } catch (e) {
          print("Error fetching user data after login: $e");
          // Continue without user data, will be handled in initialize
        }

        _setLoadingState(false);
        notifyListeners();
        return AppStatus.kSuccess;
      } else {
        _setLoadingState(false);
        notifyListeners();
        return AppStatus.kFailed;
      }
    } on FirebaseAuthException catch (e) {
      _setLoadingState(false);
      notifyListeners();
      print("Login error: ${e.code} - ${e.message}");
      return e.message ?? AppStatus.kFailed;
    } catch (e) {
      _setLoadingState(false);
      notifyListeners();
      print("Login error: $e");
      return AppStatus.kFailed;
    }
  }

  Future<String> signInWithGoogle() async {
    try {
      _setLoadingState(true);
      notifyListeners();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _setLoadingState(false);
        print("Google sign-in cancelled by user");
        notifyListeners();
        return AppStatus.kFailed;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      var userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        user = userCredential.user;
        _setLoadingState(false);
        notifyListeners();
        return AppStatus.kSuccess;
      }

      _setLoadingState(false);
      notifyListeners();
      return AppStatus.kFailed;
    } on FirebaseAuthException catch (e) {
      _setLoadingState(false);
      print("Google sign-in error: ${e.code} - ${e.message}");
      notifyListeners();
      return e.message ?? AppStatus.kFailed;
    } catch (e) {
      _setLoadingState(false);
      print("Google sign-in error: $e");
      notifyListeners();
      return AppStatus.kFailed;
    }
  }

  // Registration using email and password
  Future<String> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoadingState(true);

      // Create user
      var userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = userCredential.user;
      if (user == null) {
        _setLoadingState(false);
        notifyListeners();
        return AppStatus.kFailed;
      }

      // Send email verification
      try {
        await user!.sendEmailVerification();
        print("Email verification sent");
      } catch (e) {
        print("Error sending verification email: $e");
        // Continue even if email verification fails
      }

      _setLoadingState(false);
      notifyListeners();
      return AppStatus.kSuccess;

    } on FirebaseAuthException catch (e) {
      _setLoadingState(false);
      notifyListeners();

      if (e.code == 'email-already-in-use') {
        return AppStatus.kEmailAlreadyExists;
      }
      return e.message ?? "Authentication failed";
    } catch (e) {
      _setLoadingState(false);
      notifyListeners();
      debugPrint("Sign up error: $e");
      return "Sign up failed";
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      // Clear user data
      user = null;
      userData = null;

      // Navigate first to prevent any auth state issues
      AppRouter.offAll(context, AuthLoginScreen());

      // Then sign out
      await _auth.signOut();
      if (await GoogleSignIn().isSignedIn()) {
        await GoogleSignIn().signOut();
      }

      notifyListeners();
    } catch (e) {
      print("Sign-out error: $e");
      // Even if sign-out fails, navigate to login
      AppRouter.offAll(context, AuthLoginScreen());
    }
  }
}