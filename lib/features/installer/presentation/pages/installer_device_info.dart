import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/models/device_model.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../home/presentation/widgets/main_layout.dart';

class InstallerDeviceInfoPage extends StatefulWidget {
  final String deviceUid;
  
  const InstallerDeviceInfoPage({
    super.key,
    required this.deviceUid,
  });

  @override
  State<InstallerDeviceInfoPage> createState() => _InstallerDeviceInfoPageState();
}

class _InstallerDeviceInfoPageState extends State<InstallerDeviceInfoPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  DeviceModel? _device;
  late final DeviceService _deviceService;
  
  @override
  void initState() {
    super.initState();
    _deviceService = DeviceService(
      baseUrl: ApiConstants.serverUrl,
    );
    _loadDeviceInfo();
  }
  
  Future<void> _loadDeviceInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // 장치 UID로 장치 정보 조회
      final devices = await _deviceService.getDevicesWithFilter(
        filter: {'device_uid': widget.deviceUid},
      );
      
      if (devices.isNotEmpty) {
        setState(() {
          _device = devices.first;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = '장치를 찾을 수 없습니다.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getAddressText() {
    final List<String?> addressParts = [
      _device?.addrProv,
      _device?.addrCity,
      _device?.addrDist,
      _device?.addrDong,
      _device?.addrDetail,
    ];
    
    final fullAddress = addressParts
        .where((part) => part != null && part.isNotEmpty)
        .join(' ');
    
    return fullAddress.isEmpty ? '-' : fullAddress;
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return MainLayout(
      title: localizations.deviceInfo,
      selectedMainMenuIndex: 3, // Installer menu
      selectedSubMenuIndex: 0,
      onSubMenuSelected: (_) {},
      hideSidebar: true,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : _device == null
                  ? Center(
                      child: Text(localizations.deviceNotFound),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations.basicInfo,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(),
                                  _buildInfoRow(localizations.deviceUid, _device!.deviceUid),
                                  _buildInfoRow(localizations.meterId, _device!.meterId ?? '-'),
                                  _buildInfoRow(localizations.status, _getStatusText(_device!.flag)),
                                  _buildInfoRow(localizations.releaseDate, _device!.releaseDate ?? '-'),
                                  _buildInfoRow(localizations.lastAccess, _device!.lastAccess ?? '-'),
                                  _buildInfoRow(localizations.battery, '${_device!.battery ?? '-'}%'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations.customerInfo,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(),
                                  _buildInfoRow(localizations.customerName, _device!.customerName ?? '-'),
                                  _buildInfoRow(localizations.customerNo, _device!.customerNo ?? '-'),
                                  _buildInfoRow(localizations.address, _getAddressText()),
                                  _buildInfoRow(localizations.lastCount, _device!.lastCount?.toString() ?? '-'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(localizations.cancel),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
} 