import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyStatisticsPage extends StatefulWidget {
  const MonthlyStatisticsPage({super.key});

  @override
  State<MonthlyStatisticsPage> createState() => _MonthlyStatisticsPageState();
}

class _MonthlyStatisticsPageState extends State<MonthlyStatisticsPage> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  final List<Map<String, dynamic>> _monthlyData = [
    {
      'year': DateTime.now().year,
      'month': DateTime.now().month,
      'totalUsage': 38250.5,
      'averageUsage': 1234.5,
      'peakDay': 15,
      'peakUsage': 1525.3,
      'activeDevices': 100,
      'anomalies': 12,
      'dailyUsage': List.generate(30, (index) => 1000 + (index % 7) * 100.0),
    },
    {
      'year': DateTime.now().year,
      'month': DateTime.now().month - 1 > 0 ? DateTime.now().month - 1 : 12,
      'totalUsage': 36180.2,
      'averageUsage': 1206.0,
      'peakDay': 10,
      'peakUsage': 1418.6,
      'activeDevices': 100,
      'anomalies': 8,
      'dailyUsage': List.generate(30, (index) => 950 + (index % 5) * 120.0),
    },
    {
      'year': DateTime.now().year,
      'month': DateTime.now().month - 2 > 0 ? DateTime.now().month - 2 : 12,
      'totalUsage': 35320.8,
      'averageUsage': 1177.4,
      'peakDay': 22,
      'peakUsage': 1332.4,
      'activeDevices': 98,
      'anomalies': 10,
      'dailyUsage': List.generate(30, (index) => 900 + (index % 6) * 110.0),
    },
  ];

  Map<String, dynamic>? get _selectedMonthData {
    for (var data in _monthlyData) {
      if (data['year'] == _selectedYear && data['month'] == _selectedMonth) {
        return data;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '월별 현황',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 년월 선택기
            Row(
              children: [
                const Text(
                  '년월 선택: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _selectedYear,
                  items:
                      List.generate(5, (index) => DateTime.now().year - index)
                          .map(
                            (year) => DropdownMenuItem<int>(
                              value: year,
                              child: Text('$year년'),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedYear = value;
                      });
                    }
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  value: _selectedMonth,
                  items:
                      List.generate(12, (index) => index + 1)
                          .map(
                            (month) => DropdownMenuItem<int>(
                              value: month,
                              child: Text('$month월'),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMonth = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 통계 카드
            if (_selectedMonthData != null) ...[
              _buildStatisticsCards(),
              const SizedBox(height: 24),
              _buildDailyUsageChart(),
              const SizedBox(height: 24),
              _buildMonthlyComparisonChart(),
            ] else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('선택한 월의 데이터가 없습니다.'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final data = _selectedMonthData!;

    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 2.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard('총 사용량', '${data['totalUsage']} m³', Colors.blue[100]!),
        _buildStatCard(
          '평균 사용량',
          '${data['averageUsage']} m³',
          Colors.green[100]!,
        ),
        _buildStatCard('피크 일자', '${data['peakDay']}일', Colors.orange[100]!),
        _buildStatCard('피크 사용량', '${data['peakUsage']} m³', Colors.red[100]!),
        _buildStatCard(
          '활성 단말기',
          '${data['activeDevices']}대',
          Colors.purple[100]!,
        ),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyUsageChart() {
    final data = _selectedMonthData!;
    final dailyUsage = data['dailyUsage'] as List<dynamic>;
    final maxUsage = dailyUsage
        .map((value) => value as double)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '일별 사용량',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            children: List.generate(dailyUsage.length, (index) {
              final height = (dailyUsage[index] / maxUsage) * 150;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: height,
                        color:
                            index == data['peakDay'] - 1
                                ? Colors.red
                                : Colors.blue,
                      ),
                      const SizedBox(height: 4),
                      Text('${index + 1}', style: const TextStyle(fontSize: 8)),
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

  Widget _buildMonthlyComparisonChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최근 3개월 사용량 비교',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            children:
                _monthlyData.map((data) {
                  final height = (data['totalUsage'] / 40000) * 150;
                  final monthName = DateFormat(
                    'yyyy년 MM월',
                  ).format(DateTime(data['year'], data['month'], 1));

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 80,
                        height: height,
                        color:
                            data['year'] == _selectedYear &&
                                    data['month'] == _selectedMonth
                                ? Colors.blue
                                : Colors.blue[200],
                      ),
                      const SizedBox(height: 8),
                      Text(monthName, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        '${data['totalUsage']} m³',
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
