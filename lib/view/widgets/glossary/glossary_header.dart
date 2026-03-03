import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/icon_svg.dart';
import 'package:diplomasi_app/view/widgets/general/notification_button.dart';
import 'package:flutter/material.dart';

class GlossaryHeader extends StatelessWidget {
  const GlossaryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: getWidth(),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + height(20),
        left: width(20),
        right: width(20),
        bottom: height(20),
      ),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: scheme.onPrimary,
              size: width(22),
            ),
          ),
          SizedBox(width: width(12)),
          Text(
            'المصطلحات',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w700,
              fontSize: emp(22),
              color: scheme.onPrimary,
            ),
          ),
          SizedBox(width: width(12)),
          MySvgIcon(
            path: Assets.icons.svg.terminology,
            size: emp(24),
            color: scheme.onPrimary,
          ),
          Spacer(),
          NotificationButton(),
        ],
      ),
    );
  }
}
