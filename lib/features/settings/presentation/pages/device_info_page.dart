import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/models/device_model.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/constants/api_constants.dart';

class DeviceInfoPage extends StatefulWidget {
  final String deviceUid;

  const DeviceInfoPage({super.key, required this.deviceUid});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  late DeviceService _deviceService;
  DeviceModel? _device;
  bool _isLoading = true;
  String _errorMessage = '';

  // 모든 필드에 대한 컨트롤러 추가
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerNoController = TextEditingController();
  final TextEditingController _meterIdController = TextEditingController();
  final TextEditingController _releaseDateController = TextEditingController();
  final TextEditingController _installerIdController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _initialCountController = TextEditingController();
  final TextEditingController _installDateController = TextEditingController();
  final TextEditingController _maximumController = TextEditingController();
  final TextEditingController _minimumController = TextEditingController();
  final TextEditingController _refIntervalController = TextEditingController();
  final TextEditingController _serverIpController = TextEditingController();
  final TextEditingController _serverPortController = TextEditingController();
  final TextEditingController _addrProvController = TextEditingController();
  final TextEditingController _addrCityController = TextEditingController();
  final TextEditingController _addrDistController = TextEditingController();
  final TextEditingController _addrDongController = TextEditingController();
  final TextEditingController _addrDetailController = TextEditingController();
  final TextEditingController _addrAptController = TextEditingController();
  final TextEditingController _subscriberNoController = TextEditingController();
  
  // 드롭다운 선택 값
  String? _selectedCategory;
  String? _selectedDeviceClass;
  String? _selectedInOutdoor;
  bool _shareHouse = false;
  String _deviceStatus = 'inactive';
  int? _selectedRefInterval;

  // 카테고리 옵션
  List<String> _getCategoryOptions(AppLocalizations localizations) {
    return [
      localizations.categoryResidential, // 주택용
      localizations.categoryCookingHeating, // 취사난방용
      localizations.categoryCookingOnly,
      localizations.categoryHeatingOnly,
      localizations.categoryOther,
    ];
  }

  // 등급 옵션
  List<String> _getDeviceClassOptions(AppLocalizations localizations) {
    return [
      localizations.deviceClass25, // 2.5(G1.6)
      localizations.deviceClass4, // 4(G2.5)
      localizations.deviceClass6, // 6(G4)
      localizations.deviceClass10, // 10(G6)
      localizations.deviceClass16, // 16(G10)
      localizations.deviceClass25G16, // 25(G16)
      localizations.deviceClass40, // 40(G25)
      localizations.deviceClass65, // 65(G40)
      localizations.deviceClass100,
      localizations.deviceClass160,
      localizations.deviceClass250,
      localizations.deviceClass400,
      localizations.deviceClass650,
      localizations.deviceClass1000,
    ];
  }

  // 실내/실외 옵션
  List<String> _getInOutdoorOptions(AppLocalizations localizations) {
    return [
      localizations.indoor, // 실내
      localizations.outdoor, // 실외
    ];
  }



  @override
  void initState() {
    super.initState();
    _deviceService = DeviceService(baseUrl: ApiConstants.serverUrl);
    _loadDeviceInfo();
  }

