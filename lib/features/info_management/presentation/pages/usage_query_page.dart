import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/auth_service.dart';

class UsageQueryPage extends StatefulWidget {
  const UsageQueryPage({super.key});

  @override
  State<UsageQueryPage> createState() => _UsageQueryPageState();
}

class _UsageQueryPageState extends State<UsageQueryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedPeriod = '일별';
  final List<String> _periodOptions = ['일별', '월별', '연별'];

  // 정렬 상태를 관리하기 위한 변수 추가
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  final int _rowsPerPage = 10;
  int _currentPage = 0;

  // 데이터 상태 관리
  List<Map<String, dynamic>> _usageData = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await AuthService.initAuthData();
    _loadUsageData();
  }

  Future<void> _loadUsageData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final tableHead = [
        'customer_name',
        'customer_no',
        'addr_prov',
        'addr_city',
        'addr_dist',
        'addr_detail',
        'addr_apt',
        'meter_id',
        'prev_count',
        'current_count',
        'read_date',
        'usage',
        'cost',
      ];

      final response = await http.post(
        Uri.parse('${ApiConstants.serverUrl}/api/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'page': 'usage_info',
          'format': 'json',
          'fields': tableHead,
          ...AuthService.authData,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['code'] == 200) {
          final List<dynamic> usageJson = jsonResponse['data'];

          // 데이터 변환 및 ID 추가
          final List<Map<String, dynamic>> formattedData = [];
          for (int i = 0; i < usageJson.length; i++) {
            final item = usageJson[i];
            formattedData.add({
              'id': i + 1,
              'customer_name': item['customer_name'] ?? '',
              'customer_no': item['customer_no'] ?? '',
              'address': _formatAddress(
                item['addr_prov'],
                item['addr_city'],
                item['addr_dist'],
                item['addr_detail'],
                item['addr_apt'],
              ),
              'meter_id': item['meter_id'] ?? '',
              'prev_count': item['prev_count'] ?? 0,
              'current_count': item['current_count'] ?? 0,
              'read_date': item['read_date'] ?? '',
              'usage': item['usage'] ?? 0.0,
              'cost': item['cost'] ?? 0,
              // 원본 데이터도 저장
              'raw_data': item,
            });
          }

          setState(() {
            _usageData = formattedData;
            _isLoading = false;
          });
        } else {
          throw Exception('API 응답 오류: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;

        // 테스트용 임시 데이터 (API 연동 실패 시)
        _usageData = [
          {
            'id': 1,
            'customer_name': '홍길동',
            'customer_no': 'C001',
            'address': '서울시 강남구 테헤란로 123',
            'meter_id': 'M001',
            'prev_count': 1250,
            'current_count': 1375,
            'read_date': '2024-03-15',
            'usage': 125.0,
            'cost': 15000,
          },
          {
            'id': 2,
            'customer_name': '김철수',
            'customer_no': 'C002',
            'address': '서울시 서초구 서초대로 456',
            'meter_id': 'M002',
            'prev_count': 980,
            'current_count': 1062,
            'read_date': '2024-03-15',
            'usage': 82.0,
            'cost': 9840,
          },
          {
            'id': 3,
            'customer_name': '이영희',
            'customer_no': 'C003',
            'address': '서울시 송파구 올림픽로 789',
            'meter_id': 'M003',
            'prev_count': 2340,
            'current_count': 2497,
            'read_date': '2024-03-15',
            'usage': 157.0,
            'cost': 18840,
          },
          {
            'id': 4,
            'customer_name': '박민수',
            'customer_no': 'C004',
            'address': '서울시 강동구 천호대로 101',
            'meter_id': 'M004',
            'prev_count': 1780,
            'current_count': 1895,
            'read_date': '2024-03-15',
            'usage': 115.0,
            'cost': 13800,
          },
          {
            'id': 5,
            'customer_name': '최지은',
            'customer_no': 'C005',
            'address': '서울시 마포구 월드컵로 202',
            'meter_id': 'M005',
            'prev_count': 3120,
            'current_count': 3255,
            'read_date': '2024-03-15',
            'usage': 135.0,
            'cost': 16200,
          },
        ];
      });
    }
  }

  String _formatAddress(
    String? prov,
    String? city,
    String? dist,
    String? detail,
    String? apt,
  ) {
    return [
      prov,
      city,
      dist,
      detail,
      apt,
    ].where((part) => part != null && part.isNotEmpty).join(' ');
  }

  List<Map<String, dynamic>> get _filteredData {
    return _usageData.where((data) {
      // 검색어 필터링
      final searchText = _searchController.text.trim().toLowerCase();
      if (searchText.isNotEmpty) {
        return data['customer_name'].toLowerCase().contains(searchText) ||
            data['customer_no'].toLowerCase().contains(searchText) ||
            data['address'].toLowerCase().contains(searchText) ||
            data['meter_id'].toLowerCase().contains(searchText);
      }

      return true;
    }).toList();
  }

  // 페이지네이션을 위한 데이터 가져오기
  List<Map<String, dynamic>> _getPaginatedData() {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage;

    if (startIndex >= _filteredData.length) {
      return [];
    }

    if (endIndex > _filteredData.length) {
      return _filteredData.sublist(startIndex);
    }

    return _filteredData.sublist(startIndex, endIndex);
  }

  // 정렬 함수
  void _sort<T>(
    Comparable<T> Function(Map<String, dynamic> data) getField,
    int columnIndex,
    bool ascending,
  ) {
    _filteredData.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);

      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  // 기간별 데이터 그룹화
  Map<String, double> _getGroupedData() {
    final Map<String, double> result = {};

    for (var data in _filteredData) {
      String key;

      switch (_selectedPeriod) {
        case '일별':
          key = data['read_date'];
          break;
        case '월별':
          final date = DateTime.parse(data['read_date']);
          key = DateFormat('yyyy-MM').format(date);
          break;
        case '연별':
          final date = DateTime.parse(data['read_date']);
          key = DateFormat('yyyy').format(date);
          break;
        default:
          key = data['read_date'];
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
    _searchController.dispose();
    super.dispose();
  }

  void _generateReport() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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

  void _showUsageDetails(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${data['customer_name']}님의 사용량 상세'),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('고객명', data['customer_name']),
                  _buildDetailRow('고객번호', data['customer_no']),
                  _buildDetailRow('주소', data['address']),
                  _buildDetailRow('미터기 ID', data['meter_id']),
                  _buildDetailRow('전월검침값', data['prev_count'].toString()),
                  _buildDetailRow('현재검침값', data['current_count'].toString()),
                  _buildDetailRow('검침일', data['read_date']),
                  _buildDetailRow('사용량', '${data['usage']} m³'),
                  _buildDetailRow(
                    '요금',
                    '${NumberFormat('#,###').format(data['cost'])}원',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = _getGroupedData();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '사용량 조회',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                      hintText: '고객명, 고객번호, 주소, 미터기ID로 검색',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  items:
                      _periodOptions.map((period) {
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _loadUsageData,
                  icon: const Icon(Icons.refresh),
                  tooltip: '새로고침',
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
                          '${NumberFormat('#,###').format(_calculateTotalCost())}원',
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
                          children:
                              groupedData.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 40,
                                        height:
                                            entry.value *
                                            10, // 높이를 사용량에 비례하게 설정
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    _isLoading
                        ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                        : _errorMessage.isNotEmpty && _usageData.isEmpty
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              '데이터를 불러오는 중 오류가 발생했습니다: $_errorMessage',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        )
                        : _filteredData.isEmpty
                        ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('검색 결과가 없습니다.'),
                          ),
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                '가입자 사용량 목록',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 400,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    sortColumnIndex: _sortColumnIndex,
                                    sortAscending: _sortAscending,
                                    headingRowHeight: 56,
                                    dataRowMinHeight: 38,
                                    dataRowMaxHeight: 38,
                                    horizontalMargin: 20,
                                    columnSpacing: 30,
                                    showCheckboxColumn: false,
                                    columns: [
                                      DataColumn(
                                        label: const Text('No.'),
                                        onSort: (columnIndex, ascending) {
                                          _sort<num>(
                                            (data) => data['id'],
                                            columnIndex,
                                            ascending,
                                          );
                                        },
                                      ),
                                      DataColumn(
                                        label: const Text('고객명'),
                                        onSort: (columnIndex, ascending) {
                                          _sort<String>(
                                            (data) => data['customer_name'],
                                            columnIndex,
                                            ascending,
                                          );
                                        },
                                      ),
                                      DataColumn(
                                        label: const Text('고객번호'),
                                        onSort: (columnIndex, ascending) {
                                          _sort<String>(
                                            (data) => data['customer_no'],
                                            columnIndex,
                                            ascending,
                                          );
                                        },
                                      ),
                                      DataColumn(
                                        label: const Text('주소'),
                                        onSort: (columnIndex, ascending) {
                                          _sort<String>(
                                            (data) => data['address'],
                                            columnIndex,
                                            ascending,
                                          );
                                        },
                                      ),
                                      DataColumn(
                                        label: const Text('미터기ID'),
                                        onSort: (columnIndex, ascending) {
                                          _sort<String>(
                                            (data) => data['meter_id'],
                                            columnIndex,
                                            ascending,
                                          );
                                        },
                                      ),
                                      DataColumn(
                                        label: const Text('전월검침값'),
                                        onSort: (columnIndex, ascending) {
                                          _sort<num>(
                                            (data) => data['prev_count'],
                                            columnIndex,
                                            ascending,
                                          );
                                        },
                                      ),
                                      DataColumn(
                                        label: const Text('현재검침값'),
                                        onSort: (columnIndex, ascending) {
                                          _sort<num>(
                                            (data) => data['current_count'],
                                            columnIndex,
                                            ascending,
                                          );
                                        },
                                      ),
                                      DataColumn(
                                        label: const Text('날짜'),
                                        onSort: (columnIndex, ascending) {
                                          _sort<String>(
                                            (data) => data['read_date'],
                                            columnIndex,
                                            ascending,
                                          );
                                        },
                                      ),
                                      DataColumn(
                                        label: const Text('사용량 (m³)'),
                                        onSort: (columnIndex, ascending) {
                                          _sort<num>(
                                            (data) => data['usage'],
                                            columnIndex,
                                            ascending,
                                          );
                                        },
                                      ),
                                      DataColumn(
                                        label: const Text('요금 (원)'),
                                        onSort: (columnIndex, ascending) {
                                          _sort<num>(
                                            (data) => data['cost'],
                                            columnIndex,
                                            ascending,
                                          );
                                        },
                                      ),
                                    ],
                                    rows:
                                        _getPaginatedData().map((data) {
                                          return DataRow(
                                            onSelectChanged: (_) {
                                              _showUsageDetails(data);
                                            },
                                            color:
                                                WidgetStateProperty.resolveWith<
                                                  Color?
                                                >((Set<WidgetState> states) {
                                                  if (states.contains(
                                                    WidgetState.hovered,
                                                  )) {
                                                    return Colors.blue
                                                        .withValues(
                                                          red: Colors.blue.r,
                                                          green: Colors.blue.g,
                                                          blue: Colors.blue.b,
                                                          alpha: 0.1 * 255,
                                                        );
                                                  }
                                                  return null;
                                                }),
                                            cells: [
                                              DataCell(
                                                Text(data['id'].toString()),
                                              ),
                                              DataCell(
                                                Text(data['customer_name']),
                                              ),
                                              DataCell(
                                                Text(data['customer_no']),
                                              ),
                                              DataCell(Text(data['address'])),
                                              DataCell(Text(data['meter_id'])),
                                              DataCell(
                                                Text(
                                                  data['prev_count'].toString(),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  data['current_count']
                                                      .toString(),
                                                ),
                                              ),
                                              DataCell(Text(data['read_date'])),
                                              DataCell(
                                                Text(data['usage'].toString()),
                                              ),
                                              DataCell(
                                                Text(
                                                  NumberFormat(
                                                    '#,###',
                                                  ).format(data['cost']),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ),
                            ),

                            // 페이지네이션
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed:
                                        _currentPage > 0
                                            ? () {
                                              setState(() {
                                                _currentPage--;
                                              });
                                            }
                                            : null,
                                  ),
                                  Text(
                                    '${_currentPage + 1} / ${(_filteredData.length / _rowsPerPage).ceil()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward),
                                    onPressed:
                                        (_currentPage + 1) * _rowsPerPage <
                                                _filteredData.length
                                            ? () {
                                              setState(() {
                                                _currentPage++;
                                              });
                                            }
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
          border: Border.all(
            color: color.withValues(
              red: color.r.toDouble(),
              green: color.g.toDouble(),
              blue: color.b.toDouble(),
              alpha: 0.3 * 255,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
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
