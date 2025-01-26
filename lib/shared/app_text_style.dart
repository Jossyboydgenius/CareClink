import 'package:flutter/material.dart';

abstract class AppTextStyle {
  /// Base text style
  static const TextStyle _baseTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: AppFontWeight.regular,
    color: Color(0xFF404969),
  );

  // Welcome Back text style
  static TextStyle get welcomeBack => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: AppFontWeight.medium,
        height: 20/14, // line-height: 20px
        letterSpacing: 0.005,
      );

  // Activities summary text style
  static TextStyle get activitiesSummary => _baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: AppFontWeight.semiBold,
        height: 24/20, // line-height: 24px
      );

  // Activity hours text style
  static TextStyle get activityHours => _baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: AppFontWeight.semiBold,
        height: 28/24, // line-height: 28px
        letterSpacing: 0.005,
      );

  // Activity completed text style
  static TextStyle get activityCompleted => _baseTextStyle.copyWith(
        fontSize: 8,
        fontWeight: AppFontWeight.medium,
        height: 12/8, // line-height: 12px
        letterSpacing: 0.005,
      );

  // Activity title text style
  static TextStyle get activityTitle => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: AppFontWeight.medium,
        height: 16/12, // line-height: 16px
        letterSpacing: 0.005,
        color: Colors.grey,
      );
}

abstract class AppFontWeight {
  /// FontWeight value of `w900`
  static const FontWeight black = FontWeight.w900;

  /// FontWeight value of `w800`
  static const FontWeight extraBold = FontWeight.w800;

  /// FontWeight value of `w700`
  static const FontWeight bold = FontWeight.w700;

  /// FontWeight value of `w600`
  static const FontWeight semiBold = FontWeight.w600;

  /// FontWeight value of `w500`
  static const FontWeight medium = FontWeight.w500;

  /// FontWeight value of `w400`
  static const FontWeight regular = FontWeight.w400;

  /// FontWeight value of `w300`
  static const FontWeight light = FontWeight.w300;

  /// FontWeight value of `w200`
  static const FontWeight extraLight = FontWeight.w200;

  /// FontWeight value of `w100`
  static const FontWeight thin = FontWeight.w100;
} 