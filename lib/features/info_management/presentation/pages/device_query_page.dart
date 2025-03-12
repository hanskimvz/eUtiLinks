import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../l10n/app_localizations.dart';
// import 'package:excel/excel.dart' hide Border, BorderStyle;
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/models/device_model.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/constants/api_constants.dart';
import 'package:excel/excel.dart' as excel_lib;
import './device_info_view_page.dart';

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

    // 웹 환경이 아닌 경우 메시지 표시 후 종료
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이 기능은 웹 환경에서만 사용 가능합니다.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final excelCustomStyleHead = excel_lib.CellStyle(
      bold: true,
      fontColorHex: excel_lib.ExcelColor.fromHexString("#FFFFFF"),
      backgroundColorHex: excel_lib.ExcelColor.fromHexString("#10E0AF"),
      horizontalAlign: excel_lib.HorizontalAlign.Center,
      verticalAlign: excel_lib.VerticalAlign.Center,
      leftBorder: excel_lib.Border(
        borderStyle: excel_lib.BorderStyle.Thin,
        borderColorHex: excel_lib.ExcelColor.fromHexString('#0A0A0A'),
      ),
      rightBorder: excel_lib.Border(
        borderStyle: excel_lib.BorderStyle.Thin,
        borderColorHex: excel_lib.ExcelColor.fromHexString('#0A0A0A'),
      ),
      bottomBorder: excel_lib.Border(
        borderStyle: excel_lib.BorderStyle.Thin,
        borderColorHex: excel_lib.ExcelColor.fromHexString('#0A0A0A'),
      ),
      topBorder: excel_lib.Border(
        borderStyle: excel_lib.BorderStyle.Thin,
        borderColorHex: excel_lib.ExcelColor.fromHexString('#0A0A0A'),
      ),
    );

    final excelCustomStyle = excel_lib.CellStyle(
      horizontalAlign: excel_lib.HorizontalAlign.Center,
      verticalAlign: excel_lib.VerticalAlign.Center,
      leftBorder: excel_lib.Border(
        borderStyle: excel_lib.BorderStyle.Thin,
        borderColorHex: excel_lib.ExcelColor.fromHexString('#0A0A0A'),
      ),
      rightBorder: excel_lib.Border(
        borderStyle: excel_lib.BorderStyle.Thin,
        borderColorHex: excel_lib.ExcelColor.fromHexString('#0A0A0A'),
      ),
      bottomBorder: excel_lib.Border(
        borderStyle: excel_lib.BorderStyle.Thin,
        borderColorHex: excel_lib.ExcelColor.fromHexString('#0A0A0A'),
      ),
      topBorder: excel_lib.Border(
        borderStyle: excel_lib.BorderStyle.Thin,
        borderColorHex: excel_lib.ExcelColor.fromHexString('#0A0A0A'),
      ),
    );
    try {
      // Excel 파일 생성
      final excel = excel_lib.Excel.createExcel();
      // 기본 시트 사용 (Sheet1)
      final defaultSheet = excel.sheets.keys.first;
      final sheet = excel[defaultSheet];

      // 헤더 추가
      final headers = [
        'No',
        localizations.customerName,
        localizations.customerNo,
        localizations.lastCount,
        localizations.province,
        localizations.city,
        localizations.district,
        localizations.detailAddress,
        localizations.apartment,
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
      sheet.appendRow(headers.map((header) => excel_lib.TextCellValue(header.toString())).toList());
      // 헤더 행 높이 설정
      sheet.setRowHeight(0, 20);      

      // 컬럼 너비 설정
      final columnWidths = [
        6.0, // No
        15.0, // 고객명
        12.0, // 고객번호
        10.0, // 마지막 검침값
        8.0,  // 도
        8.0,  // 시
        8.0,  // 구
        30.0, // 상세주소
        15.0, // 아파트
        10.0, // 공동주택
        12.0, // 카테고리
        15.0, // 가입자번호
        15.0, // 미터기 ID
        20.0, // 디바이스 UID
        22.0, // 마지막 접속
        10.0, // 상태
        10.0, // 가입자 분류
        10.0, // 실내/실외
      ];
      
      // 열 너비 설정, head 스타일 적용
      for (var i = 0; i < columnWidths.length && i < headers.length; i++) {
        sheet.setColumnWidth(i, columnWidths[i].toDouble());

        final cell = sheet.cell(
          excel_lib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.cellStyle = excelCustomStyleHead;
      }

      // 데이터 추가
      for (var rowIndex = 0; rowIndex < _filteredDevices.length; rowIndex++) {
        final device = _filteredDevices[rowIndex];
        final rowData = [
          excel_lib.TextCellValue((rowIndex + 1).toString()),
          excel_lib.TextCellValue(device.customerName ?? ''),
          excel_lib.TextCellValue(device.customerNo ?? ''),
          excel_lib.TextCellValue(device.lastCount?.toString() ?? ''),
          excel_lib.TextCellValue(device.addrProv ?? ''),
          excel_lib.TextCellValue(device.addrCity ?? ''),
          excel_lib.TextCellValue(device.addrDist ?? ''),
          excel_lib.TextCellValue(device.addrDetail ?? ''),
          excel_lib.TextCellValue(device.addrApt ?? ''),
          excel_lib.TextCellValue(_flagToSymbol(device.shareHouse)),
          excel_lib.TextCellValue(device.category ?? ''),
          excel_lib.TextCellValue(device.subscriberNo ?? ''),
          excel_lib.TextCellValue(device.meterId ?? ''),
          excel_lib.TextCellValue(device.deviceUid),
          excel_lib.TextCellValue(device.lastAccess ?? ''),
          excel_lib.TextCellValue(_getStatusText(device.flag)),
          excel_lib.TextCellValue(device.deviceClass ?? ''),
          excel_lib.TextCellValue(device.inOutdoor ?? ''),
        ];

        sheet.appendRow(rowData);
        // 각 데이터 행의 높이 설정
        sheet.setRowHeight(rowIndex + 1, 20);        
        
        // 데이터 셀 스타일 적용
        for (var j = 0; j < rowData.length; j++) {
          final cell = sheet.cell(
            excel_lib.CellIndex.indexByColumnRow(
              columnIndex: j,
              rowIndex: rowIndex + 1,
            ),
          );
          cell.cellStyle = excelCustomStyle;
        }
      }

      // 시트 이름 변경 - 파일 저장 직전으로 이동
      excel.rename(defaultSheet, localizations.deviceList); // 장치 목록

      final fileName =
          '${localizations.deviceList}_${DateTime.now().toString().split('.')[0].replaceAll(':', '-')}.xlsx';

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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
                title:  Text(localizations.deviceInfo),
                onTap: () {
                  Navigator.pop(context);
                  _showDeviceInfo(device);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.show_chart, color: Colors.green),
                title:  Text(localizations.usageQuery),
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
                title:  Text(localizations.abnormalMeterQuery),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            width: 600,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(0),
            child: DeviceInfoViewPage(
              deviceUid: device.deviceUid,
            ),
          ),
        );
      },
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
          Text(localizations.deviceInfo,
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
          const SizedBox(height: 10),

          // 통계 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
          const SizedBox(height: 10),

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
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        child:
                            _filteredDevices.isEmpty
                                ? const Center(child: Text('데이터가 없습니다.'))
                                : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 6.0,
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
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                minWidth: constraints.minWidth,
                                              ),
                                              child: SingleChildScrollView(
                                                child: DataTable(
                                                  sortColumnIndex: _sortColumnIndex,
                                                  sortAscending: _sortAscending,
                                                  headingRowHeight: 40,
                                                  dataRowMinHeight: 32,
                                                  dataRowMaxHeight: 36,
                                                  horizontalMargin: 20,
                                                  columnSpacing: constraints.maxWidth < 800 ? 10 : 20,
                                                  showCheckboxColumn: false,
                                                  columns: [
                                                    DataColumn(
                                                      label: Expanded(
                                                        child: Text(
                                                          localizations.customerName,
                                                        ),
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
                                                      label: Expanded(
                                                        child: Text(
                                                          localizations.customerNo,
                                                        ),
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
                                                      label: Expanded(
                                                        child: Text(
                                                          localizations.address,
                                                        ),
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
                                                      label: Expanded(
                                                        child: Text(
                                                          localizations.meterId,
                                                        ),
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
                                                      label: Expanded(
                                                        child: Text(
                                                          localizations.deviceUid,
                                                        ),
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
                                                      label: Expanded(
                                                        child: Text(
                                                          localizations.lastCount,
                                                        ),
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
                                                      label: Expanded(
                                                        child: Text(
                                                          localizations.lastAccess,
                                                        ),
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
                                                      label: Expanded(
                                                        child: Text(
                                                          localizations.status,
                                                        ),
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
                                                      label: Expanded(
                                                        child: Text(
                                                          localizations.category,
                                                        ),
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
                                                      label: Expanded(
                                                        child: Text(
                                                          localizations.subscriberClass,
                                                        ),
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
                                                      label: Expanded(
                                                        child: Text(
                                                          localizations.inOutdoor,
                                                        ),
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
                                          );
                                        },
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
