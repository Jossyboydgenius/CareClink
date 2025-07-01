import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/signature_pad_dialog.dart';
import '../widgets/alternative_signature_dialog.dart';
import '../widgets/enhanced_signature_pad_dialog.dart';
import 'minimal_signature_test.dart';
import 'enhanced_signature_test.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';

/// Demo page to test the signature pad functionality
/// You can navigate to this page to test signature visibility
class SignaturePadTestView extends StatefulWidget {
  const SignaturePadTestView({super.key});

  @override
  State<SignaturePadTestView> createState() => _SignaturePadTestViewState();
}

class _SignaturePadTestViewState extends State<SignaturePadTestView> {
  String _lastSignatureInfo = 'No signature captured yet';

  void _showSignatureDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SignaturePadDialog(
        title: 'Test Signature Pad',
        subtitle: 'This is a test to verify signature visibility',
        actionButtonText: 'Save Test Signature',
        onCancel: () {
          Navigator.of(context).pop();
          setState(() {
            _lastSignatureInfo = 'Signature cancelled';
          });
        },
        onConfirm: (signatureBytes) {
          Navigator.of(context).pop();
          setState(() {
            _lastSignatureInfo =
                'Signature captured! Size: ${signatureBytes.length} bytes';
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Signature captured successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Signature Pad Test',
          style: AppTextStyle.semibold18.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test Information
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.grey300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Signature Pad Test',
                    style: AppTextStyle.semibold16.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  AppSpacing.v8(),
                  Text(
                    'This test page helps verify:\n'
                    '• Signature stroke visibility (should be black)\n'
                    '• Text visibility in dialog\n'
                    '• Button text readability\n'
                    '• Overall contrast and usability',
                    style: AppTextStyle.regular14.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.v24(),

            // Status Display
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.grey300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Status:',
                    style: AppTextStyle.medium14.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  AppSpacing.v8(),
                  Text(
                    _lastSignatureInfo,
                    style: AppTextStyle.regular14.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.v32(),

            // Test Button
            ElevatedButton.icon(
              onPressed: _showSignatureDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: Icon(Icons.edit, size: 20.w),
              label: Text(
                'Test Signature Pad',
                style: AppTextStyle.medium16.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),

            AppSpacing.v16(),

            // Enhanced Dialog Test Button
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => EnhancedSignaturePadDialog(
                    title: 'Enhanced Dialog Test',
                    subtitle: 'Test with color selection options',
                    actionButtonText: 'Save Enhanced Signature',
                    onCancel: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _lastSignatureInfo = 'Enhanced dialog cancelled';
                      });
                    },
                    onConfirm: (signatureBytes) {
                      Navigator.of(context).pop();
                      setState(() {
                        _lastSignatureInfo =
                            'Enhanced signature captured! Size: ${signatureBytes.length} bytes';
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enhanced signature test successful!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: Icon(Icons.color_lens, size: 20.w),
              label: Text(
                'Enhanced Dialog Test',
                style: AppTextStyle.medium16.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),

            AppSpacing.v16(),

            // Minimal Test Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MinimalSignatureTest(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: Icon(Icons.science, size: 20.w),
              label: Text(
                'Minimal Signature Test',
                style: AppTextStyle.medium16.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),

            AppSpacing.v16(),

            // Enhanced Color Test Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EnhancedSignatureTest(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: Icon(Icons.palette, size: 20.w),
              label: Text(
                'Enhanced Color Test',
                style: AppTextStyle.medium16.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),

            AppSpacing.v16(),

            // Alternative Dialog Test Button
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlternativeSignatureDialog(
                    title: 'Alternative Test',
                    onCancel: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _lastSignatureInfo = 'Alternative test cancelled';
                      });
                    },
                    onConfirm: (signatureBytes) {
                      Navigator.of(context).pop();
                      setState(() {
                        _lastSignatureInfo =
                            'Alternative signature captured! Size: ${signatureBytes.length} bytes';
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Alternative signature test successful!'),
                          backgroundColor: Colors.purple,
                        ),
                      );
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: Icon(Icons.alternate_email, size: 20.w),
              label: Text(
                'Alternative Dialog Test',
                style: AppTextStyle.medium16.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),

            AppSpacing.v16(),

            // Instructions
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.orange100,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.orange200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.orange,
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Tap the button above to test the signature pad. Check if you can see your signature strokes clearly.',
                      style: AppTextStyle.regular12.copyWith(
                        color: AppColors.orange300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
