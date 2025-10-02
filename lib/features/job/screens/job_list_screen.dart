// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:job_connect/core/constant/apiconstant.dart';
// import 'package:job_connect/core/models/job_posting_model.dart';
// import 'package:job_connect/core/services/api.dart';
// import 'package:job_connect/core/utils/format.dart';
// import 'package:job_connect/features/job/screens/job_detail_screen.dart';

// class JobListScreen extends StatefulWidget {

//   const JobListScreen({super.key});

//   @override
//   State<JobListScreen> createState() => _JobListScreenState();
// }

// class _JobListScreenState extends State<JobListScreen> {
//   bool _showFilterOptions = false;
//   bool _isSearching = false;
//   String _searchQuery = '';
//   String _currentFilter = "Tất cả";
//   final List<String> _filterOptions = [
//     "Tất cả",
//     "Đang tuyển",
//     "Đã đóng",
//     "Lưu trữ",
//   ];

//   final _apiService = ApiService( );

//   List<JobPosting> _jobList = [];
//   List<JobPosting> _filteredJobList = [];

//   String removeDiacritics(String str) {
//     const diacriticMap = {
//       'À': 'A',
//       'Á': 'A',
//       'Â': 'A',
//       'Ã': 'A',
//       'È': 'E',
//       'É': 'E',
//       'Ê': 'E',
//       'Ì': 'I',
//       'Í': 'I',
//       'Ò': 'O',
//       'Ó': 'O',
//       'Ô': 'O',
//       'Õ': 'O',
//       'Ù': 'U',
//       'Ú': 'U',
//       'Ă': 'A',
//       'Đ': 'D',
//       'Ĩ': 'I',
//       'Ũ': 'U',
//       'Ơ': 'O',
//       'à': 'a',
//       'á': 'a',
//       'â': 'a',
//       'ã': 'a',
//       'è': 'e',
//       'é': 'e',
//       'ê': 'e',
//       'ì': 'i',
//       'í': 'i',
//       'ò': 'o',
//       'ó': 'o',
//       'õ': 'o',
//       'ù': 'u',
//       'ú': 'u',
//       'ă': 'a',
//       'đ': 'd',
//       'ĩ': 'i',
//       'ũ': 'u',
//       'Ư': 'U',
//       'Ạ': 'A',
//       'Ả': 'A',
//       'Ấ': 'A',
//       'Ầ': 'A',
//       'Ẩ': 'A',
//       'Ẫ': 'A',
//       'Ậ': 'A',
//       'Ắ': 'A',
//       'Ằ': 'A',
//       'Ẳ': 'A',
//       'Ẵ': 'A',
//       'Ặ': 'A',
//       'Ẹ': 'E',
//       'Ẻ': 'E',
//       'Ẽ': 'E',
//       'Ề': 'E',
//       'Ể': 'E',
//       'ạ': 'a',
//       'ả': 'a',
//       'ấ': 'a',
//       'ầ': 'a',
//       'ẩ': 'a',
//       'ẫ': 'a',
//       'ậ': 'a',
//       'ắ': 'a',
//       'ằ': 'a',
//       'ẳ': 'a',
//       'ẵ': 'a',
//       'ặ': 'a',
//       'ẹ': 'e',
//       'ẻ': 'e',
//       'ẽ': 'e',
//       'ề': 'e',
//       'ể': 'e',
//       'ô': 'o',
//       'ố': 'o',
//       'ồ': 'o',
//       'ổ': 'o',
//       'ỗ': 'o',
//       'ộ': 'o',
//       'ơ': 'o',
//       'ớ': 'o',
//       'ờ': 'o',
//       'ở': 'o',
//       'ỡ': 'o',
//       'ợ': 'o',
//       'ư': 'u',
//       'ứ': 'u',
//       'ừ': 'u',
//       'ử': 'u',
//       'ữ': 'u',
//       'ự': 'u',
//       'ý': 'y',
//       'ỳ': 'y',
//       'ỷ': 'y',
//       'ỹ': 'y',
//       'ỵ': 'y',
//       'Ý': 'Y',
//       'Ỳ': 'Y',
//       'Ỷ': 'Y',
//       'Ỹ': 'Y',
//       'Ỵ': 'Y',
//     };
//     return str.split('').map((c) => diacriticMap[c] ?? c).join();
//   }

