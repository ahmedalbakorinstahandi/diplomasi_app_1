import 'dart:io';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/data/model/users/user_model.dart';
import 'package:diplomasi_app/data/resource/remote/general/general_data.dart';
import 'package:diplomasi_app/data/resource/remote/user/user_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileControllerImp extends GetxController {
  GeneralData generalData = GeneralData();
  UserData userData = UserData();

  // Text Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  // State
  bool isLoading = false;
  bool isUploadingImage = false;
  File? selectedImage;
  String? currentAvatarUrl;
  UserModel? currentUser;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    isLoading = true;
    update();

    final response = await userData.getMyInfo();
    if (response.success) {
      currentUser = UserModel.fromJson(response.data);
      currentAvatarUrl = currentUser?.avatar;

      Shared.setValue('user-data', response.data);

      // Populate fields
      firstNameController.text = currentUser?.firstName ?? '';
      lastNameController.text = currentUser?.lastName ?? '';
      emailController.text = currentUser?.email ?? '';
      phoneController.text = currentUser?.phone ?? '';
      addressController.text = currentUser?.address ?? '';
    }

    isLoading = false;
    update();
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        selectedImage = File(image.path);
        uploadProfileImage();
      }
    } catch (e) {
      customSnackBar(text: 'فشل اختيار الصورة', snackType: SnackBarType.error);
    }
  }

  Future<void> uploadProfileImage() async {
    if (selectedImage == null) return;

    isUploadingImage = true;
    update();

    final response = await generalData.uploadImage(
      imageFile: selectedImage!,
      folder: 'users',
    );

    if (response.isSuccess) {
      currentAvatarUrl = response.data!.imageUrl;
    }
    isUploadingImage = false;
    update();
  }

  Future<void> saveProfile() async {
    if (!formState.currentState!.validate()) return;
    isLoading = true;
    update();

    // Prepare update data
    final updateData = <String, dynamic>{
      'first_name': firstNameController.text.trim(),
      'last_name': lastNameController.text.trim(),
      'address': addressController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      if (selectedImage != null) 'avatar': currentAvatarUrl,
    };

    final response = await userData.updateProfile(updateData);

    if (response.success) {
      Get.back();
      customSnackBar(
        text: response.message ?? 'تم حفظ التغييرات بنجاح',
        snackType: SnackBarType.correct,
      );

      Shared.setValue('user-data', response.data);
    }

    isLoading = false;
    update();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
