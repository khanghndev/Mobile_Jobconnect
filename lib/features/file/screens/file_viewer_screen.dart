import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_filex/open_filex.dart';
// import 'package:dio/dio.dart'; // Nếu bạn dùng Dio

class FileViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String fileName; // Ví dụ: "mydocument.pdf" hoặc "report.docx"

  const FileViewerScreen({
    Key? key,
    required this.fileUrl,
    required this.fileName,
  }) : super(key: key);

  @override
  _FileViewerScreenState createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  bool _isLoading = true;
  String? _localFilePath;
  String? _error;
  String _downloadProgress = "0%";

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
        _downloadProgress = "0%";
      });
    }

    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${widget.fileName}';

      print('Downloading (Dio) from: ${widget.fileUrl}');
      print('Saving (Dio) to: $filePath');

      final dio = Dio();
      await dio.download(
        widget.fileUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            if (mounted) {
              setState(() {
                _downloadProgress =
                    "${(received / total * 100).toStringAsFixed(0)}%";
              });
            }
          }
        },
      );

      final downloadedFile = File(filePath); // filePath là đường dẫn đã lưu
      if (await downloadedFile.exists()) {
        final fileSize = await downloadedFile.length();
        print('File downloaded. Path: $filePath, Size: $fileSize bytes');

        if (fileSize == 0) {
          // XỬ LÝ FILE TRỐNG Ở ĐÂY
          if (mounted) {
            setState(() {
              _error =
                  'Tệp "${widget.fileName}" nhận được từ máy chủ không có nội dung (0 bytes). Không thể hiển thị.';
              _isLoading = false;
              _localFilePath =
                  null; // Quan trọng: không gán đường dẫn để PDFView không cố đọc
            });
          }
          return; // Ngừng thực thi thêm, không cố gắng hiển thị
        }
      } else {
        // Xử lý trường hợp file không tồn tại sau khi tải (lỗi khác)
        if (mounted) {
          setState(() {
            _error = 'Không tìm thấy file sau khi tải xong.';
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _localFilePath = filePath;
          _isLoading = false;
        });
      }
    } on DioException catch (dioError) {
      // Hoặc DioError tùy phiên bản
      print('DioError loading file: ${dioError.message}');
      if (mounted) {
        setState(() {
          _error = 'Lỗi mạng khi tải file: ${dioError.message}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading file with Dio: $e');
      if (mounted) {
        setState(() {
          _error = 'Không thể tải file: $e';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildContentView() {
    if (_localFilePath == null) {
      return Center(child: Text('Không có đường dẫn file cục bộ.'));
    }

    final fileExtension = widget.fileName.split('.').last.toLowerCase();

    if (fileExtension == 'pdf') {
      return PDFView(
        filePath: _localFilePath!,
        onError: (error) {
          setState(() {
            _error = error.toString();
          });
        },
        onPageError: (page, error) {
          setState(() {
            _error = 'Lỗi trang $page: ${error.toString()}';
          });
        },
      );
    } else if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
      return Image.file(
        File(_localFilePath!),
        fit: BoxFit.contain,
      ); // Từ file cục bộ
    } else if ([
      'docx',
      'doc',
      'xlsx',
      'xls',
      'pptx',
      'ppt',
      'txt',
    ].contains(fileExtension)) {
      // Mở bằng ứng dụng bên ngoài
      // `open_filex` sẽ tự động mở khi file sẵn sàng, nên ta chỉ cần thông báo
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final result = await OpenFilex.open(_localFilePath!);
        print("Open file result: ${result.message}");
        if (result.type != ResultType.done) {
          setState(() {
            _error = "Không thể mở file: ${result.message}";
          });
        }
      });
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file, size: 50),
            SizedBox(height: 10),
            Text('Đã tải xong: ${widget.fileName}'),
            SizedBox(height: 10),
            Text('Đang thử mở bằng ứng dụng mặc định...'),
            if (_error != null &&
                _error!.contains("No APP found to open this file type"))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Lỗi: Không tìm thấy ứng dụng nào để mở loại file này. Vui lòng cài đặt ứng dụng phù hợp (ví dụ: Microsoft Office, Google Docs, WPS Office...).",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    } else {
      return Center(
        child: Text(
          'Định dạng file .$fileExtension không được hỗ trợ hiển thị trực tiếp. Đã tải về: $_localFilePath',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          if (!_isLoading &&
              _localFilePath != null &&
              !widget.fileName.endsWith('.pdf') &&
              ![
                'jpg',
                'jpeg',
                'png',
                'gif',
              ].contains(widget.fileName.split('.').last.toLowerCase()))
            IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: () async {
                if (_localFilePath != null) {
                  final result = await OpenFilex.open(_localFilePath!);
                  if (result.type != ResultType.done) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Không thể mở file: ${result.message}"),
                      ),
                    );
                  }
                }
              },
              tooltip: 'Mở bằng ứng dụng khác',
            ),
        ],
      ),
      body: Center(
        child:
            _isLoading
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Đang tải file... $_downloadProgress'),
                  ],
                )
                : _error !=
                    null // << SẼ HIỂN THỊ THÔNG BÁO LỖI Ở ĐÂY
                ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    // Có thể dùng Column để thêm Icon
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'Lỗi: $_error', // Ví dụ: "Lỗi: Tệp "abc.pdf" nhận được từ máy chủ không có nội dung (0 bytes). Không thể hiển thị."
                        style: TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                : _localFilePath ==
                    null // THÊM KIỂM TRA NÀY
                ? Center(
                  child: Text('Không thể tải hoặc không có file để hiển thị.'),
                ) // Trường hợp _error null nhưng _localFilePath cũng null
                : _buildContentView(), // Chỉ gọi _buildContentView nếu _localFilePath có giá trị và không có lỗi
      ),
    );
  }
}
