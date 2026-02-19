import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/icon_svg.dart';
import 'package:flutter/material.dart';

class EditProfileAvatar extends StatelessWidget {
  final File? selectedImage;
  final String? currentAvatarUrl;
  final VoidCallback onEditTap;

  const EditProfileAvatar({
    super.key,
    this.selectedImage,
    this.currentAvatarUrl,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: width(120),
          height: width(120),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.surface,
            border: Border.all(
              color: colors.highlight,
              width: 6,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(150),
            child: _buildImage(context),
          ),
        ),
        Positioned(
          right: -width(12),
          child: GestureDetector(
            onTap: onEditTap,
            child: Container(
              width: width(32),
              height: width(32),
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.highlight,
                  width: 2,
                ),
              ),
              child: Center(
                child: MySvgIcon(
                  path: Assets.icons.svg.editPencilOutline,
                  size: emp(20),
                  color: scheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    if (selectedImage != null) {
      return Image.file(selectedImage!, fit: BoxFit.cover);
    }
    if (currentAvatarUrl != null) {
      return CachedNetworkImage(
        imageUrl: currentAvatarUrl!,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => _buildPlaceholder(context),
      );
    }
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    final colors = context.appColors;
    return Container(
      color: colors.border,
      child: Icon(
        Icons.person,
        color: colors.textSecondary,
        size: emp(40),
      ),
    );
  }
}

