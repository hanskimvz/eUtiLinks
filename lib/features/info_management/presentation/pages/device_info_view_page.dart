import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/models/device_model.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/constants/api_constants.dart';

class DeviceInfoViewPage extends StatefulWidget {
  final String deviceUid;

  const DeviceInfoViewPage({super.key, required this.deviceUid});

  @override
  State<DeviceInfoViewPage> createState() => _DeviceInfoViewPageState();
}

class _DeviceInfoViewPageState extends State<DeviceInfoViewPage> {
  late DeviceService _deviceService;
  DeviceModel? _device;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _deviceService = DeviceService(baseUrl: ApiConstants.serverUrl);
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final device = await _deviceService.getDeviceInfo(widget.deviceUid);
      setState(() {
        _device = device;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(value),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
      );
    }

    if (_device == null) {
      return Center(child: Text(localizations.deviceNotFound));
    }

    return Column(
      children: [
        // 모달 헤더
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${localizations.deviceInfo} - ${_device!.deviceUid}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        // 모달 내용
        Expanded(
          child: SingleChildScrollView(
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
                        _buildInfoRow(localizations.deviceUid, _device!.deviceUid),
                        _buildInfoRow(
                          '마지막 검침',
                          _device!.lastCount?.toString() ?? '-',
                        ),
                        _buildInfoRow('마지막 통신', _device!.lastAccess ?? '-'),
                        _buildInfoRow('상태', _getStatusText(_device!.flag)),
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
                        _buildInfoRow(
                          '고객명',
                          _device!.customerName ?? '-',
                        ),
                        _buildInfoRow(
                          '고객번호',
                          _device!.customerNo ?? '-',
                        ),
                        _buildInfoRow(
                          '미터기 ID',
                          _device!.meterId ?? '-',
                        ),
                        _buildInfoRow(
                          '주소',
                          [
                            _device!.addrProv,
                            _device!.addrCity,
                            _device!.addrDist,
                            _device!.addrDetail,
                            _device!.addrApt,
                          ].where((s) => s != null && s.isNotEmpty).join(' '),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 닫기 버튼 추가
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          alignment: Alignment.center,
          child: SizedBox(
            width: 120.0,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                localizations.close, // 닫기
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
