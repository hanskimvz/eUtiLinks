import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/models/device_model.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/constants/api_constants.dart';

class DeviceQueryPage extends StatefulWidget {
  const DeviceQueryPage({super.key});

  @override
  State<DeviceQueryPage> createState() => _DeviceQueryPageState();
}

class _DeviceQueryPageState extends State<DeviceQueryPage> {
  final _searchController = TextEditingController();
  List<DeviceModel> _devices = [];
  List<DeviceModel> _filteredDevices = [];
  bool _isLoading = true;
  String _errorMessage = '';
  late final DeviceService _deviceService;

  // 정렬 상태를 관리하기 위한 변수 추가
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  final int _rowsPerPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _deviceService = DeviceService(baseUrl: ApiConstants.serverUrl);
    _loadDevices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final tableHead = [
        'no_',
        'customer_name',
        'customer_no',
        'last_count',
        'addr_prov',
        'addr_city',
        'addr_dist',
        'addr_detail',
        'share_house',
        'addr_apt',
        'category',
        'subscriber_no',
        'meter_id',
        'class',
        'in_outdoor',
        'device_uid',
        'last_access',
        'flag',
      ];

      final devices = await _deviceService.getDevicesWithFilter(
        fields: tableHead,
        filter: {
          'meter_id': {'\$exists': true, '\$ne': ''},
        },
      );

