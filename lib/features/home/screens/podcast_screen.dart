import 'package:flutter/material.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/data/models/podcast_model.dart';
import 'package:job_connect/data/services/api.dart';
import 'package:job_connect/config/utils/format.dart';

class PodcastScreen extends StatefulWidget {
  const PodcastScreen({Key? key}) : super(key: key);

  @override
  PodcastScreenState createState() => PodcastScreenState();
}

class PodcastScreenState extends State<PodcastScreen> {
  // Danh sách lưu trữ tất cả các podcast lấy từ API
  final List<Podcast> _allPodcasts = [];
  // Danh sách podcast đã được lọc dựa trên từ khóa tìm kiếm
  List<Podcast> _filteredPodcasts = [];
  // Từ khóa tìm kiếm hiện tại
  String _searchQuery = '';
  // Trạng thái tải dữ liệu
  bool _isLoading = true;
  // Thông báo lỗi (nếu có)
  String? _errorMessage;

  // Khởi tạo service để gọi API
  final _apiService = ApiService(baseUrl: ApiConstants.baseUrl);

  @override
  void initState() {
    super.initState();
    // Gọi hàm fetchPodcasts khi widget được khởi tạo
    _fetchPodcasts();
  }

  /// Hàm loại bỏ dấu tiếng Việt khỏi một chuỗi.
  /// Ví dụ: "Xin chào" -> "Xin chao"
  String _removeDiacritics(String str) {
    const diacriticMap = {
      'À': 'A',
      'Á': 'A',
      'Â': 'A',
      'Ã': 'A',
      'È': 'E',
      'É': 'E',
      'Ê': 'E',
      'Ì': 'I',
      'Í': 'I',
      'Ò': 'O',
      'Ó': 'O',
      'Ô': 'O',
      'Õ': 'O',
      'Ù': 'U',
      'Ú': 'U',
      'Ă': 'A',
      'Đ': 'D',
      'Ĩ': 'I',
      'Ũ': 'U',
      'Ơ': 'O',
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ã': 'a',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ì': 'i',
      'í': 'i',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ù': 'u',
      'ú': 'u',
      'ă': 'a',
      'đ': 'd',
      'ĩ': 'i',
      'ũ': 'u',
      'ơ': 'o',
      'Ư': 'U',
      'Ạ': 'A',
      'Ả': 'A',
      'Ấ': 'A',
      'Ầ': 'A',
      'Ẩ': 'A',
      'Ẫ': 'A',
      'Ậ': 'A',
      'Ắ': 'A',
      'Ằ': 'A',
      'Ẳ': 'A',
      'Ẵ': 'A',
      'Ặ': 'A',
      'Ẹ': 'E',
      'Ẻ': 'E',
      'Ẽ': 'E',
      'Ề': 'E',
      'Ể': 'E',
      'ạ': 'a',
      'ả': 'a',
      'ấ': 'a',
      'ầ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ậ': 'a',
      'ắ': 'a',
      'ằ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'ặ': 'a',
      'ẹ': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ề': 'e',
      'ể': 'e',
      'ố': 'o',
      'ồ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ộ': 'o',
      'ớ': 'o',
      'ờ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ợ': 'o',
      'ư': 'u',
      'ứ': 'u',
      'ừ': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ự': 'u',
      'ý': 'y',
      'ỳ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'ỵ': 'y',
      'Ý': 'Y',
      'Ỳ': 'Y',
      'Ỷ': 'Y',
      'Ỹ': 'Y',
      'Ỵ': 'Y',
    };
    return str.split('').map((c) => diacriticMap[c] ?? c).join();
  }

  /// Hàm tìm kiếm podcast dựa trên từ khóa.
  /// [query]: Từ khóa người dùng nhập vào.
  void _searchPodcasts(String query) {
    // Chuẩn hóa từ khóa: loại bỏ dấu và chuyển thành chữ thường
    final normalizedQuery = _removeDiacritics(query).toLowerCase();

    setState(() {
      _searchQuery = query;
      if (normalizedQuery.isEmpty) {
        // Nếu từ khóa rỗng, hiển thị tất cả podcast
        _filteredPodcasts = List.from(_allPodcasts);
      } else {
        // Lọc danh sách podcast dựa trên tiêu đề
        _filteredPodcasts =
            _allPodcasts
                .where(
                  (podcast) => _removeDiacritics(
                    podcast.title,
                  ).toLowerCase().contains(normalizedQuery),
                )
                .toList();
      }
    });
  }