//   void _searchJobsByTitle(String query) {
//     if (query.isEmpty) {
//       _filteredJobList.clear();
//       return;
//     }

//     final normalizedQuery = removeDiacritics(query).toLowerCase();
//     setState(() {
//       _filteredJobList =
//           _jobList
//               .where(
//                 (job) => removeDiacritics(
//                   job.title,
//                 ).toLowerCase().contains(normalizedQuery),
//               )
//               .toList();
//     });
//   }

//   Future<void> _fetchJobList() async {
//     final data = await _apiService.get(ApiConstants.jobPostingEndpoint);
//     try {
//       _jobList =
//           data.map<JobPosting>((item) => JobPosting.fromJson(item)).toList();
//     } catch (e) {
//       print('Lỗi khi lấy danh sách công việc: $e');
//       // Có thể hiển thị thông báo lỗi cho người dùng nếu muốn
//     }
//   }

//   List<JobPosting> get _filteredJobs {
//     if (_isSearching && _searchQuery.isNotEmpty) {
//       return _filteredJobList;
//     }
//     if (_currentFilter == "Tất cả") {
//       return _jobList;
//     } else {
//       return _jobList.where((job) => job.postStatus == _currentFilter).toList();
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _fetchJobList().then((_) {
//       setState(() {});
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.dark,
//       ),
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF7F9FC),
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black87,
//           title:
//               !_isSearching
//                   ? Text(
//                     'Danh sách công việc',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 22,
//                       color: Colors.black87,
//                     ),
//                   )
//                   : TextField(
//                     autofocus: true,
//                     decoration: InputDecoration(
//                       hintText: 'Nhập công việc cần tìm',
//                       border: InputBorder.none,
//                     ),
//                     style: TextStyle(fontSize: 18, color: Colors.black87),
//                     onChanged: (value) {
//                       setState(() {
//                         _searchQuery = value;
//                         _searchJobsByTitle(_searchQuery);
//                       });
//                     },
//                   ),
//           actions: [
//             !_isSearching
//                 ? IconButton(
//                   icon: Icon(Icons.search),
//                   onPressed: () {
//                     setState(() {
//                       _isSearching = true;
//                       _searchQuery = '';
//                     });
//                   },
//                 )
//                 : IconButton(
//                   icon: Icon(Icons.close),
//                   onPressed: () {
//                     setState(() {
//                       _isSearching = false;
//                       _searchQuery = '';
//                       _filteredJobList.clear();
//                     });
//                   },
//                 ),
//             IconButton(
//               icon: Icon(Icons.filter_list),
//               onPressed: () {
//                 setState(() {
//                   _showFilterOptions = !_showFilterOptions;
//                 });
//               },
//             ),
//           ],
//         ),
//         body: Column(
//           children: [
//             if (_showFilterOptions) _buildFilterOptions(),
//             _buildJobStatistics(),
//             Expanded(child: _buildJobList()),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterOptions() {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Lọc theo trạng thái:",
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 8),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children:
//                   _filterOptions.map((filter) {
//                     bool isSelected = _currentFilter == filter;
//                     return Padding(
//                       padding: const EdgeInsets.only(right: 8),
//                       child: ChoiceChip(
//                         label: Text(filter),
//                         selected: isSelected,
//                         onSelected: (selected) {
//                           if (selected) {
//                             setState(() {
//                               _currentFilter = filter;
//                             });
//                           }
//                         },
//                         // ignore: deprecated_member_use
//                         selectedColor: const Color(0xFF3366FF).withValues(alpha:0.2),
//                         labelStyle: TextStyle(
//                           color:
//                               isSelected
//                                   ? const Color(0xFF3366FF)
//                                   : Colors.black87,
//                           fontWeight:
//                               isSelected ? FontWeight.bold : FontWeight.normal,
//                         ),
//                       ),
//                     );
//                   }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildJobStatistics() {
//     // Tính tổng số công việc cho mỗi trạng thái
//     int activeJobs =
//         _jobList.where((job) => job.postStatus == 'Đang tuyển').length;
//     int closedJobs =
//         _jobList.where((job) => job.postStatus == 'Đã đóng').length;
//     int archivedJobs =
//         _jobList.where((job) => job.postStatus == 'Lưu trữ').length;

