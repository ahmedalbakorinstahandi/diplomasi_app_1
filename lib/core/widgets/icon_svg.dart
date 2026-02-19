import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class MySvgIcon extends StatelessWidget {
  final String path;
  final double? size;
  final Color? color;
  final double? padding;
  final void Function()? onTap;
  const MySvgIcon({
    super.key,
    required this.path,
    this.size = 20,
    this.onTap,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(padding ?? 0.0),
        child: SvgPicture.asset(
          path,
          width: size,
          height: size,
          // ignore: deprecated_member_use
          color: color,
        ),
      ),
    );
  }
}
