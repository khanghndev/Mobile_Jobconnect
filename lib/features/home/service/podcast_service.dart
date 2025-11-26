import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/home/model/podcast_model.dart';

class PodcastService {
  final ApiService _apiService;

  PodcastService() : _apiService = ApiService();

  ///   Hàm nội bộ xử lý gọi API và bắt lỗi chung
  Future<List<PodcastModel>> _fetchPodcastList({
    required String endpoint,
    required String dataType,
  }) async {
    try {
      final res = await _apiService.get(endpoint: endpoint);
      if (res is! List) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API ($dataType): không phải là danh sách JSON',
          type: ServerExceptionType.api,
        );
      }

      final podcasts = res
          .map((item) => PodcastModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return podcasts;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi không xác định khi tải $dataType: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  ///   Lấy danh sách podcast
  Future<List<PodcastModel>> getPodcasts() async {
    return _fetchPodcastList(
      endpoint: ApiConstants.podcastEndpoint,
      dataType: 'podcast',
    );
  }
 
}