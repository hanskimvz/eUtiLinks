import 'package:flutter/material.dart';

class AnomalyQueryPage extends StatefulWidget {
  const AnomalyQueryPage({super.key});

  @override
  State<AnomalyQueryPage> createState() => _AnomalyQueryPageState();
}

class _AnomalyQueryPageState extends State<AnomalyQueryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedAnomalyType = '전체';
  String _selectedStatus = '전체';
  final List<String> _anomalyTypes = ['전체', '가스 누출', '비정상 사용량', '통신 오류', '센서 오류'];
  final List<String> _statusOptions = ['전체', '미처리', '처리중', '처리완료'];
  
  // 임시 데이터
  final List<Map<String, dynamic>> _anomalies = [
    {
      'id': 'ANO001',
      'deviceId': 'DEV001',
      'location': '서울시 강남구 삼성동 123-45',
      'subscriberName': '홍길동',
      'anomalyType': '가스 누출',
      'detectedAt': '2024-03-15 09:30:22',
      'status': '미처리',
      'description': '가스 누출 감지. 안전 점검 필요.',
      'severity': '높음',
    },
    {
      'id': 'ANO002',
      'deviceId': 'DEV002',
      'location': '서울시 서초구 서초동 456-78',
      'subscriberName': '김철수',
      'anomalyType': '비정상 사용량',
      'detectedAt': '2024-03-15 08:15:10',
      'status': '처리중',
      'description': '평소 사용량 대비 300% 이상 사용량 증가.',
      'severity': '중간',
    },
    {
      'id': 'ANO003',
      'deviceId': 'DEV003',
      'location': '서울시 송파구 잠실동 789-12',
      'subscriberName': '이영희',
      'anomalyType': '통신 오류',
      'detectedAt': '2024-03-14 17:45:33',
      'status': '처리완료',
      'description': '단말기 통신 오류. 재연결 필요.',
      'severity': '낮음',
    },
    {
      'id': 'ANO004',
      'deviceId': 'DEV004',
      'location': '서울시 강동구 천호동 345-67',
      'subscriberName': '박지민',
      'anomalyType': '센서 오류',
      'detectedAt': '2024-03-14 16:22:45',
      'status': '미처리',
      'description': '압력 센서 오작동. 센서 교체 필요.',
      'severity': '중간',
    },
    {
      'id': 'ANO005',
      'deviceId': 'DEV001',
      'location': '서울시 강남구 삼성동 123-45',
      'subscriberName': '홍길동',
      'anomalyType': '가스 누출',
      'detectedAt': '2024-03-13 11:10:18',
      'status': '처리완료',
      'description': '가스 누출 감지. 밸브 교체 완료.',
      'severity': '높음',
    },
  ];
  
  List<Map<String, dynamic>> get _filteredAnomalies {
    return _anomalies.where((anomaly) {
      // 이상 유형 필터링
      if (_selectedAnomalyType != '전체' && anomaly['anomalyType'] != _selectedAnomalyType) {
        return false;
      }
      
      // 상태 필터링
      if (_selectedStatus != '전체' && anomaly['status'] != _selectedStatus) {
        return false;
      }
      
      // 검색어 필터링
      final searchTerm = _searchController.text.toLowerCase();
      if (searchTerm.isEmpty) {
        return true;
      }
      
      return anomaly['id'].toLowerCase().contains(searchTerm) ||
          anomaly['deviceId'].toLowerCase().contains(searchTerm) ||
          anomaly['location'].toLowerCase().contains(searchTerm) ||
          anomaly['subscriberName'].toLowerCase().contains(searchTerm);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAnomalyDetails(Map<String, dynamic> anomaly) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('이상 검침 상세 정보: ${anomaly['id']}'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID', anomaly['id']),
              _buildDetailRow('단말기 ID', anomaly['deviceId']),
              _buildDetailRow('설치 위치', anomaly['location']),
              _buildDetailRow('가입자 이름', anomaly['subscriberName']),
              _buildDetailRow('이상 유형', anomaly['anomalyType']),
              _buildDetailRow('감지 시간', anomaly['detectedAt']),
              _buildDetailRow('상태', anomaly['status']),
              _buildDetailRow('심각도', anomaly['severity']),
              _buildDetailRow('설명', anomaly['description']),
              const SizedBox(height: 16),
              if (anomaly['status'] != '처리완료')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          anomaly['status'] = '처리중';
                        });
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('처리 시작'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          anomaly['status'] = '처리완료';
                        });
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('처리 완료'),
                    ),
                  ],
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

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case '높음':
        return Colors.red;
      case '중간':
        return Colors.orange;
      case '낮음':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '미처리':
        return Colors.red;
      case '처리중':
        return Colors.orange;
      case '처리완료':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이상 검침 조회/해제',
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
                  hintText: 'ID, 단말기, 위치, 가입자 이름으로 검색',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: _selectedAnomalyType,
              items: _anomalyTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedAnomalyType = value;
                  });
                }
              },
              hint: const Text('이상 유형'),
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
              hint: const Text('상태'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 통계 카드
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '이상 검침 통계',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard(
                      '총 이상 건수',
                      _filteredAnomalies.length.toString(),
                      Icons.error_outline,
                      Colors.red,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      '미처리',
                      _countByStatus('미처리').toString(),
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      '처리완료',
                      _countByStatus('처리완료').toString(),
                      Icons.check_circle_outline,
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // 이상 검침 목록 테이블
        Expanded(
          child: Card(
            child: _filteredAnomalies.isEmpty
                ? const Center(
                    child: Text('검색 결과가 없습니다.'),
                  )
                : SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('단말기 ID')),
                        DataColumn(label: Text('가입자')),
                        DataColumn(label: Text('이상 유형')),
                        DataColumn(label: Text('감지 시간')),
                        DataColumn(label: Text('심각도')),
                        DataColumn(label: Text('상태')),
                        DataColumn(label: Text('조치')),
                      ],
                      rows: _filteredAnomalies.map((anomaly) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(anomaly['id']),
                              onTap: () => _showAnomalyDetails(anomaly),
                            ),
                            DataCell(
                              Text(anomaly['deviceId']),
                              onTap: () => _showAnomalyDetails(anomaly),
                            ),
                            DataCell(
                              Text(anomaly['subscriberName']),
                              onTap: () => _showAnomalyDetails(anomaly),
                            ),
                            DataCell(
                              Text(anomaly['anomalyType']),
                              onTap: () => _showAnomalyDetails(anomaly),
                            ),
                            DataCell(
                              Text(anomaly['detectedAt']),
                              onTap: () => _showAnomalyDetails(anomaly),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getSeverityColor(anomaly['severity']),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(anomaly['severity']),
                                ],
                              ),
                              onTap: () => _showAnomalyDetails(anomaly),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(anomaly['status']).withValues(
                                    red: _getStatusColor(anomaly['status']).r.toDouble(),
                                    green: _getStatusColor(anomaly['status']).g.toDouble(),
                                    blue: _getStatusColor(anomaly['status']).b.toDouble(),
                                    alpha: 0.2 * 255,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _getStatusColor(anomaly['status']),
                                  ),
                                ),
                                child: Text(
                                  anomaly['status'],
                                  style: TextStyle(
                                    color: _getStatusColor(anomaly['status']),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              onTap: () => _showAnomalyDetails(anomaly),
                            ),
                            DataCell(
                              anomaly['status'] == '처리완료'
                                  ? const Text('완료됨')
                                  : TextButton(
                                      onPressed: () => _showAnomalyDetails(anomaly),
                                      child: const Text('상세/처리'),
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

  int _countByStatus(String status) {
    return _filteredAnomalies.where((anomaly) => anomaly['status'] == status).length;
  }
} 