import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../../shared/app_toast.dart';
import '../../data/services/signature_service.dart';
import '../../app/locator.dart';

class EnhancedSignaturePadDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String actionButtonText;
  final VoidCallback? onCancel;
  final Function(Uint8List signatureBytes)? onConfirm;
  final String? appointmentId; // Optional appointment ID for server upload
  final bool uploadToServer; // Whether to upload to server automatically

  const EnhancedSignaturePadDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionButtonText,
    this.onCancel,
    this.onConfirm,
    this.appointmentId,
    this.uploadToServer = false,
  });

  @override
  State<EnhancedSignaturePadDialog> createState() =>
      _EnhancedSignaturePadDialogState();
}

class _EnhancedSignaturePadDialogState
    extends State<EnhancedSignaturePadDialog> {
  late SignatureController _signatureController;
  final SignatureService _signatureService = locator<SignatureService>();
  bool _isLoading = false;
  bool _hasSignature = false;
  Color _selectedStrokeColor = Colors.black;
  Color _selectedBackgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _signatureController = SignatureController(
      penStrokeWidth: 2.5,
      penColor: _selectedStrokeColor,
      exportBackgroundColor: _selectedBackgroundColor,
    );

    // Listen for signature changes
    _signatureController.addListener(() {
      setState(() {
        _hasSignature = _signatureController.isNotEmpty;
      });
    });
  }

  void _recreateController() {
    _signatureController.dispose();
    _initializeController();
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  // Available stroke colors
  final List<Color> _strokeColors = [
    Colors.black,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.brown,
  ];

  // Available background colors
  final List<Color> _backgroundColors = [
    Colors.white,
    Colors.grey[100]!,
    Colors.grey[200]!,
    Colors.blue[50]!,
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                widget.title,
                style: AppTextStyle.semibold18.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.v8(),
              Text(
                widget.subtitle,
                style: AppTextStyle.regular14.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AppSpacing.v16(),

              // Color Selection
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stroke Color:',
                      style: AppTextStyle.medium12.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.v8(),
                    Wrap(
                      spacing: 8.w,
                      children: _strokeColors.map((color) {
                        final isSelected = color == _selectedStrokeColor;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedStrokeColor = color;
                            });
                            _recreateController();
                          },
                          child: Container(
                            width: 30.w,
                            height: 30.h,
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: color == Colors.white
                                        ? Colors.black
                                        : Colors.white,
                                    size: 16.w,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    AppSpacing.v12(),
                    Text(
                      'Background Color:',
                      style: AppTextStyle.medium12.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.v8(),
                    Wrap(
                      spacing: 8.w,
                      children: _backgroundColors.map((color) {
                        final isSelected = color == _selectedBackgroundColor;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedBackgroundColor = color;
                            });
                            _recreateController();
                          },
                          child: Container(
                            width: 30.w,
                            height: 30.h,
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: color == Colors.white
                                        ? Colors.black
                                        : Colors.white,
                                    size: 16.w,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              AppSpacing.v16(),

              // Signature Pad Container
              Container(
                height: 220.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(12.r),
                  color: _selectedBackgroundColor,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Signature(
                    controller: _signatureController,
                  ),
                ),
              ),

              AppSpacing.v8(),

              // Instruction text
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
                      'Draw your signature above (Choose colors first)',
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
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        'Clear',
                        style: AppTextStyle.medium14.copyWith(
                          color: AppColors.textPrimary,
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
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyle.medium14.copyWith(
                          color: AppColors.textPrimary,
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
      final Uint8List? signatureBytes = await _signatureController.toPngBytes();

      if (signatureBytes != null) {
        // If we should upload to server and have an appointment ID
        if (widget.uploadToServer && widget.appointmentId != null) {
          final uploadResponse =
              await _signatureService.uploadSignatureToAppointment(
            appointmentId: widget.appointmentId!,
            signatureBytes: signatureBytes,
          );

          if (uploadResponse.isSuccessful) {
            if (mounted) {
              AppToast.showSuccess(context, 'Signature uploaded successfully!');
            }
            widget.onConfirm!(signatureBytes);
          } else {
            if (mounted) {
              AppToast.showError(context,
                  'Failed to upload signature: ${uploadResponse.message}');
            }
          }
        } else {
          // Just return the signature bytes without uploading
          widget.onConfirm!(signatureBytes);
        }
      }
    } catch (e) {
      debugPrint('Error converting signature to image: $e');
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
