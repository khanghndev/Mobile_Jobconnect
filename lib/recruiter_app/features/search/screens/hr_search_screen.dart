import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/candidate_info_service.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import '../../../../model/save_candidate_model.dart';
import '../../../services/resum_skill_service.dart';
import '../../../services/save_candidate_service.dart';
import '../../candidate/screens/detail_candidate_of_hr.dart';
import 'hr_saved_candidates_screen.dart'; 

class HrSearchScreen extends StatefulWidget {
  String recruiterId;
  HrSearchScreen({
    super.key,
    required this.recruiterId,
  });

  @override
  State<HrSearchScreen> createState() => _HrSearchScreenState();
}

class _HrSearchScreenState extends State<HrSearchScreen> {
  // Controller của thanh tìm kiếm
  final TextEditingController _searchController = TextEditingController();

  // Khởi tạo các service
  final CandidateInfoService candidateInfoService = CandidateInfoService();
  final UserService accountService = UserService();
  final ResumeSkillService resumeSkillService = ResumeSkillService();
  final SaveCandidateService saveCandidateService = SaveCandidateService();

  // Các tùy chọn lọc
  List<String> locations = [
    'Tất cả địa điểm', 'An Giang', 'Bà Rịa - Vũng Tàu', 'Bạc Liêu', 'Bắc Giang', 'Bắc Kạn', 'Bắc Ninh',
    'Bến Tre', 'Bình Dương', 'Bình Định', 'Bình Phước', 'Bình Thuận', 'Cà Mau', 'Cao Bằng',
    'Cần Thơ', 'Đà Nẵng', 'Đắk Lắk', 'Đắk Nông', 'Điện Biên', 'Đồng Nai', 'Đồng Tháp',
    'Gia Lai', 'Hà Giang', 'Hà Nam', 'Hà Nội', 'Hà Tĩnh', 'Hải Dương', 'Hải Phòng',
    'Hậu Giang', 'Hòa Bình', 'Hưng Yên', 'Khánh Hòa', 'Kiên Giang', 'Kon Tum', 'Lai Châu',
    'Lâm Đồng', 'Lạng Sơn', 'Lào Cai', 'Long An', 'Nam Định', 'Nghệ An', 'Ninh Bình',
    'Ninh Thuận', 'Phú Thọ', 'Phú Yên', 'Quảng Bình', 'Quảng Nam', 'Quảng Ngãi', 'Quảng Ninh',
    'Quảng Trị', 'Sóc Trăng', 'Sơn La', 'Tây Ninh', 'Thái Bình', 'Thái Nguyên', 'Thanh Hóa',
    'Thừa Thiên Huế', 'Tiền Giang', 'Hồ Chí Minh', 'Trà Vinh', 'Tuyên Quang', 'Vĩnh Long', 'Vĩnh Phúc',
    'Yên Bái',
  ];

  List<String> experiences = ['Tất cả kinh nghiệm', 'Dưới 1 năm', '1-3 năm', 'Trên 3 năm'];
  List<String> skills = ['Tất cả kỹ năng'];
  List<String> sortOptions = ['Tất cả', 'Mới nhất', 'Phù hợp nhất', 'Kinh nghiệm nhiều nhất'];

  // Biến lưu các lựa chọn lọc chính
  String selectedLocation = '';  
  String selectedExperience = ''; 
  String selectedSkill = ''; 
  String selectedSort = ''; 

