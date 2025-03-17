import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/models/subscriber_model.dart';
import '../../../../core/services/subscriber_service.dart';
import '../../../../core/constants/api_constants.dart';

class SubscriberInfoPage extends StatefulWidget {
  final String meterId;

  const SubscriberInfoPage({super.key, required this.meterId});

  @override
  State<SubscriberInfoPage> createState() => _SubscriberInfoPageState();
}

class _SubscriberInfoPageState extends State<SubscriberInfoPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  SubscriberModel? _subscriber;
  late final SubscriberService _subscriberService;

  // 모든 필드에 대한 컨트롤러 추가
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerNoController = TextEditingController();
  final TextEditingController _subscriberNoController = TextEditingController();
  final TextEditingController _meterIdController = TextEditingController();
  final TextEditingController _addrCityController = TextEditingController();
  final TextEditingController _addrDistController = TextEditingController();
  final TextEditingController _addrDongController = TextEditingController();
  final TextEditingController _addrRoadController = TextEditingController();
  final TextEditingController _addrDetailController = TextEditingController();
  final TextEditingController _addrAptController = TextEditingController();
  final TextEditingController _shareHouseController = TextEditingController();
  final TextEditingController _bindDeviceIdController = TextEditingController();
  final TextEditingController _bindDateController = TextEditingController();

  // 드롭다운 선택 값
  String? _selectedCategory;
  String? _selectedSubscriberClass;
  String? _selectedInOutdoor;
  bool _binded = false;

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
  List<String> _getSubscriberClassOptions(AppLocalizations localizations) {
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
    _subscriberService = SubscriberService(baseUrl: ApiConstants.serverUrl);
    _loadSubscriberInfo();
  }

  @override
  void dispose() {
    // 모든 컨트롤러 해제
    _customerNameController.dispose();
    _customerNoController.dispose();
    _subscriberNoController.dispose();
    _meterIdController.dispose();
    _addrCityController.dispose();
    _addrDistController.dispose();
    _addrDongController.dispose();
    _addrRoadController.dispose();
    _addrDetailController.dispose();
    _addrAptController.dispose();
    _shareHouseController.dispose();
    _bindDeviceIdController.dispose();
    _bindDateController.dispose();
    super.dispose();
  }

  Future<void> _loadSubscriberInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final subscriber = await _subscriberService.getSubscriberByMeterId(
        widget.meterId,
      );

      setState(() {
        _subscriber = subscriber;
        _isLoading = false;
        
        // 모든 컨트롤러 초기값 설정
        _customerNameController.text = subscriber.customerName ?? '';
        _customerNoController.text = subscriber.customerNo ?? '';
        _subscriberNoController.text = subscriber.subscriberNo ?? '';
        _meterIdController.text = subscriber.meterId ?? '';
        _addrCityController.text = subscriber.addrCity ?? '';
        _addrDistController.text = subscriber.addrDist ?? '';
        _addrDongController.text = subscriber.addrDong ?? '';
        _addrRoadController.text = subscriber.addrRoad ?? '';
        _addrDetailController.text = subscriber.addrDetail ?? '';
        _addrAptController.text = subscriber.addrApt ?? '';
        _shareHouseController.text = subscriber.shareHouse ?? '';
        _bindDeviceIdController.text = subscriber.bindDeviceId ?? '';
        _bindDateController.text = _getFormattedBindDate(subscriber.bindDate);
        
        // 드롭다운 초기값 설정
        _selectedCategory = _getCategoryOptions(AppLocalizations.of(context)!).contains(subscriber.category) 
            ? subscriber.category 
            : null;
        _selectedSubscriberClass = _getSubscriberClassOptions(AppLocalizations.of(context)!).contains(subscriber.subscriberClass) 
            ? subscriber.subscriberClass 
            : null;
        _selectedInOutdoor = _getInOutdoorOptions(AppLocalizations.of(context)!).contains(subscriber.inOutdoor) 
            ? subscriber.inOutdoor 
            : null;
        _binded = subscriber.binded ?? false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSubscriberInfo() async {
    if (_subscriber == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 업데이트할 구독자 데이터 생성
      final Map<String, dynamic> updatedData = {
        'subscriber_id': _subscriber!.subscriberId,
        'customer_name': _customerNameController.text,
        'customer_no': _customerNoController.text,
        'subscriber_no': _subscriberNoController.text,
        'meter_id': _meterIdController.text,
        'addr_city': _addrCityController.text,
        'addr_dist': _addrDistController.text,
        'addr_dong': _addrDongController.text,
        'addr_road': _addrRoadController.text,
        'addr_detail': _addrDetailController.text,
        'addr_apt': _addrAptController.text,
        'share_house': _shareHouseController.text,
        'category': _selectedCategory,
        'class': _selectedSubscriberClass,
        'in_outdoor': _selectedInOutdoor,
        'bind_device_id': _bindDeviceIdController.text,
        'bind_date': _bindDateController.text,
        'binded': _binded,
      };

      await _subscriberService.updateSubscriber(
        _subscriber!.subscriberId,
        updatedData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.subscriberEditedSuccess),
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

  String _getFormattedBindDate(String? bindDate) {
    if (bindDate == null || bindDate.isEmpty) {
      return '';
    }

    // 밀리초 부분 제거 (점 이후 부분 제거)
    final parts = bindDate.split('.');
    return parts[0];
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 1200;
    final contentWidth = screenWidth > 600 ? 600.0 : screenWidth;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.subscriberInfo),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.subscriberInfo),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSubscriberInfo,
                child: Text(localizations.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_subscriber == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.subscriberInfo),
        ),
        body: Center(child: Text(localizations.subscriberNotFound)),
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
            _buildInfoRow('ID', _subscriber!.subscriberId),
            _buildInfoRow(localizations.customerName, '', readOnly: false, controller: _customerNameController),
            _buildInfoRow(localizations.customerNo, '', readOnly: false, controller: _customerNoController),
            _buildInfoRow(localizations.subscriberNo, '', readOnly: false, controller: _subscriberNoController),
            _buildInfoRow(localizations.meterId, '', readOnly: false, controller: _meterIdController),
            _buildSwitchRow('연결됨', _binded, (value) {
              setState(() {
                _binded = value;
              });
            }),
            
            const SizedBox(height: 24),
            Text(
              localizations.contractInfo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdownRow(localizations.category, _selectedCategory, _getCategoryOptions(localizations), (value) {
              setState(() {
                _selectedCategory = value;
              });
            }),
            _buildDropdownRow(localizations.subscriberClass, _selectedSubscriberClass, _getSubscriberClassOptions(localizations), (value) {
              setState(() {
                _selectedSubscriberClass = value;
              });
            }),
            _buildDropdownRow(localizations.inOutdoor, _selectedInOutdoor, _getInOutdoorOptions(localizations), (value) {
              setState(() {
                _selectedInOutdoor = value;
              });
            }),
          ],
        ),
      ),
    );

    // 주소 및 장치 정보 카드
    final addressDeviceCard = Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.addressInfo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(localizations.city, '', readOnly: false, controller: _addrCityController),
            _buildInfoRow(localizations.district, '', readOnly: false, controller: _addrDistController),
            _buildInfoRow('동', '', readOnly: false, controller: _addrDongController),
            _buildInfoRow('도로명', '', readOnly: false, controller: _addrRoadController),
            _buildInfoRow(localizations.detailAddress, '', readOnly: false, controller: _addrDetailController),
            _buildInfoRow(localizations.apartment, '', readOnly: false, controller: _addrAptController),
            _buildInfoRow(localizations.shareHouse, '', readOnly: false, controller: _shareHouseController),
            
            const SizedBox(height: 24),
            Text(
              localizations.deviceInfo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(localizations.bindDeviceId, _bindDeviceIdController.text),
            _buildInfoRow(localizations.bindDate, _bindDateController.text),
          ],
        ),
      ),
    );

    // 버튼 행
    final buttonRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _saveSubscriberInfo,
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
        title: Text('${localizations.subscriberInfo} - ${_subscriber!.meterId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: localizations.refresh,
            onPressed: _loadSubscriberInfo,
          ),
        ],
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
                          child: addressDeviceCard,
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
                      addressDeviceCard,
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
