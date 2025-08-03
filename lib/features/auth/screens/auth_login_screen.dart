import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lottie/lottie.dart';
import 'package:skin_app_migration/core/constants/app_assets.dart';
import 'package:skin_app_migration/core/constants/app_status.dart';
import 'package:skin_app_migration/core/extensions/provider_extensions.dart';
import 'package:skin_app_migration/core/helpers/toast_helper.dart';
import 'package:skin_app_migration/core/router/app_router.dart';
import 'package:skin_app_migration/core/theme/app_styles.dart';
import 'package:skin_app_migration/core/widgets/k_background_scaffold.dart';
import 'package:skin_app_migration/core/widgets/k_custom_button.dart';
import 'package:skin_app_migration/core/widgets/k_custom_input_field.dart';
import 'package:skin_app_migration/features/auth/screens/auth_registeration_screen.dart';
import 'package:skin_app_migration/features/auth/widgets/k_google_auth_button.dart';
import 'package:skin_app_migration/features/auth/widgets/k_or_bar.dart';
import 'package:skin_app_migration/features/message/screens/chat_screen.dart';

class AuthLoginScreen extends StatefulWidget {
  const AuthLoginScreen({super.key});

  @override
  State<AuthLoginScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends State<AuthLoginScreen> {
  ///controller
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  ///formKey
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  void getAuthBaseScreen(BuildContext context, String result) {
    switch (result) {
      case AppStatus.kBlocked:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Account Disabled"),
              content: Text(
                "Your account has been disabled. Please contact support.",
              ),
              actions: [
                TextButton(
                  onPressed: () => AppRouter.back(context),
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        break;

      case AppStatus.kInvalidCredential:
        ToastHelper.showErrorToast(
          context: context,
          message: "Invalid email or password",
        );
        break;

      case AppStatus.kUserNotFound:
        ToastHelper.showErrorToast(
          context: context,
          message: "User not found. Please register first.",
        );
        break;

      case AppStatus.kSuccess:
        // User exists and login successful - go to home screen
        AppRouter.replace(context, ChatScreen());
        ToastHelper.showSuccessToast(
          context: context,
          message: "Login successful",
        );
        break;

      case AppStatus.kFailed:
      default:
        ToastHelper.showErrorToast(
          context: context,
          message: "Login failed. Please try again.",
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KBackgroundScaffold(
      loading: context.readAuthProvider.isLoading,
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            spacing: 0.02.sh,
            children: [
              Lottie.asset(AppAssets.login, width: 0.80.sw),
              KCustomInputField(
                name: "email",
                hintText: "Email",
                controller: emailController,
                validators: [
                  FormBuilderValidators.email(),
                  FormBuilderValidators.required(
                    errorText: "Email is required",
                  ),
                ],
              ),
              KCustomInputField(
                isPassword: true,
                name: "password",
                hintText: "Password",
                controller: passwordController,
                validators: [
                  FormBuilderValidators.required(
                    errorText: "password is required",
                  ),
                  FormBuilderValidators.minLength(
                    6,
                    errorText: "Must be at least 6 characters",
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(right: AppStyles.padding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      // onTap: () => AppRouter.to(context, ForgetPassword()),
                      child: Text("Forget password ?"),
                    ),
                  ],
                ),
              ),
              KCustomButton(
                text: "Login",
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    if (emailController.text.trim().isNotEmpty &&
                        passwordController.text.trim().isNotEmpty) {
                      print(emailController.text);
                      print(passwordController.text);

                      if (context.readInternetProvider.connectivityStatus ==
                          AppStatus.kDisconnected) {
                        print("Please connect to internet");
                      }

                      final result = await context.readAuthProvider
                          .signInWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                            context: context,
                          );

                      getAuthBaseScreen(context, result);
                      // print("=========================$result");
                    }
                  }
                },
              ),
              KOrBar(),
              KGoogleAuthButton(
                onPressed: () async {
                  final result = await context.readAuthProvider
                      .signInWithGoogle();
                  if (!context.mounted) return;

                  // switch (result) {
                  //   case AppStatus.kBlocked:
                  //     showDialog(
                  //       context: context,
                  //       builder: (BuildContext context) {
                  //         return AlertDialog(
                  //           title: Text("Blocked"),
                  //           content: Text(
                  //             "Please contact the Admin for more information",
                  //           ),
                  //           actions: [
                  //             TextButton(
                  //               onPressed: () async {
                  //                 MyNavigation.back(context);
                  //                 await authProvider.signOut();
                  //               },
                  //               child: Text("ok"),
                  //             ),
                  //           ],
                  //         );
                  //       },
                  //     );
                  //
                  //   case AppStatus.kEmailAlreadyExists:
                  //     MyNavigation.replace(context, HomeScreenVarient2());
                  //     ToastHelper.showSuccessToast(
                  //       context: context,
                  //       message: "Login Successful",
                  //     );
                  //
                  //     break;
                  //
                  //   case AppStatus.kSuccess:
                  //     MyNavigation.replace(context, BasicDetailsScreen());
                  //     break;
                  //
                  //   case AppStatus.kFailed:
                  //     ToastHelper.showErrorToast(
                  //       context: context,
                  //       message: "Login Failed",
                  //     );
                  //     await authProvider.signOut();
                  //     break;
                  //
                  //   default:
                  //     print("Google Auth Result: $result");
                  //     ToastHelper.showErrorToast(
                  //       context: context,
                  //       message: result,
                  //     );
                  //     break;
                  // }
                },
                text: 'continue with google',
              ),
              InkWell(
                onTap: () => AppRouter.to(context, AuthRegisterationScreen()),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 0.02.sw,
                  children: [
                    Text(
                      "Not a member ?",
                      style: TextStyle(fontSize: AppStyles.subTitle),
                    ),
                    Text(
                      "Register",
                      style: TextStyle(
                        fontSize: AppStyles.subTitle,
                        color: AppStyles.links,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
