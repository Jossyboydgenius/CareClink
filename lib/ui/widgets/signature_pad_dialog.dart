import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../../shared/app_toast.dart';

class SignaturePadDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String actionButtonText;
  final VoidCallback? onCancel;
  final Function(Uint8List signatureBytes)? onConfirm;

  const SignaturePadDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionButtonText,
    this.onCancel,
    this.onConfirm,
  });

  @override
  State<SignaturePadDialog> createState() => _SignaturePadDialogState();
}

class _SignaturePadDialogState extends State<SignaturePadDialog> {
  late SignatureController _signatureController;
  bool _isLoading = false;
  bool _hasSignature = false;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 2.5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    // Listen for signature changes
    _signatureController.addListener(() {
      setState(() {
        _hasSignature = _signatureController.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              widget.title,
              style: AppTextStyle.semibold18.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700, // Make title more prominent
              ),
            ),
            AppSpacing.v8(),
            Text(
              widget.subtitle,
              style: AppTextStyle.regular14.copyWith(
                color: AppColors.textPrimary, // Better contrast than grey400
                fontWeight: FontWeight.w500,
              ),
            ),
            AppSpacing.v16(),

            // Signature Pad Container - Maximum contrast approach
            Container(
              height: 220.h,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.white, // Ensure white background
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Signature(
                  controller: _signatureController,
                ),
              ),
            ),
            AppSpacing.v8(),

            // Instruction text - Enhanced visibility
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: AppColors.grey300.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit,
                    size: 16.w,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Draw your signature above',
                    style: AppTextStyle.medium12.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.v16(),

            // Action Buttons
            Row(
              children: [
                // Clear Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearSignature,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.grey300, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      backgroundColor:
                          Colors.white, // White background for contrast
                    ),
                    child: Text(
                      'Clear',
                      style: AppTextStyle.medium14.copyWith(
                        color: AppColors.textPrimary, // Better contrast color
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                AppSpacing.h12(),

                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.grey300, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      backgroundColor:
                          Colors.white, // White background for contrast
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.medium14.copyWith(
                        color: AppColors.textPrimary, // Better contrast color
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                AppSpacing.h12(),

                // Confirm Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_hasSignature && !_isLoading)
                        ? _confirmSignature
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 16.h,
                            width: 16.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white),
                            ),
                          )
                        : Text(
                            widget.actionButtonText,
                            style: AppTextStyle.medium14.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _clearSignature() {
    _signatureController.clear();
    setState(() {
      _hasSignature = false;
    });
  }

  Future<void> _confirmSignature() async {
    if (!_hasSignature || widget.onConfirm == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert signature to image
      final Uint8List? signatureBytes = await _signatureController.toPngBytes();

      if (signatureBytes != null) {
        widget.onConfirm!(signatureBytes);
      }
    } catch (e) {
      debugPrint('Error converting signature to image: $e');
      // Handle error using AppToast
      if (mounted) {
        AppToast.showError(
            context, 'Failed to process signature. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
