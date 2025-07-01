import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../../shared/app_colors.dart';
import 'simple_signature_test.dart';

/// Enhanced signature test with color selection to diagnose visibility issues
class EnhancedSignatureTest extends StatefulWidget {
  const EnhancedSignatureTest({super.key});

  @override
  State<EnhancedSignatureTest> createState() => _EnhancedSignatureTestState();
}

class _EnhancedSignatureTestState extends State<EnhancedSignatureTest> {
  late SignatureController _controller;
  String _status = 'Ready to draw';
  Color _selectedStrokeColor = Colors.black;
  Color _selectedBackgroundColor = Colors.white;
  double _strokeWidth = 3.0;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = SignatureController(
      penStrokeWidth: _strokeWidth,
      penColor: _selectedStrokeColor,
      exportBackgroundColor: _selectedBackgroundColor,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper method to recreate the signature controller when properties change
  void _recreateSignatureController() {
    _controller.dispose();
    _initializeController();
    setState(() {
      _status = 'Controller updated with new settings';
    });
  }

  // Available colors for testing
  final List<Color> _strokeColors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.pink,
    const Color(0xFF333333), // Dark grey
    const Color(0xFF006400), // Dark green
  ];

  final List<Color> _backgroundColors = [
    Colors.white,
    Colors.grey[100]!,
    Colors.grey[200]!,
    Colors.grey[300]!,
    Colors.blue[50]!,
    Colors.green[50]!,
    Colors.yellow[50]!,
    const Color(0xFFF5F5F5), // Light grey
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Signature Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                'Status: $_status',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            // Color Selection Controls
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stroke Color Selection:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _strokeColors.map((color) {
                      final isSelected = color == _selectedStrokeColor;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedStrokeColor = color;
                            _status =
                                'Stroke color changed to ${_getColorName(color)}';
                          });
                          _recreateSignatureController();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey,
                              width: isSelected ? 3 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Background Color Selection:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _backgroundColors.map((color) {
                      final isSelected = color == _selectedBackgroundColor;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedBackgroundColor = color;
                            _status =
                                'Background color changed to ${_getColorName(color)}';
                          });
                          _recreateSignatureController();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey,
                              width: isSelected ? 3 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: isSelected
                              ? Icon(Icons.check,
                                  color: color == Colors.white
                                      ? Colors.black
                                      : Colors.white,
                                  size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Stroke Width Slider
                  Text(
                    'Stroke Width: ${_strokeWidth.toStringAsFixed(1)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _strokeWidth,
                    min: 1.0,
                    max: 10.0,
                    divisions: 18,
                    onChanged: (value) {
                      setState(() {
                        _strokeWidth = value;
                        _status = 'Stroke width: ${value.toStringAsFixed(1)}';
                      });
                      _recreateSignatureController();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Signature Pad
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Signature(
                  controller: _controller,
                  width: double.infinity,
                  height: 300,
                  backgroundColor: _selectedBackgroundColor,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey[400]!, Colors.grey[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          _controller.clear();
                          setState(() {
                            _status = 'Signature cleared';
                          });
                        },
                        child: const Center(
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple[400]!, Colors.purple[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SimpleSignatureTest(),
                            ),
                          );
                        },
                        child: const Center(
                          child: Text(
                            'Simple Test',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[400]!, Colors.blue[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _convertToImage,
                        child: const Center(
                          child: Text(
                            'Test Convert',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[400]!, Colors.green[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _saveSignatureAsImage,
                        child: const Center(
                          child: Text(
                            'Save Image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[50]!, Colors.orange[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.orange[700], size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Testing Instructions:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionItem('1',
                      'Try different stroke colors (should work properly now!)'),
                  _buildInstructionItem(
                      '2', 'Try different background colors for contrast'),
                  _buildInstructionItem(
                      '3', 'Adjust stroke width for better visibility'),
                  _buildInstructionItem('4',
                      'Draw on the signature pad - colors should change immediately'),
                  _buildInstructionItem(
                      '5', 'Save as image to verify stroke capture'),
                  _buildInstructionItem(
                      '6', 'Controller recreates when settings change'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      border: Border.all(color: Colors.amber),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '💡 Now using the "signature" package which should properly handle stroke colors and provide better performance!',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.amber[800],
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

  String _getColorName(Color color) {
    if (color == Colors.black) return 'Black';
    if (color == Colors.white) return 'White';
    if (color == Colors.red) return 'Red';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.green) return 'Green';
    if (color == Colors.orange) return 'Orange';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.brown) return 'Brown';
    if (color == Colors.pink) return 'Pink';
    if (color == Colors.grey[100]) return 'Light Grey';
    if (color == Colors.grey[200]) return 'Medium Grey';
    if (color == Colors.grey[300]) return 'Dark Grey';
    return 'Custom Color';
  }

  Future<void> _convertToImage() async {
    try {
      if (_controller.isNotEmpty) {
        final Uint8List? bytes = await _controller.toPngBytes();
        if (bytes != null) {
          setState(() {
            _status = 'Signature converted! Size: ${bytes.length} bytes';
          });

          // Show success dialog
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Success!'),
                content: Text(
                    'Signature captured successfully!\nSize: ${bytes.length} bytes'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else {
          setState(() {
            _status = 'Failed to convert signature to image';
          });
        }
      } else {
        setState(() {
          _status = 'No signature to convert - please draw something first';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _saveSignatureAsImage() async {
    try {
      if (_controller.isNotEmpty) {
        final Uint8List? bytes = await _controller.toPngBytes();
        if (bytes != null) {
          // Get the Downloads directory
          final directory = await getApplicationDocumentsDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'signature_test_$timestamp.png';
          final filePath = '${directory.path}/$fileName';

          final file = File(filePath);
          await file.writeAsBytes(bytes);

          setState(() {
            _status = 'Image saved to: $filePath\nSize: ${bytes.length} bytes';
          });

          // Show success dialog with file path
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Image Saved!'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Signature saved successfully!'),
                    const SizedBox(height: 8),
                    Text('File: $fileName'),
                    const SizedBox(height: 8),
                    Text('Size: ${bytes.length} bytes'),
                    const SizedBox(height: 8),
                    Text('Path: $filePath',
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Signature package should now properly show stroke colors! Check the saved image to verify.',
                        style: TextStyle(
                            fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else {
          setState(() {
            _status = 'Failed to convert signature to image';
          });
        }
      } else {
        setState(() {
          _status = 'No signature to save - please draw something first';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error saving image: $e';
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to save image: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.orange[600],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
