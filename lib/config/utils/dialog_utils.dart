import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/enum/dialog_type.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/custom_dialog.dart';
import 'package:job_connect/features/auth/viewmodel/auth_view_model.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';


class DialogUtils {
  static Future<void> showDialogMessage(
    BuildContext context, {
    required String message,
    String title = "Thông báo",
    DialogType type = DialogType.info,
    String buttonText = "OK",
  }) async {
    IconData icon;
    Color iconColor;

    switch (type) {
      case DialogType.success:
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case DialogType.error:
        icon = Icons.error;
        iconColor = Colors.red;
        break;
      case DialogType.warning:
        icon = Icons.warning;
        iconColor = Colors.orange;
        break;
      default:
        icon = Icons.info;
        iconColor = Colors.blue;
        break;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // bấm ra ngoài không tắt
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(
                buttonText,
                style: TextStyle(color: iconColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Hiển thị dialog xác nhận logout
  static void showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = context.read<AuthViewModel>();

    CustomDialog.show(
      context,
      title: "Đăng xuất?",
      message: "Bạn có chắc chắn muốn đăng xuất không?",
      icon: Icons.logout,
      iconColor: theme.colorScheme.error,
      confirmButtonColor: theme.colorScheme.error,
      backgroundColor: BackgroundColors.backgroundErrorPrimary,
      onConfirm: () async {
        await authViewModel.logout();
        if (!context.mounted) return;
        if (authViewModel.isSuccess) {
          context.go(
            '/auth/login', 
            extra: {
              'role': UserRole.candidate.name
            }
          );
        } else if (authViewModel.errorMessage != null) {
          SnackbarApp.show(
            context,
            title: 'Thông báo',
            message: 'Đăng xuất thất bại: ${authViewModel.errorMessage!}',
            backgroundColor: BackgroundColors.backgroundErrorPrimary,
          );
        }
      },
    );
  }

  /// Hàm tiện ích chung để hiển thị dialog xác nhận với callback tùy ý
  static void showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    IconData? icon,
    Color? iconColor,
    Color? confirmButtonColor,
    Color? backgroundColor,
    required Future<void> Function() onConfirm,
  }) {
    CustomDialog.show(
      context,
      title: title,
      message: message,
      icon: icon ?? Icons.info,
      iconColor: iconColor ?? getColor(context, icon ?? Icons.info),
      confirmButtonColor: confirmButtonColor ?? getColor(context, icon ?? Icons.info),
      backgroundColor: backgroundColor ?? getColor(context, icon ?? Icons.info),
      onConfirm: () async {
        await onConfirm();
      },
    );
  }

  static void showImageViewer(
    BuildContext context,
    List<String> images,
    int initialIndex, {
    bool canDelete = false,
    void Function(int index)? onDelete,
  }) {
    final List<String> localImages = List<String>.from(images);
    final PageController pageController = PageController(initialPage: initialIndex);
    int currentIndex = initialIndex;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          if (currentIndex >= localImages.length && localImages.isNotEmpty) {
            currentIndex = localImages.length - 1;
            pageController.jumpToPage(currentIndex);
          }
          return Dialog(
            backgroundColor: Colors.black,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                PhotoViewGallery.builder(
                  itemCount: localImages.length,
                  pageController: pageController,
                  onPageChanged: (idx) => setState(() => currentIndex = idx),
                  builder: (context, index) => PhotoViewGalleryPageOptions(
                    imageProvider: ImageUtils.getImageProvider(localImages[index]),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                  ),
                  loadingBuilder: (context, event) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

                Positioned(
                  top: 40.h,
                  right: 20.w,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 28.sp),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                if (canDelete)
                  Positioned(
                    top: 52.h,
                    left: 20.w,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30.r),
                        onTap: () {
                          try {
                            if (onDelete != null) onDelete(currentIndex);
                          } catch (_) {}
                          if (localImages.isNotEmpty) {
                            setState(() {
                              localImages.removeAt(currentIndex);
                              if (localImages.isEmpty) {
                                context.pop();
                                return;
                              }
                              if (currentIndex >= localImages.length) {
                                currentIndex = localImages.length - 1;
                              }
                              pageController.jumpToPage(currentIndex);
                            });
                          }
                        },
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Color getColor(BuildContext context, IconData icon) {
  if (icon == Icons.error || icon == Icons.delete 
    || icon == Icons.cancel || icon == Icons.close 
    || icon == Icons.clear || icon == Icons.cancel_outlined 
    || icon == Icons.clear_outlined || icon == Icons.close_outlined 
    || icon == Icons.delete_forever_rounded) {
    return BackgroundColors.backgroundErrorPrimary;
  } else if (icon == Icons.warning || icon == Icons.warning_amber_rounded) {
    return BackgroundColors.backgroundWarningPrimary;
  } else if (icon == Icons.check_circle || icon == Icons.done) {
    return BackgroundColors.backgroundSuccessPrimary;
  } else if (icon == Icons.info || icon == Icons.help_outline) {
    return BackgroundColors.backgroundInfoPrimary;
  } else {
    return Theme.of(context).colorScheme.primary;
  }
}

//DialogUtils.showLogoutDialog(context);

// DialogUtils.showConfirmationDialog(
//   context: context,
//   title: "Xóa dữ liệu?",
//   message: "Bạn có chắc chắn muốn xóa không?",
//   icon: Icons.delete,
//   iconColor: Colors.red,
//   confirmButtonColor: Colors.red,
//   onConfirm: () async {
//     await dataViewModel.deleteAll();
//     SnackbarApp.show(
//       context,
//       title: "Thông báo",
//       message: "Đã xóa dữ liệu",
//       backgroundColor: Colors.green,
//     );
//   },
// );
