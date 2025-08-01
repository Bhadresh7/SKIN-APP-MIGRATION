import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lottie/lottie.dart';
import 'package:skin_app_migration/core/constants/app_assets.dart';
import 'package:skin_app_migration/core/router/app_router.dart';
import 'package:skin_app_migration/core/theme/app_styles.dart';
import 'package:skin_app_migration/core/widgets/k_background_scaffold.dart';
import 'package:skin_app_migration/core/widgets/k_custom_button.dart';
import 'package:skin_app_migration/core/widgets/k_custom_input_field.dart';
import 'package:skin_app_migration/core/widgets/k_date_input_field.dart';
import 'package:skin_app_migration/features/about/terms_and_conditions.dart';

class BasicUserDetailsFormScreen extends StatefulWidget {
  const BasicUserDetailsFormScreen({super.key});

  @override
  State<BasicUserDetailsFormScreen> createState() =>
      _BasicUserDetailsFormScreenState();
}

class _BasicUserDetailsFormScreenState
    extends State<BasicUserDetailsFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController userNameController;
  late TextEditingController mobileNumberController;
  late TextEditingController dateController;

  @override
  void initState() {
    userNameController = TextEditingController();
    mobileNumberController = TextEditingController();
    dateController = TextEditingController();
    // userNameController.text = HiveService.formUserName ?? "User";
    super.initState();
    print("BASIC USER DETAILS ${userNameController.text}");
  }

  @override
  void dispose() {
    userNameController.dispose();
    dateController.dispose();
    mobileNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<MyAuthProvider>(context);
    // final basicDetailsProvider = Provider.of<BasicUserDetailsProvider>(context);
    // print("GOOGLE STATUS=====>>>>${context.read<MyAuthProvider>().isGoogle}");

    return PopScope(
      canPop: false,
      child: KBackgroundScaffold(
        // loading: basicDetailsProvider.isLoading,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                spacing: 0.025.sh,
                children: [
                  Lottie.asset(AppAssets.login, height: 0.3.sh),
                  KCustomInputField(
                    controller: userNameController,
                    name: "name",
                    hintText: "name",
                    validators: [
                      FormBuilderValidators.required(
                        errorText: "name is required",
                      ),
                    ],
                  ),
                  Container(
                    width: 0.6.sw,
                    alignment: Alignment.center,
                    child: FormBuilderRadioGroup<String>(
                      name: 'role',
                      decoration: InputDecoration(border: InputBorder.none),
                      validator: FormBuilderValidators.required(
                        errorText: "Please select a role",
                      ),
                      options: [
                        FormBuilderFieldOption(
                          value: "admin",
                          child: Text(
                            "Employer",
                            style: TextStyle(fontSize: AppStyles.subTitle),
                          ),
                        ),
                        FormBuilderFieldOption(
                          value: "user",
                          child: Text(
                            "Candidate",
                            style: TextStyle(fontSize: AppStyles.subTitle),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        // basicDetailsProvider.selectRole(role: value);
                      },
                    ),
                  ),
                  KCustomInputField(
                    controller: mobileNumberController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    name: "mobile number",
                    hintText: "mobile number",
                    validators: [
                      FormBuilderValidators.required(
                        errorText: "Mobile number is required",
                      ),
                      FormBuilderValidators.match(
                        RegExp(r'^[6-9]\d{9}$'),
                        errorText: "Enter a valid 10-digit mobile number",
                      ),
                    ],
                  ),
                  DateInputField(controller: dateController),
                  KCustomButton(
                    text: "submit",
                    onPressed: () async {
                      // if (_formKey.currentState!.validate() &&
                      //     basicDetailsProvider.selectedRole != null) {
                      //   UsersModel user = UsersModel(
                      //     dob: dateController.text.trim(),
                      //     mobileNumber: mobileNumberController.text.trim(),
                      //     uid: authProvider.uid,
                      //     username: userNameController.text.trim(),
                      //     email: authProvider.email,
                      //     role: basicDetailsProvider.selectedRole!,
                      //     isGoogle: authProvider.isGoogle ? true : false,
                      //     isBlocked: false,
                      //     canPost: false,
                      //     isAdmin: basicDetailsProvider.selectedRole! == "admin"
                      //         ? true
                      //         : false,
                      //     password: PasswordHashingHelper.hashPassword(
                      //       password: authProvider.passwordController.text,
                      //     ),
                      //   );
                      //   final result = await basicDetailsProvider
                      //       .saveUserToDbAndLocally(user);
                      //   print(
                      //     "BASIC USER DEATILS SCREEN ==================${result}",
                      //   );
                      //   switch (result) {
                      //     case AppStatus.kEmailAlreadyExists:
                      //       ToastHelper.showSuccessToast(
                      //         context: context,
                      //         message: AppStatus.kEmailAlreadyExists,
                      //       );
                      //       break;
                      //
                      //     case AppStatus.kSuccess:
                      //       await authProvider.completeBasicDetails();
                      //
                      //       if (authProvider.isGoogle) {
                      //         await authProvider.completeImageSetup();
                      //         MyNavigation.replace(
                      //           context,
                      //           HomeScreenVarient2(),
                      //         );
                      //       } else {
                      //         MyNavigation.replace(context, ImageSetupScreen());
                      //       }
                      //       return;
                      //
                      //     case AppStatus.kFailed:
                      //       return ToastHelper.showErrorToast(
                      //         context: context,
                      //         message: result,
                      //       );
                      //
                      //     default:
                      //       // Handle unknown status if needed
                      //       return ToastHelper.showErrorToast(
                      //         context: context,
                      //         message: 'Unexpected error occurred.',
                      //       );
                      //   }
                      // }
                    },
                  ),
                  InkWell(
                    onTap: () =>
                        AppRouter.to(context, TermsAndConditionsScreen()),
                    child: Text(
                      "Terms & Conditions",
                      style: TextStyle(color: AppStyles.links),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
