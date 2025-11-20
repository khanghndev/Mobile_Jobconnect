import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/enum/post_type.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/custom_app_bar.dart';
import 'package:job_connect/config/widgets/info_chip_width_delete.dart';
import 'package:job_connect/config/widgets/overlay_loading.dart';
import 'package:job_connect/config/widgets/reusable_bottom_sheet.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_groups_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_post_view_model.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_image_grid.dart';
import 'package:job_connect/features/mini_social/widgets/social_post/compact_row_icons.dart';
import 'package:job_connect/features/mini_social/widgets/social_post/expanded_grid_icons.dart';
import 'package:job_connect/features/mini_social/widgets/social_post/hash_tag_card.dart';
import 'package:job_connect/features/mini_social/widgets/social_post/select_group_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/widgets/social_post/user_info_create_post.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class SocialEditPostScreen extends StatefulWidget {
  final SocialPostModel socialPostModel;
  const SocialEditPostScreen({
    super.key,
    required this.socialPostModel,
  });

  @override
  State<SocialEditPostScreen> createState() => _SocialEditPostScreenState();
}

class _SocialEditPostScreenState extends State<SocialEditPostScreen> {
  final TextEditingController _contextController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();

  late final List<Map<String, dynamic>> kPostOptions;
  late List<FilterOption> postTypeOptions;

  bool _isPublic = true;
  bool _showHashtagInput = false;
  bool _showVisibilityRow = false;
  final List<String> _selectedImages = [];
  final List<String> _hashtags = [];
  String? _selectedGroupId;
  String? _selectedGroupName;
  String? _selectedPostType;
  late final UserViewModel userVm;
  late final SocialPostViewModel socialPostVm;
  late final SocialGroupsViewModel socialGroupsVm;

