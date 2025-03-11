import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:app_settings/app_settings.dart';
import '../../features/installer/presentation/pages/qr_scanner_page.dart';

/// QR 코드 및 바코드 스캔 관련 유틸리티 함수를 제공하는 클래스
class ScannerUtils {
  /// QR 코드/바코드 스캐너를 실행하고 결과를 반환하는 함수
  ///
  /// [context] - 현재 BuildContext
  /// [hintText] - 스캐너 화면에 표시할 힌트 텍스트 (선택 사항)
  /// [onSuccess] - 스캔 성공 시 호출할 콜백 함수 (선택 사항)
  /// [onPermissionDenied] - 권한 거부 시 호출할 콜백 함수 (선택 사항)
  /// [onError] - 오류 발생 시 호출할 콜백 함수 (선택 사항)
  ///
  /// 반환값: 스캔 결과 문자열 또는 null (오류 또는 취소 시)
  static Future<String?> scanQRCode({
    required BuildContext context,
    String? hintText,
    Function(String)? onSuccess,
    Function()? onPermissionDenied,
    Function(String)? onError,
  }) async {
    final localizations = AppLocalizations.of(context)!;
    String? result;

    try {
      // 카메라 권한 요청
      var status = await Permission.camera.request();
      if (!context.mounted) return null;

      if (status.isGranted) {
        // QR 코드/바코드 스캐너 페이지로 이동
        result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    QRScannerPage(hintText: hintText, autoReturn: true),
          ),
        );

        if (!context.mounted) return result;

        // 스캔 결과가 있으면 성공 콜백 호출
        if (result != null) {
          if (onSuccess != null) {
            onSuccess(result);
          } else {
            // 기본 성공 메시지 표시
            final message = localizations.scanCompleted(result);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } else if (status.isPermanentlyDenied) {
        // 권한 영구 거부 처리
        if (onPermissionDenied != null) {
          onPermissionDenied();
        } else {
          // 기본 권한 거부 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.cameraPermissionPermanentlyDenied),
              action: SnackBarAction(
                label: localizations.settings,
                onPressed: () => openAppSettings(),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        // 권한 거부 처리
        if (onPermissionDenied != null) {
          onPermissionDenied();
        } else {
          // 기본 권한 거부 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.cameraPermissionDenied)),
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return null;

      // 오류 처리
      if (onError != null) {
        onError(e.toString());
      } else {
        // 기본 오류 메시지 표시
        final errorMessage = localizations.cameraError(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }

    return result;
  }
}
