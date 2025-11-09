import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/enum/post_type.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/custom_app_bar.dart';
import 'package:job_connect/config/widgets/info_chip_width_delete.dart';
import 'package:job_connect/config/widgets/overlay_loading.dart';
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

class SocialCreatePostScreen extends StatefulWidget {
  const SocialCreatePostScreen({super.key});

  @override
  State<SocialCreatePostScreen> createState() => _SocialCreatePostScreenState();
}

class _SocialCreatePostScreenState extends State<SocialCreatePostScreen> {
  final TextEditingController _contextController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();
  late final List<Map<String, dynamic>> kPostOptions;
  bool _isPublic = true; // true = công khai, false = chỉ mình tôi
  bool _isUrgent = false; // bài viết "gấp"
  bool _showHashtagInput = false;
  bool _showVisibilityRow = false;
  final List<String> _selectedImages = [];
  final List<String> _hashtags = [];
  String? _selectedGroupId;
  String? _selectedGroupName;
  late final UserViewModel userVm;
  late final SocialPostViewModel socialPostVm;
  late final SocialGroupsViewModel socialGroupsVm;

  @override
  void initState() {
    super.initState();
    kPostOptions = [
      {
        'icon': Icons.image,
        'label': 'Ảnh/Video',
        'color': Colors.blue,
        'onPressed': _onPickImages,
      },
      {
        'icon': Icons.gif_box,
        'label': 'GIF',
        'color': Colors.lightBlue,
        'onPressed': () {},
      },
      {
        'icon': Icons.group_add,
        'label': 'Nhóm của bạn',
        'color': Colors.redAccent,
        'onPressed': _onSelectGroup,
      },
      {
        'icon': Icons.campaign,
        'label': 'Tin tuyển gấp',
        'color': Colors.orange,
        'onPressed': _onToggleUrgent,
      },
      {
        'icon': Icons.public,
        'label': 'Công khai',
        'color': Colors.purple,
        'onPressed': _onToggleVisibility,
      },
      {
        'icon': Icons.tag,
        'label': 'Hashtag',
        'color': Colors.teal,
        'onPressed': _onShowHashtagInput,
      },
    ];
    userVm = context.read<UserViewModel>();
    socialPostVm = context.read<SocialPostViewModel>();
    socialGroupsVm = context.read<SocialGroupsViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      await socialGroupsVm.getAllGroups();
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

  void _onSelectGroup() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return  Consumer<SocialGroupsViewModel>(
          builder: (context, socialGroupsVm, _) {
            return SelectGroupBottomSheet(
              groups: socialGroupsVm.allGroups,
              onSelect: (selected) {
                setState(() {
                  if (selected == null) {
                    _selectedGroupId = null;
                    _selectedGroupName = null;
                  } else {
                    _selectedGroupId = selected['id'];
                    _selectedGroupName = selected['name'];
                  }
                });
              },
            );
          }
        );
      }
    );
  }

  void _onToggleUrgent() {
    setState(() => _isUrgent = !_isUrgent);
  }

  void _onToggleVisibility() {
    setState(() => _showVisibilityRow = !_showVisibilityRow);
  }

  void _onShowHashtagInput() {
    setState(() => _showHashtagInput = !_showHashtagInput);
  }

  Future<void> _onSubmitPost() async {
    final idUser = userVm.currentUser?.idUser ?? '';
    final content = _contextController.text.trim();

    List<String> uploadedUrls = [];
    try {
      if (_selectedImages.isNotEmpty) {
        uploadedUrls = await socialPostVm.uploadImages(_selectedImages);
      }
    } catch (e) {
      if (mounted) {
        SnackbarApp.show(
          context,
          title: 'Lỗi',
          message: 'Upload ảnh thất bại: $e',
          backgroundColor: Colors.red,
        );
      }
      return;
    }

    final newPost = SocialPostModel(
      idPost: '',
      idUser: idUser,
      idGroup: _selectedGroupId ?? '',
      content: content,
      imageUrls: uploadedUrls,
      videoUrl: '',
      visibility: _isPublic ? 'public' : 'private',
      postType: _isUrgent ? 'urgent' : PostType.post.name,
      hashtags: _hashtags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await socialPostVm.createPost(newPost);

    if (socialPostVm.isSuccess && mounted) {
      context.pop();
      SnackbarApp.show(
        context,
        title: 'Thành công',
        message: 'Bài viết đã đăng thành công',
        backgroundColor: Colors.green,
      );
    } else if (mounted) {
      SnackbarApp.show(
        context,
        title: 'Thất bại',
        message: 'Bài viết đăng thất bại: ${socialPostVm.errorMessage}',
        backgroundColor: Colors.red,
      );
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
          onCollapse: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _onAddHashtag() {
    final hashtagText = _hashtagController.text.trim();
    if (hashtagText.isEmpty) return;

    // Split nhiều hashtag bằng khoảng trắng
    final tags = hashtagText.split(' ').where((e) => e.isNotEmpty);

    setState(() {
      _hashtags.addAll(tags);
      _hashtagController.clear();
      _showHashtagInput = false;
    });
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
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Tạo bài viết",
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
                      backgroundColor: _isUrgent ? Colors.red : theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: _onSubmitPost,
                    child: Text(
                      _isUrgent ? "Đăng gấp" : "Đăng",
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 14.sp
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
                  }
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: TextField(
                    controller: _contextController,
                    maxLines: null,
                    cursorColor: Colors.blue[200],
                    style: TextStyle(fontSize: 16.sp),
                    decoration: const InputDecoration(
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
                if (_selectedImages.isNotEmpty)...[
                  PostImageGrid(
                    imagePaths: _selectedImages,
                  ),
                  SizedBox(height:16.h),
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
                      Text(
                        'Chế độ hiển thị',
                        style: TextStyle( fontSize: 14.sp, fontWeight: FontWeight.w500)),
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
                                style: TextStyle(
                                    fontSize: 14.sp, color: Colors.grey[700]),
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
                  border: const Border( top: BorderSide(color: Colors.grey, width: 0.2)),
                ),
                child: CompactRowIcons(
                  onExpand: _onExpandOptions,
                  icons: kPostOptions.map((e) => {
                    'icon': e['icon'],
                    'color': e['color'],
                    'onPressed': e['onPressed'],
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}