  List<CandidateInfoModel> originalCandidates = [];
  List<CandidateInfoModel> filteredCandidates = [];
  Map<String, UserModel> accountsMap = {};
  List<CandidateInfoModel> savedCandidates = [];
  List<SaveCandidateModel> savedCandidatesList = [];
  List<String> savedCandidateIds = [];
  bool isAdvancedFilterVisible = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các giá trị lọc mặc định
    selectedLocation = locations.isNotEmpty ? locations.first : 'Tất cả địa điểm';
    selectedExperience = experiences.isNotEmpty ? experiences.first : 'Tất cả kinh nghiệm';
    selectedSkill = skills.isNotEmpty ? skills.first : 'Tất cả kỹ năng';
    selectedSort = sortOptions.isNotEmpty ? sortOptions.first : 'Tất cả';
    // Tải danh sách kỹ năng
    loadSkills();
    // Tải danh sách ứng viên và thông tin tài khoản
    loadCandidates().then((_) {
      _filterCandidates();
      _loadSavedIds();
    });
  }

  // Hàm lấy tỉnh từ chuỗi địa chỉ
  String getProvince(String address) {
    if (address.isEmpty) return '';
    final parts = address.split(',');
    return parts.isNotEmpty ? parts.last.trim() : '';
  }

  // Hàm tải danh sách kỹ năng
  Future<void> loadSkills() async {
    try {
      final fetchedSkills = await resumeSkillService.getAllResumeSkills();
      final List<String> skillNames = fetchedSkills.map((rs) => rs.skill).toList();
      skillNames.insert(0, 'Tất cả kỹ năng'); // Thêm "Tất cả kỹ năng"
      setState(() {
        skills = skillNames;
      });
    } catch (e) {
      // Hiển thị lỗi nếu xảy ra
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
      );
    }
  }

  // Hàm tải danh sách ứng viên kèm thông tin tài khoản
  Future<void> loadCandidates() async {
    try {
      final candidates = await candidateInfoService.getAllCandidates();
      final Map<String, UserModel> tempAccountsMap = {};

      // Lấy thông tin Account cho mỗi Candidate
      for (var candidate in candidates) {
        final account = await accountService.getUserById(id:candidate.idUser);
        tempAccountsMap[candidate.idUser] = account;
      }

      setState(() {
        originalCandidates = candidates;
        filteredCandidates = List.from(candidates);
        accountsMap = tempAccountsMap;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
      );
    }
  }

  // Hàm tải danh sách đã lưu
  Future<void> _loadSavedIds() async {
    try {
      final list = await saveCandidateService.getSavedCandidates(recruiterId: widget.recruiterId);
      setState(() {
        savedCandidateIds = list.map((s) => s.idUserCandidate).toList();
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách đã lưu: $e')),
      );
    }
  }

  // Hàm kiểm tra xem ứng viên đã được lưu chưa
  bool isCandidateSaved(String idUser) => savedCandidateIds.contains(idUser);

  // Hàm lưu/bỏ lưu ứng viên
  void toggleSaveCandidate(CandidateInfoModel c) async {
    final id = c.idUser;
    final name = accountsMap[id]?.userName ?? 'Ứng viên';
    try {
      if (isCandidateSaved(id)) {
        // Nếu đã lưu -> bỏ lưu
        await saveCandidateService.deleteCandidate(recruiterId: widget.recruiterId,candidateId: id);
        setState(() => savedCandidateIds.remove(id));
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Đã bỏ lưu $name'),
                duration: Duration(seconds: 3), 
            ),
        );
      } else {
        // Nếu chưa lưu -> lưu
        final item = SaveCandidateModel(
          idUserRecruiter: widget.recruiterId,
          idUserCandidate: id,
          savedAt: DateTime.now(),
          note: 'Ứng viên tiềm năng',
        );
        await saveCandidateService.saveCandidate(data: item);
        setState(() => savedCandidateIds.add(id));
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Đã lưu $name'),
                duration: Duration(seconds: 3), 
            ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu/bỏ lưu: $e')),
      );
    }
  }

  // Hàm lọc ứng viên dựa theo các tiêu chí
  void _filterCandidates() {
    setState(() {
      filteredCandidates = originalCandidates.where((candidate) {
        final account = accountsMap[candidate.idUser];
        if (account == null) return false; // Bỏ qua nếu không có thông tin Account

        // Lọc theo từ khóa tìm kiếm
        final keyword = _searchController.text.toLowerCase();
        final nameMatch = account.userName.toLowerCase().contains(keyword);
        final skillMatch = candidate.skills?.toLowerCase().contains(keyword) ?? false;
        final positionMatch = candidate.workPosition?.toLowerCase().contains(keyword) ?? false;

        // Lọc theo địa điểm
        bool locationMatch = selectedLocation == 'Tất cả địa điểm';
        if (!locationMatch && account.address != null) {
          final province = getProvince(account.address!);
          locationMatch = province == selectedLocation;
        }

        // Lọc theo kinh nghiệm
        bool experienceMatch = selectedExperience == 'Tất cả kinh nghiệm';
        if (!experienceMatch && candidate.experienceYears != null) {
          if (selectedExperience == 'Dưới 1 năm') {
            experienceMatch = candidate.experienceYears! < 1;
          } else if (selectedExperience == '1-3 năm') {
            experienceMatch = candidate.experienceYears! >= 1 && candidate.experienceYears! <= 3;
          } else if (selectedExperience == 'Trên 3 năm') {
            experienceMatch = candidate.experienceYears! > 3;
          }
        }

        // Lọc theo kỹ năng
        bool skillMatchFilter = selectedSkill == 'Tất cả kỹ năng';
        if (!skillMatchFilter && candidate.skills != null) {
          skillMatchFilter = candidate.skills!.toLowerCase().contains(selectedSkill.toLowerCase());
        }

        return (nameMatch || skillMatch || positionMatch) &&
               locationMatch &&
               experienceMatch &&
               skillMatchFilter;
      }).toList();

      // Sắp xếp kết quả dựa theo lựa chọn sắp xếp
      if (selectedSort == 'Mới nhất') {
        // Giả định danh sách đã sắp xếp theo thời gian
      } else if (selectedSort == 'Kinh nghiệm nhiều nhất') {
        filteredCandidates.sort((a, b) {
          final expA = a.experienceYears ?? 0;
          final expB = b.experienceYears ?? 0;
          return expB.compareTo(expA);
        });
      } else if (selectedSort == 'Phù hợp nhất') {
        filteredCandidates.sort((a, b) {
          final ratingA = a.ratingScore ?? 0.0;
          final ratingB = b.ratingScore ?? 0.0;
          return ratingB.compareTo(ratingA);
        });
      }
    });
  }

  // Hàm hiển thị BottomSheet sắp xếp
  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Sắp xếp theo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...sortOptions.map((option) {
                return ListTile(
                  leading: Radio<String>(
                    value: option,
                    groupValue: selectedSort,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (value) {
                      setState(() {
                        selectedSort = value!;
                        _filterCandidates();
                      });
                      context.pop();
                    },
                  ),
                  title: Text(option),
                  onTap: () {
                    setState(() {
                      selectedSort = option;
                      _filterCandidates();
                    });
                    context.pop();
                  },
                );
              // ignore: unnecessary_to_list_in_spreads
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  // Hàm hiển thị BottomSheet bộ lọc nâng cao
  void _showAdvancedFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bộ lọc nâng cao',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: [
                        const Text(
                          'Địa điểm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: locations.map((location) {
                            return FilterChip(
                              label: Text(location),
                              selected: selectedLocation == location,
                              onSelected: (selected) {
                                setState(() {
                                  selectedLocation = location;
                                });
                              },
                              // ignore: deprecated_member_use
                              selectedColor: Colors.blue.withValues(alpha:0.2),
                              checkmarkColor: Colors.blue,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Kinh nghiệm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: experiences.map((experience) {
                            return FilterChip(
                              label: Text(experience),
                              selected: selectedExperience == experience,
                              onSelected: (selected) {
                                setState(() {
                                  selectedExperience = experience;
                                });
                              },
                              // ignore: deprecated_member_use
                              selectedColor: Colors.blue.withValues(alpha:0.2),
                              checkmarkColor: Colors.blue,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Kỹ năng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: skills.map((skill) {
                            return FilterChip(
                              label: Text(skill),
                              selected: selectedSkill == skill,
                              onSelected: (selected) {
                                setState(() {
                                  selectedSkill = skill;
                                });
                              },
                              // ignore: deprecated_member_use
                              selectedColor: Colors.blue.withValues(alpha:0.2),
                              checkmarkColor: Colors.blue,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                child: const Text('Đặt lại'),
                                onPressed: () {
                                  setState(() {
                                    selectedLocation = 'Tất cả địa điểm';
                                    selectedExperience = 'Tất cả kinh nghiệm';
                                    selectedSkill = 'Tất cả kỹ năng';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  backgroundColor: Theme.of(context).primaryColor,
                                ),
                                child: const Text(
                                  'Áp dụng',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  _filterCandidates();
                                  context.pop();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Thanh AppBar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Tìm kiếm ứng viên',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Icon thông báo (có thể bật nếu cần)
//          IconButton(
//            icon: const Icon(Icons.notifications_outlined, color: Colors.blue),
//            onPressed: () {},
//          ),
          // Icon danh sách ứng viên đã lưu
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: Colors.blue),
            onPressed: () {
              // Điều hướng sang trang danh sách ứng viên đã lưu
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context)=> 
                  HrSavedCandidatesScreen(
                    savedCandidateIds: savedCandidateIds, 
                    recruiterId: widget.recruiterId,
                ))
              );
            },
          ),
        ],
      ),
      
      // Bọc toàn bộ thân giao diện trong RefreshIndicator để kéo xuống reload dữ liệu
      body: RefreshIndicator(
        onRefresh: () async {
          await loadCandidates();
          _filterCandidates();
        },
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.grey.withValues(alpha:0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    // Thanh tìm kiếm
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => _filterCandidates(),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm theo tên, vị trí, kỹ năng...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.search, color: Colors.blue),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterCandidates();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bộ lọc (địa điểm, kinh nghiệm, kỹ năng)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          Icons.location_on_outlined,
                          'Địa điểm',
                          selectedLocation,
                          locations,
                        ),
                        const SizedBox(width: 12),
                        _buildFilterChip(
                          Icons.work_outline,
                          'Kinh nghiệm',
                          selectedExperience,
                          experiences,
                        ),
                        const SizedBox(width: 12),
                        _buildFilterChip(
                          Icons.code,
                          'Kỹ năng',
                          selectedSkill,
                          skills,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Hiển thị số lượng ứng viên được tìm thấy
                  Text(
                    'Tổng: ${filteredCandidates.length} ứng viên',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Nút sắp xếp (sort)
                  GestureDetector(
                    onTap: _showSortOptions,
                    child: Row(
                      children: [
                        Icon(Icons.sort, color: Colors.black54),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 110,
                          child: Text(
                            selectedSort,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.blue),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredCandidates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không tìm thấy ứng viên phù hợp',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                selectedLocation = 'Tất cả địa điểm';
                                selectedExperience = 'Tất cả kinh nghiệm';
                                selectedSkill = 'Tất cả kỹ năng';
                                _filterCandidates();
                              });
                            },
                            child: const Text('Xóa bộ lọc'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredCandidates.length,
                      itemBuilder: (context, index) {
                        final candidate = filteredCandidates[index];
                        final account = accountsMap[candidate.idUser];
                        return _buildCandidateCard(candidate, account);
                      },
                    ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   backgroundColor: Colors.white,
      //   icon: const Icon(Icons.filter_list),
      //   label: const Text(''),
      //   onPressed: _showAdvancedFilterDialog,
      // ),
    );
  }

  // Hàm xây dựng các FilterChip
  Widget _buildFilterChip(IconData icon, String label, String selectedValue, List<String> items) {
    int item = 6; // số lượng phần tử hiển thị trong dropdown
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.blue.withValues(alpha:0.3)),
        borderRadius: BorderRadius.circular(25),
        color: selectedValue != items[0]
            // ignore: deprecated_member_use
            ? Colors.blue.withValues(alpha:0.1)
            : Colors.transparent,
      ),
      child: Builder(
        builder: (ctx) {
          return GestureDetector(
            onTap: () async {
              final renderBox = ctx.findRenderObject() as RenderBox;
              final offset = renderBox.localToGlobal(Offset.zero);
              final chipSize = renderBox.size;
              final screenSize = MediaQuery.of(ctx).size;
              final menuTop = offset.dy + chipSize.height + 20;

              final newValue = await showMenu<String>(
                context: ctx,
                position: RelativeRect.fromLTRB(
                  offset.dx - 6, // left
                  menuTop - 6,   // top
                  screenSize.width - (offset.dx + chipSize.width), // right
                  screenSize.height - menuTop, // bottom
                ),
                items: items
                    .map((item) => PopupMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
                constraints: BoxConstraints(maxHeight: 48.0 * item),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );

              if (newValue != null) {
                setState(() {
                  if (label == 'Địa điểm') {
                    selectedLocation = newValue;
                  } 
                  else if (label == 'Kinh nghiệm') {selectedExperience = newValue;}
                  else if (label == 'Kỹ năng') {selectedSkill = newValue;}
                  _filterCandidates();
                });
              }
            },
            behavior: HitTestBehavior.translucent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  items.contains(selectedValue) ? selectedValue : label,
                  style: TextStyle(
                    fontSize: 15,
                    color: selectedValue != items[0]
                        ? Colors.blue[800]
                        : Colors.black54,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 24, color: Colors.blue),
              ],
            ),
          );
        },
      ),
    );
  }

  // Hàm xây dựng thẻ ứng viên
  Widget _buildCandidateCard(CandidateInfoModel candidate, UserModel? account) {
    if (account == null) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withValues(alpha:0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: ImageUtils.getImageProvider(account.avatarUrl),
                        ),
                        if (account.accountStatus == 'active')
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                account.userName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    candidate.ratingScore?.toStringAsFixed(1) ?? '0.0',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            candidate.workPosition ?? 'Chưa xác định',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                getProvince(account.address ?? '') == ''
                                    ? '---'
                                    : getProvince(account.address!),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.work,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                candidate.experienceYears != null
                                    ? '${candidate.experienceYears} năm'
                                    : 'Chưa có',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (candidate.skills?.split(',') ?? []).isNotEmpty
                      ? candidate.skills!.split(',').map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.blue.withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              skill.trim(),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList()
                      : [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Chưa có kỹ năng',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 18,
                    color: Colors.blue,
                  ),
                  label: const Text(
                    'Xem hồ sơ',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CandidateDetailScreen(
                          candidate: candidate,
                          account: account,
                        ),
                      ),
                    );
                  },
                ),
                TextButton.icon(
                  icon: const Icon(
                    Icons.message_outlined,
                    size: 18,
                    color: Colors.blue,
                  ),
                  label: const Text(
                    'Liên hệ',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: (){},),
                TextButton.icon(
                  icon: Icon(
                    isCandidateSaved(candidate.idUser)
                        ? Icons.bookmark
                        : Icons.bookmark_outline,
                    size: 18,
                    color: Colors.blue,
                  ),
                  label: Text(
                    isCandidateSaved(candidate.idUser) ? 'Đã lưu' : 'Lưu',
                    style: const TextStyle(color: Colors.blue),
                  ),
                  onPressed: () => toggleSaveCandidate(candidate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}