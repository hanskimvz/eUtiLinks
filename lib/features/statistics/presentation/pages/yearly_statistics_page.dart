import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class YearlyStatisticsPage extends StatefulWidget {
  const YearlyStatisticsPage({super.key});

  @override
  State<YearlyStatisticsPage> createState() => _YearlyStatisticsPageState();
}

class _YearlyStatisticsPageState extends State<YearlyStatisticsPage> {
  int _selectedYear = DateTime.now().year;
  
  final List<Map<String, dynamic>> _yearlyData = [
    {
      'year': DateTime.now().year,
      'totalUsage': 458250.5,
      'averageMonthlyUsage': 38187.5,
      'peakMonth': 1, // 1월
      'peakUsage': 45525.3,
      'activeDevices': 100,
      'anomalies': 145,
      'monthlyUsage': [
        42000.5, 45525.3, 40200.8, 38500.2, 35800.6, 32500.4,
        30200.3, 31500.7, 33800.9, 36500.2, 38500.6, 42500.0
      ],
    },
    {
      'year': DateTime.now().year - 1,
      'totalUsage': 438180.2,
      'averageMonthlyUsage': 36515.0,
      'peakMonth': 12, // 12월
      'peakUsage': 43818.6,
      'activeDevices': 95,
      'anomalies': 132,
      'monthlyUsage': [
        40500.2, 42800.5, 39200.3, 37500.8, 34800.2, 31500.6,
        29200.4, 30500.3, 32800.7, 35500.9, 37500.3, 43818.6
      ],
    },
    {
      'year': DateTime.now().year - 2,
      'totalUsage': 425320.8,
      'averageMonthlyUsage': 35443.4,
      'peakMonth': 2, // 2월
      'peakUsage': 42532.4,
      'activeDevices': 90,
      'anomalies': 120,
      'monthlyUsage': [
        40000.3, 42532.4, 38200.5, 36500.7, 33800.9, 30500.2,
        28200.6, 29500.4, 31800.3, 34500.8, 36500.7, 42200.0
      ],
    },
  ];

  Map<String, dynamic>? get _selectedYearData {
    for (var data in _yearlyData) {
      if (data['year'] == _selectedYear) {
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
            '연간 현황',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // 년도 선택기
          Row(
            children: [
              const Text('년도 선택: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _selectedYear,
                items: List.generate(5, (index) => DateTime.now().year - index)
                    .map((year) => DropdownMenuItem<int>(
                          value: year,
                          child: Text('$year년'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedYear = value;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 통계 카드
          if (_selectedYearData != null) ...[
            _buildStatisticsCards(),
            const SizedBox(height: 24),
            _buildMonthlyUsageChart(),
            const SizedBox(height: 24),
            _buildYearlyComparisonChart(),
          ] else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('선택한 연도의 데이터가 없습니다.'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final data = _selectedYearData!;
    final numberFormat = NumberFormat('#,###');
    
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 2.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard('총 사용량', '${numberFormat.format(data['totalUsage'])} m³', Colors.blue[100]!),
        _buildStatCard('월평균 사용량', '${numberFormat.format(data['averageMonthlyUsage'])} m³', Colors.green[100]!),
        _buildStatCard('피크 월', '${data['peakMonth']}월', Colors.orange[100]!),
        _buildStatCard('피크 사용량', '${numberFormat.format(data['peakUsage'])} m³', Colors.red[100]!),
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

  Widget _buildMonthlyUsageChart() {
    final data = _selectedYearData!;
    final monthlyUsage = data['monthlyUsage'] as List<dynamic>;
    final maxUsage = monthlyUsage.reduce((a, b) => a > b ? a : b);
    final months = ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '월별 사용량',
          style: TextStyle(
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
              final numberFormat = NumberFormat('#,###');
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: height,
                        color: index == data['peakMonth'] - 1 
                            ? Colors.red 
                            : Colors.blue,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        months[index],
                        style: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        numberFormat.format(monthlyUsage[index]),
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

  Widget _buildYearlyComparisonChart() {
    final numberFormat = NumberFormat('#,###');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최근 3년 사용량 비교',
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _yearlyData.map((data) {
              final height = (data['totalUsage'] / 500000) * 150;
              
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 80,
                    height: height,
                    color: data['year'] == _selectedYear
                        ? Colors.blue
                        : Colors.blue[200],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${data['year']}년',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${numberFormat.format(data['totalUsage'])} m³',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
} 