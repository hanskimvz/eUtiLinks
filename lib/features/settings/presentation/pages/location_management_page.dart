import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

class LocationManagementPage extends StatefulWidget {
  const LocationManagementPage({super.key});

  @override
  State<LocationManagementPage> createState() => _LocationManagementPageState();
}

class _LocationManagementPageState extends State<LocationManagementPage> {
  final List<Map<String, dynamic>> _locations = [
    {
      'id': 1,
      'name': '서울 본사',
      'address': '서울특별시 강남구 테헤란로 123',
      'type': '본사',
      'deviceCount': 15,
      'subscriberCount': 120,
    },
    {
      'id': 2,
      'name': '부산 지사',
      'address': '부산광역시 해운대구 센텀중앙로 55',
      'type': '지사',
      'deviceCount': 8,
      'subscriberCount': 65,
    },
    {
      'id': 3,
      'name': '대전 지사',
      'address': '대전광역시 유성구 대학로 99',
      'type': '지사',
      'deviceCount': 5,
      'subscriberCount': 42,
    },
    {
      'id': 4,
      'name': '광주 지점',
      'address': '광주광역시 서구 상무중앙로 76',
      'type': '지점',
      'deviceCount': 3,
      'subscriberCount': 28,
    },
  ];

  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredLocations = [];
  int? _selectedLocationId;

  @override
  void initState() {
    super.initState();
    _filteredLocations = List.from(_locations);
    if (_locations.isNotEmpty) {
      _selectedLocationId = _locations[0]['id'];
    }
  }

  void _filterLocations(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredLocations = List.from(_locations);
      } else {
        _filteredLocations =
            _locations.where((location) {
              return location['name'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  location['address'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  location['type'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  );
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations!.locationManagement,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.locationManagementDescription,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          // 검색 및 필터링
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: '위치 검색',
                    hintText: '이름, 주소, 유형 등으로 검색',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _filterLocations,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _showAddLocationDialog();
                },
                icon: const Icon(Icons.add_location_alt),
                label: const Text('위치 추가'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brandColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 위치 목록 및 상세 정보
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 위치 목록
                Expanded(
                  flex: 1,
                  child: Card(
                    child: ListView.separated(
                      itemCount: _filteredLocations.length,
                      separatorBuilder:
                          (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final location = _filteredLocations[index];
                        final isSelected =
                            location['id'] == _selectedLocationId;

                        return ListTile(
                          title: Text(location['name']),
                          subtitle: Text(location['type']),
                          selected: isSelected,
                          selectedTileColor: Colors.grey[200],
                          selectedColor: AppTheme.brandColor,
                          onTap: () {
                            setState(() {
                              _selectedLocationId = location['id'];
                            });
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                onPressed:
                                    () => _showEditLocationDialog(location),
                                tooltip: '수정',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed:
                                    () => _showDeleteLocationDialog(location),
                                tooltip: '삭제',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 위치 상세 정보
                Expanded(flex: 2, child: _buildLocationDetails()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDetails() {
    if (_selectedLocationId == null) {
      return const Card(child: Center(child: Text('위치를 선택하세요')));
    }

    final selectedLocation = _locations.firstWhere(
      (location) => location['id'] == _selectedLocationId,
      orElse: () => _locations[0],
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedLocation['name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.brandColor.withValues(
                      red: AppTheme.brandColor.r,
                      green: AppTheme.brandColor.g,
                      blue: AppTheme.brandColor.b,
                      alpha: 0.1 * 255,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    selectedLocation['type'],
                    style: TextStyle(
                      color: AppTheme.brandColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow('주소', selectedLocation['address']),
            const SizedBox(height: 16),
            _buildDetailRow('단말기 수', '${selectedLocation['deviceCount']}대'),
            const SizedBox(height: 16),
            _buildDetailRow('가입자 수', '${selectedLocation['subscriberCount']}명'),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              '위치 통계',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildLocationStats(selectedLocation)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  Widget _buildLocationStats(Map<String, dynamic> location) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '단말기 상태',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '정상: ${(location['deviceCount'] * 0.9).round()}대',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '이상: ${(location['deviceCount'] * 0.1).round()}대',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '가입자 상태',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '활성: ${(location['subscriberCount'] * 0.95).round()}명',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '비활성: ${(location['subscriberCount'] * 0.05).round()}명',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            color: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '최근 이벤트',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildEventItem(
                          '단말기 추가',
                          '2023-03-01 14:30',
                          Colors.green,
                        ),
                        _buildEventItem(
                          '가입자 변경',
                          '2023-03-01 11:15',
                          Colors.blue,
                        ),
                        _buildEventItem(
                          '이상 감지',
                          '2023-02-28 09:45',
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventItem(String title, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  void _showAddLocationDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    String selectedType = '지점';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('위치 추가'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '위치 이름',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: '주소',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '유형',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(value: '본사', child: Text('본사')),
                      DropdownMenuItem(value: '지사', child: Text('지사')),
                      DropdownMenuItem(value: '지점', child: Text('지점')),
                      DropdownMenuItem(value: '영업소', child: Text('영업소')),
                    ],
                    onChanged: (value) {
                      selectedType = value!;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      addressController.text.isNotEmpty) {
                    setState(() {
                      final newId =
                          _locations
                              .map((l) => l['id'] as int)
                              .reduce((a, b) => a > b ? a : b) +
                          1;
                      final newLocation = {
                        'id': newId,
                        'name': nameController.text,
                        'address': addressController.text,
                        'type': selectedType,
                        'deviceCount': 0,
                        'subscriberCount': 0,
                      };
                      _locations.add(newLocation);
                      _filterLocations(_searchQuery);
                      _selectedLocationId = newId;
                    });
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('위치가 추가되었습니다.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text('추가'),
              ),
            ],
          ),
    );
  }

  void _showEditLocationDialog(Map<String, dynamic> location) {
    final nameController = TextEditingController(text: location['name']);
    final addressController = TextEditingController(text: location['address']);
    String selectedType = location['type'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('위치 수정'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '위치 이름',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: '주소',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '유형',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(value: '본사', child: Text('본사')),
                      DropdownMenuItem(value: '지사', child: Text('지사')),
                      DropdownMenuItem(value: '지점', child: Text('지점')),
                      DropdownMenuItem(value: '영업소', child: Text('영업소')),
                    ],
                    onChanged: (value) {
                      selectedType = value!;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      addressController.text.isNotEmpty) {
                    setState(() {
                      final index = _locations.indexWhere(
                        (l) => l['id'] == location['id'],
                      );
                      if (index != -1) {
                        _locations[index]['name'] = nameController.text;
                        _locations[index]['address'] = addressController.text;
                        _locations[index]['type'] = selectedType;
                        _filterLocations(_searchQuery);
                      }
                    });
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('위치 정보가 수정되었습니다.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text('저장'),
              ),
            ],
          ),
    );
  }

  void _showDeleteLocationDialog(Map<String, dynamic> location) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('위치 삭제'),
            content: Text('${location['name']} 위치를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _locations.removeWhere((l) => l['id'] == location['id']);
                    _filterLocations(_searchQuery);
                    if (_locations.isNotEmpty) {
                      _selectedLocationId = _locations[0]['id'];
                    } else {
                      _selectedLocationId = null;
                    }
                  });
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('위치가 삭제되었습니다.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
