import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PostItemContent extends StatelessWidget {
  final SocialPostModel socialPostModel;
  final VoidCallback? onOpenDetail;

  const PostItemContent({
    super.key,
    required this.socialPostModel,
    this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final images = (socialPostModel.imageUrl is List)
      ? List<String>.from(socialPostModel.imageUrl as Iterable)
          .where((e) => e.isNotEmpty)
          .toList()
      : (socialPostModel.imageUrl != null && socialPostModel.imageUrl!.isNotEmpty)
          ? [socialPostModel.imageUrl!]
          : <String>[];

    final videoUrl = socialPostModel.videoUrl;

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onOpenDetail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nội dung HTML
          Html(
            data: socialPostModel.content ?? '',
            style: {
              "body": Style(
                fontSize: FontSize(14),
                lineHeight: LineHeight.number(1.5),
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                color: Colors.black87,
              ),
            },
          ),

          const SizedBox(height: 8),

          // Hiển thị hình ảnh (nhiều hình)
          if (images.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: images.length > 3 ? 3 : images.length,
                itemBuilder: (context, index) {
                  final imageUrl = images[index];
                  final isLast = index == 2 && images.length > 3;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            backgroundColor: Colors.black,
                            body: Stack(
                              children: [
                                PhotoViewGallery.builder(
                                  itemCount: images.length,
                                  builder: (context, i) {
                                    return PhotoViewGalleryPageOptions(
                                      imageProvider: ImageUtils.getImageProvider(images[i]),
                                      minScale: PhotoViewComputedScale.contained,
                                      maxScale: PhotoViewComputedScale.covered * 2,
                                    );
                                  },
                                  scrollPhysics:
                                      const BouncingScrollPhysics(),
                                  backgroundDecoration:
                                      const BoxDecoration(color: Colors.black),
                                ),
                                Positioned(
                                  top: 40,
                                  left: 20,
                                  child: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                        if (isLast)
                          Container(
                            color: Colors.black45,
                            child: Center(
                              child: Text(
                                '+${images.length - 2}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Hiển thị video (nếu có)
          if (videoUrl != null && videoUrl.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 64,
                  ),
                  // TODO: Nếu có thumbnail video, thêm Image.network(videoThumbnailUrl)
                ],
              ),
            ),
        ],
      ),
    );
  }
}