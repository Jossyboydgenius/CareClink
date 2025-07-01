import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../shared/app_colors.dart';

/// Simple signature test to isolate color issues
class SimpleSignatureTest extends StatefulWidget {
  const SimpleSignatureTest({super.key});

  @override
  State<SimpleSignatureTest> createState() => _SimpleSignatureTestState();
}

class _SimpleSignatureTestState extends State<SimpleSignatureTest> {
  late SignatureController _signatureController;
  Color _currentStrokeColor = Colors.black;
  String _status = 'Ready to draw';

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 3.0,
      penColor: _currentStrokeColor,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  void _changeColor(Color newColor) {
    setState(() {
      _currentStrokeColor = newColor;
      _status = 'Color changed to ${_colorToString(newColor)}';
    });

    // Recreate controller with new color
    final currentPaths = _signatureController.value;
    _signatureController.dispose();
    _signatureController = SignatureController(
      penStrokeWidth: 3.0,
      penColor: _currentStrokeColor,
      exportBackgroundColor: Colors.white,
      points: currentPaths,
    );
  }

  String _colorToString(Color color) {
    if (color == Colors.black) return 'Black';
    if (color == Colors.red) return 'Red';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.green) return 'Green';
    return 'Color(${color.value.toRadixString(16)})';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Signature Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            // Color Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildColorButton(Colors.black, 'Black'),
                _buildColorButton(Colors.red, 'Red'),
                _buildColorButton(Colors.blue, 'Blue'),
                _buildColorButton(Colors.green, 'Green'),
              ],
            ),

            const SizedBox(height: 16),

            // Signature Pad
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Signature(
                    controller: _signatureController,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _signatureController.clear();
                      setState(() {
                        _status = 'Signature cleared';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save Image'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color, String name) {
    final isSelected = color == _currentStrokeColor;
    return GestureDetector(
      onTap: () => _changeColor(color),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 24)
            : null,
      ),
    );
  }

  Future<void> _saveImage() async {
    try {
      if (_signatureController.isEmpty) {
        setState(() {
          _status = 'No signature to save';
        });
        return;
      }

      final image = await _signatureController.toPngBytes();
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${directory.path}/simple_signature_$timestamp.png';

        final file = File(filePath);
        await file.writeAsBytes(image);

        setState(() {
          _status = 'Image saved: ${image.length} bytes';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Signature saved to: $filePath'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _status = 'Failed to generate image';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error saving: $e';
      });
    }
  }
}
