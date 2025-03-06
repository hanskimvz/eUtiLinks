import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../info_management/presentation/pages/info_management_page.dart';
import '../../../installer/presentation/pages/installer_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
// API 상수 import
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/localization/locale_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  String? _errorMessage;
  bool _isLoading = false;
  final Dio _dio = Dio();

  // 서버 URL 설정 (ApiConstants에서 가져옴)
  late final String _serverUrl = ApiConstants.serverUrl;

  @override
  void initState() {
    super.initState();
    _setupDio();
    _loadSavedUsername();
    _checkLoginStatus();
  }

  // 로그인 상태 확인
  Future<void> _checkLoginStatus() async {
    setState(() {
      _isLoading = true;
    });

    final isLoggedIn = await AuthService.isLoggedIn();

    if (isLoggedIn && mounted) {
      // 이미 로그인되어 있으면 모바일 기기인 경우 installer 페이지로, 그렇지 않은 경우 정보관리 페이지로 이동
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const InstallerPage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const InfoManagementPage()),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setupDio() {
    _dio.options.baseUrl = _serverUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // OPTIONS 메서드 문제 해결을 위한 설정
    _dio.options.validateStatus = (status) {
      return status != null && status < 500;
    };

    // 로깅 인터셉터 추가
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  Future<void> _loadSavedUsername() async {
    if (kIsWeb) {
      // 웹 환경에서는 SharedPreferences 사용
      final prefs = await SharedPreferences.getInstance();
      final savedUsername = prefs.getString('saved_username');
      if (savedUsername != null && savedUsername.isNotEmpty) {
        setState(() {
          _usernameController.text = savedUsername;
          _rememberMe = true;
        });
      }
    } else {
      // 모바일 환경에서는 SharedPreferences 사용
      final prefs = await SharedPreferences.getInstance();
      final savedUsername = prefs.getString('saved_username');
      if (savedUsername != null && savedUsername.isNotEmpty) {
        setState(() {
          _usernameController.text = savedUsername;
          _rememberMe = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // HTTPS 요청 시도
        await _tryLogin();
      } catch (e) {
        // print('로그인 요청 오류: $e');
        _handleLoginError(e);
      }
    }
  }

  // 로그인 시도 (웹과 모바일 모두 지원)
  Future<void> _tryLogin() async {
    final client = http.Client();

    try {
      final response = await client.post(
        Uri.parse(ApiConstants.getApiUrl(ApiConstants.loginEndpoint)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'format': 'json',
          'id': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      // print('응답 상태 코드: ${response.statusCode}');
      await _processResponse(response.statusCode, response.body);
    } finally {
      client.close();
    }
  }

  // 응답 처리
  Future<void> _processResponse(int statusCode, String body) async {
    if (statusCode == 200) {
      try {
        final responseData = jsonDecode(body);
        // print('응답 데이터: $responseData');

        if (responseData['code'] == 200) {
          await _processLoginSuccess(responseData);
          return;
        } else {
          setState(() {
            _errorMessage = responseData['message'] ?? '로그인에 실패했습니다.';
            _isLoading = false;
          });
        }
      } catch (e) {
        // print('응답 파싱 오류: $e');
        setState(() {
          _errorMessage = '서버 응답을 처리할 수 없습니다.';
          _isLoading = false;
        });
      }
    } else if (statusCode == 401) {
      setState(() {
        _errorMessage = '아이디 또는 비밀번호가 올바르지 않습니다.';
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = '서버 연결에 실패했습니다. (상태 코드: $statusCode)';
        _isLoading = false;
      });
    }
  }

  // 로그인 오류 처리
  void _handleLoginError(dynamic error) {
    // print('로그인 오류: $error');
    setState(() {
      _errorMessage = '서버에 연결할 수 없습니다. 네트워크 연결을 확인하세요.';
      _isLoading = false;
    });

    // 개발 환경에서 테스트를 위한 로그인 처리
    if (_usernameController.text == 'admin' &&
        _passwordController.text == 'admin') {
      _testLogin();
    }
  }

  // 로그인 성공 처리를 위한 공통 메서드
  Future<void> _processLoginSuccess(dynamic responseData) async {
    final userData = responseData['data'];

    // AuthService를 사용하여 사용자 정보 저장
    await AuthService.saveUserInfo(
      id: userData['ID'],
      dbName: userData['db_name'],
      role: userData['role'],
      name: userData['name'],
      userseq: userData['userseq'].toString(),
    );

    // 사용자 이름 저장 (Remember me)
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_username', _usernameController.text);
    } else {
      await prefs.remove('saved_username');
    }

    if (mounted) {
      // 모바일 기기인 경우 installer 페이지로, 그렇지 않은 경우 info_management 페이지로 이동
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const InstallerPage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const InfoManagementPage()),
        );
      }
    }
  }

  // 테스트용 로그인 처리 메서드
  Future<void> _testLogin() async {
    // print('테스트 로그인 시도 중...');

    // AuthService를 사용하여 테스트 사용자 정보 저장
    await AuthService.saveUserInfo(
      id: 'admin',
      dbName: 'test_db',
      role: 'admin',
      name: '관리자',
      userseq: '1',
    );

    // 사용자 이름 저장 (Remember me)
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_username', _usernameController.text);
    } else {
      await prefs.remove('saved_username');
    }

    if (mounted) {
      // 모바일 기기인 경우 installer 페이지로, 그렇지 않은 경우 info_management 페이지로 이동
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const InstallerPage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const InfoManagementPage()),
        );
      }
    }
  }

  void _resetPassword() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.forgotPasswordTitle),
            content: Text(AppLocalizations.of(context)!.forgotPasswordMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.confirm),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          localizations.appTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E88E5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // 언어 선택 드롭다운
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          alignment: Alignment.centerRight,
                          child: DropdownButton<Locale>(
                            value: localeProvider.locale,
                            underline: Container(
                              height: 1,
                              color: Colors.grey.shade400,
                            ),
                            onChanged: (Locale? newLocale) {
                              if (newLocale != null) {
                                localeProvider.setLocale(newLocale);
                              }
                            },
                            items:
                                LocaleProvider.supportedLocales.map((locale) {
                                  return DropdownMenuItem<Locale>(
                                    value: locale,
                                    child: Text(
                                      LocaleProvider.localeNames[locale
                                              .languageCode] ??
                                          locale.languageCode,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),

                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: localizations.username,
                            prefixIcon: const Icon(Icons.person),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return localizations.usernameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: localizations.password,
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return localizations.passwordRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                ),
                                Text(localizations.rememberMe),
                              ],
                            ),
                            TextButton(
                              onPressed: _resetPassword,
                              child: Text(localizations.forgotPassword),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E88E5),
                              foregroundColor: Colors.white,
                            ),
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : Text(
                                      localizations.login,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
