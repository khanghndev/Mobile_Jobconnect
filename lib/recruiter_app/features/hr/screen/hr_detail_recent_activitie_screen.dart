import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class HrDetailRecentActivitieScreen extends StatelessWidget {
  final String title;
  final String time;
  final String description;
  final IconData icon;
  final Color color;
  final List<String>? details; // list các dòng chi tiết (ví dụ: ["Người thực hiện: A", "Vị trí: B"])
  final List<Attachment>? attachments; // file / link đính kèm

  const HrDetailRecentActivitieScreen({
    super.key,
    required this.title,
    required this.time,
    required this.description,
    required this.icon,
    required this.color,
    this.details,
    this.attachments,
  });

  Future<void> _copyText(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã sao chép vào clipboard')),
      );
    }
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link không hợp lệ')),
        );
      }
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không mở được link')),
        );
      }
    }
  }

  Future<void> _share(BuildContext context, String text) async {
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onSurface),
        title: Text('Chi tiết hoạt động', style: tt.titleMedium?.copyWith(color: cs.onSurface, fontSize: 17.sp)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            color: cs.onSurface,
            onPressed: () => _share(context, '$title\n$time\n\n$description'),
          ),
        ],
      ),
      backgroundColor: cs.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: icon + title + time + actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha:0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(icon, size: 28.sp, color: color),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14.sp, color: cs.onSurfaceVariant),
                            SizedBox(width: 6.w),
                            Text(time, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Quick actions
                  IconButton(
                    icon: Icon(Icons.copy, size: 20.sp, color: cs.onSurface),
                    onPressed: () => _copyText(context, '$title\n$time\n\n$description'),
                    tooltip: 'Sao chép nội dung',
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // Description card
              Text(
                    description.isNotEmpty ? description : 'Không có mô tả cho hoạt động này.',
                    style: tt.bodyMedium?.copyWith(height: 1.5, color: cs.onSurface),
                  ),
              SizedBox(height: 16.h),

              // Details / timeline
              if (details != null && details!.isNotEmpty) ...[
                Text('Chi tiết', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: 8.h),
                Column(
                  children: details!
                      .map((d) => Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 6.h),
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(d, style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
                                )
                              ],
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: 12.h),
              ],

              // Attachments
              if (attachments != null && attachments!.isNotEmpty) ...[
                Text('Đính kèm', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: 8.h),
                Column(
                  children: attachments!
                      .map((att) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 46.w,
                              height: 46.w,
                              decoration: BoxDecoration(
                                color: cs.surfaceVariant,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Icon(att.icon ?? Icons.attach_file, color: cs.onSurface, size: 20.sp),
                              ),
                            ),
                            title: Text(att.title, style: tt.bodyLarge?.copyWith(color: cs.onSurface)),
                            subtitle: att.subtitle != null ? Text(att.subtitle!, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)) : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (att.url != null)
                                  IconButton(
                                    icon: Icon(Icons.open_in_new, size: 20.sp, color: cs.primary),
                                    onPressed: () => _openUrl(context, att.url!),
                                    tooltip: 'Mở',
                                  ),
                                IconButton(
                                  icon: Icon(Icons.share, size: 20.sp, color: cs.onSurface),
                                  onPressed: () => _share(context, '${att.title} - ${att.url ?? ''}'),
                                  tooltip: 'Chia sẻ',
                                ),
                              ],
                            ),
                            onTap: att.url != null ? () => _openUrl(context, att.url!) : null,
                          ))
                      .toList(),
                ),
                SizedBox(height: 12.h),
              ],

              // Example timeline / notes
              Text('Ghi chú', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              Text(
                'Không có ghi chú thêm.',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),

              SizedBox(height: 24.h),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copyText(context, '$title\n$time\n\n$description'),
                      icon: Icon(Icons.copy, size: 18.sp, color: cs.primary),
                      label: Text('Sao chép', style: tt.bodyMedium?.copyWith(color: cs.primary)),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: cs.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _share(context, '$title\n$time\n\n$description'),
                      icon: Icon(Icons.send, size: 18.sp),
                      label: Text('Chia sẻ', style: tt.bodyMedium?.copyWith(color: cs.onPrimary)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

/// Attachment helper model
class Attachment {
  final String title;
  final String? subtitle;
  final String? url;
  final IconData? icon;

  Attachment({
    required this.title,
    this.subtitle,
    this.url,
    this.icon,
  });
}