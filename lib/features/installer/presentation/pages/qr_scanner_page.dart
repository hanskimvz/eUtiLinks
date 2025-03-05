import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QRScannerPage extends StatefulWidget {
  /// 스캔 결과에 대한 힌트 텍스트 (선택 사항)
  final String? hintText;
  
  /// 스캔 후 자동으로 이전 화면으로 돌아갈지 여부
  final bool autoReturn;
  
  /// 스캔 결과를 처리하는 콜백 함수 (선택 사항)
  /// autoReturn이 false인 경우 필수
  final Function(String)? onScan;

  const QRScannerPage({
    super.key, 
    this.hintText,
    this.autoReturn = true,
    this.onScan,
  }) : assert(autoReturn == true || onScan != null, 
      'onScan 콜백은 autoReturn이 false일 때 필수입니다.');

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanning = true;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _handleScan(String code) {
    if (!_isScanning) return;
    
    setState(() {
      _isScanning = false;
    });
    
    if (widget.autoReturn) {
      // 스캔 결과를 이전 화면으로 전달
      Navigator.pop(context, code);
    } else if (widget.onScan != null) {
      // 콜백 함수 호출
      widget.onScan!(code);
      // 스캔 상태 초기화
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isScanning = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 로컬라이제이션 객체 가져오기
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.qrScanTitle),
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: _isFlashOn ? Colors.yellow : Colors.grey,
            ),
            tooltip: localizations.toggleFlash,
            onPressed: () {
              setState(() {
                _isFlashOn = !_isFlashOn;
              });
              _scannerController.toggleTorch();
            },
          ),
          IconButton(
            icon: Icon(
              _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
            ),
            tooltip: localizations.switchCamera,
            onPressed: () {
              setState(() {
                _isFrontCamera = !_isFrontCamera;
              });
              _scannerController.switchCamera();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && _isScanning) {
                  final String code = barcodes.first.rawValue ?? '';
                  if (code.isNotEmpty) {
                    _handleScan(code);
                  }
                }
              },
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.black54,
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.hintText ?? localizations.scanInstructions,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
} 