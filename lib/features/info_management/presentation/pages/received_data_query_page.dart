import 'package:flutter/material.dart';

class ReceivedDataQueryPage extends StatefulWidget {
  const ReceivedDataQueryPage({super.key});

  @override
  State<ReceivedDataQueryPage> createState() => _ReceivedDataQueryPageState();
}

class _ReceivedDataQueryPageState extends State<ReceivedDataQueryPage> {
  final TextEditingController _deviceIdController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  
  // 임시 데이터
  final List<Map<String, dynamic>> _receivedData = [
    {
      'id': 1,
      'deviceId': 'DEV001',
      'timestamp': '2024-03-15 09:30:22',
      'gasUsage': 12.5,
      'pressure': 2.3,
      'temperature': 22.1,
      'status': '정상',
    },
    {
      'id': 2,
      'deviceId': 'DEV001',
      'timestamp': '2024-03-15 08:30:15',
      'gasUsage': 11.8,
      'pressure': 2.2,
      'temperature': 21.8,
      'status': '정상',
    },
    {
      'id': 3,
      'deviceId': 'DEV002',
      'timestamp': '2024-03-15 09:15:33',
      'gasUsage': 8.2,
      'pressure': 2.1,
      'temperature': 23.4,
      'status': '정상',
    },
    {
      'id': 4,
      'deviceId': 'DEV003',
      'timestamp': '2024-03-15 09:45:10',
      'gasUsage': 15.7,
      'pressure': 2.4,
      'temperature': 22.8,
      'status': '정상',
    },
    {
      'id': 5,
      'deviceId': 'DEV002',
      'timestamp': '2024-03-15 08:15:45',
      'gasUsage': 7.9,
      'pressure': 2.0,
      'temperature': 23.1,
      'status': '정상',
    },
  ];
  
  List<Map<String, dynamic>> get _filteredData {
    return _receivedData.where((data) {
      // 단말기 ID 필터링
      final deviceId = _deviceIdController.text.trim();
      if (deviceId.isNotEmpty && !data['deviceId'].contains(deviceId)) {
        return false;
      }
      
      // 날짜 필터링 (임시로 현재 날짜만 표시)
      final dataDate = data['timestamp'].split(' ')[0];
      final selectedDateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      
      return dataDate.contains(selectedDateStr);
    }).toList();
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '수신데이터 조회',
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
                controller: _deviceIdController,
                decoration: const InputDecoration(
                  labelText: '단말기 ID',
                  hintText: '단말기 ID로 검색',
                  prefixIcon: Icon(Icons.devices),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: () => _selectDate(context),
              icon: const Icon(Icons.calendar_today),
              label: Text(
                '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 데이터 통계 카드
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '데이터 통계',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard(
                      '총 수신 데이터',
                      _filteredData.length.toString(),
                      Icons.data_usage,
                      Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      '평균 가스 사용량',
                      '${_calculateAverageGasUsage().toStringAsFixed(2)} m³',
                      Icons.gas_meter,
                      Colors.green,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      '평균 온도',
                      '${_calculateAverageTemperature().toStringAsFixed(1)} °C',
                      Icons.thermostat,
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // 수신 데이터 테이블
        Expanded(
          child: Card(
            child: _filteredData.isEmpty
                ? const Center(
                    child: Text('검색 결과가 없습니다.'),
                  )
                : SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('단말기 ID')),
                        DataColumn(label: Text('타임스탬프')),
                        DataColumn(label: Text('가스 사용량 (m³)')),
                        DataColumn(label: Text('압력 (bar)')),
                        DataColumn(label: Text('온도 (°C)')),
                        DataColumn(label: Text('상태')),
                      ],
                      rows: _filteredData.map((data) {
                        return DataRow(
                          cells: [
                            DataCell(Text(data['id'].toString())),
                            DataCell(Text(data['deviceId'])),
                            DataCell(Text(data['timestamp'])),
                            DataCell(Text(data['gasUsage'].toString())),
                            DataCell(Text(data['pressure'].toString())),
                            DataCell(Text(data['temperature'].toString())),
                            DataCell(
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: data['status'] == '정상' ? Colors.green : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(data['status']),
                                ],
                              ),
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(red: color.r, green: color.g, blue: color.b, alpha: 0.1 * 255),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(red: color.r, green: color.g, blue: color.b, alpha: 0.3 * 255)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 36,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateAverageGasUsage() {
    if (_filteredData.isEmpty) return 0;
    
    double sum = 0;
    for (var data in _filteredData) {
      sum += data['gasUsage'] as double;
    }
    
    return sum / _filteredData.length;
  }

  double _calculateAverageTemperature() {
    if (_filteredData.isEmpty) return 0;
    
    double sum = 0;
    for (var data in _filteredData) {
      sum += data['temperature'] as double;
    }
    
    return sum / _filteredData.length;
  }
} 