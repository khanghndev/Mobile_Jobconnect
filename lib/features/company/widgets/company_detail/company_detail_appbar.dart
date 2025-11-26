import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';
import 'package:job_connect/config/widgets/custom_adaptive_tap_effect.dart';
import 'package:job_connect/features/company/widgets/company_detail/company_logo_header.dart';

class CompanyDetailAppbar extends StatelessWidget {
  final String companyName;
  final String industry;
  final String? logoCompany;
  final String jobName;
  final VoidCallback onShare;
  final bool isCompany;

  const CompanyDetailAppbar({
    super.key,
    required this.onShare, 
    required this.companyName, 
    required this.industry, 
    this.logoCompany, 
    required this.jobName,
    required this.isCompany,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 280.h, 
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 2.0,
      systemOverlayStyle: SystemUiOverlayStyle.light, 

      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
          StretchMode.fadeTitle,
        ],
        background: CompanyLogoHeader(
          companyName: companyName,
          industry: industry,
          logoCompany: logoCompany,
          jobName: jobName,
          isCompany: isCompany,
        ),
        titlePadding: EdgeInsetsDirectional.only(
          start: 50.w,
          end: 50.w,
          bottom: 24.h,
        ),
        centerTitle: true,
        title: Text(
          companyName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 3.r,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      leading: CustomAdaptiveTapEffect(
        isOpacity: true,
        onPressed: () => context.pop(),
        child: Icon(
          getAdaptiveBackIcon(context),
          size: 22.sp,
          color: IconColors.iconBrandOnbrand,
        ),
      ),
      actions: [
        CustomAdaptiveTapEffect(
          isOpacity: true,
          onPressed: () => onShare,
          child: Icon(
            Icons.share_rounded,
            size: 22.sp,
            color: IconColors.iconBrandOnbrand,
          ),
        ),
      ],
    );
  }
}
