import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  @override
  void initState() {
    super.initState();
    _deviceService = DeviceService(
      baseUrl: ApiConstants.serverUrl,
    );
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
        _filteredDevices = _devices.where((device) {
          final searchFields = [
            device.deviceUid,
            device.customerName ?? '',
            device.customerNo ?? '',
            device.meterId ?? '',
            _getFormattedAddress(device),
          ].map((s) => s.toLowerCase());
          
          return searchFields.any((field) => field.contains(query.toLowerCase()));
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

  void _sort<T>(Comparable<T> Function(DeviceModel device) getField, int columnIndex, bool ascending) {
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
      final sheet = excel['장치 목록'];
      
      // 헤더 추가
      sheet.appendRow([
        TextCellValue('단말기 UID'),
        TextCellValue('고객명'),
        TextCellValue('고객번호'),
        TextCellValue('주소'),
        TextCellValue('미터기 ID'),
        TextCellValue('마지막 검침'),
        TextCellValue('마지막 통신'),
        TextCellValue('상태'),
        TextCellValue('배터리'),
      ]);
      
      // 데이터 추가
      for (final device in _filteredDevices) {
        sheet.appendRow([
          TextCellValue(device.deviceUid),
          TextCellValue(device.customerName ?? ''),
          TextCellValue(device.customerNo ?? ''),
          TextCellValue(_getFormattedAddress(device)),
          TextCellValue(device.meterId ?? ''),
          TextCellValue(device.lastCount?.toString() ?? ''),
          TextCellValue(device.lastAccess ?? ''),
          TextCellValue(_getStatusText(device.flag)),
          TextCellValue(device.battery?.toString() ?? ''),
        ]);
      }

      final fileName = '장치목록_${DateTime.now().toString().split('.')[0].replaceAll(':', '-')}.xlsx';
      
      if (kIsWeb) {
        // 웹 환경에서의 다운로드 처리
        final bytes = excel.encode()!;
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.excelFileSaved)),
        );
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
      builder: (context) => AlertDialog(
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
                final deviceUids = deviceUidsController.text
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
                        localizations.devicesRegisteredSuccess(deviceUids.length),
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
                        '${localizations.deviceRegistrationFailed}: $e'
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
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.deviceManagementDescription,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                    value: _devices.where((d) => d.flag?.toLowerCase() == 'active' || d.flag?.toLowerCase() == 'normal').length.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    title: localizations.inactiveDevices,
                    value: _devices.where((d) => d.flag?.toLowerCase() == 'inactive' || d.flag == null || d.flag!.isEmpty).length.toString(),
                    icon: Icons.cancel,
                    color: Colors.grey,
                  ),
                  _buildStatCard(
                    title: localizations.needsAttention,
                    value: _devices.where((d) => d.battery != null && d.battery! < 30).length.toString(),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                    : Card(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dataTableTheme: DataTableThemeData(
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              dataTextStyle: const TextStyle(
                                color: Colors.black87,
                              ),
                              headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                              dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.hovered)) {
                                    return Colors.blue.withValues(
                                      red: Colors.blue.r.toDouble(),
                                      green: Colors.blue.g.toDouble(),
                                      blue: Colors.blue.b.toDouble(),
                                      alpha: 0.1 * 255,
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              // 헤더 부분 (고정)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: MediaQuery.of(context).size.width - 64,
                                  ),
                                  child: DataTable(
                                    showCheckboxColumn: false,
                                    sortColumnIndex: _sortColumnIndex,
                                    sortAscending: _sortAscending,
                                    headingRowHeight: 56,
                                    // dataRowHeight: 0,
                                    dividerThickness: 1,
                                    columnSpacing: 56.0,
                                    columns: [
                                      DataColumn(
                                        label: Text(localizations.deviceUid),
                                        onSort: (columnIndex, ascending) {
                                          _sort<String>((device) => device.deviceUid, columnIndex, ascending);
                                        },
                                      ),
                                      DataColumn(
                                        label: Text(localizations.customerName),
                                        onSort: (columnIndex, ascending) {
                                          _sort<String>((device) => device.customerName ?? '', columnIndex, ascending);
                                        },
                                      ),
                                      DataColumn(
                                        label: Text(localizations.customerNo),
                                        onSort: (columnIndex, ascending) {
                                          _sort<String>((device) => device.customerNo ?? '', columnIndex, ascending);
                                        },
                                      ),
                                      DataColumn(
                                        label: Text(localizations.address),
                                        onSort: (columnIndex, ascending) {
                                          _sort<String>((device) => _getFormattedAddress(device), columnIndex, ascending);
                                        },
                                      ),
                                      DataColumn(
                                        label: Text(localizations.meterId),
                                        onSort: (columnIndex, ascending) {
                                          _sort<String>((device) => device.meterId ?? '', columnIndex, ascending);
                                        },
                                      ),
                                      DataColumn(
                                        label: Text(localizations.lastCount),
                                        onSort: (columnIndex, ascending) {
                                          _sort<num>((device) => device.lastCount ?? 0, columnIndex, ascending);
                                        },
                                      ),
                                      DataColumn(
                                        label: Text(localizations.lastAccess),
                                        onSort: (columnIndex, ascending) {
                                          _sort<String>((device) => device.lastAccess ?? '', columnIndex, ascending);
                                        },
                                      ),
                                      DataColumn(
                                        label: Text(localizations.status),
                                        onSort: (columnIndex, ascending) {
                                          _sort<num>((device) => _getStatusValue(device.flag), columnIndex, ascending);
                                        },
                                      ),
                                      DataColumn(
                                        label: Text(localizations.battery),
                                        onSort: (columnIndex, ascending) {
                                          _sort<num>((device) => device.battery ?? 0, columnIndex, ascending);
                                        },
                                      ),
                                    ],
                                    rows: const [],
                                  ),
                                ),
                              ),
                              
                              // 데이터 부분 (스크롤)
                              Expanded(
                                child: SingleChildScrollView(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: MediaQuery.of(context).size.width - 64,
                                      ),
                                      child: DataTable(
                                        showCheckboxColumn: false,
                                        sortColumnIndex: _sortColumnIndex,
                                        sortAscending: _sortAscending,
                                        headingRowHeight: 0,
                                        columnSpacing: 56.0,
                                        columns: [
                                          DataColumn(label: Container()),
                                          DataColumn(label: Container()),
                                          DataColumn(label: Container()),
                                          DataColumn(label: Container()),
                                          DataColumn(label: Container()),
                                          DataColumn(label: Container()),
                                          DataColumn(label: Container()),
                                          DataColumn(label: Container()),
                                          DataColumn(label: Container()),
                                        ],
                                        rows: _filteredDevices.map((device) {
                                          final address = _getFormattedAddress(device);
                                          
                                          return DataRow(
                                            onSelectChanged: (_) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => DeviceInfoPage(
                                                    deviceUid: device.deviceUid,
                                                  ),
                                                ),
                                              );
                                            },
                                            cells: [
                                              DataCell(Text(device.deviceUid)),
                                              DataCell(Text(device.customerName ?? '-')),
                                              DataCell(Text(device.customerNo ?? '-')),
                                              DataCell(Text(address.isEmpty ? '-' : address)),
                                              DataCell(Text(device.meterId ?? '-')),
                                              DataCell(Text(device.lastCount?.toString() ?? '-')),
                                              DataCell(Text(device.lastAccess ?? '-')),
                                              DataCell(
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 12,
                                                      height: 12,
                                                      decoration: BoxDecoration(
                                                        color: _getStatusColor(device.flag),
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(_getStatusText(device.flag)),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                device.battery != null
                                                    ? Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            width: 50,
                                                            height: 10,
                                                            decoration: BoxDecoration(
                                                              color: _getBatteryLevelColor(device.battery!),
                                                              borderRadius: BorderRadius.circular(5),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Text('${device.battery}%'),
                                                        ],
                                                      )
                                                    : const Text('-'),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
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