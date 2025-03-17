import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../l10n/app_localizations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/auth_service.dart';

class DbViewerPage extends StatefulWidget {
  const DbViewerPage({super.key});

  @override
  State<DbViewerPage> createState() => _DbViewerPageState();
}

class _DbViewerPageState extends State<DbViewerPage> {
  final _tableController = TextEditingController();
  final _filterController = TextEditingController();
  final _limitController = TextEditingController(text: '100');
  final _orderByController = TextEditingController(text: 'datetime: desc');

  // 서버 목록 및 선택된 서버
  final List<Map<String, String>> _servers = [
    {'name': '1. hongkong aliyun', 'id': '1'},
    {'name': '2. oracle cloud', 'id': '2'},
  ];
  String? _selectedServerId;

  List<String> _dbNames = [];
  String? _selectedDb;
  List<String> _tables = [];
  String? _selectedTable;
  List<Map<String, dynamic>> _data = [];
  List<String> _columns = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // DB와 컬렉션 정보를 저장하는 맵
  Map<String, List<String>> _dbCollections = {};

  @override
  void initState() {
    super.initState();
    _selectedServerId = _servers[0]['id']; // 기본 서버 ID 설정
    _loadDbTree();
  }

  @override
  void dispose() {
    _tableController.dispose();
    _filterController.dispose();
    _limitController.dispose();
    _orderByController.dispose();
    super.dispose();
  }

  Future<void> _loadDbTree() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // AuthService 초기화
      await AuthService.initAuthData();