  @override
  void initState() {
    super.initState();
    userVm = context.read<UserViewModel>();
    socialPostVm = context.read<SocialPostViewModel>();
    socialGroupsVm = context.read<SocialGroupsViewModel>();

    _selectedPostType = widget.socialPostModel.postType ?? PostType.post.name;
    _contextController.text = widget.socialPostModel.content;
    if (widget.socialPostModel.imageUrls != null) {
      _selectedImages.addAll(widget.socialPostModel.imageUrls!);
    }
    if (widget.socialPostModel.hashtags != null) {
      _hashtags.addAll(widget.socialPostModel.hashtags!);
    }
    _isPublic = widget.socialPostModel.visibility == 'public';
    _selectedGroupId = (widget.socialPostModel.idGroup?.isNotEmpty ?? false)
        ? widget.socialPostModel.idGroup
        : null;

    postTypeOptions = [
      FilterOption(
        icon: Icons.edit_note,
        title: "Bài viết",
        value: PostType.post.name,
        iconColor: Colors.blue,
        onTapItem: () {
          setState(() {
            _selectedPostType = PostType.post.name;
          });
        },
      ),
      FilterOption(
        icon: Icons.question_answer,
        title: "Hỏi đáp",
        value: PostType.qa.name,
        iconColor: Colors.orange,
        onTapItem: () {
          setState(() {
            _selectedPostType = PostType.qa.name;
          });
        },
      ),
      FilterOption(
        icon: Icons.work,
        title: "Tuyển dụng",
        value: PostType.job.name,
        iconColor: Colors.green,
        onTapItem: () {
          setState(() {
            _selectedPostType = PostType.job.name;
          });
        },
      ),
      FilterOption(
        icon: Icons.task_alt,
        title: "Việc ngắn hạn",
        value: PostType.microjob.name,
        iconColor: Colors.purple,
        onTapItem: () {
          setState(() {
            _selectedPostType = PostType.microjob.name;
          });
        },
      ),
    ];

    kPostOptions = [
      {
        'icon': Icons.image,
        'label': 'Ảnh/Video',
        'color': Colors.blue,
        'onPressed': _onPickImages,
      },
      {
        'icon': Icons.group_add,
        'label': 'Nhóm của bạn',
        'color': Colors.grey,
        'onPressed': (){},
      },
      {
        'icon': Icons.campaign,
        'label': 'Loại bài đăng',
        'color': Colors.orange,
        'onPressed': () => _onOpenSheetPostType(context),
      },
      {
        'icon': Icons.public,
        'label': 'Công khai',
        'color': Colors.pink,
        'onPressed': _onToggleVisibility,
      },
      {
        'icon': Icons.tag,
        'label': 'Hashtag',
        'color': Colors.green,
        'onPressed': _onShowHashtagInput,
      },
      {
        'icon': Icons.post_add_sharp,
        'label': 'Loại bài đăng',
        'color': Colors.yellow,
        'onPressed': () => _onOpenSheetPostType(context),
      },
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await socialGroupsVm.getAllGroups();
      if (_selectedGroupId != null) {
        final g = socialGroupsVm.allGroups.firstWhere(
          (e) => e.idGroup == _selectedGroupId,
        );
        setState(() => _selectedGroupName = g.groupName);
      }
    });
  }

  @override
  void dispose() {
    _contextController.dispose();
    _hashtagController.dispose();
    super.dispose();
  }

  double get _bottomBarHeight {
    double height = 68.h;
    if (_showVisibilityRow) height += 72.h;
    if (_showHashtagInput) height += 156.h;
    if (_hashtags.isNotEmpty) height += 74.h;
    return height;
  }

  String _getPostTypeName(String postType) {
    if (postType == PostType.post.name) {
      return "bài viết";
    } else if (postType == PostType.qa.name) {
      return "bài hỏi đáp";
    } else if (postType == PostType.job.name) {
      return "bài tuyển dụng";
    } else if (postType == PostType.microjob.name) {
      return "việc ngắn";
    } else {
      return "bài viết";
    }
  }

  Future<void> _onPickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultiImage(
        imageQuality: 80,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles.map((xfile) => xfile.path));
        });
      }
    } catch (e) {
      if (mounted) {
        SnackbarApp.show(
          context,
          title: "Lỗi",
          message: "Lỗi tải ảnh ${e.toString()}",
          backgroundColor: BackgroundColors.backgroundErrorPrimary,
        );
      }
    }
  }

  void _onOpenSheetPostType(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => ReusableBottomSheet(
        headerIcon: Icons.filter_list,
        options: postTypeOptions,
        selectedValue: _selectedPostType ?? PostType.job.name,
        showRadio: true,
        onSelected: (value) {
          setState(() {
            _selectedPostType = value;
          });
        },
      ),
    );
  }

  void _onToggleVisibility() {
    setState(() => _showVisibilityRow = !_showVisibilityRow);
  }

  void _onShowHashtagInput() {
    setState(() => _showHashtagInput = !_showHashtagInput);
  }

  Future<void> _onSubmitSavePost() async {
    final content = _contextController.text.trim();

    try {
      final currentImages = List<String>.from(_selectedImages);
      final oldImages = widget.socialPostModel.imageUrls ?? [];

      // Ảnh bị xóa 
      final removedImages = oldImages.where((url) => !currentImages.contains(url)).toList();

      // Ảnh mới cần upload (
      final newImages = currentImages.where((p) {
        final isLocalFile = p.startsWith('/') || p.startsWith('file:');
        final isNewUrl = !oldImages.contains(p);
        return isLocalFile || isNewUrl;
      }).toList();

      // Upload ảnh mới lên Appwrite 
      List<String> uploadedUrls = [];
      if (newImages.isNotEmpty) {
        uploadedUrls = await socialPostVm.uploadImages(newImages);
      }

      // Gộp danh sách ảnh cuối cùng: ảnh cũ còn giữ + ảnh mới upload
      final finalImageUrls = [
        ...currentImages.where((p) => oldImages.contains(p)),
        ...uploadedUrls,
      ];

      //Tạo post mới đã chỉnh sửa
      final updatedPost = widget.socialPostModel.copyWith(
        content: content,
        imageUrls: finalImageUrls,
        visibility: _isPublic ? 'public' : 'private',
        postType: _selectedPostType ?? widget.socialPostModel.postType,
        hashtags: _hashtags.isNotEmpty ? _hashtags : widget.socialPostModel.hashtags,
        updatedAt: DateTime.now(),
      );

      // Cập nhật bài viết trong CSDL
      await socialPostVm.updatePost(updatedPost);

      //Nếu thành công thì xóa ảnh cũ bị gỡ khỏi Appwrite
      if (socialPostVm.isSuccess) {
        if (removedImages.isNotEmpty) {
          try {
            await socialPostVm.deleteImagesByUrls(removedImages);
          } catch (e) {
            if (mounted) {
              SnackbarApp.show(
                context,
                title: 'Lỗi',
                message: 'Xóa ảnh cũ thất bại: $e',
                backgroundColor: BackgroundColors.backgroundErrorPrimary,
              );
            }
          }
        }

        if (mounted) {
          context.pop();
          SnackbarApp.show(
            context,
            title: 'Thành công',
            message: 'Cập nhật bài viết thành công',
            backgroundColor: Colors.green,
          );
        }
      } else if (mounted) {
        SnackbarApp.show(
          context,
          title: 'Thất bại',
          message: 'Cập nhật bài viết thất bại: ${socialPostVm.errorMessage}',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarApp.show(
          context,
          title: 'Lỗi',
          message: 'Quá trình cập nhật thất bại: $e',
          backgroundColor: BackgroundColors.backgroundErrorPrimary,
        );
      }
    }
  }

  void _onExpandOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ExpandedGridIcons(
          options: kPostOptions,
          onCollapse: () => context.pop(),
        ),
      ),
    );
  }

  void _onAddHashtag() {
    final hashtagText = _hashtagController.text.trim();
    if (hashtagText.isEmpty) return;

    final tags = hashtagText.split(' ').where((e) => e.isNotEmpty);

    setState(() {
      _hashtags.addAll(tags);
      _hashtagController.clear();
      _showHashtagInput = false;
    });
  }

  void _onClosePost() {
    // giá trị gốc từ model
    final originalContent = widget.socialPostModel.content;
    final originalImages = widget.socialPostModel.imageUrls ?? <String>[];
    final originalHashtags = widget.socialPostModel.hashtags ?? <String>[];
    final originalVisibility = widget.socialPostModel.visibility;
    final originalPostType = widget.socialPostModel.postType ?? PostType.post.name;
    final originalGroupId = widget.socialPostModel.idGroup ?? '';

    // giá trị hiện tại trên UI
    final currentContent = _contextController.text.trim();
    final currentImages = List<String>.from(_selectedImages);
    final currentHashtags = List<String>.from(_hashtags);
    final currentVisibility = _isPublic ? 'public' : 'private';
    final currentPostType = _selectedPostType ?? PostType.post.name;
    final currentGroupId = _selectedGroupId ?? '';

    bool listEquals(List a, List b) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }

    int changes = 0;
    if (currentContent != originalContent) changes++;
    if (!listEquals(currentImages, originalImages)) changes++;
    if (!listEquals(currentHashtags, originalHashtags)) changes++;
    if (currentVisibility != originalVisibility) changes++;
    if (currentPostType != originalPostType) changes++;
    if (currentGroupId != originalGroupId) changes++;

    if (changes == 0) {
      context.pop();
      return;
    }

    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Thoát",
      message: "Bạn muốn thoát khi chưa lưu?",
      icon: Icons.exit_to_app,
      backgroundColor: BackgroundColors.backgroundInfoPrimary,
      onConfirm: () async {
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final socialPostViewModel = context.watch<SocialPostViewModel>();

    return OverlayLoading(
      isLoading: socialPostViewModel.isLoading,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppbar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.black, size: 22.sp),
            onPressed: _onClosePost,
          ),
          title: Text(
            "Chỉnh sửa bài viết",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 17.sp),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Consumer2<SocialPostViewModel, UserViewModel>(
                builder: (context, postVm, userVm, child) {
                  return TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: Size(40.w, 30.h),
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: _onSubmitSavePost,
                    child: Text(
                      "Lưu ${_getPostTypeName(_selectedPostType ?? PostType.post.name)}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
        body: UnfocusWidget(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              children: [
                Consumer<UserViewModel>(
                  builder: (context, userVm, child) {
                    return UserInfoCreatePost(
                      user: userVm.currentUser,
                      roleName: userVm.roleName ?? '',
                      groupName: _selectedGroupName,
                      isPublic: _isPublic,
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: TextField(
                    controller: _contextController,
                    maxLines: null,
                    cursorColor: Colors.blue[200],
                    style: TextStyle(fontSize: 16.sp),
                    decoration: InputDecoration(
                      hintText: "Bạn muốn nói về điều gì?",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_selectedImages.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () {
                      DialogUtils.showImageViewer(
                        context,
                        _selectedImages,
                        0,
                        canDelete: true,
                        onDelete: (index) {
                          setState(() {
                            _selectedImages.removeAt(index);
                          });
                        },
                      );
                    },
                    child: PostImageGrid(
                      imagePaths: _selectedImages,
                      onRemoveImage: (path) {
                        setState(() {
                          _selectedImages.remove(path);
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ],
            ),
          ),
        ),
        bottomNavigationBar: SizedBox(
          height: _bottomBarHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_hashtags.isNotEmpty)
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _hashtags.map((tag) {
                    return InfoChipWidthDelete(
                      tag: tag,
                      onDeleted: () {
                        setState(() {
                          _hashtags.remove(tag);
                        });
                      },
                    );
                  }).toList(),
                ),
              if (_showHashtagInput)
                HashtagCard(
                  controller: _hashtagController,
                  onClose: () => setState(() => _showHashtagInput = false),
                  onSend: _onAddHashtag,
                ),
              if (_showVisibilityRow)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Chế độ hiển thị', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isPublic ? Icons.public : Icons.lock,
                                size: 16.sp,
                                color: Colors.grey[700],
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _isPublic ? 'Công khai' : 'Chỉ mình tôi',
                                style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          SizedBox(width: 12.w),
                          Switch(
                            value: _isPublic,
                            activeColor: Colors.blue,
                            onChanged: (val) {
                              setState(() => _isPublic = val);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: const Border(top: BorderSide(color: Colors.grey, width: 0.2)),
                ),
                child: CompactRowIcons(
                  onExpand: _onExpandOptions,
                  icons: kPostOptions
                      .map((e) => {
                            'icon': e['icon'],
                            'color': e['color'],
                            'onPressed': e['onPressed'],
                          })
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}