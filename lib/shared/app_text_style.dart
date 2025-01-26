import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

abstract class AppTextStyle {
  /// Base text style
  static const TextStyle _baseTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: AppFontWeight.regular,
    color: AppColors.textPrimary,
  );

  ///Inter 10
  static TextStyle get regular10 => _baseTextStyle.copyWith(fontSize: 10);

  ///Inter medium 10
  static TextStyle get medium10 =>
      regular10.copyWith(fontWeight: AppFontWeight.medium);

  ///Inter 12
  static TextStyle get regular12 => _baseTextStyle.copyWith(fontSize: 12);

  ///Inter medium 12
  static TextStyle get medium12 =>
      regular12.copyWith(fontWeight: AppFontWeight.medium);

  ///Inter semibold 12
  static TextStyle get semibold12 =>
      regular12.copyWith(fontWeight: AppFontWeight.semiBold);

  ///Inter medium 14
  static TextStyle get medium14 => regular10.copyWith(
        fontWeight: AppFontWeight.medium,
        fontSize: 14.spMin,
      );

  ///Inter medium 16
  static TextStyle get medium16 => regular10.copyWith(
        fontWeight: AppFontWeight.medium,
        fontSize: 16.spMin,
      );

  ///Inter 14
  static TextStyle get regular14 => _baseTextStyle.copyWith(fontSize: 14);

  ///Inter light 14
  static TextStyle get light14 =>
      regular14.copyWith(fontWeight: AppFontWeight.light);

  ///Inter semibold 14
  static TextStyle get semibold14 =>
      regular14.copyWith(fontWeight: AppFontWeight.semiBold);

  ///Inter bold 14
  static TextStyle get bold14 =>
      regular14.copyWith(fontWeight: AppFontWeight.bold);

  ///Inter 15
  static TextStyle get regular15 => _baseTextStyle.copyWith(fontSize: 15);

  ///Inter medium 15
  static TextStyle get medium15 =>
      regular15.copyWith(fontWeight: AppFontWeight.medium);

  ///Inter semibold 15
  static TextStyle get semibold15 =>
      regular15.copyWith(fontWeight: AppFontWeight.semiBold);

  ///Inter 16
  static TextStyle get regular16 => _baseTextStyle.copyWith(fontSize: 16);

  ///Inter light 16
  static TextStyle get light16 =>
      regular16.copyWith(fontWeight: AppFontWeight.light);

  ///Inter semibold 16
  static TextStyle get semibold16 =>
      regular16.copyWith(fontWeight: AppFontWeight.semiBold);

  ///Inter bold 16
  static TextStyle get bold16 =>
      regular16.copyWith(fontWeight: AppFontWeight.bold);

  ///Inter 18
  static TextStyle get regular18 => _baseTextStyle.copyWith(fontSize: 18);

  ///Inter semibold 18
  static TextStyle get semibold18 =>
      regular18.copyWith(fontWeight: AppFontWeight.semiBold);

  ///Inter bold 18
  static TextStyle get bold18 =>
      regular18.copyWith(fontWeight: AppFontWeight.bold);

  ///Inter 20
  static TextStyle get regular20 => _baseTextStyle.copyWith(fontSize: 20);

  ///Inter medium 20
  static TextStyle get medium20 =>
      regular20.copyWith(fontWeight: AppFontWeight.medium);

  ///Inter semibold 20
  static TextStyle get semibold20 =>
      regular20.copyWith(fontWeight: AppFontWeight.semiBold);

  ///Inter bold 20
  static TextStyle get bold20 =>
      regular20.copyWith(fontWeight: AppFontWeight.bold);

  ///Inter 24
  static TextStyle get regular24 => _baseTextStyle.copyWith(fontSize: 24);

  ///Inter semibold 24
  static TextStyle get semibold24 => regular24.copyWith(
        fontWeight: AppFontWeight.semiBold,
      );

  ///Inter bold 24
  static TextStyle get bold24 => regular24.copyWith(
        fontWeight: AppFontWeight.bold,
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

  // Timesheet styles
  static TextStyle get timesheetTitle => _baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: AppFontWeight.semiBold,
        height: 24/20, // line-height: 24px
      );

  static TextStyle get visitId => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: AppFontWeight.semiBold,
        height: 20/14, // line-height: 20px
      );

  static TextStyle get timesheetLabel => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: AppFontWeight.regular,
        height: 16/12, // line-height: 16px
        letterSpacing: 0.005,
      );

  static TextStyle get timesheetTime => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: AppFontWeight.semiBold,
        height: 16/12, // line-height: 16px
      );

  static TextStyle get clockOutButton => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: AppFontWeight.medium,
        height: 16/12, // line-height: 16px
        letterSpacing: 0.005,
        color: AppColors.primary,
      );

  static TextStyle get appointmentDetails => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: AppFontWeight.medium,
        height: 16/12, // line-height: 16px
        letterSpacing: 0.005,
        color: AppColors.grey300,
      );

  static TextStyle get durationLabel => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: AppFontWeight.medium,
        height: 16/12, // line-height: 16px
        letterSpacing: 0.005,
      );

  static TextStyle get durationValue => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: AppFontWeight.semiBold,
        height: 16/12, // line-height: 16px
        letterSpacing: 0.005,
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