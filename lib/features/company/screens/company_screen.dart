import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/company/viewmodel/company_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:job_connect/config/utils/string_utils.dart';
import 'package:job_connect/config/widgets/background_empty_state.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_search_bar_main.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/company/widgets/company/company_card.dart';
import 'package:job_connect/features/company/widgets/company/company_shimmer.dart';

class CompanyScreen extends StatefulWidget {
  final String idUser;
  const CompanyScreen({super.key, required this.idUser});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _initData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    _listAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    final viewModel = context.read<CompanyViewModel>();
    await Future.wait([
      viewModel.getCompanies(),
    ]);
    if (mounted) _listAnimationController.forward();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final keyword = StringUtils.removeDiacritics(_searchController.text.trim());
      context.read<CompanyViewModel>().filterCompanies(keyword);
      _listAnimationController.forward(from: 0);
    });
  }

  Future<void> _onRefresh() async {
    _listAnimationController.reset();
    _searchController.clear();
    await context.read<CompanyViewModel>().refreshCompanies();
    if (mounted) _listAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppbarTitleLarge(title: "Khám phá doanh nghiệp"),
      body: UnfocusWidget(
        child: Consumer<CompanyViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CompanyShimmer());
            }

            if (vm.errorMessage != null && vm.errorMessage!.isNotEmpty) {
              return BackgroundErrorState(
                title: "Hệ thống đang gặp sự cố\nVui lòng thử lại sau.",
                onRetry: _onRefresh,
              );
            }

            final companies = vm.filteredCompanies;
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: theme.primaryColor,
              backgroundColor: theme.cardColor,
              child: Column(
                children: [
                  CustomSearchBarMain(
                    controller: _searchController,
                    onChanged: (_) => _onSearchChanged(),
                    onClear: _searchController.clear,
                    hinText: "Tìm theo tên, ngành nghề, địa chỉ...",
                  ),
                  Expanded(
                    child: companies.isEmpty
                      ? BackgroundEmptyState(
                          isSearching: _searchController.text.isNotEmpty,
                          onRefresh: _onRefresh,
                          title: "Công Ty",
                          iconData: Icons.apartment_rounded,
                        )
                      : AnimationLimiter(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            padding:
                                EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                            itemCount: companies.length,
                            itemBuilder: (context, index) {
                              final company = companies[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration:
                                    const Duration(milliseconds: 425),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: CompanyCard(
                                      company: company,
                                      idUser: widget.idUser,
                                      jobCount: 1,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
