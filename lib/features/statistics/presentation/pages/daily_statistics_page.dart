import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyStatisticsPage extends StatefulWidget {
  const DailyStatisticsPage({super.key});

  @override
  State<DailyStatisticsPage> createState() => _DailyStatisticsPageState();
}

class _DailyStatisticsPageState extends State<DailyStatisticsPage> {
  DateTime _selectedDate = DateTime.now();
  final List<Map<String, dynamic>> _dailyData = [
    {
      'date': DateTime.now().subtract(const Duration(days: 0)),
      'totalUsage': 1250.5,
      'averageUsage': 12.5,
      'peakHour': 18,
      'peakUsage': 125.3,
      'activeDevices': 100,
      'anomalies': 2,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'totalUsage': 1180.2,
      'averageUsage': 11.8,
      'peakHour': 19,
      'peakUsage': 118.6,
      'activeDevices': 100,
      'anomalies': 1,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'totalUsage': 1320.8,
      'averageUsage': 13.2,
      'peakHour': 17,
      'peakUsage': 132.4,
      'activeDevices': 100,
      'anomalies': 3,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'totalUsage': 1150.3,
      'averageUsage': 11.5,
      'peakHour': 20,
      'peakUsage': 115.8,
      'activeDevices': 100,
      'anomalies': 0,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'totalUsage': 1280.6,
      'averageUsage': 12.8,
      'peakHour': 18,
      'peakUsage': 128.5,
      'activeDevices': 100,
      'anomalies': 2,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'totalUsage': 1210.4,
      'averageUsage': 12.1,
      'peakHour': 19,
      'peakUsage': 121.7,
      'activeDevices': 100,
      'anomalies': 1,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 6)),
      'totalUsage': 1190.9,
      'averageUsage': 11.9,
      'peakHour': 18,
      'peakUsage': 119.5,
      'activeDevices': 100,
      'anomalies': 2,
    },
  ];

  Map<String, dynamic>? get _selectedDayData {
    final formattedSelectedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    for (var data in _dailyData) {
      final formattedDataDate = DateFormat('yyyy-MM-dd').format(data['date'] as DateTime);
      if (formattedSelectedDate == formattedDataDate) {
        return data;
      }
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '일일 현황',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // 날짜 선택기
          Row(
            children: [
              const Text('날짜 선택: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 통계 카드
          if (_selectedDayData != null) ...[
            _buildStatisticsCards(),
            const SizedBox(height: 24),
            _buildHourlyUsageChart(),
          ] else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('선택한 날짜의 데이터가 없습니다.'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final data = _selectedDayData!;
    
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 2.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard('총 사용량', '${data['totalUsage']} m³', Colors.blue[100]!),
        _buildStatCard('평균 사용량', '${data['averageUsage']} m³', Colors.green[100]!),
        _buildStatCard('피크 시간', '${data['peakHour']}시', Colors.orange[100]!),
        _buildStatCard('피크 사용량', '${data['peakUsage']} m³', Colors.red[100]!),
        _buildStatCard('활성 단말기', '${data['activeDevices']}대', Colors.purple[100]!),
        _buildStatCard('이상 발생', '${data['anomalies']}건', Colors.amber[100]!),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      color: color,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyUsageChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '시간대별 사용량',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(24, (index) {
              // 시간대별 사용량을 임의로 생성 (실제로는 API에서 가져와야 함)
              final height = 20 + (index % 3 == 0 ? 100 : 50) * (index / 24);
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: height,
                        color: index == _selectedDayData!['peakHour'] 
                            ? Colors.red 
                            : Colors.blue,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$index',
                        style: const TextStyle(fontSize: 10),
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
} 