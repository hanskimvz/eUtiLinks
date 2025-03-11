import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../home/presentation/widgets/main_layout.dart';
// import '../pages/installer_device_info.dart';
// import '../../../../core/models/device_model.dart';

class InstallationConfirmPage extends StatefulWidget {
  final String deviceUid;

  const InstallationConfirmPage({super.key, required this.deviceUid});

  @override
  State<InstallationConfirmPage> createState() =>
      _InstallationConfirmPageState();
}

class _InstallationConfirmPageState extends State<InstallationConfirmPage> {
  late final DeviceService _deviceService;
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  bool _isPolling = false;
  String? _lastAccessTime;
  bool _isConnected = false;
  String _statusMessage = '';
  int _countdown = 10; // 10초 카운트다운

  @override
  void initState() {
    super.initState();
    _deviceService = DeviceService(baseUrl: ApiConstants.serverUrl);

    // 카운트다운 타이머 시작
    _startCountdown();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 여기서 localizations 객체에 접근 가능
    final localizations = AppLocalizations.of(context)!;
    setState(() {
      _statusMessage = '$_countdown${localizations.secondsBeforeCommunication}';
    });
  }

  @override
  void dispose() {
    _stopPolling();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
          final localizations = AppLocalizations.of(context)!;
          _statusMessage =
              '$_countdown${localizations.secondsBeforeCommunication}';
        });
      } else {
        _countdownTimer?.cancel();
        if (mounted) {
          _startPolling();
        }
      }
    });
  }

  void _startPolling() {
    if (_pollingTimer != null) {
      _pollingTimer!.cancel();
    }

    setState(() {
      _isPolling = true;
      final localizations = AppLocalizations.of(context)!;
      _statusMessage = localizations.checkingCommunicationStatus;
    });

    // 즉시 첫 번째 폴링 실행
    _pollDeviceStatus();

    // 2초마다 폴링 설정
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _pollDeviceStatus();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;

    setState(() {
      _isPolling = false;
    });
  }

  Future<void> _pollDeviceStatus() async {
    try {
      final devices = await _deviceService.getDevicesWithFilter(
        filter: {'device_uid': widget.deviceUid},
      );

      if (!mounted) return;
      final localizations = AppLocalizations.of(context)!;

      if (devices.isNotEmpty && devices.first.lastAccess != null) {
        final lastAccess = devices.first.lastAccess!;

        setState(() {
          _lastAccessTime = lastAccess;

          // 현재 시간과 lastAccess 시간 비교
          final lastAccessDateTime = DateTime.tryParse(lastAccess);
          if (lastAccessDateTime != null) {
            final now = DateTime.now();
            final difference = now.difference(lastAccessDateTime);

            // 5분 이내에 통신이 있었으면 연결된 것으로 간주
            _isConnected = difference.inMinutes < 5;

            if (_isConnected) {
              _statusMessage = localizations.deviceCommunicatingSuccessfully;
            } else {
              _statusMessage = localizations.deviceCommunicationProblem;
            }
          } else {
            _isConnected = false;
            _statusMessage = localizations.invalidCommunicationTimeInfo;
          }
        });
      } else {
        setState(() {
          _isConnected = false;
          _statusMessage = localizations.cannotGetDeviceInfo;
        });
      }
    } catch (e) {
      if (!mounted) return;
      final localizations = AppLocalizations.of(context)!;

      setState(() {
        _isConnected = false;
        _statusMessage = '${localizations.communicationError}: ${e.toString()}';
      });
    }
  }

  // 장비 연결 해제 메서드 추가
  Future<bool> _disconnectDevice() async {
    try {
      // 현재 장비 정보 가져오기
      final devices = await _deviceService.getDevicesWithFilter(
        filter: {'device_uid': widget.deviceUid},
      );

      if (devices.isEmpty) {
        return false;
      }

      // 장비 상태를 비활성으로 변경
      final device = devices.first;

      // 새로운 DeviceModel 객체 생성 (flag를 'inactive'로 설정)
      final requestData = {
        'action': 'unbind',
        'data': {
          'device_uid': device.deviceUid,
          'meter_id': device.meterId,
          'customer_name': device.customerName,
          'customer_no': device.customerNo,
        },
      };

      // 서버에 장비 연결 해제 요청
      // final result = await _deviceService.updateDevice(updatedDevice);
      await _deviceService.bindDeviceInstallation(requestData);

      // 결과가 존재하면 성공
      return true;
    } catch (e) {
      if (!mounted) return false;

      final localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${localizations.deviceDisconnectionError}: ${e.toString()}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return MainLayout(
      title: localizations.installationConfirmation,
      selectedMainMenuIndex: 3, // Installer menu
      selectedSubMenuIndex: 0,
      onSubMenuSelected: (_) {},
      hideSidebar: true,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // 안내 카드
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 48,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.pressButtonForFiveSeconds,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.communicationWillStartAfterTenSeconds,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 통신 상태 표시
            Card(
              elevation: 2,
              color:
                  _isPolling
                      ? (_isConnected
                          ? Colors.green.shade50
                          : Colors.orange.shade50)
                      : Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _isPolling
                          ? (_isConnected
                              ? Icons.check_circle
                              : Icons.warning_amber)
                          : Icons.timer,
                      size: 48,
                      color:
                          _isPolling
                              ? (_isConnected ? Colors.green : Colors.orange)
                              : Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            _isPolling
                                ? (_isConnected
                                    ? Colors.green.shade800
                                    : Colors.orange.shade800)
                                : Colors.blue.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${localizations.lastCommunicationTime}: ${_lastAccessTime ?? localizations.null_value}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color:
                            _lastAccessTime != null
                                ? Colors.blue.shade700
                                : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isPolling)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(localizations.checkingCommunicationStatus),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${localizations.waitingForCommunication}... $_countdown${localizations.seconds}',
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // 버튼 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 다른 장비 연결 버튼
                ElevatedButton(
                  onPressed: () {
                    _stopPolling();
                    _countdownTimer?.cancel();

                    // 새로운 장치 연결을 위해 장비 목록 페이지로 이동
                    Navigator.of(context).pushReplacementNamed('/installer');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(localizations.connectAnotherDevice),
                ),
                const SizedBox(width: 16),
                // 장비 연결 해제 버튼
                ElevatedButton(
                  onPressed: () async {
                    // 통신 종료
                    _stopPolling();
                    _countdownTimer?.cancel();

                    // 장비 연결 해제 시도
                    final localizations = AppLocalizations.of(context)!;
                    final navigatorContext = Navigator.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    // 로딩 표시
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (context) => AlertDialog(
                            content: Row(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(width: 16),
                                Text(localizations.disconnectingDevice),
                              ],
                            ),
                          ),
                    );

                    // 장비 연결 해제 요청
                    final success = await _disconnectDevice();

                    // 로딩 다이얼로그 닫기
                    if (mounted) {
                      navigatorContext.pop();
                    }

                    if (success && mounted) {
                      // 성공 메시지 표시
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            localizations.deviceDisconnectedSuccessfully,
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // 장비 리스트 페이지로 이동
                      navigatorContext.pushReplacementNamed('/installer');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(localizations.disconnectDevice),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