//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.black.withValues(alpha:0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Tổng quan",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildStatCard(
//                     icon: Icons.work,
//                     iconColor: const Color(0xFF3366FF),
//                     title: "Tổng số",
//                     count: _jobList.length.toString(),
//                     backgroundColor: const Color(0xFFE6EFFF),
//                     showBadge: false,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildStatCard(
//                     icon: Icons.check_circle_outline,
//                     iconColor: Colors.green,
//                     title: "Đang tuyển",
//                     count: activeJobs.toString(),
//                     // ignore: deprecated_member_use
//                     backgroundColor: Colors.green.withValues(alpha:0.1),
//                     showBadge: activeJobs > 0,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildStatCard(
//                     icon: Icons.block,
//                     iconColor: Colors.red,
//                     title: "Đã đóng",
//                     count: closedJobs.toString(),
//                     // ignore: deprecated_member_use
//                     backgroundColor: Colors.red.withValues(alpha:0.1),
//                     showBadge: false,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildStatCard(
//                     icon: Icons.archive_outlined,
//                     iconColor: Colors.grey,
//                     title: "Lưu trữ",
//                     count: archivedJobs.toString(),
//                     // ignore: deprecated_member_use
//                     backgroundColor: Colors.grey.withValues(alpha:0.1),
//                     showBadge: false,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCard({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required String count,
//     required Color backgroundColor,
//     required bool showBadge,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: iconColor, size: 20),
//               if (showBadge) ...[
//                 const SizedBox(width: 4),
//                 Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: iconColor, width: 1.5),
//                   ),
//                   child: Text(
//                     "!",
//                     style: TextStyle(
//                       color: iconColor,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             count,
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: iconColor,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             style: TextStyle(fontSize: 12, color: Colors.black87),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildJobList() {
//     return _filteredJobs.isEmpty
//         ? _buildEmptyState()
//         : ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: _filteredJobs.length,
//           itemBuilder: (context, index) {
//             final job = _filteredJobs[index];
//             return _buildJobCard(job);
//           },
//         );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
//           const SizedBox(height: 16),
//           Text(
//             "Không tìm thấy công việc nào",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade700,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "Hãy thử bỏ bộ lọc hoặc tạo công việc mới",
//             style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildJobCard(JobPosting job) {
//     Color statusColor;
//     Widget statusIcon;

//     switch (job.postStatus) {
//       case 'Đang tuyển':
//         statusColor = Colors.green;
//         statusIcon = const Icon(
//           Icons.check_circle_outline,
//           size: 16,
//           color: Colors.green,
//         );
//         break;
//       case 'Đã đóng':
//         statusColor = Colors.red;
//         statusIcon = const Icon(Icons.block, size: 16, color: Colors.red);
//         break;
//       case 'Lưu trữ':
//         statusColor = Colors.grey;
//         statusIcon = const Icon(
//           Icons.archive_outlined,
//           size: 16,
//           color: Colors.grey,
//         );
//         break;
//       default:
//         statusColor = Colors.blue;
//         statusIcon = const Icon(
//           Icons.info_outline,
//           size: 16,
//           color: Colors.blue,
//         );
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.black.withValues(alpha:0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         // ignore: deprecated_member_use
//                         color: const Color(0xFF3366FF).withValues(alpha:0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Icon(
//                         Icons.work_outline,
//                         color: Color(0xFF3366FF),
//                         size: 24,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               // if (job['isUrgent'])
//                               //   Container(
//                               //     margin: const EdgeInsets.only(right: 8),
//                               //     padding: const EdgeInsets.symmetric(
//                               //       horizontal: 8,
//                               //       vertical: 2,
//                               //     ),
//                               //     decoration: BoxDecoration(
//                               //       // ignore: deprecated_member_use
//                               //       color: Colors.red.withValues(alpha:0.1),
//                               //       borderRadius: BorderRadius.circular(10),
//                               //     ),
//                               //     child: const Row(
//                               //       mainAxisSize: MainAxisSize.min,
//                               //       children: [
//                               //         Icon(
//                               //           Icons.priority_high,
//                               //           color: Colors.red,
//                               //           size: 12,
//                               //         ),
//                               //         SizedBox(width: 4),
//                               //         Text(
//                               //           "Gấp",
//                               //           style: TextStyle(
//                               //             color: Colors.red,
//                               //             fontSize: 12,
//                               //             fontWeight: FontWeight.bold,
//                               //           ),
//                               //         ),
//                               //       ],
//                               //     ),
//                               //   ),
//                               Expanded(
//                                 child: Text(
//                                   job.title,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.location_on_outlined,
//                                 size: 14,
//                                 color: Colors.grey.shade600,
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 job.location,
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Icon(
//                                 Icons.access_time,
//                                 size: 14,
//                                 color: Colors.grey.shade600,
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 job.workType,
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 3,
//                             ),
//                             decoration: BoxDecoration(
//                               // ignore: deprecated_member_use
//                               color: statusColor.withValues(alpha:0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 statusIcon,
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   job.postStatus,
//                                   style: TextStyle(
//                                     color: statusColor,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     PopupMenuButton<String>(
//                       icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
//                       itemBuilder:
//                           (BuildContext context) => <PopupMenuEntry<String>>[
//                             const PopupMenuItem<String>(
//                               value: 'edit',
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.edit, size: 18),
//                                   SizedBox(width: 8),
//                                   Text('Chỉnh sửa'),
//                                 ],
//                               ),
//                             ),
//                             const PopupMenuItem<String>(
//                               value: 'status',
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.swap_horiz, size: 18),
//                                   SizedBox(width: 8),
//                                   Text('Thay đổi trạng thái'),
//                                 ],
//                               ),
//                             ),
//                             const PopupMenuItem<String>(
//                               value: 'duplicate',
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.content_copy, size: 18),
//                                   SizedBox(width: 8),
//                                   Text('Nhân bản'),
//                                 ],
//                               ),
//                             ),
//                             const PopupMenuItem<String>(
//                               value: 'delete',
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     Icons.delete_outline,
//                                     color: Colors.red,
//                                     size: 18,
//                                   ),
//                                   SizedBox(width: 8),
//                                   Text(
//                                     'Xóa',
//                                     style: TextStyle(color: Colors.red),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: _buildInfoItem(
//                         icon: Icons.payments_outlined,
//                         label:
//                             job.salary != null
//                                 ? "Lương: ${job.salary} triệu"
//                                 : "Lương: Thỏa thuận",
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: _buildInfoItem(
//                         icon: Icons.calendar_today_outlined,
//                         label: "Đăng: ${job.createdAt}",
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: _buildInfoItem(
//                         icon: Icons.event_busy_outlined,
//                         label: "Hết hạn: ${job.applicationDeadline}",
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.person_outline,
//                       size: 16,
//                       color: Colors.grey.shade600,
//                     ),
//                     const SizedBox(width: 4),
//                     // Text(
//                     //   "${job['applicants']} ứng viên",
//                     //   style: TextStyle(
//                     //     fontSize: 13,
//                     //     color: Colors.grey.shade700,
//                     //   ),
//                     // ),
//                     // const SizedBox(width: 16),
//                     // Icon(
//                     //   Icons.visibility_outlined,
//                     //   size: 16,
//                     //   color: Colors.grey.shade600,
//                     // ),
//                     // const SizedBox(width: 4),
//                     // Text(
//                     //   "${job['views']} lượt xem",
//                     //   style: TextStyle(
//                     //     fontSize: 13,
//                     //     color: Colors.grey.shade700,
//                     //   ),
//                     // ),
//                   ],
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder:
//                             (context) => JobDetailScreen(
//                               idUser: widget.idUser,
//                               title: job.title,
//                               companyName: job.company.companyName,
//                               companyLogo: job.company.logoUrl ?? '',
//                               description: job.description,
//                               requirements: job.requirements,
//                               benefits:
//                                   job.benefits ?? 'Thông tin không có sẵn',
//                               salary: job.salary.toString(),
//                               location: job.location,
//                               employmentType: job.workType,
//                               experience: job.experienceLevel,
//                               postedDate:
//                                   FormatUtils.formattedDateTime(
//                                     job.createdAt,
//                                   ).toString(),
//                               applicantsCount: 0,
//                               company: job.company,
//                             ),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF3366FF),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Text("Xem chi tiết"),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoItem({required IconData icon, required String label}) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 16, color: Colors.grey.shade600),
//         const SizedBox(width: 4),
//         Expanded(
//           child: Text(
//             label,
//             style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }
