import 'package:flutter/material.dart';

/// Lấy extension của file
String getFileExtension(String fileName) {
  if (!fileName.contains(".")) return "";
  return fileName.split(".").last.toLowerCase();
}

/// Kiểm tra PDF
bool isPdf(String fileName) {
  final ext = getFileExtension(fileName);
  return ext == "pdf";
}

/// Kiểm tra DOC / DOCX
bool isDoc(String fileName) {
  final ext = getFileExtension(fileName);
  return ext == "doc" || ext == "docx";
}

/// Kiểm tra hình ảnh (jpg, jpeg, png, webp)
bool isImage(String fileName) {
  final ext = getFileExtension(fileName);
  return ["jpg", "jpeg", "png", "webp"].contains(ext);
}

/// Icon theo đuôi file
IconData getFileIcon(String fileName) {
  if (isPdf(fileName)) return Icons.picture_as_pdf_rounded;
  if (isDoc(fileName)) return Icons.description_rounded;
  if (isImage(fileName)) return Icons.image_rounded;
  return Icons.insert_drive_file_rounded;
}

/// Màu nền icon theo đuôi file
Color getFileBgColor(String fileName, BuildContext context) {
  final theme = Theme.of(context);

  if (isPdf(fileName)) {
    return theme.colorScheme.errorContainer.withValues( alpha: 0.7);
  }

  if (isDoc(fileName)) {
    return theme.colorScheme.primaryContainer.withValues( alpha: 0.7);
  }

  if (isImage(fileName)) {
    return theme.colorScheme.tertiaryContainer.withValues( alpha: 0.7);
  }

  return theme.colorScheme.surfaceVariant.withValues( alpha: 0.6);
}

/// Màu icon theo đuôi file
Color getFileIconColor(String fileName, BuildContext context) {
  final theme = Theme.of(context);

  if (isPdf(fileName)) {
    return theme.colorScheme.onErrorContainer;
  }

  if (isDoc(fileName)) {
    return theme.colorScheme.onPrimaryContainer;
  }

  if (isImage(fileName)) {
    return theme.colorScheme.onTertiaryContainer;
  }

  return theme.colorScheme.onSurfaceVariant;
}
