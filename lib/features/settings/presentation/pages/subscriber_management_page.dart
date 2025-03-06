import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/models/subscriber_model.dart';
import '../../../../core/services/subscriber_service.dart';
import '../../../../core/constants/api_constants.dart';
import 'subscriber_info_page.dart';

class SubscriberManagementPage extends StatefulWidget {
  const SubscriberManagementPage({super.key});

  @override
  State<SubscriberManagementPage> createState() =>
      _SubscriberManagementPageState();
}

class _SubscriberManagementPageState extends State<SubscriberManagementPage> {
  final _searchController = TextEditingController();
  List<SubscriberModel> _subscribers = [];
  List<SubscriberModel> _filteredSubscribers = [];
  bool _isLoading = true;
  String _errorMessage = '';
  late final SubscriberService _subscriberService;

  // 정렬 상태를 관리하기 위한 변수 추가
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  int _rowsPerPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _subscriberService = SubscriberService(baseUrl: ApiConstants.serverUrl);
    _loadSubscribers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubscribers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final subscribers = await _subscriberService.getSubscribers();

      setState(() {
        _subscribers = subscribers;
        _filteredSubscribers = subscribers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterSubscribers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSubscribers = _subscribers;
      } else {
        _filteredSubscribers =
            _subscribers.where((subscriber) {
              final searchFields = [
                subscriber.subscriberId,
                subscriber.customerName ?? '',
                subscriber.customerNo ?? '',
                subscriber.subscriberNo ?? '',
                subscriber.meterId ?? '',
                subscriber.phoneNumber ?? '',
                subscriber.email ?? '',
                _getFormattedAddress(subscriber),
              ].map((s) => s.toLowerCase());

              return searchFields.any(
                (field) => field.contains(query.toLowerCase()),
              );
            }).toList();
      }
    });
  }

  String _getFormattedAddress(SubscriberModel subscriber) {
    return [
      subscriber.addrProv,
      subscriber.addrCity,
      subscriber.addrDist,
      subscriber.addrDetail,
      subscriber.addrApt,
    ].where((s) => s != null && s.isNotEmpty).join(' ');
  }

  String _getFormattedBindDate(String? bindDate) {
    if (bindDate == null || bindDate.isEmpty) {
      return '';
    }

    // 밀리초 부분 제거 (점 이후 부분 제거)
    final parts = bindDate.split('.');
    return parts[0];
  }

  void _sort<T>(
    Comparable<T> Function(SubscriberModel subscriber) getField,
    int columnIndex,
    bool ascending,
  ) {
    _filteredSubscribers.sort((a, b) {
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

  Future<void> _exportToExcel() async {
    final localizations = AppLocalizations.of(context)!;
    try {
      // Excel 파일 생성
      final excel = Excel.createExcel();
      final sheet = excel['가입자 목록'];

      // 헤더 추가
      sheet.appendRow([
        TextCellValue('No.'),
        TextCellValue(localizations.customerName),
        TextCellValue(localizations.customerNo),
        TextCellValue(localizations.address),
        TextCellValue(localizations.shareHouse),
        TextCellValue(localizations.category),
        TextCellValue(localizations.subscriberNo),
        TextCellValue(localizations.meterId),
        TextCellValue(localizations.subscriberClass),
        TextCellValue(localizations.inOutdoor),
        TextCellValue(localizations.bindDeviceId),
        TextCellValue(localizations.bindDate),
      ]);

      // 데이터 추가
      for (final subscriber in _filteredSubscribers) {
        sheet.appendRow([
          TextCellValue(subscriber.subscriberId),
          TextCellValue(subscriber.customerName ?? ''),
          TextCellValue(subscriber.customerNo ?? ''),
          TextCellValue(_getFormattedAddress(subscriber)),
          TextCellValue(subscriber.shareHouse ?? ''),
          TextCellValue(subscriber.category ?? ''),
          TextCellValue(subscriber.subscriberNo ?? ''),
          TextCellValue(subscriber.meterId ?? ''),
          TextCellValue(subscriber.subscriberClass ?? ''),
          TextCellValue(subscriber.inOutdoor ?? ''),
          TextCellValue(subscriber.bindDeviceId ?? ''),
          TextCellValue(_getFormattedBindDate(subscriber.bindDate)),
        ]);
      }

      final fileName =
          '가입자목록_${DateTime.now().toString().split('.')[0].replaceAll(':', '-')}.xlsx';

      if (kIsWeb) {
        // 웹 환경에서의 다운로드 처리
        final bytes = excel.encode()!;
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.document.createElement('a') as html.AnchorElement
              ..href = url
              ..style.display = 'none'
              ..download = fileName;
        html.document.body!.children.add(anchor);
        anchor.click();
        html.document.body!.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      } else {
        // 데스크톱/모바일 환경에서의 다운로드 처리
        final result = await FilePicker.platform.saveFile(
          dialogTitle: '엑셀 파일 저장',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
        );

        if (result != null) {
          final file = File(result);
          await file.writeAsBytes(excel.encode()!);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizations.excelFileSaved)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.excelFileSaveError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddSubscriberDialog() {
    // 가입자 추가 다이얼로그 구현
    // 실제 구현은 추후에 진행
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
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
            localizations.subscriberManagement,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.subscriberManagementDescription,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // 검색 및 버튼 영역
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: localizations.searchSubscriber,
                    hintText: localizations.searchSubscriberHint,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: _filterSubscribers,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddSubscriberDialog,
                icon: const Icon(Icons.add),
                label: Text(localizations.addSubscriber),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _loadSubscribers,
                icon: const Icon(Icons.refresh),
                tooltip: localizations.refresh,
              ),
              IconButton(
                onPressed: _exportToExcel,
                icon: const Icon(Icons.file_download),
                tooltip: localizations.exportSubscribersToExcel,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 통계 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    title: localizations.totalSubscribers,
                    value: _subscribers.length.toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    title: localizations.activeSubscribers,
                    value:
                        _subscribers.where((s) => s.isActive).length.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    title: localizations.inactiveSubscribers,
                    value:
                        _subscribers
                            .where((s) => !s.isActive)
                            .length
                            .toString(),
                    icon: Icons.cancel,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 데이터 테이블
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                    ? Center(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                    : Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child:
                            _filteredSubscribers.isEmpty
                                ? const Center(child: Text('데이터가 없습니다.'))
                                : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16.0,
                                      ),
                                      child: Text(
                                        localizations.subscriberList,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
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
                                              label: Text('No.'),
                                              onSort: (columnIndex, ascending) {
                                                _sort<String>(
                                                  (subscriber) =>
                                                      subscriber.subscriberId,
                                                  columnIndex,
                                                  ascending,
                                                );
                                              },
                                            ),
                                            DataColumn(
                                              label: Text(
                                                localizations.customerName,
                                              ),
                                              onSort: (columnIndex, ascending) {
                                                _sort<String>(
                                                  (subscriber) =>
                                                      subscriber.customerName ??
                                                      '',
                                                  columnIndex,
                                                  ascending,
                                                );
                                              },
                                            ),
                                            DataColumn(
                                              label: Text(
                                                localizations.customerNo,
                                              ),
                                              onSort: (columnIndex, ascending) {
                                                _sort<String>(
                                                  (subscriber) =>
                                                      subscriber.customerNo ??
                                                      '',
                                                  columnIndex,
                                                  ascending,
                                                );
                                              },
                                            ),
                                            DataColumn(
                                              label: Text(
                                                localizations.address,
                                              ),
                                              onSort: (columnIndex, ascending) {
                                                _sort<String>(
                                                  (subscriber) =>
                                                      _getFormattedAddress(
                                                        subscriber,
                                                      ),
                                                  columnIndex,
                                                  ascending,
                                                );
                                              },
                                            ),
                                            DataColumn(
                                              label: Text(
                                                localizations.shareHouse,
                                              ),
                                              onSort: (columnIndex, ascending) {
                                                _sort<String>(
                                                  (subscriber) =>
                                                      subscriber.shareHouse ??
                                                      '',
                                                  columnIndex,
                                                  ascending,
                                                );
                                              },
                                            ),
                                            DataColumn(
                                              label: Text(
                                                localizations.category,
                                              ),
                                              onSort: (columnIndex, ascending) {
                                                _sort<String>(
                                                  (subscriber) =>
                                                      subscriber.category ?? '',
                                                  columnIndex,
                                                  ascending,
                                                );
                                              },
                                            ),
                                            DataColumn(
                                              label: Text(
                                                localizations.subscriberNo,
                                              ),
                                              onSort: (columnIndex, ascending) {
                                                _sort<String>(
                                                  (subscriber) =>
                                                      subscriber.subscriberNo ??
                                                      '',
                                                  columnIndex,
                                                  ascending,
                                                );
                                              },
                                            ),
                                            DataColumn(
                                              label: Text(
                                                localizations.meterId,
                                              ),
                                              onSort: (columnIndex, ascending) {
                                                _sort<String>(
                                                  (subscriber) =>
                                                      subscriber.meterId ?? '',
                                                  columnIndex,
                                                  ascending,
                                                );
                                              },
                                            ),
                                            DataColumn(
                                              label: Text(
                                                localizations.subscriberClass,
                                              ),
                                              onSort: (columnIndex, ascending) {
                                                _sort<String>(
                                                  (subscriber) =>
                                                      subscriber
                                                          .subscriberClass ??
                                                      '',
                                                  columnIndex,
                                                  ascending,
                                                );
                                              },
                                            ),
                                            DataColumn(
                                              label: Text(
                                                localizations.inOutdoor,
                                              ),
                                              onSort: (columnIndex, ascending) {
                                                _sort<String>(
                                                  (subscriber) =>
                                                      subscriber.inOutdoor ??
                                                      '',
                                                  columnIndex,
                                                  ascending,
                                                );
                                              },
                                            ),
                                            DataColumn(
                                              label: Text(
                                                localizations.bindDeviceId,
                                              ),
                                              onSort: (columnIndex, ascending) {
                                                _sort<String>(
                                                  (subscriber) =>
                                                      subscriber.bindDeviceId ??
                                                      '',
                                                  columnIndex,
                                                  ascending,
                                                );
                                              },
                                            ),
                                            DataColumn(
                                              label: Text(
                                                localizations.bindDate,
                                              ),
                                              onSort: (columnIndex, ascending) {
                                                _sort<String>(
                                                  (subscriber) =>
                                                      _getFormattedBindDate(
                                                        subscriber.bindDate,
                                                      ),
                                                  columnIndex,
                                                  ascending,
                                                );
                                              },
                                            ),
                                          ],
                                          rows:
                                              _getPaginatedData().map((
                                                subscriber,
                                              ) {
                                                final address =
                                                    _getFormattedAddress(
                                                      subscriber,
                                                    );

                                                return DataRow(
                                                  cells: [
                                                    DataCell(
                                                      Text(
                                                        subscriber.subscriberId,
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        subscriber
                                                                .customerName ??
                                                            '',
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        subscriber.customerNo ??
                                                            '',
                                                      ),
                                                    ),
                                                    DataCell(Text(address)),
                                                    DataCell(
                                                      Text(
                                                        subscriber.shareHouse ??
                                                            '',
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        subscriber.category ??
                                                            '',
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        subscriber
                                                                .subscriberNo ??
                                                            '',
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        subscriber.meterId ??
                                                            '',
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        subscriber
                                                                .subscriberClass ??
                                                            '',
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        subscriber.inOutdoor ??
                                                            '',
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        subscriber
                                                                .bindDeviceId ??
                                                            '',
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        _getFormattedBindDate(
                                                          subscriber.bindDate,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  onSelectChanged: (_) {
                                                    // 가입자 상세 정보 페이지로 이동
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => SubscriberInfoPage(
                                                              meterId:
                                                                  subscriber
                                                                      .meterId ??
                                                                  '',
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${localizations.rowsPerPage}: ',
                                              ),
                                              DropdownButton<int>(
                                                value: _rowsPerPage,
                                                items:
                                                    const [10, 20, 50, 100].map(
                                                      (int value) {
                                                        return DropdownMenuItem<
                                                          int
                                                        >(
                                                          value: value,
                                                          child: Text('$value'),
                                                        );
                                                      },
                                                    ).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _rowsPerPage = value!;
                                                    _currentPage = 0; // 페이지 리셋
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.first_page,
                                                ),
                                                onPressed:
                                                    _currentPage > 0
                                                        ? () {
                                                          setState(() {
                                                            _currentPage = 0;
                                                          });
                                                        }
                                                        : null,
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.chevron_left,
                                                ),
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
                                                '${_currentPage + 1} / ${(_filteredSubscribers.length / _rowsPerPage).ceil()}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.chevron_right,
                                                ),
                                                onPressed:
                                                    _currentPage <
                                                            (_filteredSubscribers
                                                                            .length /
                                                                        _rowsPerPage)
                                                                    .ceil() -
                                                                1
                                                        ? () {
                                                          setState(() {
                                                            _currentPage++;
                                                          });
                                                        }
                                                        : null,
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.last_page,
                                                ),
                                                onPressed:
                                                    _currentPage <
                                                            (_filteredSubscribers
                                                                            .length /
                                                                        _rowsPerPage)
                                                                    .ceil() -
                                                                1
                                                        ? () {
                                                          setState(() {
                                                            _currentPage =
                                                                (_filteredSubscribers
                                                                            .length /
                                                                        _rowsPerPage)
                                                                    .ceil() -
                                                                1;
                                                          });
                                                        }
                                                        : null,
                                              ),
                                            ],
                                          ),
                                        ],
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

  List<SubscriberModel> _getPaginatedData() {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex =
        startIndex + _rowsPerPage > _filteredSubscribers.length
            ? _filteredSubscribers.length
            : startIndex + _rowsPerPage;

    if (startIndex >= _filteredSubscribers.length) {
      return [];
    }

    return _filteredSubscribers.sublist(startIndex, endIndex);
  }
}
