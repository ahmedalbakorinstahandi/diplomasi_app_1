import 'package:cached_network_image/cached_network_image.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = getUserData();
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Positioned(
      top: height(90),
      child: Column(
        children: [
          // Profile Picture with Gold Border
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
              child: CachedNetworkImage(
                imageUrl: user?.avatar ?? '',
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: colors.border,
                  child: Icon(
                    Icons.person,
                    color: colors.textSecondary,
                    size: emp(40),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: height(16)),
          // User Name
          Text(
            '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
            style: TextStyle(
              fontSize: emp(16),
              fontWeight: FontWeight.w400,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: height(8)),
          // Email
          Text(
            user?.email ?? 'Example@gmail.com',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: emp(16),
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

