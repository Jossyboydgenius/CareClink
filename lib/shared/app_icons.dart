// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIconData {
  static const String _basePath = 'assets/svgs/';
  static const String calendar = '${_basePath}calendar.svg';
  static const String dashboard = '${_basePath}dashboard.svg';
  static const String notification = '${_basePath}notification.svg';
  static const String check = '${_basePath}check.svg';
  static const String logOut = '${_basePath}log-out.svg';
  static const String roundCheck = '${_basePath}round-check.svg';
  static const String signature = '${_basePath}signature.svg';
  static const String digitalSignature = '${_basePath}digital-signature.svg';
  static const String interpreter = '${_basePath}interpeter.svg';
  static const String translator = '${_basePath}translator.svg';
  static const String staff = '${_basePath}staff.svg';
  static const String staffs = '${_basePath}staffs.svg';
  static const String client = '${_basePath}client.svg';
}

class AppIcons extends StatelessWidget {
  final VoidCallback? onPressed;
  final String icon;
  final double size;
  final Color? color;
  const AppIcons({
    super.key,
    this.onPressed,
    this.color,
    required this.icon,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SvgPicture.asset(
        icon,
        height: size,
        width: size,
        color: color,
      ),
    );
  }
}
