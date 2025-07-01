import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../shared/app_colors.dart';

/// Minimal signature pad test to isolate any potential issues
class MinimalSignatureTest extends StatefulWidget {
  const MinimalSignatureTest({super.key});

  @override
  State<MinimalSignatureTest> createState() => _MinimalSignatureTestState();
}

class _MinimalSignatureTestState extends State<MinimalSignatureTest> {
  late SignatureController _signatureController1;
  late SignatureController _signatureController2;
  String _status = 'Ready to draw';

  @override
  void initState() {
    super.initState();
    _signatureController1 = SignatureController(
      penStrokeWidth: 7.5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    _signatureController2 = SignatureController(
      penStrokeWidth: 9.0,
      penColor: Colors.red,
      exportBackgroundColor: Colors.grey[100]!,
    );
  }

  @override
  void dispose() {
    _signatureController1.dispose();
    _signatureController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minimal Signature Test'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Debug Information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DEBUGGING SIGNATURE VISIBILITY:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                      '• If strokes are invisible, this could be a theme/color conflict'),
                  const Text('• Try drawing on both pads below'),
                  const Text('• Check console for debug logs'),
                  const Text(
                      '• Status updates show if touch events are working'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Status: $_status',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Test 1: Simplest possible configuration
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 3),
              ),
              child: Signature(
                controller: _signatureController1,
              ),
            ),

            const SizedBox(height: 20),

            // Test with alternative colors
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 3),
              ),
              child: Signature(
                controller: _signatureController2,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _signatureController1.clear();
                      _signatureController2.clear();
                      setState(() {
                        _status = 'Cleared';
                      });
                    },
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        if (_signatureController1.isEmpty) {
                          setState(() {
                            _status = 'No signature to convert';
                          });
                          return;
                        }

                        final bytes = await _signatureController1.toPngBytes();
                        if (bytes != null) {
                          setState(() {
                            _status = 'Converted! Size: ${bytes.length} bytes';
                          });
                        } else {
                          setState(() {
                            _status = 'Failed to convert';
                          });
                        }
                      } catch (e) {
                        setState(() {
                          _status = 'Error: $e';
                        });
                      }
                    },
                    child: const Text('Test Convert'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
