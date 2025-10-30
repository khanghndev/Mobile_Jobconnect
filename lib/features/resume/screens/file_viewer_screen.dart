import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_buttom_leading_icon.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class FileViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String fileName;

  const FileViewerScreen({
    Key? key,
    required this.fileUrl,
    required this.fileName,
  }) : super(key: key);

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  bool _isLoading = true;
  String? _localFilePath;
  String? _error;
  String _downloadProgress = "0%";

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  Future<void> _downloadFile() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _downloadProgress = "0%";
    });

    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${widget.fileName}';

      final dio = Dio();
      await dio.download(
        widget.fileUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress =
                  "${(received / total * 100).toStringAsFixed(0)}%";
            });
          }
        },
      );

      final file = File(filePath);
      if (!await file.exists() || await file.length() == 0) {
        setState(() {
          _error = 'File trống hoặc không tồn tại.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _localFilePath = filePath;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Không thể tải file: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildContentView(ThemeData theme) {
    if (_localFilePath == null) {
      return Center(
        child: Text(
          'Không có file để hiển thị.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final ext = widget.fileName.split('.').last.toLowerCase();

    if (ext == 'pdf') {
      return PDFView(
        filePath: _localFilePath!,
        onError: (err) => setState(() => _error = err.toString()),
        onPageError: (page, err) =>
            setState(() => _error = 'Lỗi trang $page: $err'),
      );
    } else if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
      return InteractiveViewer(
        child: Image.file(File(_localFilePath!), fit: BoxFit.contain),
      );
    } else if (ext == 'txt') {
      return FutureBuilder<String>(
        future: File(_localFilePath!).readAsString(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi đọc file: ${snapshot.error}'));
          }
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Text(
              snapshot.data ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
            ),
          );
        },
      );
    } else {
      // Office hoặc file không hỗ trợ hiển thị
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file, size: 60.w, color: theme.primaryColor),
            SizedBox(height: 12.h),
            Text(
              'Đã tải xong: ${widget.fileName}',
              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            CustomButtomLeadingIcon(
              width: 300.w,
              onPressed: () => OpenFilex.open(_localFilePath!),
              text: "Mở bằng ứng dụng khác",
              backgroundColor: theme.primaryColor,
              textColor: Colors.white,
              icon: Icons.open_in_new,
              iconColor: Colors.white,
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppbarTitleLarge(title: widget.fileName),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Center(
          child: _isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: const CircularProgressIndicator(),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Đang tải file... $_downloadProgress',
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                    ),
                  ],
                )
              : _error != null
                  ? Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        'Lỗi: $_error',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 15.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _buildContentView(theme),
        ),
      ),
    );
  }
}
