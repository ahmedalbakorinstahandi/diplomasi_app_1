import 'package:diplomasi_app/core/classes/validator.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/controllers/profile/edit_profile_controller.dart';
import 'package:diplomasi_app/view/shimmers/profile/presentation/shimmer/edit_profile_screen_shimmer.dart';
import 'package:diplomasi_app/view/widgets/profile/edit_profile_avatar.dart';
import 'package:diplomasi_app/view/widgets/profile/edit_profile_field.dart';
import 'package:diplomasi_app/view/widgets/profile/edit_profile_text_field.dart';
import 'package:diplomasi_app/view/widgets/profile/edit_profile_header.dart';
import 'package:diplomasi_app/view/widgets/profile/edit_profile_save_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(EditProfileControllerImp());

    return MyScaffold(
      body: GetBuilder<EditProfileControllerImp>(
        builder: (controller) {
          if (controller.isLoading && controller.currentUser == null) {
            return const EditProfileScreenShimmer();
          }

          return SingleChildScrollView(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Form(
                  key: controller.formState,
                  child: Column(
                    children: [
                      const EditProfileHeader(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width(14)),
                        child: Column(
                          children: [
                            SizedBox(height: height(110)),

                            // Name Fields
                            Row(
                              children: [
                                Expanded(
                                  child: EditProfileField(
                                    label: 'الاسم الاول',

                                    child: EditProfileTextField(
                                      controller:
                                          controller.firstNameController,
                                      keyboardType: TextInputType.text,
                                      validator: (value) =>
                                          MyValidator.validate(
                                            value,
                                            type: ValidatorType.text,
                                          ),
                                      iconPath: Assets.icons.svg.personOutline,
                                    ),
                                  ),
                                ),
                                SizedBox(width: width(12)),
                                Expanded(
                                  child: EditProfileField(
                                    label: 'الاسم الثاني',
                                    // iconPath: Assets.icons.svg.personOutline,
                                    child: EditProfileTextField(
                                      controller: controller.lastNameController,
                                      keyboardType: TextInputType.text,
                                      validator: (value) =>
                                          MyValidator.validate(
                                            value,
                                            type: ValidatorType.text,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Email
                            EditProfileField(
                              label: 'البريد الالكتروني',
                              iconPath: Assets.icons.svg.emailOutline,
                              child: EditProfileTextField(
                                controller: controller.emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => MyValidator.validate(
                                  value,
                                  type: ValidatorType.email,
                                ),
                                readOnly: true,
                                iconPath: Assets.icons.svg.emailOutline,
                              ),
                            ),
                            // Phone
                            EditProfileField(
                              label: 'رقم الهاتف',
                              iconPath: Assets.icons.svg.phone,
                              child: EditProfileTextField(
                                controller: controller.phoneController,
                                keyboardType: TextInputType.phone,
                                validator: (value) => MyValidator.validate(
                                  value,
                                  type: ValidatorType.phone,
                                ),
                                iconPath: Assets.icons.svg.phone,
                              ),
                            ),
                            // Address
                            EditProfileField(
                              label: 'العنوان',
                              iconPath: Assets.icons.svg.locationOutline,
                              child: EditProfileTextField(
                                controller: controller.addressController,
                                keyboardType: TextInputType.text,
                                validator: (value) => MyValidator.validate(
                                  value,
                                  type: ValidatorType.text,
                                ),
                                iconPath: Assets.icons.svg.locationOutline,
                              ),
                            ),
                            SizedBox(height: height(32)),
                            EditProfileSaveButton(
                              isLoading: controller.isLoading,
                              onPressed: controller.saveProfile,
                            ),
                            SizedBox(height: height(24)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: height(130),
                  child: EditProfileAvatar(
                    selectedImage: controller.selectedImage,
                    currentAvatarUrl: controller.currentAvatarUrl,
                    onEditTap: controller.pickImage,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
