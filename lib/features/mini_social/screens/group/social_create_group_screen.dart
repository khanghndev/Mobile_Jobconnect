import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/enum/image_type.dart';
import 'package:job_connect/config/enum/privacy_type.dart';
import 'package:job_connect/config/utils/input_validators.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/custom_app_bar.dart';
import 'package:job_connect/config/widgets/custom_input_field.dart';
import 'package:job_connect/config/widgets/info_chip_width_delete.dart';
import 'package:job_connect/config/widgets/overlay_loading.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/mini_social/model/social_groups_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_groups_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_post_view_model.dart';
import 'package:job_connect/features/mini_social/widgets/social_post/compact_row_icons.dart';
import 'package:job_connect/features/mini_social/widgets/social_post/expanded_grid_icons.dart';
import 'package:job_connect/features/mini_social/widgets/social_post/hash_tag_card.dart';
import 'package:job_connect/features/mini_social/widgets/social_post/user_info_create_post.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class SocialCreateGroupScreen extends StatefulWidget {
  const SocialCreateGroupScreen({super.key});

  @override
  State<SocialCreateGroupScreen> createState() => _SocialCreateGroupScreenState();
}

class _SocialCreateGroupScreenState extends State<SocialCreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameGroupCon = TextEditingController();
  final TextEditingController _decriptionGroupCon = TextEditingController();
  final TextEditingController _hashtagCon = TextEditingController();
  late final List<Map<String, dynamic>> kPostOptions;
  bool _isPublic = true; // true = công khai, false = chỉ mình tôi
  bool _showHashtagInput = false;
  String? _coverImagePath;
  String? _mainImagePath;
  final List<String> _hashtags = [];
  String? _selectedGroupName;
  late final UserViewModel userVm;
  late final SocialPostViewModel socialPostVm;
  late final SocialGroupsViewModel socialGroupsVm;

  @override
  void initState() {
    super.initState();
    kPostOptions = [
      {
        'icon': Icons.group,
        'label': 'Bạn bè của bạn',
        'color': Colors.redAccent,
        'onPressed': (){},
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
    _nameGroupCon.dispose();
    _decriptionGroupCon.dispose();
    _hashtagCon.dispose();
    super.dispose();
  }

  Future<void> _onPickImages(ImageType type) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          if (type == ImageType.groupAvatar) {
            _mainImagePath = pickedFile.path;
          } else {
            _coverImagePath = pickedFile.path;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        SnackbarApp.show(
          context,
          title: "Lỗi",
          message: "Không thể chọn ảnh: ${e.toString()}",
          backgroundColor: BackgroundColors.backgroundErrorPrimary,
        );
      }
    }
  }

  void _onToggleVisibility() {}

  void _onShowHashtagInput() {
    setState(() => _showHashtagInput = !_showHashtagInput);
  }

  Future<void> _onSubmitGroup() async {
    if (!_formKey.currentState!.validate()) return;
    List<String> urls = [];
    try {
      urls = await socialGroupsVm.uploadMainAndCoverImages(
        mainImagePath: _mainImagePath ?? '',
        coverImagePath: _coverImagePath ?? '',
      );
    } catch (e) {
      if (mounted) {
        SnackbarApp.show(
          context,
          title: 'Lỗi tải ảnh',
          message: 'Không thể tải ảnh lên. Vui lòng thử lại!',
          backgroundColor: Colors.red,
        );
      }
      return;
    }
    final user = userVm.currentUser!;
    final group = SocialGroupsModel(
      idGroup: '',
      groupName: _nameGroupCon.text.trim(),
      description: _decriptionGroupCon.text.trim(),
      creatorName: user.userName,
      createdBy: user.idUser,
      privacy: _isPublic ? PrivacyType.public.name : PrivacyType.private.name,
      coverImageUrl: urls.isNotEmpty ? urls[1] : '',
      avatarUrl: urls.isNotEmpty ? urls[0] : '',
      memberCount: 0,
      postCount: 0,
      tags: _hashtags,
      createdAt: DateTime.now(),
    );
    final createdGroup = await socialGroupsVm.createGroup(group: group);
    if (!mounted) return;
    if (createdGroup != null) {
      context.push(
        '/social/group',
        extra: {
          'idGroup': createdGroup.idGroup,
          'isLoggedIn': true,
          'idUser': user.idUser,
        },
      );
      SnackbarApp.show(
        context,
        title: 'Thành công',
        message: 'Tạo nhóm thành công',
        backgroundColor: Colors.green,
      );
    } else {
      SnackbarApp.show(
        context,
        title: 'Thất bại',
        message: socialGroupsVm.errorMessage ?? 'Tạo nhóm thất bại',
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
          onCollapse: () => context.pop(),
        ),
      ),
    );
  }

  void _onAddHashtag() {
    final hashtagText = _hashtagCon.text.trim();
    if (hashtagText.isEmpty) return;

    final tags = hashtagText.split(' ').where((e) => e.isNotEmpty);

    setState(() {
      _hashtags.addAll(tags);
      _hashtagCon.clear();
      _showHashtagInput = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final socialGroupsVm = context.watch<SocialGroupsViewModel>();

    return OverlayLoading(
      isLoading: socialGroupsVm.isLoading,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppbar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.black, size: 22.sp),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Tạo nhóm của bạn",
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
                    onPressed: _onSubmitGroup,
                    child: Text(
                      "Tạo nhóm",
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
            child: Form(  
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<UserViewModel>(
                    builder: (context, userVm, child) {
                      return UserInfoCreatePost(
                        user: userVm.currentUser,
                        roleName: userVm.roleName ?? '',
                        groupName: _selectedGroupName,
                        isPublic: _isPublic,
                        userRoleName: "Quản trị viên",
                        iconRole: Icons.admin_panel_settings,
                      );
                    }
                  ),
                  SizedBox(height: 16.h),
                  SectionTitle(
                    title: 'Tên nhóm',
                    icon: Icons.group,
                    iconColor: theme.iconTheme.color,
                  ),
                  SizedBox(height: 8.h),
                  CustomInputField(
                    controller: _nameGroupCon,
                    keyboardType: TextInputType.text,
                    hintText: 'Nhập tên nhóm',
                    prefixIcon: Icon(Icons.group, color: Colors.grey, size: 20.sp),
                    fillColor: Colors.grey.shade50,
                    contentPadding: EdgeInsets.all(16.w),
                    validator: (value) => InputValidators.validate(
                      value: value,
                      hintText: 'Tên nhóm',
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SectionTitle(
                    title: 'Ảnh nhóm',
                    icon: Icons.photo,
                    iconColor: theme.iconTheme.color,
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () => _onPickImages(ImageType.groupAvatar),
                    child: Container(
                      width: double.infinity,
                      height: 150.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: Colors.grey[300],
                        image: _mainImagePath != null && _mainImagePath!.isNotEmpty
                            ? DecorationImage(
                                image: FileImage(File(_mainImagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (_mainImagePath == null || _mainImagePath!.isEmpty)
                          ? Center(
                              child: Text(
                                'Chọn ảnh nhóm',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            )
                          : null,
                    ),
                  ),

                  SizedBox(height: 16.h),
                  SectionTitle(
                    title: 'Ảnh bìa nhóm',
                    icon: Icons.picture_in_picture,
                    iconColor: theme.iconTheme.color,
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () => _onPickImages(ImageType.coverImage),
                    child: Container(
                      width: double.infinity,
                      height: 150.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: Colors.grey[300],
                        image: _coverImagePath != null && _coverImagePath!.isNotEmpty
                            ? DecorationImage(
                                image: FileImage(File(_coverImagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (_coverImagePath == null || _coverImagePath!.isEmpty)
                          ? Center(
                              child: Text(
                                'Chọn ảnh bìa',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SectionTitle(
                    title: 'Mô tả',
                    icon: Icons.description,
                    iconColor: theme.iconTheme.color,
                  ),
                  SizedBox(height: 8.h),
                  CustomInputField(
                    controller: _decriptionGroupCon,
                    keyboardType: TextInputType.text,
                    hintText: 'Nhập mô tả nhóm',
                    prefixIcon: Icon(Icons.description, color: Colors.grey, size: 20.sp),
                    fillColor: Colors.grey.shade50,
                    contentPadding: EdgeInsets.all(16.w),
                    maxLines: 3,
                    validator: (value) => InputValidators.validate(
                      value: value,
                      hintText: 'Mô tả nhóm',
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SectionTitle(
                        title: 'Chế độ hiển thị:',
                        icon: _isPublic ? Icons.public : Icons.lock,
                        iconColor: theme.iconTheme.color,
                      ),
                      SectionTitle(
                        title: _isPublic ? 'công khai' : 'riêng tư',
                        fontWeight: FontWeight.normal,
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
                  if (_hashtags.isNotEmpty)...[
                    SectionTitle(
                      title: 'Hashtag',
                      icon: Icons.tag,
                      iconColor: theme.iconTheme.color,
                    ),
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
                  ],
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SizedBox(
          height: _showHashtagInput ? 220.h : 80.h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showHashtagInput)...[
                HashtagCard(
                  controller: _hashtagCon,
                  onClose: () => setState(() => _showHashtagInput = false),
                  onSend: _onAddHashtag,
                ),
              ],
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