      setState(() {
        _devices = devices;
        _filteredDevices = devices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterDevices(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDevices = _devices;
      } else {
        _filteredDevices =
            _devices.where((device) {
              final searchFields = [
                device.deviceUid,
                device.customerName ?? '',
                device.customerNo ?? '',
                device.subscriberNo ?? '',
                device.meterId ?? '',
                _getFormattedAddress(device),
              ].map((s) => s.toLowerCase());

              return searchFields.any(
                (field) => field.contains(query.toLowerCase()),
              );
            }).toList();
      }
    });
  }

  String _getFormattedAddress(DeviceModel device) {
    return [
      device.addrProv,
      device.addrCity,
      device.addrDist,
      device.addrDetail,
      device.addrApt,
    ].where((s) => s != null && s.isNotEmpty).join(' ');
  }

  String _flagToSymbol(bool? flag) {
    if (flag == null) {
      return '';
    }
    return flag ? 'O' : 'X';
  }

  void _sort<T>(
    Comparable<T> Function(DeviceModel device) getField,
    int columnIndex,
    bool ascending,
  ) {
    _filteredDevices.sort((a, b) {
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
      final sheet = excel['디바이스 목록'];

      // 헤더 추가
      final headers = [
        'No.',
        localizations.customerName,
        localizations.customerNo,
        localizations.lastCount,
        "도",
        "시",
        "구",
        "상세주소",
        "아파트",
        localizations.shareHouse,
        localizations.category,
        localizations.subscriberNo,
        localizations.meterId,
        localizations.deviceUid,

        localizations.lastAccess,
        localizations.status,
        localizations.subscriberClass,
        localizations.inOutdoor,
      ];

      // 헤더 행 추가
      sheet.appendRow(headers.map((header) => TextCellValue(header)).toList());

      // 컬럼 너비 설정
      final columnWidths = [
        5.0,
        10.0,
        12.0,
        25.0,
        8.0,
        10.0,
        10.0,
        15.0,
        10.0,
        10.0,
        10.0,
        10.0,
        10.0,
        10.0,
      ];
      for (var i = 0; i < columnWidths.length; i++) {
        sheet.setColumnWidth(i, columnWidths[i]);
      }

      // 헤더 스타일 적용 - 기본 스타일만 적용
      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.cellStyle = CellStyle(bold: true, fontSize: 12);
      }

      // 데이터 추가
      for (var rowIndex = 0; rowIndex < _filteredDevices.length; rowIndex++) {
        final device = _filteredDevices[rowIndex];
        final rowData = [
          TextCellValue(device.no_?.toString() ?? ''),
          TextCellValue(device.customerName ?? ''),
          TextCellValue(device.customerNo ?? ''),
          TextCellValue(device.lastCount?.toString() ?? ''),
          TextCellValue(device.addrProv ?? ''),
          TextCellValue(device.addrCity ?? ''),
          TextCellValue(device.addrDist ?? ''),
          TextCellValue(device.addrDetail ?? ''),
          TextCellValue(device.addrApt ?? ''),
          TextCellValue(device.shareHouse.toString()),
          TextCellValue(device.category ?? ''),
          TextCellValue(_flagToSymbol(device.shareHouse)),
          TextCellValue(device.meterId ?? ''),
          TextCellValue(device.deviceUid),

          TextCellValue(device.lastAccess ?? ''),
          TextCellValue(device.flag ?? ''),
          TextCellValue(device.deviceClass ?? ''),
          TextCellValue(device.inOutdoor ?? ''),
        ];

        sheet.appendRow(rowData);
      }

      final fileName =
          '디바이스목록_${DateTime.now().toString().split('.')[0].replaceAll(':', '-')}.xlsx';

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

  List<DeviceModel> _getPaginatedData() {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage;

    if (startIndex >= _filteredDevices.length) {
      return [];
    }

    if (endIndex > _filteredDevices.length) {
      return _filteredDevices.sublist(startIndex);
    }

    return _filteredDevices.sublist(startIndex, endIndex);
  }

  Color _getStatusColor(String? flag) {
    if (flag == null || flag.isEmpty) {
      return Colors.grey;
    }

    switch (flag.toLowerCase()) {
      case 'active':
      case 'normal':
        return Colors.green;
      case 'inactive':
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? flag) {
    if (flag == null || flag.isEmpty) {
      return '알 수 없음';
    }

    switch (flag.toLowerCase()) {
      case 'active':
      case 'normal':
        return '정상';
      case 'inactive':
        return '비활성';
      case 'warning':
        return '주의';
      case 'error':
        return '오류';
      default:
        return flag;
    }
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

  void _showDeviceMenu(DeviceModel device) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${device.meterId ?? "장치"} 메뉴'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text('장치 정보'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeviceInfo(device);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.show_chart, color: Colors.green),
                title: const Text('사용량 내역'),
                onTap: () {
                  Navigator.pop(context);
                  _showUsageHistory(device);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.warning_amber_outlined,
                  color: Colors.orange,
                ),
                title: const Text('이상 증상 확인'),
                onTap: () {
                  Navigator.pop(context);
                  _showAbnormalStatus(device);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(localizations.cancel),
            ),
          ],
        );
      },
    );
  }

  void _showDeviceInfo(DeviceModel device) {
    // 장치 정보 표시 로직
    Navigator.pushNamed(
      context,
      '/device_info',
      arguments: {'deviceId': device.meterId},
    );
  }

  void _showUsageHistory(DeviceModel device) {
    final localizations = AppLocalizations.of(context)!;
    // 사용량 내역 표시 로직
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('사용량 내역'),
          content: const SizedBox(
            width: 600,
            height: 400,
            child: Center(child: Text('사용량 내역 기능은 준비 중입니다.')),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(localizations.confirm),
            ),
          ],
        );
      },
    );
  }

  void _showAbnormalStatus(DeviceModel device) {
    final localizations = AppLocalizations.of(context)!;
    // 이상 증상 확인 로직
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('이상 증상 확인'),
          content: const SizedBox(
            width: 600,
            height: 400,
            child: Center(child: Text('이상 증상 확인 기능은 준비 중입니다.')),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(localizations.confirm),
            ),
          ],
        );
      },
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
            '디바이스 조회',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '디바이스 정보를 조회합니다.',
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
                    labelText: '디바이스 검색',
                    hintText: '디바이스 ID, 고객명, 주소 등으로 검색',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: _filterDevices,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _loadDevices,
                icon: const Icon(Icons.refresh),
                tooltip: localizations.refresh,
              ),
              IconButton(
                onPressed: _exportToExcel,
                icon: const Icon(Icons.file_download),
                tooltip: '엑셀로 내보내기',
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
                    title: '전체 디바이스',
                    value: _devices.length.toString(),
                    icon: Icons.devices,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    title: '정상 디바이스',
                    value:
                        _devices
                            .where(
                              (d) =>
                                  d.flag?.toLowerCase() == 'normal' ||
                                  d.flag?.toLowerCase() == 'active',
                            )
                            .length
                            .toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    title: '주의 필요',
                    value:
                        _devices
                            .where(
                              (d) =>
                                  d.flag?.toLowerCase() == 'warning' ||
                                  d.flag?.toLowerCase() == 'error',
                            )
                            .length
                            .toString(),
                    icon: Icons.warning,
                    color: Colors.orange,
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
                            _filteredDevices.isEmpty
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
                                        localizations.deviceList,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
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
                                                label: Text('No.'),
                                                onSort: (
                                                  columnIndex,
                                                  ascending,
                                                ) {
                                                  _sort<num>(
                                                    (device) => device.no_ ?? 0,
                                                    columnIndex,
                                                    ascending,
                                                  );
                                                },
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  localizations.customerName,
                                                ),
                                                onSort: (
                                                  columnIndex,
                                                  ascending,
                                                ) {
                                                  _sort<String>(
                                                    (device) =>
                                                        device.customerName ??
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
                                                onSort: (
                                                  columnIndex,
                                                  ascending,
                                                ) {
                                                  _sort<String>(
                                                    (device) =>
                                                        device.customerNo ?? '',
                                                    columnIndex,
                                                    ascending,
                                                  );
                                                },
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  localizations.address,
                                                ),
                                                onSort: (
                                                  columnIndex,
                                                  ascending,
                                                ) {
                                                  _sort<String>(
                                                    (device) =>
                                                        _getFormattedAddress(
                                                          device,
                                                        ),
                                                    columnIndex,
                                                    ascending,
                                                  );
                                                },
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  localizations.meterId,
                                                ),
                                                onSort: (
                                                  columnIndex,
                                                  ascending,
                                                ) {
                                                  _sort<String>(
                                                    (device) =>
                                                        device.meterId ?? '',
                                                    columnIndex,
                                                    ascending,
                                                  );
                                                },
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  localizations.deviceUid,
                                                ),
                                                onSort: (
                                                  columnIndex,
                                                  ascending,
                                                ) {
                                                  _sort<String>(
                                                    (device) =>
                                                        device.deviceUid,
                                                    columnIndex,
                                                    ascending,
                                                  );
                                                },
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  localizations.lastCount,
                                                ),
                                                onSort: (
                                                  columnIndex,
                                                  ascending,
                                                ) {
                                                  _sort<String>(
                                                    (device) =>
                                                        device.lastCount
                                                            ?.toString() ??
                                                        '',
                                                    columnIndex,
                                                    ascending,
                                                  );
                                                },
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  localizations.lastAccess,
                                                ),
                                                onSort: (
                                                  columnIndex,
                                                  ascending,
                                                ) {
                                                  _sort<String>(
                                                    (device) =>
                                                        device.lastAccess ?? '',
                                                    columnIndex,
                                                    ascending,
                                                  );
                                                },
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  localizations.status,
                                                ),
                                                onSort: (
                                                  columnIndex,
                                                  ascending,
                                                ) {
                                                  _sort<String>(
                                                    (device) =>
                                                        device.flag ?? '',
                                                    columnIndex,
                                                    ascending,
                                                  );
                                                },
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  localizations.category,
                                                ),
                                                onSort: (
                                                  columnIndex,
                                                  ascending,
                                                ) {
                                                  _sort<String>(
                                                    (device) =>
                                                        device.category ?? '',
                                                    columnIndex,
                                                    ascending,
                                                  );
                                                },
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  localizations.subscriberClass,
                                                ),
                                                onSort: (
                                                  columnIndex,
                                                  ascending,
                                                ) {
                                                  _sort<String>(
                                                    (device) =>
                                                        device.deviceClass ??
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
                                                onSort: (
                                                  columnIndex,
                                                  ascending,
                                                ) {
                                                  _sort<String>(
                                                    (device) =>
                                                        device.inOutdoor ?? '',
                                                    columnIndex,
                                                    ascending,
                                                  );
                                                },
                                              ),
                                            ],
                                            rows:
                                                _getPaginatedData().map((
                                                  device,
                                                ) {
                                                  final address =
                                                      _getFormattedAddress(
                                                        device,
                                                      );

                                                  return DataRow(
                                                    onSelectChanged: (_) {
                                                      _showDeviceMenu(device);
                                                    },
                                                    color:
                                                        WidgetStateProperty.resolveWith<
                                                          Color?
                                                        >((
                                                          Set<WidgetState>
                                                          states,
                                                        ) {
                                                          if (states.contains(
                                                            WidgetState.hovered,
                                                          )) {
                                                            return Colors.blue
                                                                .withValues(
                                                                  red:
                                                                      Colors
                                                                          .blue
                                                                          .r,
                                                                  green:
                                                                      Colors
                                                                          .blue
                                                                          .g,
                                                                  blue:
                                                                      Colors
                                                                          .blue
                                                                          .b,
                                                                  alpha:
                                                                      0.1 * 255,
                                                                );
                                                          }
                                                          return null;
                                                        }),
                                                    cells: [
                                                      DataCell(
                                                        Text(
                                                          device.no_
                                                                  ?.toString() ??
                                                              '',
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          device.customerName ??
                                                              '',
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          device.customerNo ??
                                                              '',
                                                        ),
                                                      ),
                                                      DataCell(Text(address)),
                                                      DataCell(
                                                        Text(
                                                          device.meterId ?? '',
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(device.deviceUid),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          device.lastCount
                                                                  ?.toString() ??
                                                              '',
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          device.lastAccess ??
                                                              '',
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 12,
                                                              height: 12,
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    _getStatusColor(
                                                                      device
                                                                          .flag,
                                                                    ),
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            Text(
                                                              _getStatusText(
                                                                device.flag,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          device.category ?? '',
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          device.deviceClass ??
                                                              '',
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          device.inOutdoor ??
                                                              '',
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                            '${_currentPage + 1} / ${(_filteredDevices.length / _rowsPerPage).ceil()}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.arrow_forward,
                                            ),
                                            onPressed:
                                                (_currentPage + 1) *
                                                            _rowsPerPage <
                                                        _filteredDevices.length
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
          ),
        ],
      ),
    );
  }
}
