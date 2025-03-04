import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

class PermissionManagementPage extends StatefulWidget {
  const PermissionManagementPage({super.key});

  @override
  State<PermissionManagementPage> createState() => _PermissionManagementPageState();
}

class _PermissionManagementPageState extends State<PermissionManagementPage> {
  final List<Map<String, dynamic>> _roles = [
    {
      'id': 1,
      'name': '관리자',
      'description': '모든 기능에 접근 가능',
      'permissions': {
        '정보관리': true,
        '현황집계': true,
        '설정': true,
        '사용자 관리': true,
        '권한 관리': true,
      },
    },
    {
      'id': 2,
      'name': '운영자',
      'description': '일부 설정 기능 제외 접근 가능',
      'permissions': {
        '정보관리': true,
        '현황집계': true,
        '설정': true,
        '사용자 관리': false,
        '권한 관리': false,
      },
    },
    {
      'id': 3,
      'name': '일반 사용자',
      'description': '정보 조회만 가능',
      'permissions': {
        '정보관리': true,
        '현황집계': true,
        '설정': false,
        '사용자 관리': false,
        '권한 관리': false,
      },
    },
  ];

  int? _selectedRoleId;

  @override
  void initState() {
    super.initState();
    _selectedRoleId = _roles[0]['id'];
  }

  @override
  Widget build(BuildContext context) {
    // final localizations = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '권한 관리',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '역할별 권한을 설정하고 관리합니다.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 역할 목록
              Expanded(
                flex: 1,
                child: Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _roles.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final role = _roles[index];
                      final isSelected = role['id'] == _selectedRoleId;
                      
                      return ListTile(
                        title: Text(role['name']),
                        subtitle: Text(role['description']),
                        selected: isSelected,
                        selectedTileColor: Colors.grey[200],
                        selectedColor: AppTheme.brandColor,
                        onTap: () {
                          setState(() {
                            _selectedRoleId = role['id'];
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 권한 설정
              Expanded(
                flex: 2,
                child: _buildPermissionSettings(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showAddRoleDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('역할 추가'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  _savePermissions();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brandColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('저장'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionSettings() {
    final selectedRole = _roles.firstWhere(
      (role) => role['id'] == _selectedRoleId,
      orElse: () => _roles[0],
    );
    
    final permissions = selectedRole['permissions'] as Map<String, dynamic>;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${selectedRole['name']} 권한 설정',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              itemCount: permissions.length,
              itemBuilder: (context, index) {
                final entry = permissions.entries.elementAt(index);
                return SwitchListTile(
                  title: Text(entry.key),
                  value: entry.value,
                  activeColor: AppTheme.brandColor,
                  onChanged: (value) {
                    setState(() {
                      permissions[entry.key] = value;
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRoleDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('역할 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '역할 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '역할 설명',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  final newId = _roles.map((r) => r['id'] as int).reduce((a, b) => a > b ? a : b) + 1;
                  _roles.add({
                    'id': newId,
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'permissions': {
                      '정보관리': false,
                      '현황집계': false,
                      '설정': false,
                      '사용자 관리': false,
                      '권한 관리': false,
                    },
                  });
                  _selectedRoleId = newId;
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _savePermissions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('권한 설정이 저장되었습니다.'),
        backgroundColor: Colors.green,
      ),
    );
  }
} 