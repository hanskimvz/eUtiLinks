import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

class SubscriberStatisticsPage extends StatefulWidget {
  const SubscriberStatisticsPage({super.key});

  @override
  State<SubscriberStatisticsPage> createState() => _SubscriberStatisticsPageState();
}

class _SubscriberStatisticsPageState extends State<SubscriberStatisticsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  String _selectedPeriod = '월간';
  final List<String> _periods = ['일간', '월간', '연간'];
  
  final List<Map<String, dynamic>> _subscriberData = [
    {
      'id': 'SUB001',
      'name': '홍길동',
      'address': '서울시 강남구 테헤란로 123',
      'deviceId': 'DEV001',
      'totalUsage': 1250.5,
      'averageUsage': 41.7,
      'lastMonthUsage': 1180.2,
      'usageChange': 5.9,
      'anomalies': 2,
      'monthlyUsage': [
        1180.2, 1250.5, 1150.3, 1100.8, 980.6, 850.4,
        800.3, 820.7, 900.9, 1050.2, 1150.6, 1200.0
      ],
    },
    {
      'id': 'SUB002',
      'name': '김철수',
      'address': '서울시 서초구 서초대로 456',
      'deviceId': 'DEV002',
      'totalUsage': 980.3,
      'averageUsage': 32.7,
      'lastMonthUsage': 950.8,
      'usageChange': 3.1,
      'anomalies': 0,
      'monthlyUsage': [
        950.8, 980.3, 920.5, 880.2, 820.6, 750.4,
        720.3, 740.7, 800.9, 850.2, 900.6, 930.0
      ],
    },
    {
      'id': 'SUB003',
      'name': '이영희',
      'address': '서울시 송파구 올림픽로 789',
      'deviceId': 'DEV003',
      'totalUsage': 1520.8,
      'averageUsage': 50.7,
      'lastMonthUsage': 1480.5,
      'usageChange': 2.7,
      'anomalies': 1,
      'monthlyUsage': [
        1480.5, 1520.8, 1450.3, 1400.8, 1280.6, 1150.4,
        1100.3, 1120.7, 1200.9, 1350.2, 1450.6, 1500.0
      ],
    },
    {
      'id': 'SUB004',
      'name': '박민수',
      'address': '서울시 마포구 마포대로 321',
      'deviceId': 'DEV004',
      'totalUsage': 850.2,
      'averageUsage': 28.3,
      'lastMonthUsage': 820.6,
      'usageChange': 3.6,
      'anomalies': 0,
      'monthlyUsage': [
        820.6, 850.2, 800.5, 780.2, 720.6, 650.4,
        620.3, 640.7, 700.9, 750.2, 800.6, 830.0
      ],
    },
    {
      'id': 'SUB005',
      'name': '정수진',
      'address': '서울시 강동구 천호대로 654',
      'deviceId': 'DEV005',
      'totalUsage': 1100.5,
      'averageUsage': 36.7,
      'lastMonthUsage': 1050.8,
      'usageChange': 4.7,
      'anomalies': 1,
      'monthlyUsage': [
        1050.8, 1100.5, 1050.3, 1000.8, 920.6, 850.4,
        800.3, 820.7, 880.9, 950.2, 1020.6, 1080.0
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredSubscribers {
    if (_searchTerm.isEmpty) {
      return _subscriberData;
    }
    
    return _subscriberData.where((subscriber) {
      return subscriber['name'].toString().contains(_searchTerm) ||
             subscriber['id'].toString().contains(_searchTerm) ||
             subscriber['address'].toString().contains(_searchTerm) ||
             subscriber['deviceId'].toString().contains(_searchTerm);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '가입자별 현황',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // 검색 및 필터
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: '가입자 검색',
                    hintText: '이름, ID, 주소 또는 단말기 ID로 검색',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedPeriod,
                items: _periods.map((period) => DropdownMenuItem<String>(
                  value: period,
                  child: Text(period),
                )).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPeriod = value;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 가입자 통계 테이블
          Expanded(
            child: _filteredSubscribers.isEmpty
                ? const Center(child: Text('검색 결과가 없습니다.'))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildSubscriberTable(),
                        const SizedBox(height: 24),
                        if (_filteredSubscribers.length == 1)
                          _buildDetailedSubscriberStats(_filteredSubscribers.first),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriberTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('이름')),
          DataColumn(label: Text('주소')),
          DataColumn(label: Text('단말기 ID')),
          DataColumn(label: Text('총 사용량 (m³)')),
          DataColumn(label: Text('평균 사용량 (m³)')),
          DataColumn(label: Text('전월 대비 변화 (%)')),
          DataColumn(label: Text('이상 발생 (건)')),
          DataColumn(label: Text('상세 보기')),
        ],
        rows: _filteredSubscribers.map((subscriber) {
          final usageChange = subscriber['usageChange'] as double;
          final isIncrease = usageChange > 0;
          
          return DataRow(
            cells: [
              DataCell(Text(subscriber['id'])),
              DataCell(Text(subscriber['name'])),
              DataCell(Text(subscriber['address'])),
              DataCell(Text(subscriber['deviceId'])),
              DataCell(Text('${subscriber['totalUsage']}')),
              DataCell(Text('${subscriber['averageUsage']}')),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isIncrease ? Colors.red : Colors.green,
                      size: 16,
                    ),
                    Text(
                      '${usageChange.abs()}%',
                      style: TextStyle(
                        color: isIncrease ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Text(
                  '${subscriber['anomalies']}',
                  style: TextStyle(
                    color: subscriber['anomalies'] > 0 ? Colors.red : Colors.black,
                    fontWeight: subscriber['anomalies'] > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () {
                    _showSubscriberDetails(subscriber);
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailedSubscriberStats(Map<String, dynamic> subscriber) {
    final monthlyUsage = subscriber['monthlyUsage'] as List<dynamic>;
    final maxUsage = monthlyUsage.reduce((a, b) => a > b ? a : b);
    final months = ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${subscriber['name']}님의 월별 사용량',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(12, (index) {
              final height = (monthlyUsage[index] / maxUsage) * 180;
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: height,
                        color: index == DateTime.now().month - 1 
                            ? Colors.blue 
                            : Colors.blue[200],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        months[index],
                        style: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${monthlyUsage[index]}',
                        style: const TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  void _showSubscriberDetails(Map<String, dynamic> subscriber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${subscriber['name']}님의 상세 정보'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID', subscriber['id']),
                _buildDetailRow('이름', subscriber['name']),
                _buildDetailRow('주소', subscriber['address']),
                _buildDetailRow('단말기 ID', subscriber['deviceId']),
                _buildDetailRow('총 사용량', '${subscriber['totalUsage']} m³'),
                _buildDetailRow('평균 사용량', '${subscriber['averageUsage']} m³'),
                _buildDetailRow('전월 사용량', '${subscriber['lastMonthUsage']} m³'),
                _buildDetailRow('전월 대비 변화', '${subscriber['usageChange']}%'),
                _buildDetailRow('이상 발생', '${subscriber['anomalies']}건'),
                const SizedBox(height: 16),
                _buildDetailedSubscriberStats(subscriber),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
} 