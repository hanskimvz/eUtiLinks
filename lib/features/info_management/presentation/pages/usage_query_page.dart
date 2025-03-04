import 'package:flutter/material.dart';

class UsageQueryPage extends StatefulWidget {
  const UsageQueryPage({super.key});

  @override
  State<UsageQueryPage> createState() => _UsageQueryPageState();
}

class _UsageQueryPageState extends State<UsageQueryPage> {
  final TextEditingController _subscriberIdController = TextEditingController();
  String _selectedPeriod = '일별';
  final List<String> _periodOptions = ['일별', '월별', '연별'];
  
  // 임시 데이터
  final List<Map<String, dynamic>> _usageData = [
    {
      'id': 1,
      'subscriberId': 'SUB001',
      'subscriberName': '홍길동',
      'date': '2024-03-15',
      'month': '2024-03',
      'year': '2024',
      'usage': 12.5,
      'cost': 15000,
    },
    {
      'id': 2,
      'subscriberId': 'SUB001',
      'subscriberName': '홍길동',
      'date': '2024-03-14',
      'month': '2024-03',
      'year': '2024',
      'usage': 11.8,
      'cost': 14160,
    },
    {
      'id': 3,
      'subscriberId': 'SUB002',
      'subscriberName': '김철수',
      'date': '2024-03-15',
      'month': '2024-03',
      'year': '2024',
      'usage': 8.2,
      'cost': 9840,
    },
    {
      'id': 4,
      'subscriberId': 'SUB003',
      'subscriberName': '이영희',
      'date': '2024-03-15',
      'month': '2024-03',
      'year': '2024',
      'usage': 15.7,
      'cost': 18840,
    },
    {
      'id': 5,
      'subscriberId': 'SUB002',
      'subscriberName': '김철수',
      'date': '2024-03-14',
      'month': '2024-03',
      'year': '2024',
      'usage': 7.9,
      'cost': 9480,
    },
  ];
  
  List<Map<String, dynamic>> get _filteredData {
    return _usageData.where((data) {
      // 가입자 ID 필터링
      final subscriberId = _subscriberIdController.text.trim();
      if (subscriberId.isNotEmpty && 
          !data['subscriberId'].toLowerCase().contains(subscriberId.toLowerCase()) &&
          !data['subscriberName'].toLowerCase().contains(subscriberId.toLowerCase())) {
        return false;
      }
      
      return true;
    }).toList();
  }

  // 기간별 데이터 그룹화
  Map<String, double> _getGroupedData() {
    final Map<String, double> result = {};
    
    for (var data in _filteredData) {
      String key;
      
      switch (_selectedPeriod) {
        case '일별':
          key = data['date'];
          break;
        case '월별':
          key = data['month'];
          break;
        case '연별':
          key = data['year'];
          break;
        default:
          key = data['date'];
      }
      
      if (result.containsKey(key)) {
        result[key] = result[key]! + data['usage'];
      } else {
        result[key] = data['usage'];
      }
    }
    
    return result;
  }

  @override
  void dispose() {
    _subscriberIdController.dispose();
    super.dispose();
  }

  void _generateReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용량 보고서 생성'),
        content: const Text('선택한 기간의 사용량 보고서가 생성되었습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = _getGroupedData();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '사용량 조회',
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
                controller: _subscriberIdController,
                decoration: const InputDecoration(
                  labelText: '가입자 ID/이름',
                  hintText: '가입자 ID 또는 이름으로 검색',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: _selectedPeriod,
              items: _periodOptions.map((period) {
                return DropdownMenuItem<String>(
                  value: period,
                  child: Text(period),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPeriod = value;
                  });
                }
              },
              hint: const Text('기간 선택'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _generateReport,
              icon: const Icon(Icons.download),
              label: const Text('보고서 생성'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // 사용량 통계 카드
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_selectedPeriod 사용량 통계',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard(
                      '총 사용량',
                      '${_calculateTotalUsage().toStringAsFixed(2)} m³',
                      Icons.data_usage,
                      Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      '평균 사용량',
                      '${_calculateAverageUsage().toStringAsFixed(2)} m³',
                      Icons.show_chart,
                      Colors.green,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      '총 요금',
                      '${_calculateTotalCost().toStringAsFixed(0)}원',
                      Icons.attach_money,
                      Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // 사용량 그래프 (간단한 시각화)
        if (groupedData.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_selectedPeriod 사용량 그래프',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: groupedData.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 40,
                                height: entry.value * 10, // 높이를 사용량에 비례하게 설정
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                entry.key,
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${entry.value.toStringAsFixed(1)}m³',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        
        // 사용량 데이터 테이블
        Expanded(
          child: Card(
            child: _filteredData.isEmpty
                ? const Center(
                    child: Text('검색 결과가 없습니다.'),
                  )
                : SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('가입자 ID')),
                        DataColumn(label: Text('가입자 이름')),
                        DataColumn(label: Text('날짜')),
                        DataColumn(label: Text('사용량 (m³)')),
                        DataColumn(label: Text('요금 (원)')),
                      ],
                      rows: _filteredData.map((data) {
                        return DataRow(
                          cells: [
                            DataCell(Text(data['subscriberId'])),
                            DataCell(Text(data['subscriberName'])),
                            DataCell(Text(_getDisplayDate(data))),
                            DataCell(Text(data['usage'].toString())),
                            DataCell(Text('${data['cost']}원')),
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

  String _getDisplayDate(Map<String, dynamic> data) {
    switch (_selectedPeriod) {
      case '일별':
        return data['date'];
      case '월별':
        return data['month'];
      case '연별':
        return data['year'];
      default:
        return data['date'];
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(
            red: color.r.toDouble(),
            green: color.g.toDouble(),
            blue: color.b.toDouble(),
            alpha: 0.1 * 255,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(
            red: color.r.toDouble(),
            green: color.g.toDouble(),
            blue: color.b.toDouble(),
            alpha: 0.3 * 255,
          )),
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

  double _calculateTotalUsage() {
    if (_filteredData.isEmpty) return 0;
    
    double sum = 0;
    for (var data in _filteredData) {
      sum += data['usage'] as double;
    }
    
    return sum;
  }

  double _calculateAverageUsage() {
    if (_filteredData.isEmpty) return 0;
    
    return _calculateTotalUsage() / _filteredData.length;
  }

  double _calculateTotalCost() {
    if (_filteredData.isEmpty) return 0;
    
    double sum = 0;
    for (var data in _filteredData) {
      sum += data['cost'] as int;
    }
    
    return sum;
  }
} 