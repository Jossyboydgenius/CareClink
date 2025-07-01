import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../app/locator.dart';
import 'api/api.dart';
import 'api/api_response.dart';

class SignatureService {
  final Api _api = locator<Api>();

  /// Upload signature to appointment
  ///
  /// Example usage:
  /// ```dart
  /// // In your widget where you want to show signature dialog for clock in/out:
  /// showDialog(
  ///   context: context,
  ///   barrierDismissible: false,
  ///   builder: (context) => EnhancedSignaturePadDialog(
  ///     title: 'Clock In Signature',
  ///     subtitle: 'Please sign to confirm your clock in',
  ///     actionButtonText: 'Submit Signature',
  ///     appointmentId: appointment.id, // Pass the appointment ID
  ///     uploadToServer: true, // Enable automatic server upload
  ///     onCancel: () => Navigator.of(context).pop(),
  ///     onConfirm: (signatureBytes) {
  ///       Navigator.of(context).pop();
  ///       // Signature has been uploaded to server automatically
  ///       // You can handle success here
  ///     },
  ///   ),
  /// );
  /// ```
  Future<ApiResponse> uploadSignatureToAppointment({
    required String appointmentId,
    required Uint8List signatureBytes,
  }) async {
    try {
      // First, upload the signature image to a file hosting service
      final signatureUrl = await _uploadSignatureImage(signatureBytes);

      if (signatureUrl == null) {
        return ApiResponse(
          isSuccessful: false,
          message: 'Failed to upload signature image',
        );
      }

      // Then send the signature URL to the appointment endpoint
      final response = await _api.patchData(
        '/user-appointment/$appointmentId/signature',
        {
          'signature': signatureUrl,
        },
        hasHeader: true,
      );

      if (response.isSuccessful) {
        debugPrint('Signature uploaded successfully: ${response.data}');
      } else {
        debugPrint('Signature upload failed: ${response.message}');
      }

      return response;
    } catch (e) {
      debugPrint('Error uploading signature: $e');
      return ApiResponse(
        isSuccessful: false,
        message: 'Failed to upload signature: $e',
      );
    }
  }

  /// Upload signature image to file hosting service and return URL
  Future<String?> _uploadSignatureImage(Uint8List signatureBytes) async {
    try {
      // For now, we'll use a temporary image hosting service
      // In production, you would typically use your own server or a service like AWS S3, Cloudinary, etc.

      // Example using imgur API (you'll need to register for an API key)
      // const imgurClientId = 'YOUR_IMGUR_CLIENT_ID';

      // For demonstration purposes, let's save locally and return a placeholder URL
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'signature_$timestamp.png';

      final filePath =
          await saveSignatureAsImage(signatureBytes, fileName: fileName);

      if (filePath != null) {
        // In a real implementation, you would upload this file to your server
        // and return the actual URL. For now, return a placeholder.

        // TODO: Implement actual file upload to your server
        // Example: return await _uploadToServer(filePath);

        // Placeholder URL for testing - replace with actual implementation
        return 'https://static.vecteezy.com/system/resources/previews/023/264/100/original/fake-hand-drawn-autographs-set-handwritten-signature-scribble-for-business-certificate-or-letter-isolated-illustration-vector.jpg';
      }

      return null;
    } catch (e) {
      debugPrint('Error uploading signature image: $e');
      return null;
    }
  }

  /// Upload file to server (implement this based on your backend)
  Future<String?> _uploadToServer(String filePath) async {
    try {
      // TODO: Implement multipart file upload to your server
      // This is where you would upload the actual image file to your backend
      // and return the URL where it's hosted

      /*
      Example implementation:
      
      final file = File(filePath);
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${_api.baseUrl}/upload/signature'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('signature', filePath),
      );
      
      request.headers.addAll(_api._headers);
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return data['url']; // Assuming the server returns the file URL
      }
      */

      return null;
    } catch (e) {
      debugPrint('Error uploading to server: $e');
      return null;
    }
  }

  /// Save signature as image to local storage and return the file path
  static Future<String?> saveSignatureAsImage(
    Uint8List signatureBytes, {
    String? fileName,
  }) async {
    try {
      // Get the app's document directory
      final directory = await getApplicationDocumentsDirectory();

      // Create signatures subdirectory if it doesn't exist
      final signaturesDir = Directory('${directory.path}/signatures');
      if (!await signaturesDir.exists()) {
        await signaturesDir.create(recursive: true);
      }

      // Generate filename if not provided
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final finalFileName = fileName ?? 'signature_$timestamp.png';

      // Create the file
      final file = File('${signaturesDir.path}/$finalFileName');

      // Write the bytes to the file
      await file.writeAsBytes(signatureBytes);

      debugPrint('Signature saved to: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('Error saving signature: $e');
      return null;
    }
  }

  /// Delete signature file
  static Future<bool> deleteSignature(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Signature deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting signature: $e');
      return false;
    }
  }

  /// Check if signature file exists
  static Future<bool> signatureExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking signature file: $e');
      return false;
    }
  }

  /// Get signature bytes from file path
  static Future<Uint8List?> getSignatureBytes(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('Error reading signature file: $e');
      return null;
    }
  }

  /// Clean up old signature files (older than specified days)
  static Future<void> cleanupOldSignatures({int daysOld = 30}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final signaturesDir = Directory('${directory.path}/signatures');

      if (!await signaturesDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      await for (final entity in signaturesDir.list()) {
        if (entity is File) {
          final stats = await entity.stat();
          if (stats.modified.isBefore(cutoffDate)) {
            await entity.delete();
            debugPrint('Cleaned up old signature: ${entity.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up signatures: $e');
    }
  }
}
