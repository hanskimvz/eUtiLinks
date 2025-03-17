import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/models/subscriber_model.dart';
import '../../../../core/services/subscriber_service.dart';
import '../../../../core/constants/api_constants.dart';

class ImportSubscriberPage extends StatefulWidget {
  const ImportSubscriberPage({super.key});

  @override
  State<ImportSubscriberPage> createState() => _ImportSubscriberPageState();
}

class _ImportSubscriberPageState extends State<ImportSubscriberPage> {
  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;
  List<Map<String, dynamic>> _importedData = [];
  late final SubscriberService _subscriberService;

  @override
  void initState() {
    super.initState();
    _subscriberService = SubscriberService(baseUrl: ApiConstants.serverUrl);
  }

  Future<void> _pickExcelFile() async {
    if (!kIsWeb) {
      setState(() {
        _message = '이 기능은 웹 환경에서만 사용 가능합니다.';
        _isSuccess = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _message = '';
        _isSuccess = false;
      });

      // 파일 선택 다이얼로그 열기
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = '.xlsx,.xls';
      uploadInput.click();

      await uploadInput.onChange.first;
      final file = uploadInput.files!.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      await reader.onLoad.first;
      final data = reader.result as List<int>;
      
      // Excel 파일 파싱
      final excel = excel_lib.Excel.decodeBytes(data);
      final sheet = excel.tables.values.first;

      // 헤더 행 가져오기 (첫 번째 행)
      final headers = <String>[];
      for (var cell in sheet.rows[0]) {
        headers.add(cell?.value.toString() ?? '');
      }

      // 데이터 행 파싱
      _importedData = [];
      for (var i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        final Map<String, dynamic> rowData = {};
        
        for (var j = 0; j < headers.length && j < row.length; j++) {
          rowData[headers[j]] = row[j]?.value.toString() ?? '';
        }
        
        if (rowData.values.any((value) => value.toString().isNotEmpty)) {
          _importedData.add(rowData);
        }
      }

      setState(() {
        _isLoading = false;
        print(_importedData);
        _message = '${_importedData.length}개의 가입자 정보를 가져왔습니다.';
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = '파일 처리 중 오류가 발생했습니다: $e';
        _isSuccess = false;
      });
    }
  }

  Future<void> _importSubscribers() async {
    if (_importedData.isEmpty) {
      setState(() {
        _message = '가져온 데이터가 없습니다. 먼저 Excel 파일을 선택해주세요.';
        _isSuccess = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _message = '';
      });

      // 여기서 실제 가입자 정보를 서버에 등록하는 로직을 구현
      // 예시로 성공 메시지만 표시
      await Future.delayed(const Duration(seconds: 2)); // 서버 요청 시뮬레이션

      setState(() {
        _isLoading = false;
        _message = '${_importedData.length}개의 가입자 정보가 성공적으로 등록되었습니다.';
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = '가입자 등록 중 오류가 발생했습니다: $e';
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('가입자 일괄 등록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '가입자 일괄 등록',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '가입자 정보를 대량으로 등록할 수 있습니다. Excel 파일(.xlsx, .xls)을 업로드하세요.',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                
                // 파일 업로드 영역
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '1. Excel 파일 업로드',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '다음 형식의 Excel 파일을 준비해주세요:\n'
                          '- 첫 번째 행: 헤더 (customer_name, customer_no, addr_city 등)\n'
                          '- 두 번째 행부터: 가입자 데이터',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _pickExcelFile,
                            icon: const Icon(Icons.upload_file),
                            label: Text('Excel 파일 선택'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 가져온 데이터 정보 및 등록 버튼
                if (_importedData.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '2. 가입자 정보 등록',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('총 ${_importedData.length}개의 가입자 정보가 준비되었습니다.'),
                          const SizedBox(height: 24),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _importSubscribers,
                              icon: const Icon(Icons.save),
                              label: Text('가입자 등록하기'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // 메시지 표시 영역
                if (_message.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isSuccess ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isSuccess ? Icons.check_circle : Icons.error,
                          color: _isSuccess ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _message,
                            style: TextStyle(
                              color: _isSuccess ? Colors.green.shade900 : Colors.red.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // 로딩 인디케이터
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 