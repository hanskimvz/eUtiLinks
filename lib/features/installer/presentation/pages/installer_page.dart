import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/menu_constants.dart';
import '../../../../core/constants/auth_service.dart';
import '../../../../core/models/device_model.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../home/presentation/widgets/main_layout.dart';
import 'package:image_picker/image_picker.dart';
import 'installer_device_info.dart';

class InstallerPage extends StatefulWidget {
  const InstallerPage({super.key});

  @override
  State<InstallerPage> createState() => _InstallerPageState();
}

class _InstallerPageState extends State<InstallerPage> {
  int _selectedSubMenuIndex = 0;
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

  void _onSubMenuSelected(int index) {
    setState(() {
      _selectedSubMenuIndex = index;
    });
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 로그인한 사용자 정보 가져오기
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('로그인 정보를 찾을 수 없습니다.');
      }

      final loginId = currentUser['id'];
      
      // installer_id 필터를 적용하여 장치 목록 가져오기
      final devices = await _deviceService.getDevicesWithFilter(
        filter: {'installer_id': loginId},
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
        _filteredDevices = _devices.where((device) {
          final searchFields = [
            device.deviceUid,
            device.meterId ?? '',
            device.releaseDate ?? '',
            device.flag ?? '',
          ].map((s) => s.toLowerCase());
          
          return searchFields.any((field) => field.contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  void _navigateToDeviceInfo(String deviceUid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstallerDeviceInfoPage(deviceUid: deviceUid),
      ),
    );
  }

  String _getStatusText(String? flag) {
    final localizations = AppLocalizations.of(context)!;
    
    if (flag == null || flag.isEmpty) {
      return localizations.statusUnknown;
    }
    
    switch (flag.toLowerCase()) {
      case 'active':
      case 'normal':
        return localizations.statusNormal;
      case 'inactive':
        return localizations.statusInactive;
      case 'warning':
        return localizations.statusWarning;
      case 'error':
        return localizations.statusError;
      default:
        return flag;
    }
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

  Future<void> _logout() async {
    final localizations = AppLocalizations.of(context)!;
    // 로그아웃 확인 다이얼로그 표시
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.logoutTitle),
        content: Text(localizations.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.logout),
          ),
        ],
      ),
    ) ?? false;
    
    if (shouldLogout) {
      await AuthService.logout();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  Future<void> _openCamera() async {
    final localizations = AppLocalizations.of(context)!;
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      
      if (photo != null) {
        // 여기서 이미지를 처리하는 로직을 추가할 수 있습니다.
        // 예: QR 코드 스캔, 바코드 인식 등
        
        // 임시로 스낵바 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.imageCaptured(photo.path)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.cameraError('$e')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return MainLayout(
      title: MenuConstants.getInstaller(context),
      selectedMainMenuIndex: 3,
      selectedSubMenuIndex: _selectedSubMenuIndex,
      onSubMenuSelected: _onSubMenuSelected,
      onLogout: _logout,
      hideSidebar: true,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   localizations.installerMenu,
            //   style: const TextStyle(
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // const SizedBox(height: 16),
            // Text(
            //   localizations.installerPageDescription,
            //   style: const TextStyle(
            //     fontSize: 16,
            //     color: Colors.grey,
            //   ),
            // ),
            // const SizedBox(height: 24),
            
            // 검색 영역
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: localizations.deviceSearch,
                      hintText: localizations.deviceSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: _filterDevices,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _openCamera,
                  icon: const Icon(Icons.camera_alt),
                  tooltip: localizations.scanWithCamera,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _loadDevices,
                  icon: const Icon(Icons.refresh),
                  tooltip: localizations.refresh,
                ),
              ],
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
                                    if (states.contains(WidgetState.selected)) {
                                      return Theme.of(context).colorScheme.primary.withValues(
                                        red: Theme.of(context).colorScheme.primary.r,
                                        green: Theme.of(context).colorScheme.primary.g,
                                        blue: Theme.of(context).colorScheme.primary.b,
                                        alpha: 0.08 * 255,
                                      );
                                    }
                                    if (states.contains(WidgetState.hovered)) {
                                      return Colors.grey.withValues(
                                        red: Colors.grey.r,
                                        green: Colors.grey.g,
                                        blue: Colors.grey.b,
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
                                Container(
                                  color: Colors.grey[100],
                                  child: Row(
                                    children: [
                                      _buildHeaderCell(localizations.deviceUid, 0, flex: 2),
                                      _buildHeaderCell(localizations.releaseDate, 1, flex: 1),
                                      _buildHeaderCell(localizations.meterId, 2, flex: 2),
                                      _buildHeaderCell(localizations.status, 3, flex: 1),
                                    ],
                                  ),
                                ),
                                // 데이터 부분 (스크롤 가능)
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _filteredDevices.length,
                                    itemBuilder: (context, index) {
                                      final device = _filteredDevices[index];
                                      return InkWell(
                                        onTap: () => _navigateToDeviceInfo(device.deviceUid),
                                        onHover: (isHovering) {
                                          // hover 상태 변경 시 UI 업데이트
                                          if (isHovering) {
                                            setState(() {
                                              // 필요한 경우 hover 상태 관리 로직 추가
                                            });
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: index % 2 == 0 
                                                ? Colors.white 
                                                : Colors.grey[50],
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey[300]!,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              _buildDataCell(device.deviceUid, flex: 2),
                                              _buildDataCell(device.releaseDate ?? '', flex: 1),
                                              _buildDataCell(device.meterId ?? '', flex: 2),
                                              _buildDataCell(_getStatusText(device.flag), flex: 1),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 헤더 셀 위젯
  Widget _buildHeaderCell(String text, int columnIndex, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () {
          _sort<String>(
            (device) {
              switch (columnIndex) {
                case 0:
                  return device.deviceUid;
                case 1:
                  return device.releaseDate ?? '';
                case 2:
                  return device.meterId ?? '';
                case 3:
                  return device.flag ?? '';
                default:
                  return '';
              }
            },
            columnIndex,
            _sortColumnIndex == columnIndex ? !_sortAscending : true,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold))),
              if (_sortColumnIndex == columnIndex)
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 데이터 셀 위젯
  Widget _buildDataCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
} 