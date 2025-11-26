import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service để extract text từ file PDF
/// Sử dụng backend API để extract text (vì Flutter không có package tốt để extract PDF text)
class PdfTextExtractorService {
  /// Extract text từ file PDF bằng cách gửi lên backend
  /// Trả về text content hoặc null nếu có lỗi
  Future<String?> extractTextFromPdf(File pdfFile) async {
    try {
      // TODO: Tạo API endpoint để extract text từ PDF
      // Tạm thời sử dụng cách đơn giản: đọc file và parse thủ công
      
      // Đọc file PDF
      final bytes = await pdfFile.readAsBytes();
      
      // Convert bytes sang string để tìm text (cách đơn giản)
      // Lưu ý: Cách này không hoàn hảo, tốt nhất là có API endpoint
      final text = utf8.decode(bytes, allowMalformed: true);
      
      // Extract text từ PDF bytes (cách đơn giản)
      // Tìm các đoạn text có thể đọc được
      final regex = RegExp(r'[a-zA-ZÀ-ỹ0-9\s\.\,\;\:\!\?\(\)\[\]\{\}\-\+\=\*\/\@\#\$\%\&\*]+');
      final matches = regex.allMatches(text);
      
      final extractedText = matches
          .map((m) => m.group(0))
          .where((s) => s != null && s.length > 3)
          .join(' ')
          .trim();
      
      if (extractedText.isEmpty || extractedText.length < 50) {
        // Nếu không extract được, thử cách khác
        // Tạm thời trả về thông báo cần API endpoint
        throw Exception(
          'Không thể đọc được text từ PDF. '
          'Vui lòng đảm bảo file PDF có thể copy text hoặc liên hệ admin để cấu hình API extract PDF.',
        );
      }
      
      return extractedText;
    } catch (e) {
      throw Exception('Lỗi khi đọc PDF: ${e.toString()}');
    }
  }

  /// Extract text từ file PDF với progress callback
  Future<String?> extractTextFromPdfWithProgress(
    File pdfFile,
    void Function(double progress) onProgress,
  ) async {
    onProgress(0.0);
    final result = await extractTextFromPdf(pdfFile);
    onProgress(1.0);
    return result;
  }

  /// Extract text từ PDF URL (sử dụng backend API nếu có)
  Future<String?> extractTextFromPdfUrl(String pdfUrl) async {
    try {
      // Download PDF từ URL
      final response = await http.get(Uri.parse(pdfUrl));
      
      if (response.statusCode != 200) {
        throw Exception('Không thể tải file PDF từ URL');
      }

      // Lưu tạm file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/cv_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await tempFile.writeAsBytes(response.bodyBytes);

      try {
        return await extractTextFromPdf(tempFile);
      } finally {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    } catch (e) {
      throw Exception('Lỗi khi đọc PDF từ URL: ${e.toString()}');
    }
  }
}

