import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';

/// Alternative signature pad implementation to test different approaches
class AlternativeSignatureDialog extends StatefulWidget {
  final String title;
  final VoidCallback? onCancel;
  final Function(Uint8List signatureBytes)? onConfirm;

  const AlternativeSignatureDialog({
    super.key,
    required this.title,
    this.onCancel,
    this.onConfirm,
  });

  @override
  State<AlternativeSignatureDialog> createState() =>
      _AlternativeSignatureDialogState();
}

class _AlternativeSignatureDialogState
    extends State<AlternativeSignatureDialog> {
  late SignatureController _signatureController;
  bool _hasSignature = false;
  bool _isLoading = false;

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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Alternative 1: Minimal wrapping approach
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Material(
                color: Colors.white,
                child: Signature(
                  controller: _signatureController,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Simple instruction
            const Text(
              'Draw your signature above',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      _signatureController.clear();
                      setState(() {
                        _hasSignature = false;
                      });
                    },
                    child: const Text('Clear'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _hasSignature && !_isLoading ? _confirmSignature : null,
                    child: _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignature() async {
    if (!_hasSignature || widget.onConfirm == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final Uint8List? signatureBytes = await _signatureController.toPngBytes();

      if (signatureBytes != null) {
        widget.onConfirm!(signatureBytes);
      }
    } catch (e) {
      print('Error converting signature to image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
