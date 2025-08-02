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

  // final AuthService _service = AuthService();
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
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.currentUser?.reload();
      user = FirebaseAuth.instance.currentUser!;
    }
    print(user);
    if (user == null)
      AppRouter.replace(context, AuthLoginScreen());
    else if (!(user!.emailVerified))
      AppRouter.replace(context, EmailVerificationScreen());
    else {
      var _tempData = (await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get());

      if (!_tempData.exists) {
        print("user Data Not Exists");
        AppRouter.replace(context, BasicUserDetailsFormScreen());
      } else {
        userData = UsersModel.fromFirestore(_tempData.data()!);
        if (!userData!.isGoogle! && userData!.imageUrl == null) {
          AppRouter.replace(context, ImageSetupScreen());
        } else
          Provider.of<ChatProvider>(context,listen:false). initializeSharingIntent(context);
        Provider.of<ChatProvider>(context,listen:false).initIntentHandling();
          AppRouter.replace(context, ChatScreen());
      }
    }
    _setLoadingState(false);
    notifyListeners();
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

      if (userCredential != null) {
        user = userCredential.user;
        if (!(user!.emailVerified)) {
          _setLoadingState(false);
          AppRouter.replace(context, EmailVerificationScreen());
        }
        if (user != null) {
          userData = UsersModel.fromFirestore(
            (await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .get())
                .data()!,
          );
          _setLoadingState(false);
          notifyListeners();
          return AppStatus.kSuccess;
        }
        _setLoadingState(false);
        notifyListeners();
        return AppStatus.kFailed;
      } else {
        _setLoadingState(false);
        notifyListeners();
        return AppStatus.kFailed;
      }
    } catch (e) {
      _setLoadingState(false);
      notifyListeners();
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
        print("Google sign-in error");
        notifyListeners();
        return AppStatus.kFailed;
      } // user aborted sign in

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google [UserCredential]
      var userCredential = await _auth.signInWithCredential(credential);
      if (userCredential != null) {
        user = userCredential.user;
        _setLoadingState(false);
        notifyListeners();
        return AppStatus.kEmailAlreadyExists;
      }
      return AppStatus.kSuccess;
    } catch (e) {
      _setLoadingState(false);
      print("Google sign-in error: $e");
      notifyListeners();
      return AppStatus.kFailed;
    }
  }

  // registeration using email and password
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
      print(userCredential);
      print("a");
      user = userCredential.user;
      if (user == null) {
        print("b");
        print(user);
        return AppStatus.kFailed;
      }
      print("c");
      // Send email verification
      await user!.sendEmailVerification();
      print("d");
      // Save auth state

      // await _notificationService.storeDeviceToken(uid: uid);
      // if (userCredential != null) {
      //   if (userCredential!.user != null) {
      //     userData = UsersModel.fromFirestore(
      //       (await FirebaseFirestore.instance
      //               .collection('users')
      //               .doc(userCredential!.user!.uid)
      //               .get())
      //           .data()!,
      //     );
      //     _setLoadingState(false);
      //     notifyListeners();
      //     return AppStatus.kSuccess;
      //   }
      //   _setLoadingState(false);
      //   notifyListeners();
      //   return AppStatus.kFailed;
      // } else {
      _setLoadingState(false);
      notifyListeners();
      return AppStatus.kSuccess;
      // }
    } on FirebaseAuthException catch (e) {
      if (e.code == AppStatus.kEmailAlreadyExists) {
        return AppStatus.kEmailAlreadyExists;
      }
      return e.message ?? "Authentication failed";
    } catch (e) {
      debugPrint("Sign up error: $e");
      return "Sign up failed";
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      AppRouter.offAll(context, AuthLoginScreen());
      await _auth.signOut();
      if (await GoogleSignIn().isSignedIn()) {
        await GoogleSignIn().signOut();
      }
      // Navigate after successful sign-out
    } catch (e) {
      print("Sign-out error: $e");
    }
  }
}
