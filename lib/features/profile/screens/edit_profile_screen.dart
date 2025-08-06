import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:skin_app_migration/core/constants/app_assets.dart';
import 'package:skin_app_migration/core/helpers/toast_helper.dart';
import 'package:skin_app_migration/core/widgets/k_custom_button.dart';
import 'package:skin_app_migration/core/widgets/k_custom_input_field.dart';
import 'package:skin_app_migration/core/widgets/k_date_input_field.dart';
import 'package:skin_app_migration/features/auth/providers/my_auth_provider.dart';

import '../../../core/extensions/provider_extensions.dart';
import '../../../core/provider/image_picker_provider.dart';
import '../../../core/widgets/k_background_scaffold.dart';

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
  bool isLoading = true;

  late ImagePickerProvider imagePickerProvider;
  String? _userId;

  @override
  void initState() {
    super.initState();
    imagePickerProvider = context.read<ImagePickerProvider>();

    _userId = context.readAuthProvider.userData?.uid;

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = _userId;
    if (userId == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    final data = doc.data();

    if (data != null) {
      usernameController.text = data['username'] ?? '';
      mobileNumberController.text = data['mobileNumber'] ?? '';
      dateController.text = data['dob'] ?? '';

      print(context.readAuthProvider.userData!.dob);
      print(data['dob']);
      print(dateController.text.length);

      setState(() {
        isLoading = false;
      });
    }
    usernameController.addListener(_checkForChanges);
    mobileNumberController.addListener(_checkForChanges);
    dateController.addListener(_checkForChanges);
    imagePickerProvider.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final currentUser = context.readAuthProvider.userData;
    final selectedImage = context.readImagePickerProvider.selectedImage;

    final isChanged =
        usernameController.text.trim() != (currentUser?.username ?? "user") ||
        mobileNumberController.text.trim() !=
            (currentUser?.mobileNumber ?? "") ||
        dateController.text.trim() != (currentUser?.dob ?? "") ||
        selectedImage != null;
    print(isChanged);

    print(dateController.text);
    print(dateController.text.trim() != (currentUser?.dob ?? ""));

    isUpdateEnabled.value = isChanged;
  }

  Future<String?> _uploadImage(File file, String userId) async {
    final ref = FirebaseStorage.instance.ref().child(
      "users/$userId/profile.jpg",
    );
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = _userId;
    if (userId == null) return;

    String? imageUrl;
    final pickedImage = imagePickerProvider.selectedImage;
    if (pickedImage != null) {
      imageUrl = await _uploadImage(pickedImage, userId);
    }

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'username': usernameController.text.trim(),
      'mobileNumber': mobileNumberController.text.trim(),
      'dob': dateController.text.trim(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    });

    imagePickerProvider.clear();
    isUpdateEnabled.value = false;

    if (context.mounted) {
      ToastHelper.showSuccessToast(
        context: context,
        message: "Profile Updated Successfully",
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    mobileNumberController.dispose();
    dateController.dispose();
    imagePickerProvider.removeListener(_checkForChanges);
    isUpdateEnabled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyAuthProvider authProvider = Provider.of<MyAuthProvider>(context);
    return KBackgroundScaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: isLoading
          ? CircularProgressIndicator()
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GestureDetector(
                    onTap: () async {
                      await imagePickerProvider.pickImage();
                    },
                    child: CircleAvatar(
                      radius: 0.3.sw,
                      backgroundImage: imagePickerProvider.selectedImage != null
                          ? FileImage(imagePickerProvider.selectedImage!)
                          : authProvider.userData!.isGoogle!
                          ? NetworkImage(
                              context.readAuthProvider.user!.photoURL!,
                            )
                          : authProvider.userData!.imageUrl != null
                          ? NetworkImage(
                              context.readAuthProvider.userData!.imageUrl!,
                            )
                          : AssetImage(AppAssets.profileImage),
                    ),
                  ),
                  const SizedBox(height: 20),
                  KCustomInputField(
                    controller: usernameController,
                    name: 'name',
                    hintText: 'username',
                    validators: [FormBuilderValidators.required()],
                  ),
                  const SizedBox(height: 20),
                  KCustomInputField(
                    controller: mobileNumberController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    name: '',
                    hintText: '',
                    validators: [],
                  ),
                  const SizedBox(height: 20),

                  DateInputField(controller: dateController),
                  const SizedBox(height: 30),
                  ValueListenableBuilder<bool>(
                    valueListenable: isUpdateEnabled,
                    builder: (context, enabled, _) {
                      return KCustomButton(
                        text: "Update",
                        onPressed: () {
                          _handleUpdate();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
