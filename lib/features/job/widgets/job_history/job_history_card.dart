import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/config/utils/status_helper.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';

class JobHistoryCard extends StatelessWidget {
  final JobApplicationModel jobApp;
  final VoidCallback? onViewDetail;
  final VoidCallback? onCancel; 
  final bool? isShowAction;

  const JobHistoryCard({
    super.key,
    required this.jobApp,
    this.onViewDetail,
    this.onCancel,
    this.isShowAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.only(top: 16.h),
      elevation: 4.0,
      shadowColor: theme.shadowColor.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: InkWell(
        onTap: onViewDetail,
        borderRadius: BorderRadius.circular(16.r),
        splashColor: theme.primaryColor.withValues(alpha: 0.1),
        highlightColor: theme.primaryColor.withValues(alpha: 0.05),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompanyLogo(theme),
                  SizedBox(width: 14.w),
                  Expanded(child: _buildTitleAndCompany(theme)),
                  SizedBox(width: 8.w),
                ],
              ),
              SizedBox(height: 16.h),
              // Info
              _buildInfoRow(
                theme,
                icon: Icons.location_on_outlined,
                text: jobApp.jobPosting!.location.isEmpty ? 'Chưa có địa chỉ' : jobApp.jobPosting!.location,
                iconColor: theme.colorScheme.tertiary,
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              _buildInfoRow(
                theme,
                icon: Icons.paid_outlined,
                text: FormatUtils.formatSalary(jobApp.jobPosting!.salary ?? 0),
                iconColor: theme.colorScheme.tertiary,
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              _buildInfoRow(
                theme,
                icon: Icons.calendar_today_rounded,
                text: 'Nộp ngày: ${FormatUtils.formattedDateTime(jobApp.submittedAt)}',
                iconSize: 14.sp,
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              // Footer
              if(isShowAction == true) ... [
                // Divider
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Divider(
                    height: 1,
                    color: theme.dividerColor.withValues(alpha: 0.4),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusChip(theme),
                    _buildActionButtons(theme),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // Header Helpers
  Widget _buildCompanyLogo(ThemeData theme) {
    final String? logoUrl = jobApp.jobPosting!.company!.logoCompany;
    final String placeholder = jobApp.jobPosting!.company!.companyName.isNotEmpty
        ? jobApp.jobPosting!.company!.companyName[0].toUpperCase()
        : 'C';

    final Widget logoWidget = (logoUrl != null && logoUrl.isNotEmpty)
        ? Image.network(
            logoUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                Center(child: Text(placeholder, style: theme.textTheme.headlineSmall?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold))),
          )
        : Center(child: Text(placeholder, style: theme.textTheme.headlineSmall?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold)));

    return Container(
      width: 58.w,
      height: 58.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.4),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3), width: 0.8),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(11.r), child: logoWidget),
    );
  }

  Widget _buildTitleAndCompany(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          jobApp.jobPosting!.title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, height: 1.25),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 5.h),
        Text(
          jobApp.jobPosting!.company!.companyName,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.85), fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    final Color bgColor = AppStatus.getBgColor(jobApp.applicationStatus);
    final Color textColor = AppStatus.getTextColor(jobApp.applicationStatus);
    final IconData icon = AppStatus.getIcon(jobApp.applicationStatus);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 1.0),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: textColor.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.sp, color: textColor),
          SizedBox(width: 6.w),
          Text(
            AppStatus.getDisplayText(jobApp.applicationStatus),
            style: theme.textTheme.labelSmall?.copyWith(color: textColor, fontWeight: FontWeight.bold, letterSpacing: 0.2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Info Helper
  Widget _buildInfoRow(ThemeData theme, {required IconData icon, required String text, Color? iconColor, TextStyle? textStyle, double iconSize = 16}) {
    return Row(
      children: [
        Icon(icon, size: iconSize.sp, color: iconColor ?? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: textStyle ?? theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant, 
              fontWeight: FontWeight.w500
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  // Footer Helpers
  Widget _buildActionButtons(ThemeData theme) {
    final buttonStyle = OutlinedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
      side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.9), width: 1.5),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: onViewDetail,
          style: buttonStyle.copyWith(foregroundColor: WidgetStateProperty.all(theme.primaryColor)),
          icon: Icon(Icons.visibility_rounded, size: 18.sp, color: theme.primaryColor),
          label: const Text('Xem'),
        ),
        if (jobApp.applicationStatus == AppStatus.pending && onCancel != null) ...[
          SizedBox(width: 10.w),
          OutlinedButton.icon(
            onPressed: onCancel,
            style: buttonStyle.copyWith(
              side: WidgetStateProperty.all(BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.9), width: 1.5)),
              foregroundColor: WidgetStateProperty.all(theme.colorScheme.error),
            ),
            icon: Icon(Icons.cancel_rounded, size: 18.sp, color: theme.colorScheme.error),
            label: const Text('Hủy'),
          ),
        ],
      ],
    );
  }
}
