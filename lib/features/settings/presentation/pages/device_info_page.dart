import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/models/device_model.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/constants/api_constants.dart';

class DeviceInfoPage extends StatefulWidget {
  final String deviceUid;

  const DeviceInfoPage({
    super.key,
    required this.deviceUid,
  });

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  late DeviceService _deviceService;
  DeviceModel? _device;
  bool _isLoading = true;
  String _errorMessage = '';
  
  // 컨트롤러 추가
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerNoController = TextEditingController();
  final TextEditingController _meterIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _deviceService = DeviceService(
      baseUrl: ApiConstants.serverUrl,
    );
    _loadDeviceInfo();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerNoController.dispose();
    _meterIdController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final device = await _deviceService.getDeviceInfo(widget.deviceUid);
      setState(() {
        _device = device;
        _isLoading = false;
        // 컨트롤러 초기값 설정
        _customerNameController.text = device.customerName ?? '';
        _customerNoController.text = device.customerNo ?? '';
        _meterIdController.text = device.meterId ?? '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDeviceInfo() async {
    if (_device == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedDevice = DeviceModel(
        deviceUid: _device!.deviceUid,
        customerName: _customerNameController.text,
        customerNo: _customerNoController.text,
        meterId: _meterIdController.text,
        lastCount: _device!.lastCount,
        lastAccess: _device!.lastAccess,
        flag: _device!.flag,
        uptime: _device!.uptime,
        initialAccess: _device!.initialAccess,
        battery: _device!.battery,
        addrProv: _device!.addrProv,
        addrCity: _device!.addrCity,
        addrDist: _device!.addrDist,
        addrDetail: _device!.addrDetail,
        addrApt: _device!.addrApt,
      );

      await _deviceService.updateDevice(updatedDevice);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.deviceEditedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value, {bool readOnly = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: readOnly
                ? Text(value)
                : TextFormField(
                    controller: label == '고객명'
                        ? _customerNameController
                        : label == '고객번호'
                            ? _customerNoController
                            : _meterIdController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_device == null) {
      return Center(
        child: Text(localizations.deviceNotFound),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${localizations.deviceInfo} - ${_device!.deviceUid}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.basicInfo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('단말기 UID', _device!.deviceUid),
                    _buildInfoRow('마지막 검침', _device!.lastCount?.toString() ?? '-'),
                    _buildInfoRow('마지막 통신', _device!.lastAccess ?? '-'),
                    _buildInfoRow('상태', _device!.flag ? '활성' : '비활성'),
                    _buildInfoRow('가동시간', _device!.uptime.toString()),
                    _buildInfoRow('초기 통신', _device!.initialAccess ?? '-'),
                    _buildInfoRow('배터리', '${_device!.battery ?? 0}%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.customerInfo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('고객명', _device!.customerName ?? '-', readOnly: false),
                    _buildInfoRow('고객번호', _device!.customerNo ?? '-', readOnly: false),
                    _buildInfoRow('미터기 ID', _device!.meterId ?? '-', readOnly: false),
                    _buildInfoRow('주소', [
                      _device!.addrProv,
                      _device!.addrCity,
                      _device!.addrDist,
                      _device!.addrDetail,
                      _device!.addrApt,
                    ].where((s) => s != null && s.isNotEmpty).join(' ')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveDeviceInfo,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(localizations.save),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(localizations.cancel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 