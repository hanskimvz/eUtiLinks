import 'package:flutter/material.dart';

class DeviceQueryPage extends StatefulWidget {
  const DeviceQueryPage({super.key});

  @override
  State<DeviceQueryPage> createState() => _DeviceQueryPageState();
}

class _DeviceQueryPageState extends State<DeviceQueryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '전체';
  final List<String> _statusOptions = ['전체', '정상', '오류', '연결 끊김', '배터리 부족'];
  
  // 임시 데이터
  final List<Map<String, dynamic>> _devices = [
    {
      'id': 'DEV001',
      'location': '서울시 강남구 삼성동 123-45',
      'status': '정상',
      'lastUpdate': '2024-03-15 09:30:22',
      'battery': 85,
    },
    {
      'id': 'DEV002',
      'location': '서울시 서초구 서초동 456-78',
      'status': '오류',
      'lastUpdate': '2024-03-15 08:15:10',
      'battery': 62,
    },
    {
      'id': 'DEV003',
      'location': '서울시 송파구 잠실동 789-12',
      'status': '정상',
      'lastUpdate': '2024-03-15 09:45:33',
      'battery': 91,
    },
    {
      'id': 'DEV004',
      'location': '서울시 강동구 천호동 345-67',
      'status': '연결 끊김',
      'lastUpdate': '2024-03-14 17:22:45',
      'battery': 45,
    },
    {
      'id': 'DEV005',
      'location': '서울시 마포구 합정동 234-56',
      'status': '배터리 부족',
      'lastUpdate': '2024-03-15 07:10:18',
      'battery': 12,
    },
  ];
  
  List<Map<String, dynamic>> get _filteredDevices {
    return _devices.where((device) {
      // 상태 필터링
      if (_selectedStatus != '전체' && device['status'] != _selectedStatus) {
        return false;
      }
      
      // 검색어 필터링
      final searchTerm = _searchController.text.toLowerCase();
      if (searchTerm.isEmpty) {
        return true;
      }
      
      return device['id'].toLowerCase().contains(searchTerm) ||
          device['location'].toLowerCase().contains(searchTerm);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeviceDetails(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('단말기 상세 정보: ${device['id']}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID', device['id']),
              _buildDetailRow('설치 위치', device['location']),
              _buildDetailRow('상태', device['status']),
              _buildDetailRow('최종 업데이트', device['lastUpdate']),
              _buildDetailRow('배터리', '${device['battery']}%'),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: device['battery'] / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getBatteryColor(device['battery']),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '정상':
        return Colors.green;
      case '오류':
        return Colors.red;
      case '연결 끊김':
        return Colors.orange;
      case '배터리 부족':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Color _getBatteryColor(int batteryLevel) {
    if (batteryLevel > 60) {
      return Colors.green;
    } else if (batteryLevel > 20) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '단말기 조회',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        
        // 검색 및 필터 영역
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: '검색',
                  hintText: '단말기 ID 또는 위치로 검색',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: _selectedStatus,
              items: _statusOptions.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
              hint: const Text('상태 필터'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 단말기 목록 테이블
        Expanded(
          child: Card(
            child: _filteredDevices.isEmpty
                ? const Center(
                    child: Text('검색 결과가 없습니다.'),
                  )
                : SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('설치 위치')),
                        DataColumn(label: Text('상태')),
                        DataColumn(label: Text('최종 업데이트')),
                        DataColumn(label: Text('배터리')),
                      ],
                      rows: _filteredDevices.map((device) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(device['id']),
                              onTap: () => _showDeviceDetails(device),
                            ),
                            DataCell(
                              Text(device['location']),
                              onTap: () => _showDeviceDetails(device),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(device['status']),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(device['status']),
                                ],
                              ),
                              onTap: () => _showDeviceDetails(device),
                            ),
                            DataCell(
                              Text(device['lastUpdate']),
                              onTap: () => _showDeviceDetails(device),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: LinearProgressIndicator(
                                      value: device['battery'] / 100,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getBatteryColor(device['battery']),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${device['battery']}%'),
                                ],
                              ),
                              onTap: () => _showDeviceDetails(device),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
} 