      final response = await http.post(
        Uri.parse('${ApiConstants.serverUrl}/api/database'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'list',
          'page': 'database',
          'format': 'json',
          'server': _selectedServerId, // 서버 ID 전송
          ...AuthService.authData,
        }),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is Map && responseData.containsKey('data')) {
          final List<dynamic> dbList = responseData['data'];

          // DB 이름 목록과 각 DB의 컬렉션 맵 생성
          final dbNames = <String>[];
          final dbCollections = <String, List<String>>{};

          for (var dbInfo in dbList) {
            final dbName = dbInfo['db'].toString();
            dbNames.add(dbName);

            final collections =
                (dbInfo['collections'] as List<dynamic>)
                    .map((collection) => collection.toString())
                    .toList();

            dbCollections[dbName] = collections;
          }

          setState(() {
            _dbNames = dbNames;
            _dbCollections = dbCollections;

            if (_dbNames.isNotEmpty) {
              _selectedDb = _dbNames.first;
              _tables = _dbCollections[_selectedDb] ?? [];
              if (_tables.isNotEmpty) {
                _selectedTable = _tables.first;
              }
            }
            _isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load DB list: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _queryTable() async {
    if (_selectedDb == null) {
      setState(() {
        _errorMessage = 'Select a database.';
      });
      return;
    }

    if (_selectedTable == null || _selectedTable!.isEmpty) {
      setState(() {
        _errorMessage = 'Select a table.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _data = [];
      _columns = [];
    });

    try {
      // AuthService 초기화 확인
      if (AuthService.authData.isEmpty) {
        await AuthService.initAuthData();
      }

      Map<String, dynamic> filter = {};
      if (_filterController.text.isNotEmpty) {
        try {
          filter = json.decode(_filterController.text);
        } catch (e) {
          setState(() {
            _errorMessage = 'Invalid filter format: $e';
            _isLoading = false;
          });
          return;
        }
      }

      int limit = 100;
      if (_limitController.text.isNotEmpty) {
        try {
          limit = int.parse(_limitController.text);
        } catch (e) {
          setState(() {
            _errorMessage = 'Invalid limit value: $e';
            _isLoading = false;
          });
          return;
        }
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.serverUrl}/api/database'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'view',
          'table': _selectedTable,
          'fields': [],
          'filter': filter,
          'limit': limit,
          'orderby': _orderByController.text,
          'format': 'json',
          'db': _selectedDb,
          'server': _selectedServerId, // 서버 ID 전송
          ...AuthService.authData,
        }),
      );

      if (response.statusCode == 200) {
        // print('response.body: ${response.body}');
        final dynamic responseData = json.decode(response.body);

        if (responseData is Map) {
          if (responseData.containsKey('fields') &&
              responseData.containsKey('data')) {
            // 새로운 응답 형식 처리 (fields와 data가 있는 경우)
            final List<dynamic> fields = responseData['fields'];
            final List<dynamic> data = responseData['data'];
            _processDataWithFields(fields.cast<String>(), data);
          } else if (responseData.containsKey('data')) {
            // 기존 응답 형식 처리 (data만 있는 경우)
            final List<dynamic> data = responseData['data'];
            _processData(data);
          } else {
            throw Exception('Unexpected response format');
          }
        } else if (responseData is List) {
          _processData(responseData);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Table query failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // 새로운 응답 형식을 처리하는 메서드 (fields와 data가 분리된 경우)
  void _processDataWithFields(List<String> fields, List<dynamic> data) {
    if (data.isEmpty) {
      setState(() {
        _data = [];
        _columns = [];
        _isLoading = false;
      });
      return;
    }

    // 데이터를 Map<String, dynamic> 형태로 변환
    final processedData =
        data.map((item) {
          return Map<String, dynamic>.fromEntries(
            fields.map((field) {
              var value = item[field];
              // 값이 null이거나 빈 문자열이면 '-'로 표시
              if (value == null) {
                value = '-';
              } else if (value is Map || value is List) {
                value = json.encode(value);
              }
              return MapEntry(field, value);
            }),
          );
        }).toList();

    setState(() {
      _data = processedData;
      _columns = fields;
      _isLoading = false;
    });
  }

  // 기존 응답 형식을 처리하는 메서드 (data만 있는 경우)
  void _processData(List<dynamic> data) {
    if (data.isEmpty) {
      setState(() {
        _data = [];
        _columns = [];
        _isLoading = false;
      });
      return;
    }

    // 첫 번째 항목에서 모든 키를 추출하여 컬럼으로 사용
    final columns = data.first.keys.toList();

    // 데이터를 Map<String, dynamic> 형태로 변환
    final processedData =
        data.map((item) {
          return Map<String, dynamic>.fromEntries(
            columns.map((column) {
              var value = item[column];
              // 값이 null이거나 빈 문자열이면 '-'로 표시
              if (value == null) {
                value = '-';
              } else if (value is Map || value is List) {
                value = json.encode(value);
              }
              return MapEntry(column, value);
            }),
          );
        }).toList();

    setState(() {
      _data = processedData;
      _columns = columns;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.dbViewer,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.dbViewerDescription,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // 테이블 선택 및 쿼리 영역
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 서버 선택
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: '서버 선택',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          value: _selectedServerId,
                          items: _servers.map((server) {
                            return DropdownMenuItem<String>(
                              value: server['id'],
                              child: Text(server['name']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedServerId = value;
                              // 서버가 변경되면 DB 목록 다시 로드
                              _dbNames = [];
                              _tables = [];
                              _selectedDb = null;
                              _selectedTable = null;
                              _loadDbTree();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // DB 선택
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: localizations.dbName,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          value: _selectedDb,
                          items:
                              _dbNames.map((dbName) {
                                return DropdownMenuItem<String>(
                                  value: dbName,
                                  child: Text(dbName),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDb = value;
                              // DB가 변경되면 해당 DB의 테이블 목록으로 업데이트
                              _tables = _dbCollections[value] ?? [];
                              _selectedTable =
                                  _tables.isNotEmpty ? _tables.first : null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 테이블 선택
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: localizations.selectTable,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          value: _selectedTable,
                          items:
                              _tables.map((table) {
                                return DropdownMenuItem<String>(
                                  value: table,
                                  child: Text(table),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTable = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 결과 제한
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _limitController,
                          decoration: InputDecoration(
                            labelText: localizations.limit,
                            hintText: '100',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Order By 필드
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _orderByController,
                          decoration: InputDecoration(
                            labelText: localizations.orderBy,
                            hintText: 'datetime: desc',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 필터
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _filterController,
                          decoration: InputDecoration(
                            labelText: localizations.filter,
                            hintText: '{"field": "value"}',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 새로고침 버튼
                      IconButton(
                        onPressed: _loadDbTree,
                        icon: const Icon(Icons.refresh),
                        tooltip: localizations.refresh,
                      ),
                      // 조회 버튼
                      ElevatedButton.icon(
                        onPressed: _queryTable,
                        icon: const Icon(Icons.search, color: Colors.white),
                        label: Text(localizations.query),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 에러 메시지
          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red[100],
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // 데이터 테이블
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _data.isEmpty
                    ? Center(child: Text(localizations.noData))
                    : Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                '$_selectedTable ${localizations.tableData} (${_data.length} ${localizations.rows})',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columnSpacing: 20,
                                    headingRowHeight: 56,
                                    dataRowMinHeight: 38,
                                    dataRowMaxHeight: 38,
                                    horizontalMargin: 10,
                                    showCheckboxColumn: false,
                                    columns:
                                        _columns.map((column) {
                                          return DataColumn(
                                            label: Container(
                                              constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
                                              child: Text(
                                                column,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                    rows:
                                        _data.map((row) {
                                          return DataRow(
                                            cells:
                                                _columns.map((column) {
                                                  String displayText =
                                                      row[column].toString();
                                                  // 텍스트 길이가 32자를 초과하면 자르고 "..."를 추가
                                                  if (displayText.length > 64) {
                                                    displayText =
                                                        "${displayText.substring(0, 64)}...";
                                                  }
                                                  return DataCell(
                                                    Container(
                                                      constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
                                                      child: Text(
                                                        displayText,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                            onSelectChanged: (selected) {
                                              if (selected != null &&
                                                  selected) {
                                                _showRowDetailDialog(
                                                  context,
                                                  row,
                                                );
                                              }
                                            },
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  // 행 상세 정보를 보여주는 다이얼로그
  void _showRowDetailDialog(
    BuildContext context,
    Map<String, dynamic> rowData,
  ) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.dataDetails,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children:
                        rowData.entries.map((entry) {
                          String valueText = entry.value.toString();
                          bool isJson = false;

                          // JSON 형식인지 확인하고 예쁘게 포맷팅
                          if (entry.value is String) {
                            try {
                              final jsonValue = json.decode(
                                entry.value as String,
                              );
                              if (jsonValue is Map || jsonValue is List) {
                                valueText = const JsonEncoder.withIndent(
                                  '  ',
                                ).convert(jsonValue);
                                isJson = true;
                              }
                            } catch (e) {
                              // JSON이 아니면 그냥 진행
                            }
                          } else if (entry.value is Map ||
                              entry.value is List) {
                            valueText = const JsonEncoder.withIndent(
                              '  ',
                            ).convert(entry.value);
                            isJson = true;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child:
                                      isJson
                                          ? SelectableText(
                                            valueText,
                                            style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 14,
                                            ),
                                          )
                                          : SelectableText(valueText),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // 클립보드에 JSON 형식으로 복사
                        final jsonData = json.encode(rowData);
                        Clipboard.setData(ClipboardData(text: jsonData));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(localizations.dataCopied),
                          ),
                        );
                      },
                      child: Text(localizations.copyAsJson),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(localizations.close),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
