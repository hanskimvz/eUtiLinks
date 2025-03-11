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

  @override
  void initState() {
    super.initState();
    _subscriberService = SubscriberService(baseUrl: ApiConstants.serverUrl);
    _loadSubscriberInfo();
  }

  Future<void> _loadSubscriberInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // print('meterId: ${widget.meterId}');
      final subscriber = await _subscriberService.getSubscriberByMeterId(
        widget.meterId,
      );

      setState(() {
        _subscriber = subscriber;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getFormattedAddress(SubscriberModel subscriber) {
    return [
      subscriber.addrProv,
      subscriber.addrCity,
      subscriber.addrDist,
      subscriber.addrDetail,
      subscriber.addrApt,
    ].where((s) => s != null && s.isNotEmpty).join(' ');
  }

  String _getFormattedBindDate(String? bindDate) {
    if (bindDate == null || bindDate.isEmpty) {
      return '-';
    }

    // 밀리초 부분 제거 (점 이후 부분 제거)
    final parts = bindDate.split('.');
    return parts[0];
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.subscriberInfo),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: localizations.edit,
            onPressed: () {
              // 구독자 정보 수정 페이지로 이동
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: localizations.refresh,
            onPressed: _loadSubscriberInfo,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
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
              )
              : _subscriber == null
              ? Center(child: Text(localizations.subscriberNotFound))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 기본 정보 섹션
                    _buildInfoSection(
                      title: localizations.basicInfo,
                      children: [
                        _buildInfoItem(
                          label: 'ID',
                          value: _subscriber!.subscriberId,
                          icon: Icons.tag,
                        ),
                        _buildInfoItem(
                          label: localizations.customerName,
                          value: _subscriber!.customerName ?? '',
                          icon: Icons.person,
                        ),
                        _buildInfoItem(
                          label: localizations.customerNo,
                          value: _subscriber!.customerNo ?? '',
                          icon: Icons.numbers,
                        ),
                        _buildInfoItem(
                          label: localizations.subscriberNo,
                          value: _subscriber!.subscriberNo ?? '',
                          icon: Icons.confirmation_number,
                        ),
                        _buildInfoItem(
                          label: localizations.meterId,
                          value: _subscriber!.meterId ?? '',
                          icon: Icons.speed,
                        ),
                        _buildInfoItem(
                          label: localizations.status,
                          value:
                              _subscriber!.isActive
                                  ? localizations.active
                                  : localizations.inactive,
                          icon: Icons.info,
                        ),
                      ],
                    ),

                    // 주소 정보 섹션
                    _buildInfoSection(
                      title: localizations.addressInfo,
                      children: [
                        _buildInfoItem(
                          label: localizations.fullAddress,
                          value: _getFormattedAddress(_subscriber!),
                          icon: Icons.location_on,
                        ),
                        _buildInfoItem(
                          label: localizations.province,
                          value: _subscriber!.addrProv ?? '',
                          icon: Icons.map,
                        ),
                        _buildInfoItem(
                          label: localizations.city,
                          value: _subscriber!.addrCity ?? '',
                          icon: Icons.location_city,
                        ),
                        _buildInfoItem(
                          label: localizations.district,
                          value: _subscriber!.addrDist ?? '',
                          icon: Icons.domain,
                        ),
                        _buildInfoItem(
                          label: localizations.detailAddress,
                          value: _subscriber!.addrDetail ?? '',
                          icon: Icons.home,
                        ),
                        _buildInfoItem(
                          label: localizations.apartment,
                          value: _subscriber!.addrApt ?? '',
                          icon: Icons.apartment,
                        ),
                        _buildInfoItem(
                          label: localizations.shareHouse,
                          value: _subscriber!.shareHouse ?? '',
                          icon: Icons.people,
                        ),
                      ],
                    ),

                    // 계약 정보 섹션
                    _buildInfoSection(
                      title: localizations.contractInfo,
                      children: [
                        _buildInfoItem(
                          label: localizations.category,
                          value: _subscriber!.category ?? '',
                          icon: Icons.category,
                        ),
                        _buildInfoItem(
                          label: localizations.subscriberClass,
                          value: _subscriber!.subscriberClass ?? '',
                          icon: Icons.class_,
                        ),
                        _buildInfoItem(
                          label: localizations.inOutdoor,
                          value: _subscriber!.inOutdoor ?? '',
                          icon: Icons.home_work,
                        ),
                        _buildInfoItem(
                          label: localizations.contractType,
                          value: _subscriber!.contractType ?? '',
                          icon: Icons.description,
                        ),
                        _buildInfoItem(
                          label: localizations.registrationDate,
                          value: _subscriber!.registrationDate ?? '',
                          icon: Icons.date_range,
                        ),
                        _buildInfoItem(
                          label: localizations.lastPaymentDate,
                          value: _subscriber!.lastPaymentDate ?? '',
                          icon: Icons.payment,
                        ),
                      ],
                    ),

                    // 장치 정보 섹션
                    _buildInfoSection(
                      title: localizations.deviceInfo,
                      children: [
                        _buildInfoItem(
                          label: localizations.deviceCount,
                          value: _subscriber!.deviceCount?.toString() ?? '0',
                          icon: Icons.devices,
                        ),
                        _buildInfoItem(
                          label: localizations.bindDeviceId,
                          value: _subscriber!.bindDeviceId ?? '',
                          icon: Icons.link,
                        ),
                        _buildInfoItem(
                          label: localizations.bindDate,
                          value: _getFormattedBindDate(_subscriber!.bindDate),
                          icon: Icons.calendar_today,
                        ),
                        _buildInfoItem(
                          label: localizations.lastCount,
                          value: _subscriber!.lastCount ?? '',
                          icon: Icons.countertops,
                        ),
                        _buildInfoItem(
                          label: localizations.lastAccess,
                          value: _subscriber!.lastAccess ?? '',
                          icon: Icons.access_time,
                        ),
                      ],
                    ),

                    // 메모 섹션
                    if (_subscriber!.memo != null &&
                        _subscriber!.memo!.isNotEmpty)
                      _buildInfoSection(
                        title: localizations.memo,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(_subscriber!.memo!),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
    );
  }
}
