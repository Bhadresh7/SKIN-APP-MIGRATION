import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skin_app_migration/core/widgets/k_background_scaffold.dart';
import 'package:skin_app_migration/core/widgets/k_custom_button.dart';
import 'package:skin_app_migration/core/widgets/k_custom_input_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  final ValueNotifier<bool> isUpdateEnabled = ValueNotifier(false);
  late Future<void> _loadUserDataFuture;
  // late ImagePickerProvider imagePickerProvider;

  @override
  void initState() {
    super.initState();
    // _loadUserDataFuture = _loadUserData();
    //
    // usernameController.addListener(_checkForChanges);
    // mobileNumberController.addListener(_checkForChanges);
    // dateController.addListener(_checkForChanges);
    //
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   imagePickerProvider = context.read<ImagePickerProvider>();
    //   imagePickerProvider.addListener(_checkForChanges);
    // });
  }

  // Future<void> _loadUserData() async {
  //   final data = HiveService.getCurrentUser();
  //   usernameController.text = data?.username ?? "user";
  //   mobileNumberController.text = data?.mobileNumber ?? "";
  //   dateController.text = data?.dob ?? "";
  // }

  // Future<void> _handleUpdate(
  //   MyAuthProvider provider,
  //   BasicUserDetailsProvider basicUserDetailsProvider,
  //   ImagePickerProvider imagePickerProvider,
  //   InternetProvider internetProvider,
  // ) async {
  //   if (_formKey.currentState!.validate()) {
  //     final confirm = await showDialog<bool>(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text("Confirm Update"),
  //         content: const Text("Do you want to update the profile?"),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(false),
  //             child: const Text("Cancel"),
  //           ),
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(true),
  //             child: const Text("Yes"),
  //           ),
  //         ],
  //       ),
  //     );
  //
  //     if (confirm != true) return;
  //
  //     String? imageUrl = provider.currentUser?.imageUrl ?? "";
  //
  //     if (imagePickerProvider.selectedImage != null) {
  //       imageUrl = await imagePickerProvider.uploadImageToFirebase(
  //         HiveService.getCurrentUser()?.uid ?? "",
  //       );
  //     }
  //
  //     final result = await basicUserDetailsProvider.updateUserProfile(
  //       mobile: mobileNumberController.text.trim(),
  //       dob: dateController.text.trim(),
  //       name: usernameController.text.trim(),
  //       imgUrl: imageUrl,
  //     );
  //
  //     if (internetProvider.connectionStatus == AppStatus.kDisconnected) {
  //       return ToastHelper.showErrorToast(
  //         context: context,
  //         message: "Please check your internet connection",
  //       );
  //     }
  //
  //     if (result == AppStatus.kFailed) {
  //       return ToastHelper.showErrorToast(
  //         context: context,
  //         message: "User not found",
  //       );
  //     }
  //
  //     if (result == AppStatus.kSuccess) {
  //       ToastHelper.showSuccessToast(
  //         context: context,
  //         message: "Updated Successfully",
  //       );
  //
  //       await provider.getUserDetails(email: provider.email);
  //       HiveService.saveUserToHive(user: provider.currentUser);
  //       await _loadUserData();
  //       imagePickerProvider.clear();
  //       isUpdateEnabled.value = false;
  //     }
  //   }
  // }
  //
  // void _checkForChanges() {
  //   final currentUser = HiveService.getCurrentUser();
  //   final selectedImage = context.read<ImagePickerProvider>().selectedImage;
  //
  //   final isChanged =
  //       usernameController.text.trim() != (currentUser?.username ?? "user") ||
  //       mobileNumberController.text.trim() !=
  //           (currentUser?.mobileNumber ?? "") ||
  //       dateController.text.trim() != (currentUser?.dob ?? "") ||
  //       selectedImage != null;
  //
  //   if (isUpdateEnabled.value != isChanged) {
  //     isUpdateEnabled.value = isChanged;
  //   }
  // }

  // @override
  // void dispose() {
  //   usernameController.removeListener(_checkForChanges);
  //   mobileNumberController.removeListener(_checkForChanges);
  //   dateController.removeListener(_checkForChanges);
  //
  //   imagePickerProvider.removeListener(_checkForChanges);
  //
  //   usernameController.dispose();
  //   mobileNumberController.dispose();
  //   dateController.dispose();
  //   isUpdateEnabled.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    // final basicUserDetailsProvider = context.watch<BasicUserDetailsProvider>();
    // final imagePickerProvider = context.watch<ImagePickerProvider>();
    // final provider = context.read<MyAuthProvider>();
    // final internetProvider = context.watch<InternetProvider>();

    return PopScope(
      // onPopInvokedWithResult: (didPop, result) {
      //   if (didPop) {
      //     imagePickerProvider.clear();
      //   }
      // },
      child: FutureBuilder(
        future: _loadUserDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const KBackgroundScaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return KBackgroundScaffold(
            // loading:
            //     imagePickerProvider.isUploading ||
            //     basicUserDetailsProvider.isLoading,
            appBar: AppBar(),
            body: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 0.03.sh),
                  GestureDetector(
                    onTap: () async {
                      // await imagePickerProvider.pickImage();
                    },
                    child: CircleAvatar(
                      radius: 0.15.sh,
                      // backgroundImage: imagePickerProvider.selectedImage != null
                      //     ? FileImage(imagePickerProvider.selectedImage!)
                      //     : (HiveService.getCurrentUser()
                      //               ?.imageUrl
                      //               ?.isNotEmpty ??
                      //           false)
                      //     ? CachedNetworkImageProvider(
                      //         HiveService.getCurrentUser()!.imageUrl!,
                      //       )
                      //     : AssetImage(AppAssets.profileImage) as ImageProvider,
                    ),
                  ),
                  SizedBox(height: 0.03.sh),
                  KCustomInputField(
                    controller: usernameController,
                    name: "name",
                    hintText: "name",
                    validators: [
                      // FormBuilderValidators.required(
                      //   errorText: "name is required",
                      // ),
                      // FormBuilderValidators.minLength(
                      //   3,
                      //   errorText: "Enter a valid username",
                      // ),
                    ],
                  ),
                  SizedBox(height: 0.03.sh),
                  KCustomInputField(
                    controller: mobileNumberController,
                    name: "mobile",
                    hintText: "mobile number",
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    validators: [
                      // FormBuilderValidators.required(
                      //   errorText: "Mobile number is required",
                      // ),
                      // FormBuilderValidators.match(
                      //   RegExp(r'^[6789]\d{9}$'),
                      //   errorText: "Enter a valid mobile number",
                      // ),
                    ],
                  ),
                  SizedBox(height: 0.03.sh),
                  // DateInputField(
                  //   controller: dateController,
                  //   initialValue: DateFormaterHelper.formatedDate(
                  //     value: dateController.text,
                  //   ),
                  // ),
                  SizedBox(height: 0.09.sh),
                  ValueListenableBuilder<bool>(
                    valueListenable: isUpdateEnabled,
                    builder: (context, enabled, _) {
                      return KCustomButton(
                        text: "Update",
                        enabled: enabled,
                        onPressed: () {
                          // _handleUpdate(
                          //   provider,
                          //   basicUserDetailsProvider,
                          //   imagePickerProvider,
                          //   internetProvider,
                          // );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 0.05.sh),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
