import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:skin_app_migration/core/widgets/k_background_scaffold.dart';
import 'package:skin_app_migration/core/widgets/k_custom_button.dart';
import 'package:skin_app_migration/core/widgets/k_custom_input_field.dart';

class AuthForgetPasswordScreen extends StatelessWidget {
  AuthForgetPasswordScreen({super.key});

  ///formKey
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ///controller
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return KBackgroundScaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: Column(
          spacing: 0.03.sh,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KCustomInputField(
              name: "email",
              hintText: "Email",
              controller: emailController,
              validators: [
                FormBuilderValidators.email(),
                FormBuilderValidators.required(errorText: "Email is required"),
              ],
            ),
            KCustomButton(
              // isLoading: myAuthProvider.isLoading,
              prefixWidget: Icon(Icons.email, size: 0.025.sh),
              text: "Get email",
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                // if (internetProvider.connectionStatus ==
                //         AppStatus.kDisconnected ||
                //     internetProvider.connectionStatus == AppStatus.kSlow) {
                //   return ToastHelper.showErrorToast(
                //     context: context,
                //     message: "Please check your internet connection !!",
                //   );
                // }

                // final result = await myAuthProvider.resetPassword(
                //   email: emailController.text.trim(),
                // );

                // if (context.mounted) {
                //   if (result == AppStatus.kSuccess) {
                //     ToastHelper.showSuccessToast(
                //       context: context,
                //       message: "Email has sent to your email",
                //     );
                //     MyNavigation.back(context);
                //   } else if (result == AppStatus.kEmailNotFound) {
                //     ToastHelper.showErrorToast(
                //       context: context,
                //       message: "Email not exists",
                //     );
                //   } else {
                //     ToastHelper.showErrorToast(
                //       context: context,
                //       message: "Error while sending email",
                //     );
                //   }
                // }
              },
            ),
          ],
        ),
      ),
    );
  }
}
