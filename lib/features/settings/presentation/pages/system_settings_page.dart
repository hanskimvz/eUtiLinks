import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/locale_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/server_config.dart';

class SystemSettingsPage extends StatefulWidget {
  const SystemSettingsPage({super.key});

  @override
  State<SystemSettingsPage> createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends State<SystemSettingsPage> {
  final _serverAddressController = TextEditingController();
  final _serverPortController = TextEditingController();
  bool _useCustomServer = false;
  bool _useDevServer = true;
  
  @override
  void initState() {
    super.initState();
    _loadCurrentServerSettings();
  }
  
  void _loadCurrentServerSettings() {
    setState(() {
      _serverAddressController.text = ApiConstants.serverAddress;
      _serverPortController.text = ApiConstants.serverPort.toString();
      _useCustomServer = ApiConstants.isCustomServer;
      _useDevServer = ApiConstants.isDevServer;
    });
  }
  
  @override
  void dispose() {
    _serverAddressController.dispose();
    _serverPortController.dispose();
    super.dispose();
  }
  
  void _saveServerSettings() async {
    final localizations = AppLocalizations.of(context)!;
    
    if (_useCustomServer) {
      final address = _serverAddressController.text.trim();
      final portText = _serverPortController.text.trim();
      
      if (address.isEmpty) {
        _showErrorDialog(localizations.serverAddressRequired);
        return;
      }
      
      final port = int.tryParse(portText);
      if (port == null || port <= 0 || port > 65535) {
        _showErrorDialog(localizations.validPortRequired);
        return;
      }
      
      // HTTPS 프로토콜 확인 및 추가
      String finalAddress = address;
      if (!finalAddress.startsWith('https://') && !finalAddress.startsWith('http://')) {
        finalAddress = 'https://$finalAddress';
      }
      
      ApiConstants.setCustomServer(finalAddress, port);
    } else if (_useDevServer) {
      ApiConstants.useDevEnvironment();
    } else {
      ApiConstants.useProdEnvironment();
    }
    
    await ServerConfig.saveCurrentConfig();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.serverSettingsSaved)),
      );
    }
  }
  
  void _showErrorDialog(String message) {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.confirm),
          ),
        ],
      ),
    );
  }
  
  void _resetServerSettings() async {
    final localizations = AppLocalizations.of(context)!;
    
    await ServerConfig.resetConfig();
    _loadCurrentServerSettings();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.serverSettingsReset)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.systemSettings,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.systemSettingsDescription,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          // 언어 설정
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.languageSettings,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLanguageSelector(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // 서버 설정 섹션
          Text(
            localizations.serverSettings,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.serverSettingsDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 서버 환경 선택
                  Text(
                    localizations.selectServerEnvironment, 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 8),
                  
                  // 개발 서버 옵션
                  RadioListTile<bool>(
                    title: Text(localizations.devServer),
                    subtitle: Text('${localizations.address}: ${ApiConstants.serverAddress}'),
                    value: true,
                    groupValue: _useDevServer,
                    onChanged: _useCustomServer ? null : (value) {
                      setState(() {
                        _useDevServer = value!;
                      });
                    },
                  ),
                  
                  // 운영 서버 옵션
                  RadioListTile<bool>(
                    title: Text(localizations.prodServer),
                    subtitle: Text('${localizations.address}: ${ApiConstants.prodServerAddress}'),
                    value: false,
                    groupValue: _useDevServer,
                    onChanged: _useCustomServer ? null : (value) {
                      setState(() {
                        _useDevServer = value!;
                      });
                    },
                  ),
                  
                  const Divider(),
                  
                  // 사용자 정의 서버 옵션
                  Row(
                    children: [
                      Checkbox(
                        value: _useCustomServer,
                        onChanged: (value) {
                          setState(() {
                            _useCustomServer = value!;
                          });
                        },
                      ),
                      Text(localizations.useCustomServer),
                    ],
                  ),
                  
                  // 사용자 정의 서버 설정 필드
                  if (_useCustomServer) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _serverAddressController,
                      decoration: InputDecoration(
                        labelText: localizations.serverAddress,
                        hintText: localizations.serverAddressHint,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _serverPortController,
                      decoration: InputDecoration(
                        labelText: localizations.serverPort,
                        hintText: localizations.serverPortHint,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // 버튼 영역
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _resetServerSettings,
                        child: Text(localizations.reset),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _saveServerSettings,
                        child: Text(localizations.save),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale.languageCode;
    final localizations = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        _buildLanguageOption(
          context: context,
          languageCode: 'ko',
          languageName: localizations.korean,
          isSelected: currentLocale == 'ko',
          onTap: () => localeProvider.setLocale(const Locale('ko')),
        ),
        const Divider(),
        _buildLanguageOption(
          context: context,
          languageCode: 'en',
          languageName: localizations.english,
          isSelected: currentLocale == 'en',
          onTap: () => localeProvider.setLocale(const Locale('en')),
        ),
      ],
    );
  }
  
  Widget _buildLanguageOption({
    required BuildContext context,
    required String languageCode,
    required String languageName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Text(
              languageName,
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check,
                color: Colors.blue,
              ),
          ],
        ),
      ),
    );
  }
} 