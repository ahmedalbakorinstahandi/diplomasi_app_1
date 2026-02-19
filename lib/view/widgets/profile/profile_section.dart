import 'package:diplomasi_app/view/widgets/profile/profile_item.dart';
import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  final List<ProfileItem> items;

  const ProfileSection({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: items);
  }
}

