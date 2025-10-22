import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'featured_company_card.dart';
import 'package:job_connect/features/company/model/company_model.dart';

class FeaturedCompaniesList extends StatelessWidget {
  final List<CompanyModel> companies;

  const FeaturedCompaniesList({
    super.key,
    required this.companies,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (companies.isEmpty) {
      return SizedBox(
        height: 60.h,
        child: Center(
          child: Text(
            'Chưa có doanh nghiệp nổi bật',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return SizedBox(
      height: 210.h,
      child: AnimationLimiter(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: companies.length,
          itemBuilder: (context, index) {
            final company = companies[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 475),
              child: SlideAnimation(
                verticalOffset: 50.h,
                horizontalOffset: 100.w,
                child: FadeInAnimation(
                  child: FeaturedCompanyCard(
                    company: company,
                    index: index,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}