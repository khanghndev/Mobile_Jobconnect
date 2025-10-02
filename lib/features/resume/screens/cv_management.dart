import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CVManagementPage extends StatefulWidget {
  const CVManagementPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CVManagementPageState createState() => _CVManagementPageState();
}

class _CVManagementPageState extends State<CVManagementPage> {
  // Dữ liệu mẫu với thông tin thêm về mỗi CV
  List<Map<String, dynamic>> cvList = [
    {
      "name": "CV1.pdf",
      "size": "1.2 MB",
      "lastModified": DateTime.now().subtract(const Duration(days: 5)),
      "tags": ["Marketing", "Design"],
    },
    {
      "name": "CV2.pdf",
      "size": "0.8 MB",
      "lastModified": DateTime.now().subtract(const Duration(days: 2)),
      "tags": ["Developer", "Flutter"],
    },
  ];

  final _cvNameController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isGridView = false;

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tải lên CV mới'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _cvNameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên file CV',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Chọn file từ thiết bị'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () {
                    // Xử lý chọn file từ thiết bị
                    Navigator.of(context).pop();
                    _uploadNewCV();
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
            ],
          ),
    );
  }

  void _uploadNewCV() {
    if (_cvNameController.text.isEmpty) {
      _cvNameController.text = "CV_NewUser.pdf";
    }

    setState(() {
      cvList.add({
        "name": _cvNameController.text,
        "size": "${(0.5 + (cvList.length * 0.2)).toStringAsFixed(1)} MB",
        "lastModified": DateTime.now(),
        "tags": ["Mới"],
      });
      _cvNameController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tải lên CV thành công!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> cv, int index) {
    final TextEditingController nameController = TextEditingController(
      text: cv["name"],
    );
    final TextEditingController tagController = TextEditingController();
    List<String> tags = List<String>.from(cv["tags"]);

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Chỉnh sửa CV'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên file CV',
                            prefixIcon: Icon(Icons.description),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: tagController,
                                decoration: const InputDecoration(
                                  labelText: 'Thêm thẻ',
                                  prefixIcon: Icon(Icons.tag),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                if (tagController.text.isNotEmpty) {
                                  setState(() {
                                    tags.add(tagController.text);
                                    tagController.clear();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Thẻ:'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children:
                              tags
                                  .map(
                                    (tag) => Chip(
                                      label: Text(tag),
                                      deleteIcon: const Icon(
                                        Icons.close,
                                        size: 16,
                                      ),
                                      onDeleted: () {
                                        setState(() {
                                          tags.remove(tag);
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Hủy'),
                    ),
                    FilledButton(
                      onPressed: () {
                        final updatedCV = {
                          "name": nameController.text,
                          "size": cv["size"],
                          "lastModified": DateTime.now(),
                          "tags": tags,
                        };

                        this.setState(() {
                          cvList[index] = updatedCV;
                        });

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Cập nhật CV thành công!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text('Lưu'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc chắn muốn xóa ${cvList[index]["name"]}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  setState(() {
                    cvList.removeAt(index);
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đã xóa CV!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Lọc CV'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Mới nhất'),
                  onTap: () {
                    setState(() {
                      cvList.sort(
                        (a, b) => (b["lastModified"] as DateTime).compareTo(
                          a["lastModified"] as DateTime,
                        ),
                      );
                    });
                    Navigator.pop(context, true);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Cũ nhất'),
                  onTap: () {
                    setState(() {
                      cvList.sort(
                        (a, b) => (a["lastModified"] as DateTime).compareTo(
                          b["lastModified"] as DateTime,
                        ),
                      );
                    });
                    Navigator.pop(context, true);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha),
                  title: const Text('Theo tên (A-Z)'),
                  onTap: () {
                    setState(() {
                      cvList.sort(
                        (a, b) => (a["name"] as String).compareTo(
                          b["name"] as String,
                        ),
                      );
                    });
                    Navigator.pop(context, true);
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    _cvNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredList {
    if (_searchQuery.isEmpty) return cvList;
    return cvList
        .where(
          (cv) =>
              cv["name"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              cv["tags"].any(
                (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()),
              ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quản lý CV",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(
          context,
          // ignore: deprecated_member_use
        ).colorScheme.primaryContainer.withValues(alpha:0.8),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip:
                _isGridView
                    ? "Chuyển sang dạng danh sách"
                    : "Chuyển sang dạng lưới",
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: "Lọc danh sách CV",
            onPressed: _showFilterDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm CV theo tên hoặc thẻ...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Thống kê
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Tổng số CV: ${_filteredList.length}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Kết quả tìm kiếm: ${_filteredList.length}/${cvList.length}'
                      : '',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Danh sách CV
          Expanded(
            child:
                _filteredList.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isNotEmpty
                                ? Icons.search_off
                                : Icons.description_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? "Không tìm thấy CV phù hợp"
                                : "Bạn chưa có CV nào. Hãy tải lên!",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            TextButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text("Xóa bộ lọc"),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            ),
                        ],
                      ),
                    )
                    : _isGridView
                    ? _buildGridView()
                    : _buildListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadDialog,
        icon: const Icon(Icons.add),
        label: const Text("Tải lên CV"),
        tooltip: "Tải lên CV mới",
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _filteredList.length,
      itemBuilder: (context, index) {
        final cv = _filteredList[index];
        final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PDF Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // CV details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cv["name"],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatter.format(cv["lastModified"]),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.storage,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                cv["size"],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Action buttons - now with proper spacing and smaller size
                    SizedBox(
                      width: 90, // Reduced width
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Xem: ${cv["name"]}")),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.visibility,
                                size: 18,
                                color: Colors.indigo.shade400,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap:
                                () => _showEditDialog(cv, cvList.indexOf(cv)),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.blue.shade400,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap:
                                () =>
                                    _showDeleteConfirmation(cvList.indexOf(cv)),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Tags
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children:
                      (cv["tags"] as List<String>)
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredList.length,
      itemBuilder: (context, index) {
        final cv = _filteredList[index];
        final DateFormat formatter = DateFormat('dd/MM/yyyy');

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with document icon
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.picture_as_pdf,
                    size: 56,
                    color: Colors.red.shade700,
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cv["name"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            formatter.format(cv["lastModified"]),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.storage,
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cv["size"],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children:
                          (cv["tags"] as List<String>)
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Actions
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.visibility,
                        size: 20,
                        color: Colors.indigo.shade400,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Xem: ${cv["name"]}")),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.blue.shade400,
                      ),
                      onPressed: () => _showEditDialog(cv, cvList.indexOf(cv)),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        size: 20,
                        color: Colors.red.shade400,
                      ),
                      onPressed:
                          () => _showDeleteConfirmation(cvList.indexOf(cv)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
