import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../l10n/app_localizations.dart';
import 'dart:async';
import '../../../../core/models/device_model.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/services/subscriber_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/scanner_utils.dart';
import '../../../home/presentation/widgets/main_layout.dart';
import './installation_confirm_page.dart';

class InstallerDeviceInfoPage extends StatefulWidget {
  final String deviceUid;

  const InstallerDeviceInfoPage({super.key, required this.deviceUid});

  @override
  State<InstallerDeviceInfoPage> createState() =>
      _InstallerDeviceInfoPageState();
}

class _InstallerDeviceInfoPageState extends State<InstallerDeviceInfoPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  DeviceModel? _device;
  late final DeviceService _deviceService;
  late final SubscriberService _subscriberService;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _initialValueController = TextEditingController();
  final TextEditingController _meterIdController = TextEditingController();
  DateTime? _installDate;
  bool _isActive = true;
  int _selectedInterval = 43200; // 기본값: 12시간

  // 가입자 정보 변수 추가
  String? _customerName;
  String? _customerNo;
  String? _subscriberNo;
  String? _address;
  bool _isLoadingCustomer = false;

  // 디바운스 타이머 추가
  Timer? _debounceTimer;

  // 스낵바 컨트롤러 추가
  ScaffoldFeatureController? _currentSnackBar;

  @override
  void initState() {
    super.initState();
    _deviceService = DeviceService(baseUrl: ApiConstants.serverUrl);
    _subscriberService = SubscriberService(baseUrl: ApiConstants.serverUrl);
    _loadDeviceInfo();
    _installDate = DateTime.now();

    // 미터기 ID 컨트롤러에 리스너 추가
    _meterIdController.addListener(_onMeterIdChanged);

    // 초기값 컨트롤러에 리스너 추가
    _initialValueController.addListener(_checkButtonState);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _initialValueController.removeListener(_checkButtonState);
    _initialValueController.dispose();
    _meterIdController.removeListener(_onMeterIdChanged);
    _meterIdController.dispose();
    // 타이머 취소
    _debounceTimer?.cancel();
    super.dispose();
  }

  // 스낵바 표시 메서드 (중복 방지)
  void _showSnackBar(String message, {Color backgroundColor = Colors.black}) {
    // 이전 스낵바가 있으면 닫기
    if (_currentSnackBar != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    // 새 스낵바 표시
    _currentSnackBar = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  // 미터기 ID 변경 감지 리스너
  void _onMeterIdChanged() {
    // 디바운스 처리
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    final meterId = _meterIdController.text;

    // 미터기 ID가 비어있으면 가입자 정보 초기화
    if (meterId.isEmpty) {
      setState(() {
        _customerName = null;
        _customerNo = null;
        _subscriberNo = null;
        _address = null;
      });
      _checkButtonState();
      return;
    }

    // 500ms 후에 가입자 정보 조회
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      _fetchCustomerInfo(meterId);
    });

    // 버튼 상태 확인
    _checkButtonState();
  }

  // 버튼 상태 확인 메서드
  void _checkButtonState() {
    // setState를 호출하여 버튼 상태 업데이트
    setState(() {
      // 상태 변경 없이 리빌드만 트리거
    });
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
      _checkButtonState();
      return;
    }

    // 이미 로딩 중이면 중복 요청 방지
    if (_isLoadingCustomer) return;

    setState(() {
      _isLoadingCustomer = true;
    });

    try {
      // DeviceService 대신 SubscriberService 사용
      final subscriber = await _subscriberService.getSubscriberByMeterId(
        meterId,
      );

      // 마운트 상태 확인
      if (!mounted) return;

      setState(() {
        if (subscriber.customerName != null ||
            subscriber.customerNo != null ||
            subscriber.subscriberNo != null) {
          _customerName = subscriber.customerName;
          _customerNo = subscriber.customerNo;
          _subscriberNo = subscriber.subscriberNo;

          // 주소 조합 (SubscriberModel에 맞게 수정)
          final addressParts =
              [
                subscriber.addrProv,
                subscriber.addrCity,
                subscriber.addrDist,
                subscriber.addrDetail,
                subscriber.addrApt,
              ].where((part) => part != null && part.isNotEmpty).toList();

          _address = addressParts.isNotEmpty ? addressParts.join(' ') : null;
        } else {
          _customerName = null;
          _customerNo = null;
          _subscriberNo = null;
          _address = null;

          // 가입자 정보가 없을 때 메시지 표시 (선택적)
          if (mounted) {
            _showSnackBar(
              '미터기 ID에 해당하는 가입자 정보가 없습니다.',
              backgroundColor: Colors.orange,
            );
          }
        }
        _isLoadingCustomer = false;
        _checkButtonState();
      });
    } catch (e) {
      // 마운트 상태 확인
      if (!mounted) return;

      setState(() {
        _customerName = null;
        _customerNo = null;
        _subscriberNo = null;
        _address = null;
        _isLoadingCustomer = false;
      });
      _checkButtonState();

      // 오류 발생 시 메시지 표시
      if (mounted) {
        _showSnackBar('가입자 정보 조회 중 오류가 발생했습니다', backgroundColor: Colors.red);
      }
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

            // 미터기 ID가 있으면 가입자 정보 조회
            _fetchCustomerInfo(_device!.meterId!);
          }

          // 상태 설정
          _isActive =
              _device?.flag?.toLowerCase() == 'active' ||
              _device?.flag?.toLowerCase() == 'normal';
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Future<void> _completeInstallation() async {
    final localizations = AppLocalizations.of(context)!;

    // 활성 상태일 때만 미터기 ID와 계량기 초기값 필수 검증
    if (_isActive) {
      if (_meterIdController.text.isEmpty) {
        _showSnackBar('미터기 ID를 입력해주세요.', backgroundColor: Colors.red);
        return;
      }

      if (_initialValueController.text.isEmpty) {
        _showSnackBar('계량기 초기값을 입력해주세요.', backgroundColor: Colors.red);
        return;
      }

      // 가입자 정보 확인 (활성 상태일 때만)
      if (_customerName == null &&
          _customerNo == null &&
          _subscriberNo == null) {
        _showSnackBar('가입자 정보를 확인하세요.', backgroundColor: Colors.red);
        return;
      }
    } else {
      // 비활성 상태(해제)일 때는 미터기 ID만 필수
      if (_meterIdController.text.isEmpty) {
        _showSnackBar('미터기 ID를 입력해주세요.', backgroundColor: Colors.red);
        return;
      }
    }

    // 설치 완료 처리 로직
    setState(() {
      _isLoading = true;
    });

    try {
      // API 요청 데이터 준비
      final Map<String, dynamic> requestData = {
        'action': _isActive ? 'bind' : 'unbind',
        'data': {
          'device_uid': widget.deviceUid,
          'meter_id': _meterIdController.text,
          'install_date':
              _installDate != null
                  ? '${_installDate!.year.toString()}-${_installDate!.month.toString().padLeft(2, '0')}-${_installDate!.day.toString().padLeft(2, '0')}'
                  : null,
          'initial_count':
              _initialValueController.text.isNotEmpty
                  ? double.tryParse(_initialValueController.text) ?? 0.0
                  : 0.0,
          'ref_interval': _selectedInterval, // 초 단위
          'comment': _commentController.text,
          'flag': _isActive ? true : false,
        },
      };
      // print(requestData);

      // API 호출
      await _deviceService.bindDeviceInstallation(requestData);

      // 성공 메시지 표시
      if (mounted) {
        _showSnackBar(
          _isActive ? localizations.installationCompleted : '해제가 완료되었습니다.',
        );

        if (_isActive) {
          // 활성 상태일 때만 설치 확인 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      InstallationConfirmPage(deviceUid: widget.deviceUid),
            ),
          );
        } else {
          // 비활성 상태(해제)일 때는 installer_page로 이동
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });

        // 오류 메시지 표시
        _showSnackBar(
          '설치 완료 처리 중 오류가 발생했습니다: ${e.toString()}',
          backgroundColor: Colors.red,
        );
      }
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
        _showSnackBar(message);

        // 스캔 후 가입자 정보 즉시 조회 (디바운스 없이)
        if (code.isNotEmpty) {
          // 진행 중인 디바운스 타이머가 있으면 취소
          _debounceTimer?.cancel();
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
      {'value': 3600, 'text': localizations.r1hour},
      {'value': 7200, 'text': localizations.r2hours},
      {'value': 10800, 'text': localizations.r3hours},
      {'value': 21600, 'text': localizations.r6hours},
      {'value': 43200, 'text': localizations.r12hours},
      {'value': 86400, 'text': localizations.r1day},
    ];

    // _selectedInterval 값이 intervalOptions에 없는 경우 기본값(3600)으로 설정
    if (!intervalOptions.any(
      (option) => option['value'] == _selectedInterval,
    )) {
      _selectedInterval = 43200; // 기본값: 12시간
    }

    return MainLayout(
      title: localizations.deviceInfo,
      selectedMainMenuIndex: 3, // Installer menu
      selectedSubMenuIndex: 0,
      onSubMenuSelected: (_) {},
      hideSidebar: true,
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
              : _device == null
              ? Center(child: Text(localizations.deviceNotFound))
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
                            _buildInfoRow(
                              localizations.deviceUid,
                              _device!.deviceUid,
                            ),

                            // 미터기 ID (입력 가능)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: Row(
                                      children: [
                                        Text(
                                          localizations.meterId,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (_isActive)
                                          Text(
                                            ' *',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _meterIdController,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                          vertical: 8.0,
                                        ),
                                        hintText:
                                            _isActive ? '필수 입력 항목입니다' : null,
                                      ),
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                            else if (_customerName != null ||
                                _customerNo != null ||
                                _subscriberNo != null ||
                                _address != null)
                              Card(
                                color: Colors.blue.shade50,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          padding: const EdgeInsets.only(
                                            bottom: 4.0,
                                          ),
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
                                          padding: const EdgeInsets.only(
                                            bottom: 4.0,
                                          ),
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
                                          padding: const EdgeInsets.only(
                                            bottom: 4.0,
                                          ),
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
                                          padding: const EdgeInsets.only(
                                            bottom: 4.0,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                              Expanded(child: Text(_address!)),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                            _buildInfoRow(
                              localizations.releaseDate,
                              _device!.releaseDate ?? '-',
                            ),

                            // 설치일자 (선택 가능)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
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
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal: 12.0,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4.0,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _installDate != null
                                                  ? '${_installDate!.year}-${_installDate!.month.toString().padLeft(2, '0')}-${_installDate!.day.toString().padLeft(2, '0')}'
                                                  : localizations.selectDate,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
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
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: Row(
                                      children: [
                                        Text(
                                          localizations.initialValue,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (_isActive)
                                          Text(
                                            ' *',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _initialValueController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9.]'),
                                        ),
                                      ],
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                          vertical: 8.0,
                                        ),
                                        hintText:
                                            _isActive ? '필수 입력 항목입니다' : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 데이터 전송주기 (선택 가능)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(
                                          4.0,
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: _selectedInterval,
                                          isExpanded: true,
                                          hint: Text('주기 선택'),
                                          items:
                                              intervalOptions.map((option) {
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

                            _buildInfoRow(
                              localizations.installerId,
                              _device!.installerId ?? '-',
                            ),

                            // 상태 (스위치로 변경)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
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
                                    _isActive
                                        ? localizations.statusNormal
                                        : localizations.statusInactive,
                                    style: TextStyle(
                                      color:
                                          _isActive
                                              ? Colors.green
                                              : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_isActive)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16.0,
                                      ),
                                      child: Text(
                                        '(미터기 ID와 계량기 초기값 필수)',
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 10,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // 코멘트 (입력 가능)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
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
                          onPressed:
                              _isButtonEnabled() ? _completeInstallation : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isActive ? Colors.green : Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            // 비활성화 상태일 때의 스타일
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.grey.shade600,
                          ),
                          child: Text(
                            _isActive
                                ? localizations.completeInstallation
                                : localizations.completeUninstallation,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
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

  // 버튼 활성화 여부 확인 메서드
  bool _isButtonEnabled() {
    if (_isLoadingCustomer) {
      return false; // 가입자 정보 로딩 중일 때는 비활성화
    }

    if (_isActive) {
      // 설치완료 버튼 - 활성 상태일 때
      return _meterIdController.text.isNotEmpty &&
          _initialValueController.text.isNotEmpty &&
          (_customerName != null ||
              _customerNo != null ||
              _subscriberNo != null);
    } else {
      // 해제완료 버튼 - 비활성 상태일 때
      return _meterIdController.text.isNotEmpty;
    }
  }
}