  @override
  void dispose() {
    // 모든 컨트롤러 해제
    _customerNameController.dispose();
    _customerNoController.dispose();
    _meterIdController.dispose();
    _releaseDateController.dispose();
    _installerIdController.dispose();
    _commentController.dispose();
    _initialCountController.dispose();
    _installDateController.dispose();
    _maximumController.dispose();
    _minimumController.dispose();
    _refIntervalController.dispose();
    _serverIpController.dispose();
    _serverPortController.dispose();
    _addrProvController.dispose();
    _addrCityController.dispose();
    _addrDistController.dispose();
    _addrDongController.dispose();
    _addrDetailController.dispose();
    _addrAptController.dispose();
    _subscriberNoController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final device = await _deviceService.getDeviceInfo(widget.deviceUid);
      setState(() {
        _device = device;
        _isLoading = false;
        
        // 모든 컨트롤러 초기값 설정
        _customerNameController.text = device.customerName ?? '';
        _customerNoController.text = device.customerNo ?? '';
        _meterIdController.text = device.meterId ?? '';
        _releaseDateController.text = device.releaseDate ?? '';
        _installerIdController.text = device.installerId ?? '';
        _commentController.text = device.comment ?? '';
        _initialCountController.text = device.initialCount?.toString() ?? '';
        _installDateController.text = device.installDate ?? '';
        _maximumController.text = device.maximum?.toString() ?? '';
        _minimumController.text = device.minimum?.toString() ?? '';
        _refIntervalController.text = device.refInterval?.toString() ?? '';
        _serverIpController.text = device.serverIp ?? '';
        _serverPortController.text = device.serverPort?.toString() ?? '';
        _addrProvController.text = device.addrProv ?? '';
        _addrCityController.text = device.addrCity ?? '';
        _addrDistController.text = device.addrDist ?? '';
        _addrDongController.text = device.addrDong ?? '';
        _addrDetailController.text = device.addrDetail ?? '';
        _addrAptController.text = device.addrApt ?? '';
        _subscriberNoController.text = device.subscriberNo ?? '';
        
        // 드롭다운 초기값 설정 - 유효한 값인지 확인
        _selectedCategory = _getCategoryOptions(AppLocalizations.of(context)!).contains(device.category) ? device.category : null;
        _selectedDeviceClass = _getDeviceClassOptions(AppLocalizations.of(context)!).contains(device.deviceClass) ? device.deviceClass : null;
        _selectedInOutdoor = _getInOutdoorOptions(AppLocalizations.of(context)!).contains(device.inOutdoor) ? device.inOutdoor : null;
        _shareHouse = device.shareHouse ?? false;
        _deviceStatus = device.flag?.toLowerCase() ?? 'inactive';
        
        // 통신간격 초기값 설정
        _selectedRefInterval = device.refInterval;
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
      // 업데이트할 디바이스 모델 생성
      final updatedDevice = DeviceModel(
        deviceUid: _device!.deviceUid,
        customerName: _customerNameController.text,
        customerNo: _customerNoController.text,
        meterId: _meterIdController.text,
        releaseDate: _releaseDateController.text,
        installerId: _installerIdController.text,
        comment: _commentController.text,
        initialCount: int.tryParse(_initialCountController.text),
        installDate: _installDateController.text,
        maximum: int.tryParse(_maximumController.text),
        minimum: int.tryParse(_minimumController.text),
        refInterval: _selectedRefInterval,
        serverIp: _serverIpController.text,
        serverPort: int.tryParse(_serverPortController.text),
        lastCount: _device!.lastCount,
        lastAccess: _device!.lastAccess,
        flag: _deviceStatus,
        uptime: _device!.uptime,
        initialAccess: _device!.initialAccess,
        battery: _device!.battery,
        lastTimestamp: _device!.lastTimestamp,
        addrProv: _addrProvController.text,
        addrCity: _addrCityController.text,
        addrDist: _addrDistController.text,
        addrDong: _addrDongController.text,
        addrDetail: _addrDetailController.text,
        addrApt: _addrAptController.text,
        category: _selectedCategory,
        deviceClass: _selectedDeviceClass,
        subscriberNo: _subscriberNoController.text,
        inOutdoor: _selectedInOutdoor,
        shareHouse: _shareHouse,
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
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value, {bool readOnly = true, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
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
            child: readOnly
                ? Text(value)
                : TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // 초 단위 시간을 일, 시간, 분, 초로 변환하는 함수
  String _formatUptime(int seconds) {
    final localizations = AppLocalizations.of(context)!;
    int days = seconds ~/ 86400;
    int hours = (seconds % 86400) ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    
    return '$days${localizations.days}$hours${localizations.hours}$minutes${localizations.minutes}$remainingSeconds${localizations.secondsUnit}';
  }

  Widget _buildDropdownRow(String label, String? value, List<String> options, Function(String?) onChanged) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
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
            child: Container(
              height: 36.0,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: options.contains(value) ? value : null,
                  hint: Text(localizations.pleaseSelect),
                  isDense: true,
                  items: options.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
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
            child: Align(
              alignment: Alignment.centerLeft,
              child: Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalDropdown() {
    final localizations = AppLocalizations.of(context)!;
    final List<Map<String, dynamic>> localizedOptions = [
      {'value': 3600, 'text': localizations.r1hour},
      {'value': 7200, 'text': localizations.r2hours},
      {'value': 10800, 'text': localizations.r3hours},
      {'value': 21600, 'text': localizations.r6hours},
      {'value': 43200, 'text': localizations.r12hours},
      {'value': 86400, 'text': localizations.r1day},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              localizations.dataInterval,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              height: 36.0,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _selectedRefInterval,
                  hint: Text(localizations.pleaseSelect),
                  isDense: true,
                  items: localizedOptions.map((Map<String, dynamic> item) {
                    return DropdownMenuItem<int>(
                      value: item['value'],
                      child: Text(
                        item['text'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRefInterval = value;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryIndicator(int? batteryLevel) {
    final localizations = AppLocalizations.of(context)!;
    final level = batteryLevel ?? 0;
    Color batteryColor;
    IconData batteryIcon;

    if (level >= 80) {
      batteryColor = Colors.green;
      batteryIcon = Icons.battery_full;
    } else if (level >= 50) {
      batteryColor = Colors.lightGreen;
      batteryIcon = Icons.battery_5_bar;
    } else if (level >= 30) {
      batteryColor = Colors.orange;
      batteryIcon = Icons.battery_3_bar;
    } else if (level >= 15) {
      batteryColor = Colors.deepOrange;
      batteryIcon = Icons.battery_2_bar;
    } else {
      batteryColor = Colors.red;
      batteryIcon = Icons.battery_1_bar;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              localizations.battery,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Icon(
                  batteryIcon,
                  color: batteryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '$level%',
                  style: TextStyle(
                    color: batteryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSwitch() {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              localizations.status,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: _deviceStatus == 'active' || _deviceStatus == 'normal',
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        _deviceStatus = value ? 'active' : 'inactive';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(_deviceStatus),
                  style: TextStyle(
                    color: _getStatusColor(_deviceStatus),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? flag) {
    switch (flag?.toLowerCase()) {
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

  String _getStatusText(String? flag) {
    final localizations = AppLocalizations.of(context)!;
    
    if (flag == null || flag.isEmpty) {
      return localizations.null_value;
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 1200;
    final contentWidth = screenWidth > 600 ? 600.0 : screenWidth;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.deviceInfo),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.deviceInfo),
        ),
        body: Center(
          child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (_device == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.deviceInfo),
        ),
        body: Center(child: Text(localizations.deviceNotFound)),
      );
    }

    // 기본 정보 카드
    final basicInfoCard = Card(
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
            _buildInfoRow(localizations.releaseDate, '', readOnly: false, controller: _releaseDateController),
            _buildInfoRow(localizations.installerId, '', readOnly: false, controller: _installerIdController),
            _buildStatusSwitch(),
            _buildInfoRow(localizations.initialValue, '', readOnly: false, controller: _initialCountController),
            _buildInfoRow(localizations.installDate, '', readOnly: false, controller: _installDateController),
            _buildInfoRow(localizations.maximum, '', readOnly: false, controller: _maximumController),
            _buildInfoRow(localizations.minimum, '', readOnly: false, controller: _minimumController),
            _buildIntervalDropdown(),
            _buildInfoRow(localizations.serverIp, '', readOnly: false, controller: _serverIpController),
            _buildInfoRow(localizations.serverPort, '', readOnly: false, controller: _serverPortController),
            _buildBatteryIndicator(_device!.battery),
            _buildInfoRow(localizations.initialCommunication, _device!.initialAccess ?? '-'),
            _buildInfoRow(localizations.lastCommunicationTime, _device!.lastAccess ?? '-'),
            _buildInfoRow(localizations.lastCount, _device!.lastCount?.toString() ?? '-'),
            _buildInfoRow(localizations.lastTimestamp, _device!.lastTimestamp?.toString() ?? '-'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      localizations.uptime,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        Text('${_device!.uptime}${localizations.seconds}'),
                        const SizedBox(width: 8),
                        Text(
                          '(${_formatUptime(_device!.uptime ?? 0)})',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildInfoRow(localizations.comment, '', readOnly: false, controller: _commentController),
          ],
        ),
      ),
    );

    // 고객 정보 카드
    final customerInfoCard = Card(
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
            _buildInfoRow(localizations.customerName, '', readOnly: false, controller: _customerNameController),
            _buildInfoRow(localizations.customerNo, '', readOnly: false, controller: _customerNoController),
            _buildInfoRow(localizations.subscriberNo, '', readOnly: false, controller: _subscriberNoController),
            _buildInfoRow(localizations.meterId, '', readOnly: false, controller: _meterIdController),
            _buildDropdownRow(localizations.category, _selectedCategory, _getCategoryOptions(localizations), (value) {
              setState(() {
                _selectedCategory = value;
              });
            }),
            _buildDropdownRow(localizations.subscriberClass, _selectedDeviceClass, _getDeviceClassOptions(localizations), (value) {
              setState(() {
                _selectedDeviceClass = value;
              });
            }),
            _buildDropdownRow(localizations.inOutdoor, _selectedInOutdoor, _getInOutdoorOptions(localizations), (value) {
              setState(() {
                _selectedInOutdoor = value;
              });
            }),
            _buildSwitchRow(localizations.shareHouse, _shareHouse, (value) {
              setState(() {
                _shareHouse = value;
              });
            }),
            const SizedBox(height: 24),
            Text(
              localizations.addressInfo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(localizations.province, '', readOnly: false, controller: _addrProvController),
            _buildInfoRow(localizations.city, '', readOnly: false, controller: _addrCityController),
            _buildInfoRow(localizations.district, '', readOnly: false, controller: _addrDistController),
            _buildInfoRow(localizations.district, '', readOnly: false, controller: _addrDongController),
            _buildInfoRow(localizations.detailAddress, '', readOnly: false, controller: _addrDetailController),
            _buildInfoRow(localizations.apartment, '', readOnly: false, controller: _addrAptController),
          ],
        ),
      ),
    );

    // 버튼 행
    final buttonRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _saveDeviceInfo,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
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
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${localizations.deviceInfo} - ${_device!.deviceUid}'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: isWideScreen
              ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: contentWidth,
                          margin: const EdgeInsets.only(right: 8.0),
                          child: basicInfoCard,
                        ),
                        Container(
                          width: contentWidth,
                          margin: const EdgeInsets.only(left: 8.0),
                          child: customerInfoCard,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    buttonRow,
                    const SizedBox(height: 16),
                  ],
                )
              : SizedBox(
                  width: contentWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      basicInfoCard,
                      const SizedBox(height: 16),
                      customerInfoCard,
                      const SizedBox(height: 16),
                      buttonRow,
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
