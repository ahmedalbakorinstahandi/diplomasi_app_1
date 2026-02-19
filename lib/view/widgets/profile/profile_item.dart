import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/icon_svg.dart';
import 'package:flutter/material.dart';

class ProfileItem extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback? onTap;
  final bool hasSwitch;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final bool hasDropdown;
  final String? dropdownValue;
  final List<String>? dropdownItems;
  final ValueChanged<String>? onDropdownChanged;
  final bool isLoading;

  const ProfileItem({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.hasSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
    this.hasDropdown = false,
    this.dropdownValue,
    this.dropdownItems,
    this.onDropdownChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: (hasSwitch || hasDropdown) ? null : onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: height(8)),
        padding: EdgeInsets.symmetric(
          horizontal: width(16),
          vertical: height(20),
        ),
        decoration: BoxDecoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon
            MySvgIcon(path: icon, size: emp(24), color: scheme.onSurface),
            SizedBox(width: width(12)),
            // Title
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: emp(14),
                  fontWeight: FontWeight.w400,
                  height: 17 / 14,
                  color: scheme.onSurface,
                ),
              ),
            ),
            SizedBox(width: width(12)),
            // Switch, Dropdown or Arrow
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: scheme.primary,
                  strokeWidth: 2,
                ),
              )
            else if (hasDropdown &&
                dropdownItems != null &&
                dropdownValue != null)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colors.borderStrong, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: width(12),
                  vertical: height(10),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    popupMenuTheme: PopupMenuThemeData(
                      color: colors.backgroundSecondary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: colors.border, width: 1),
                      ),
                    ),
                  ),
                  child: PopupMenuButton<String>(
                    offset: Offset(0, height(50)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dropdownValue!,
                          style: TextStyle(
                            fontSize: emp(14),
                            fontWeight: FontWeight.w400,
                            color: scheme.onSurface,
                          ),
                        ),
                        SizedBox(width: width(8)),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: scheme.onSurface,
                          size: emp(20),
                        ),
                      ],
                    ),
                    itemBuilder: (context) {
                      return dropdownItems!.map((item) {
                        final isSelected = item == dropdownValue;
                        return PopupMenuItem<String>(
                          value: item,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: emp(14),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? scheme.primary
                                        : scheme.onSurface,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  color: scheme.primary,
                                  size: emp(18),
                                ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    onSelected: (value) {
                      if (onDropdownChanged != null) {
                        onDropdownChanged!(value);
                      }
                    },
                  ),
                ),
              )
            else if (hasSwitch)
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: scheme.primary,
                activeThumbColor: colors.backgroundSecondary,
              )
            else
              MySvgIcon(
                path: Assets.icons.svg.arrowLeft,
                size: emp(24),
                color: scheme.onSurface,
              ),
          ],
        ),
      ),
    );
  }
}
