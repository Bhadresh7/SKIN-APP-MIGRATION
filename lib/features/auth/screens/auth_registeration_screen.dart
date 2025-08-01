import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lottie/lottie.dart';
import 'package:skin_app_migration/core/constants/app_assets.dart';
import 'package:skin_app_migration/core/router/app_router.dart';
import 'package:skin_app_migration/core/theme/app_styles.dart';
import 'package:skin_app_migration/core/widgets/k_background_scaffold.dart'
    show KBackgroundScaffold;
import 'package:skin_app_migration/core/widgets/k_custom_button.dart';
import 'package:skin_app_migration/core/widgets/k_custom_input_field.dart';
import 'package:skin_app_migration/features/auth/screens/auth_login_screen.dart';
import 'package:skin_app_migration/features/auth/widgets/k_google_auth_button.dart';
import 'package:skin_app_migration/features/auth/widgets/k_or_bar.dart';

class AuthRegisterationScreen extends StatefulWidget {
  const AuthRegisterationScreen({super.key});

  @override
  State<AuthRegisterationScreen> createState() =>
      _AuthRegisterationScreenState();
}

class _AuthRegisterationScreenState extends State<AuthRegisterationScreen> {
  @override
  Widget build(BuildContext context) {
    /// formKey
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    /// providers
    // final authProvider = Provider.of<MyAuthProvider>(context);

    return KBackgroundScaffold(
      // loading: authProvider.isLoading,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Form(
          key: formKey,
          child: Column(
            spacing: 0.025.sh,
            children: [
              Lottie.asset(AppAssets.login, height: 0.25.sh),
              KCustomInputField(
                name: "username",
                hintText: "Username",
                // controller: authProvider.usernameController,
                validators: [
                  FormBuilderValidators.required(
                    errorText: "Username is required",
                  ),
                  FormBuilderValidators.minLength(
                    3,
                    errorText: "Must be at least 3 characters",
                  ),
                ],
              ),
              KCustomInputField(
                name: "email",
                hintText: "Email",
                // controller: authProvider.emailController,
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
                // controller: authProvider.passwordController,
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
              KCustomInputField(
                isPassword: true,
                name: "confirm password",
                hintText: "Confirm Password",
                // controller: authProvider.confirmPasswordController,
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
              KCustomButton(
                text: "Register",
                onPressed: () async {
                  // if (formKey.currentState!.validate()) {
                  //   if (!(authProvider.passwordController.text.trim() ==
                  //       authProvider.confirmPasswordController.text.trim())) {
                  //     return ToastHelper.showErrorToast(
                  //       context: context,
                  //       message: "Password doesn't match",
                  //     );
                  //   }
                  //   final result = await authProvider
                  //       .signUpWithEmailAndPassword(
                  //         username: authProvider.usernameController.text.trim(),
                  //         email: authProvider.emailController.text.trim(),
                  //         password: authProvider.passwordController.text.trim(),
                  //       );
                  //   if (context.mounted) {
                  //     switch (result) {
                  //       case AppStatus.kUserNameAlreadyExists:
                  //         return ToastHelper.showErrorToast(
                  //           context: context,
                  //           message: AppStatus.kUserNameAlreadyExists,
                  //         );
                  //       case AppStatus.kEmailAlreadyExists:
                  //         return ToastHelper.showErrorToast(
                  //           context: context,
                  //           message: AppStatus.kEmailAlreadyExists,
                  //         );
                  //       case AppStatus.kUserFound:
                  //         return ToastHelper.showErrorToast(
                  //           context: context,
                  //           message: "Username already exists",
                  //         );
                  //       case AppStatus.kFailed:
                  //         return ToastHelper.showErrorToast(
                  //           context: context,
                  //           message: "Failed to Register",
                  //         );
                  //       case AppStatus.kSuccess:
                  //         ToastHelper.showSuccessToast(
                  //           context: context,
                  //           message: "Registeration successful",
                  //         );
                  //
                  //         MyNavigation.to(context, EmailVerificationScreen());
                  //         break;
                  //       default:
                  //         return ToastHelper.showErrorToast(
                  //           context: context,
                  //           message: result,
                  //         );
                  //     }
                  //   }
                  // }
                },
              ),

              ///---or--- Divider
              KOrBar(),

              ///OAuthButton
              KGoogleAuthButton(
                // onPressed: () async {
                //   final result = await authProvider.signInWithGoogle();
                //   print("0000000000000000$result");
                //   if (!context.mounted) return;
                //   switch (result) {
                //     case AppStatus.kBlocked:
                //       showDialog(
                //         context: context,
                //         builder: (BuildContext context) {
                //           return AlertDialog(
                //             title: Text("User Blocked"),
                //             content: Text(
                //               "Please contact the Admin for more information",
                //             ),
                //             actions: [
                //               TextButton(
                //                 onPressed: () => MyNavigation.back(context),
                //                 child: Text("ok"),
                //               ),
                //             ],
                //           );
                //         },
                //       );
                //     case AppStatus.kEmailAlreadyExists:
                //       MyNavigation.replace(context, HomeScreenVarient2());
                //       ToastHelper.showSuccessToast(
                //         context: context,
                //         message: "Login Successful",
                //       );
                //
                //       break;
                //
                //     case AppStatus.kSuccess:
                //       MyNavigation.replace(context, BasicDetailsScreen());
                //       break;
                //
                //     case AppStatus.kFailed:
                //       ToastHelper.showErrorToast(
                //         context: context,
                //         message: "Login Failed",
                //       );
                //       break;
                //
                //     default:
                //       print("Google Auth Result: $result");
                //
                //       break;
                //   }
                // },
                onPressed: () {},
                text: 'continue with google',
              ),

              InkWell(
                onTap: () => AppRouter.replace(context, AuthLoginScreen()),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 0.02.sw,
                  children: [
                    Text(
                      "Already a member ?",
                      style: TextStyle(fontSize: AppStyles.subTitle),
                    ),
                    Text(
                      "Login",
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
