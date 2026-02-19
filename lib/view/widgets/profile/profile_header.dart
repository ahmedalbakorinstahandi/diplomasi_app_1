import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/view/widgets/general/notification_button.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: getWidth(),
      height: height(150),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + height(20),
        left: width(20),
        right: width(20),
        bottom: height(30),
      ),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "حسابي",
                style: TextStyle(
                  fontSize: emp(20),
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimary,
                ),
              ),
              Spacer(),
              NotificationButton(),
            ],
          ),
        ],
      ),
    );
  }
}
