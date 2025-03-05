import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/models/device_model.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/scanner_utils.dart';
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
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _initialValueController = TextEditingController();
  final TextEditingController _meterIdController = TextEditingController();
  DateTime? _installDate;
  bool _isActive = true;
  int _selectedInterval = 3600; // 기본값: 1시간
  
  // 가입자 정보 변수 추가
  String? _customerName;
  String? _customerNo;
  String? _subscriberNo;
  String? _address;
  bool _isLoadingCustomer = false;
  
  @override
  void initState() {
    super.initState();
    _deviceService = DeviceService(
      baseUrl: ApiConstants.serverUrl,
    );
    _loadDeviceInfo();
    _installDate = DateTime.now();
    
    // 미터기 ID 컨트롤러에 리스너 추가
    _meterIdController.addListener(_onMeterIdChanged);
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    _initialValueController.dispose();
    _meterIdController.removeListener(_onMeterIdChanged);
    _meterIdController.dispose();
    super.dispose();
  }
  
  // 미터기 ID 변경 감지 리스너
  void _onMeterIdChanged() {
    // 디바운스 처리를 위한 타이머 추가 가능
    // 여기서는 간단하게 구현
  }
  
  // 미터기 ID로 가입자 정보 조회
  Future<void> _fetchCustomerInfo(String meterId) async {
    if (meterId.isEmpty) {
      setState(() {
        _customerName = null;
        _customerNo = null;
        _subscriberNo = null;
        _address = null;
      });
      return;
    }
    
    setState(() {
      _isLoadingCustomer = true;
    });
    
    try {
      final deviceInfo = await _deviceService.getDeviceByMeterId(meterId);
      
      setState(() {
        if (deviceInfo != null) {
          _customerName = deviceInfo.customerName;
          _customerNo = deviceInfo.customerNo;
          _subscriberNo = deviceInfo.subscriberNo;
          
          // 주소 조합
          final addressParts = [
            deviceInfo.addrProv,
            deviceInfo.addrCity,
            deviceInfo.addrDist,
            deviceInfo.addrDong,
            deviceInfo.addrDetail
          ].where((part) => part != null && part.isNotEmpty).toList();
          
          _address = addressParts.isNotEmpty ? addressParts.join(' ') : null;
        } else {
          _customerName = null;
          _customerNo = null;
          _subscriberNo = null;
          _address = null;
        }
        _isLoadingCustomer = false;
      });
    } catch (e) {
      setState(() {
        _customerName = null;
        _customerNo = null;
        _subscriberNo = null;
        _address = null;
        _isLoadingCustomer = false;
      });
    }
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
          
          // 초기값 설정
          if (_device?.lastCount != null) {
            _initialValueController.text = _device!.lastCount.toString();
          }
          
          // 미터기 ID 설정
          if (_device?.meterId != null) {
            _meterIdController.text = _device!.meterId!;
          }
          
          // 상태 설정
          _isActive = _device?.flag?.toLowerCase() == 'active' || _device?.flag?.toLowerCase() == 'normal';
          
          // 데이터 전송주기 설정
          if (_device?.refInterval != null) {
            // 분 단위를 초 단위로 변환
            _selectedInterval = (_device!.refInterval! * 60);
          }
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
  
  // String _getStatusText(String? flag) {
  //   final localizations = AppLocalizations.of(context)!;
    
  //   if (flag == null || flag.isEmpty) {
  //     return localizations.statusUnknown;
  //   }
    
  //   switch (flag.toLowerCase()) {
  //     case 'active':
  //     case 'normal':
  //       return localizations.statusNormal;
  //     case 'inactive':
  //       return localizations.statusInactive;
  //     case 'warning':
  //       return localizations.statusWarning;
  //     case 'error':
  //       return localizations.statusError;
  //     default:
  //       return flag;
  //   }
  // }
  
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
  
  Future<void> _completeInstallation() async {
    final localizations = AppLocalizations.of(context)!;
    // 설치 완료 처리 로직
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 설치 정보 업데이트를 위한 데이터 준비
      final Map<String, dynamic> updateData = {
        'device_uid': widget.deviceUid,
        'meter_id': _meterIdController.text,
        'install_date': _installDate != null 
            ? '${_installDate!.year}-${_installDate!.month.toString().padLeft(2, '0')}-${_installDate!.day.toString().padLeft(2, '0')}'
            : null,
        'initial_count': _initialValueController.text.isNotEmpty 
            ? double.tryParse(_initialValueController.text) ?? 0.0
            : 0.0,
        'ref_interval': _selectedInterval, // 초 단위
        'flag': _isActive ? 'active' : 'inactive',
        'comment': _commentController.text,
      };
      
      // 여기에 설치 완료 API 호출 로직 추가
      await _deviceService.updateDeviceInstallation(updateData);
      
      // 디버그용 로그 출력
      // print('설치 정보 업데이트: $updateData');
      
      // 임시로 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.installationCompleted)),
      );
      
      // 이전 화면으로 돌아가기
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _selectInstallDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _installDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _installDate) {
      setState(() {
        _installDate = picked;
      });
    }
  }
  

  Future<void> _openCamera() async {
    final localizations = AppLocalizations.of(context)!;
    
    // ScannerUtils 클래스를 사용하여 QR 코드 스캔
    final result = await ScannerUtils.scanQRCode(
      context: context,
      hintText: localizations.meterId,
      onSuccess: (code) {
        setState(() {
          _meterIdController.text = code;
        });
        
        // 다국어 지원 - scanCompleted 메서드 직접 호출
        final message = localizations.scanCompleted(code);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
        
        // 스캔 후 가입자 정보 조회
        if (code.isNotEmpty) {
          _fetchCustomerInfo(code);
        }
      },
    );
    
    // 결과가 있고 onSuccess 콜백이 호출되지 않은 경우 여기서 처리
    if (result != null && mounted) {
      // 이미 onSuccess에서 처리했으므로 여기서는 추가 작업 불필요
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    // 데이터 전송주기 옵션
    final List<Map<String, dynamic>> intervalOptions = [
      { 'value': 3600, 'text': localizations.r1hour },
      { 'value': 7200, 'text': localizations.r2hours },
      { 'value': 10800, 'text': localizations.r3hours },
      { 'value': 21600, 'text': localizations.r6hours },
      { 'value': 43200, 'text': localizations.r12hours },
      { 'value': 86400, 'text': localizations.r1day },
    ];
    
    // _selectedInterval 값이 intervalOptions에 없는 경우 기본값(3600)으로 설정
    if (!intervalOptions.any((option) => option['value'] == _selectedInterval)) {
      _selectedInterval = 43200; // 기본값: 12시간
    }
    
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
                                    localizations.deviceInfo,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(),
                                  _buildInfoRow(localizations.deviceUid, _device!.deviceUid),
                                  
                                  // 미터기 ID (입력 가능)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            localizations.meterId,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: TextField(
                                            controller: _meterIdController,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                            ),
                                            onChanged: (value) {
                                              if (value.isNotEmpty && value.length > 3) {
                                                _fetchCustomerInfo(value);
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.camera_alt),
                                          tooltip: localizations.scanWithCamera,
                                          onPressed: _openCamera,
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.blue.shade100,
                                            foregroundColor: Colors.blue.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // 가입자 정보 표시 영역
                                  if (_isLoadingCustomer)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8.0),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                    )
                                  else if (_customerName != null || _customerNo != null || _subscriberNo != null || _address != null)
                                    Card(
                                      color: Colors.blue.shade50,
                                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              localizations.customerInfo,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            if (_customerName != null)
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 4.0),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 100,
                                                      child: Text(
                                                        localizations.customerName,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(_customerName!),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (_customerNo != null)
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 4.0),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 100,
                                                      child: Text(
                                                        localizations.customerNo,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(_customerNo!),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (_subscriberNo != null)
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 4.0),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 100,
                                                      child: Text(
                                                        localizations.subscriberNo,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(_subscriberNo!),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (_address != null)
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 4.0),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 100,
                                                      child: Text(
                                                        localizations.address,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(_address!),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  
                                  _buildInfoRow(localizations.releaseDate, _device!.releaseDate ?? '-'),
                                  
                                  // 설치일자 (선택 가능)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            localizations.installDate,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: _selectInstallDate,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(4.0),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    _installDate != null
                                                        ? '${_installDate!.year}-${_installDate!.month.toString().padLeft(2, '0')}-${_installDate!.day.toString().padLeft(2, '0')}'
                                                        : localizations.selectDate,
                                                    style: const TextStyle(fontSize: 16),
                                                  ),
                                                  const Icon(Icons.calendar_today),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // 계량기 초기값 (입력 가능)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            localizations.initialValue,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: TextField(
                                            controller: _initialValueController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // 데이터 전송주기 (선택 가능)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            localizations.dataInterval,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.circular(4.0),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<int>(
                                                value: _selectedInterval,
                                                isExpanded: true,
                                                hint: Text('주기 선택'),
                                                items: intervalOptions.map((option) {
                                                  return DropdownMenuItem<int>(
                                                    value: option['value'],
                                                    child: Text(option['text']),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    setState(() {
                                                      _selectedInterval = value;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  _buildInfoRow(localizations.installerId, _device!.installerId ?? '-'),
                                  
                                  // 상태 (스위치로 변경)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            localizations.status,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Switch(
                                          value: _isActive,
                                          onChanged: (value) {
                                            setState(() {
                                              _isActive = value;
                                            });
                                          },
                                          activeColor: Colors.green,
                                        ),
                                        Text(
                                          _isActive ? localizations.statusNormal : localizations.statusInactive,
                                          style: TextStyle(
                                            color: _isActive ? Colors.green : Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // 코멘트 (입력 가능)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          localizations.comment,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: _commentController,
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            hintText: localizations.enterComment,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // 버튼 영역
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _completeInstallation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: Text(localizations.completeInstallation),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
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