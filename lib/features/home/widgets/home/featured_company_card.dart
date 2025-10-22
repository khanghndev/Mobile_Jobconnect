import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/features/company/model/company_model.dart';

class FeaturedCompanyCard extends StatelessWidget {
  final CompanyModel company;
  final int index;

  const FeaturedCompanyCard({
    super.key,
    required this.company,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Color> cardGradientColors = [
      Colors.primaries[index % Colors.primaries.length].withValues(alpha:0.1),
      Colors.accents[(index + 5) % Colors.accents.length].withValues(alpha:0.05),
    ];
    if (theme.brightness == Brightness.dark) {
      cardGradientColors = [
        Colors.primaries[index % Colors.primaries.length].withValues(alpha:0.2),
        Colors.accents[(index + 5) % Colors.accents.length].withValues(alpha:0.15),
      ];
    }

    return Container(
      width: 175.w,
      margin: EdgeInsets.only(right: 18.w, bottom: 10.h, top: 6.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cardGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha:0.1),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: theme.dividerColor.withValues(alpha:0.15),
          width: 1.w,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            context.push(
              "/company/detail",
              extra: {
                "company" : company,
                "idUser" : ""
              }
            );
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 70.h,
                width: 70.w,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r), 
                  child: Image.network(
                    company.logoCompany ?? '',
                    fit: BoxFit.contain,
                    errorBuilder:
                      (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha:0.4),
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                        child: Center(
                          child: Image.asset(
                            AppImages.logoApp,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                company.companyName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
