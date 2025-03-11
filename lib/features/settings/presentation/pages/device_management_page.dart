import 'package:flutter/material.dart' hide Border;
import '../../../../l10n/app_localizations.dart';
import 'package:excel/excel.dart' as excel_lib;
// import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;
// import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/painting.dart' show Border;
import '../../../../core/models/device_model.dart';
import '../../../../core/services/device_service.dart';
import 'device_info_page.dart';
import '../../../../core/constants/api_constants.dart';

class DeviceManagementPage extends StatefulWidget {
  const DeviceManagementPage({super.key});

  @override
  State<DeviceManagementPage> createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends State<DeviceManagementPage> {
  final _searchController = TextEditingController();
  List<DeviceModel> _devices = [];
  List<DeviceModel> _filteredDevices = [];
  bool _isLoading = true;
  String _errorMessage = '';
  late final DeviceService _deviceService;

  // 정렬 상태를 관리하기 위한 변수 추가
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  // 페이지네이션을 위한 변수 추가
  int _rowsPerPage = 10;
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
      final devices = await _deviceService.getDevices();

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

  Color _getStatusColor(String? flag) {
    if (flag == null || flag.isEmpty) {
      return Colors.grey;
    }

    switch (flag.toLowerCase()) {
      case 'active':
      case 'normal':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getBatteryLevelColor(int level) {
    if (level > 70) {
      return Colors.green;
    } else if (level > 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // 배터리 수준에 따른 아이콘 반환 메서드 추가
  IconData _getBatteryIcon(int level) {
    if (level > 70) {
      return Icons.battery_full;
    } else if (level > 50) {
      return Icons.battery_6_bar;
    } else if (level > 30) {
      return Icons.battery_4_bar;
    } else if (level > 15) {
      return Icons.battery_2_bar;
    } else {
      return Icons.battery_alert;
    }
  }

  String _getFormattedAddress(DeviceModel device) {
    return [
      device.addrProv,
      device.addrCity,
      device.addrDist,
      device.addrDong,
      device.addrDetail,
      device.addrApt,
    ].where((s) => s != null && s.isNotEmpty).join(' ');
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
      _currentPage = 0; // 정렬 시 첫 페이지로 이동
    });
  }

  // 페이지네이션된 데이터를 가져오는 메서드 추가
  List<DeviceModel> _getPaginatedData() {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex =
        startIndex + _rowsPerPage > _filteredDevices.length
            ? _filteredDevices.length
            : startIndex + _rowsPerPage;

    if (startIndex >= _filteredDevices.length) {
      return [];
    }

    return _filteredDevices.sublist(startIndex, endIndex);
  }

  // 엑셀 내보내기
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

      final widths = [12, 10, 12, 50, 20, 15, 22, 10, 10];
      // 헤더 추가
      sheet.appendRow([
        excel_lib.TextCellValue(localizations.deviceUid), // 단말기 UID
        excel_lib.TextCellValue(localizations.customerName), // 고객명
        excel_lib.TextCellValue(localizations.customerNo), // 고객번호
        excel_lib.TextCellValue(localizations.address), // 주소
        excel_lib.TextCellValue(localizations.meterId), // 미터기 ID
        excel_lib.TextCellValue(localizations.lastCount), // 마지막 검침
        excel_lib.TextCellValue(localizations.lastAccess), // 마지막 통신
        excel_lib.TextCellValue(localizations.status), // 상태
        excel_lib.TextCellValue(localizations.battery), // 배터리
      ]);

      // 헤더 행 높이 설정
      sheet.setRowHeight(0, 20);
      for (var i = 0; i < widths.length; i++) {
        sheet.setColumnWidth(i, widths[i].toDouble());

        final cell = sheet.cell(
          excel_lib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.cellStyle = excelCustomStyleHead;
      }

      // 데이터 추가
      for (var i = 0; i < _filteredDevices.length; i++) {
        final device = _filteredDevices[i];
        sheet.appendRow([
          excel_lib.TextCellValue(device.deviceUid),
          excel_lib.TextCellValue(device.customerName ?? ''),
          excel_lib.TextCellValue(device.customerNo ?? ''),
          excel_lib.TextCellValue(_getFormattedAddress(device)),
          excel_lib.TextCellValue(device.meterId?.toString() ?? ''),
          excel_lib.TextCellValue(device.lastCount?.toString() ?? ''),
          excel_lib.TextCellValue(device.lastAccess ?? ''),
          excel_lib.TextCellValue(_getStatusText(device.flag)),
          excel_lib.TextCellValue(
            device.battery != null ? '${device.battery.toString()}%' : '',
          ),
        ]);

        // 각 데이터 행의 높이 설정
        sheet.setRowHeight(i + 1, 20);
        for (var j = 0; j < widths.length; j++) {
          final cell = sheet.cell(
            excel_lib.CellIndex.indexByColumnRow(
              columnIndex: j,
              rowIndex: i + 1,
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
        // 데스크톱/모바일 환경에서의 다운로드 처리 - 제거
        // 이 부분은 더 이상 실행되지 않음
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizations.excelFileSaved)));
      }
    } catch (e) {
      // print('Excel export error: $e');
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

  void _showBulkAddDeviceDialog() {
    final localizations = AppLocalizations.of(context)!;
    final deviceUidsController = TextEditingController();
    final releaseDateController = TextEditingController();
    final installerIdController = TextEditingController();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.bulkDeviceRegistration),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.deviceUidListDescription,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: deviceUidsController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: 'F68C057D\nA149490D\nB123456E',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: releaseDateController,
                    decoration: InputDecoration(
                      labelText: localizations.releaseDate,
                      hintText: 'YYYY-MM-DD',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: installerIdController,
                    decoration: InputDecoration(
                      labelText: localizations.installerId,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final deviceUids =
                        deviceUidsController.text
                            .split('\n')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();

                    if (deviceUids.isEmpty) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(localizations.enterAtLeastOneDeviceUid),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (releaseDateController.text.isEmpty) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(localizations.enterReleaseDate),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (installerIdController.text.isEmpty) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(localizations.enterInstallerId),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.of(context).pop();
                    setState(() => _isLoading = true);

                    for (final uid in deviceUids) {
                      final newDevice = DeviceModel(
                        deviceUid: uid,
                        flag: 'active',
                        lastCount: 0,
                        battery: 100,
                        releaseDate: releaseDateController.text,
                        installerId: installerIdController.text,
                      );

                      await _deviceService.addDevice(newDevice);
                    }

                    await _loadDevices();

                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            localizations.devicesRegisteredSuccess(
                              deviceUids.length,
                            ),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    setState(() => _isLoading = false);
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            '${localizations.deviceRegistrationFailed}: $e',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(localizations.register),
              ),
            ],
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
            localizations.deviceManagement,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.deviceManagementDescription,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // 검색 및 버튼 영역
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: localizations.searchDevice,
                    hintText: localizations.searchDeviceHint,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: _filterDevices,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showBulkAddDeviceDialog,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(localizations.bulkDeviceRegistration),
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
                onPressed: _loadDevices,
                icon: const Icon(Icons.refresh),
                tooltip: localizations.refresh,
              ),
              IconButton(
                onPressed: _exportToExcel,
                icon: const Icon(Icons.file_download),
                tooltip: localizations.exportToExcel,
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
                    title: localizations.totalDevices,
                    value: _devices.length.toString(),
                    icon: Icons.devices,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    title: localizations.activeDevices,
                    value:
                        _devices
                            .where(
                              (d) =>
                                  d.flag?.toLowerCase() == 'active' ||
                                  d.flag?.toLowerCase() == 'normal',
                            )
                            .length
                            .toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    title: localizations.inactiveDevices,
                    value:
                        _devices
                            .where(
                              (d) =>
                                  d.flag?.toLowerCase() == 'inactive' ||
                                  d.flag == null ||
                                  d.flag!.isEmpty,
                            )
                            .length
                            .toString(),
                    icon: Icons.cancel,
                    color: Colors.grey,
                  ),
                  _buildStatCard(
                    title: localizations.needsAttention,
                    value:
                        _devices
                            .where((d) => d.battery != null && d.battery! < 30)
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 테이블 타이틀 추가
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                localizations.deviceList, // 단말기 목록
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // 기존 테이블 내용을 Expanded로 감싸기
                            Expanded(
                              child: SingleChildScrollView(
                                child: DataTable(
                                  sortColumnIndex: _sortColumnIndex,
                                  sortAscending: _sortAscending,
                                  headingRowHeight: 36,
                                  dataRowMinHeight: 36,
                                  dataRowMaxHeight: 36,
                                  horizontalMargin: 20,
                                  columnSpacing: 30,
                                  showCheckboxColumn: false,
                                  columns: [
                                    DataColumn(
                                      label: Text(localizations.deviceUid),
                                      onSort: (columnIndex, ascending) {
                                        _sort<String>(
                                          (device) => device.deviceUid,
                                          columnIndex,
                                          ascending,
                                        );
                                      },
                                    ),
                                    DataColumn(
                                      label: Text(localizations.customerName),
                                      onSort: (columnIndex, ascending) {
                                        _sort<String>(
                                          (device) => device.customerName ?? '',
                                          columnIndex,
                                          ascending,
                                        );
                                      },
                                    ),
                                    DataColumn(
                                      label: Text(localizations.customerNo),
                                      onSort: (columnIndex, ascending) {
                                        _sort<String>(
                                          (device) => device.customerNo ?? '',
                                          columnIndex,
                                          ascending,
                                        );
                                      },
                                    ),
                                    DataColumn(
                                      label: Text(localizations.address),
                                      onSort: (columnIndex, ascending) {
                                        _sort<String>(
                                          (device) =>
                                              _getFormattedAddress(device),
                                          columnIndex,
                                          ascending,
                                        );
                                      },
                                    ),
                                    DataColumn(
                                      label: Text(localizations.meterId),
                                      onSort: (columnIndex, ascending) {
                                        _sort<String>(
                                          (device) => device.meterId ?? '',
                                          columnIndex,
                                          ascending,
                                        );
                                      },
                                    ),
                                    DataColumn(
                                      label: Text(localizations.lastCount),
                                      onSort: (columnIndex, ascending) {
                                        _sort<num>(
                                          (device) => device.lastCount ?? 0,
                                          columnIndex,
                                          ascending,
                                        );
                                      },
                                    ),
                                    DataColumn(
                                      label: Text(localizations.lastAccess),
                                      onSort: (columnIndex, ascending) {
                                        _sort<String>(
                                          (device) => device.lastAccess ?? '',
                                          columnIndex,
                                          ascending,
                                        );
                                      },
                                    ),
                                    DataColumn(
                                      label: Text(localizations.status),
                                      onSort: (columnIndex, ascending) {
                                        _sort<num>(
                                          (device) =>
                                              _getStatusValue(device.flag),
                                          columnIndex,
                                          ascending,
                                        );
                                      },
                                    ),
                                    DataColumn(
                                      label: Text(localizations.battery),
                                      onSort: (columnIndex, ascending) {
                                        _sort<num>(
                                          (device) => device.battery ?? 0,
                                          columnIndex,
                                          ascending,
                                        );
                                      },
                                    ),
                                  ],
                                  rows:
                                      _getPaginatedData().map((device) {
                                        final address = _getFormattedAddress(
                                          device,
                                        );

                                        return DataRow(
                                          onSelectChanged: (_) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => DeviceInfoPage(
                                                      deviceUid:
                                                          device.deviceUid,
                                                    ),
                                              ),
                                            );
                                          },
                                          cells: [
                                            DataCell(
                                              Text(
                                                device.deviceUid,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                device.customerName ?? '-',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                device.customerNo ?? '-',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                address.isEmpty ? '-' : address,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                device.meterId ?? '-',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                device.lastCount?.toString() ??
                                                    '-',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                device.lastAccess ?? '-',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color: _getStatusColor(
                                                        device.flag,
                                                      ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      _getStatusText(
                                                        device.flag,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    device.battery != null
                                                        ? _getBatteryIcon(
                                                          device.battery!,
                                                        )
                                                        : Icons.battery_unknown,
                                                    color:
                                                        device.battery != null
                                                            ? _getBatteryLevelColor(
                                                              device.battery!,
                                                            )
                                                            : Colors.grey,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    device.battery != null
                                                        ? '${device.battery}%'
                                                        : '알 수 없음',
                                                    style: TextStyle(
                                                      color:
                                                          device.battery != null
                                                              ? _getBatteryLevelColor(
                                                                device.battery!,
                                                              )
                                                              : Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),

                            // 페이지네이션 컨트롤 추가
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text('${localizations.rowsPerPage}: '),
                                      DropdownButton<int>(
                                        value: _rowsPerPage,
                                        items:
                                            const [10, 20, 50, 100].map((
                                              int value,
                                            ) {
                                              return DropdownMenuItem<int>(
                                                value: value,
                                                child: Text('$value'),
                                              );
                                            }).toList(),
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
                                        icon: const Icon(Icons.first_page),
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
                                        icon: const Icon(Icons.chevron_left),
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
                                        icon: const Icon(Icons.chevron_right),
                                        onPressed:
                                            _currentPage <
                                                    (_filteredDevices.length /
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
                                        icon: const Icon(Icons.last_page),
                                        onPressed:
                                            _currentPage <
                                                    (_filteredDevices.length /
                                                                _rowsPerPage)
                                                            .ceil() -
                                                        1
                                                ? () {
                                                  setState(() {
                                                    _currentPage =
                                                        (_filteredDevices
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  int _getStatusValue(String? flag) {
    if (flag == null || flag.isEmpty) {
      return 0;
    }

    switch (flag.toLowerCase()) {
      case 'active':
      case 'normal':
        return 1;
      case 'inactive':
        return 0;
      case 'warning':
        return 2;
      case 'error':
        return 3;
      default:
        return 0;
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
}