  /// Hàm lấy danh sách podcast từ API.
  Future<void> _fetchPodcasts() async {
    setState(() {
      _isLoading = true; // Bắt đầu tải
      _errorMessage = null; // Reset thông báo lỗi
    });
    try {
      final response = await _apiService.get(ApiConstants.podcastEndpoint);
      setState(() {
        _allPodcasts.clear();
        _allPodcasts.addAll(
          (response as List<dynamic>)
              .map<Podcast>(
                (data) => Podcast.fromJson(data as Map<String, dynamic>),
              )
              .toList(),
        );
        // Ban đầu, danh sách lọc giống danh sách đầy đủ
        _filteredPodcasts = List.from(_allPodcasts);
        _isLoading = false; // Tải xong
      });
    } catch (e) {
      // Xử lý lỗi khi không lấy được dữ liệu
      print('Lỗi khi tải podcasts: $e');
      setState(() {
        _isLoading = false; // Tải xong (thất bại)
        _errorMessage = 'Không thể tải danh sách podcast. Vui lòng thử lại.';
      });
    }
  }

  /// Widget xây dựng thanh tìm kiếm.
  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: _searchPodcasts,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm podcast...',
          hintStyle: TextStyle(color: theme.hintColor),
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // Không viền mặc định
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.dividerColor, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  /// Widget xây dựng card hiển thị thông tin một podcast.
  /// [podcast]: Đối tượng Podcast chứa thông tin cần hiển thị.
  Widget _buildPodcastCard(BuildContext context, Podcast podcast) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Định dạng ngày phát hành
    // Giả sử publishDate là DateTime, nếu là String, cần parse trước
    // Ví dụ: final date = DateTime.tryParse(podcast.publishDateString);
    // if (date != null) { ... }

    return Card(
      // Sử dụng Card để có hiệu ứng đổ bóng và bo góc chuẩn
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh đại diện hoặc icon cho podcast
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                // Sử dụng màu từ theme
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              ),
              child: Center(
                child: Icon(
                  Icons.podcasts_rounded, // Icon khác một chút cho đẹp
                  color: theme.colorScheme.primary,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Phần thông tin chi tiết của podcast
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FormatUtils.formattedDateTime(
                      podcast.createdAt,
                    ), // Ngày đã định dạng
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    podcast.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Người dẫn: ${podcast.host ?? 'Không rõ'}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thời lượng: ${FormatUtils.formatDuration(podcast.duration)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      // Icon Play/Pause (ví dụ)
                      Icon(
                        Icons.play_circle_fill_rounded,
                        color: theme.colorScheme.secondary, // Sử dụng màu phụ
                        size: 36,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Icon yêu thích (ví dụ)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(
                  // Giả sử có trạng thái isFavorite trong model Podcast
                  // podcast.isFavorite ? Icons.favorite : Icons.favorite_border,
                  Icons.favorite_border, // Tạm thời để border
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  // Xử lý sự kiện yêu thích
                  print('Yêu thích: ${podcast.title}');
                },
                tooltip: 'Yêu thích',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Xác định danh sách podcast sẽ hiển thị (toàn bộ hoặc đã lọc)
    final displayedPodcasts =
        _searchQuery.isEmpty && _allPodcasts.isNotEmpty
            ? _allPodcasts
            : _filteredPodcasts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Podcast'),
        actions: [
          // Nút refresh để tải lại dữ liệu
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                _isLoading ? null : _fetchPodcasts, // Vô hiệu hóa khi đang tải
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          _buildSearchBar(context),
          // Phần hiển thị danh sách podcast hoặc thông báo
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(),
                    ) // Hiển thị khi đang tải
                    : _errorMessage != null
                    ? Center(
                      // Hiển thị khi có lỗi
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    )
                    : displayedPodcasts.isEmpty
                    ? Center(
                      // Hiển thị khi không có podcast nào
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'Không có podcast nào.'
                            : 'Không tìm thấy podcast phù hợp.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )
                    : RefreshIndicator(
                      // Cho phép kéo để làm mới
                      onRefresh: _fetchPodcasts,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: displayedPodcasts.length,
                        itemBuilder: (context, index) {
                          final podcast = displayedPodcasts[index];
                          return _buildPodcastCard(context, podcast);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
