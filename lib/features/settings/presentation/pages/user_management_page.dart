import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/auth_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await AuthService.initAuthData();
    _fetchUsers();
  }

  // 서버에서 사용자 목록을 가져오는 함수
  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final tableHead = [
        'code',
        'ID',
        'email',
        'name',
        'lang',
        'role',
        'groups',
        'regdate',
        'flag',
      ];

      final response = await http.post(
        Uri.parse('${ApiConstants.serverAddress}/api/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'page': 'users',
          'format': 'json',
          'fields': tableHead,
          ...AuthService.authData,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['code'] == 200) {
          setState(() {
            _users.clear();

            // 서버에서 받은 사용자 데이터를 처리
            if (data['data'] != null && data['data'] is List) {
              for (var user in data['data']) {
                _users.add({
                  'id': user['code'] ?? '',
                  'username': user['ID'] ?? '',
                  'name': user['name'] ?? '',
                  'email': user['email'] ?? '',
                  'role': user['role'] ?? '',
                  'lastLogin': user['regdate'] ?? '-',
                  'status': user['flag'] == true ? 'active' : 'inactive',
                  'lang': user['lang'] ?? 'kor',
                });
              }
            }

            _filteredUsers = List.from(_users);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = '사용자 데이터를 가져오는데 실패했습니다. 코드: ${data['code']}';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = '서버 응답 오류: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '오류 발생: $e';
        _isLoading = false;
        // print(e);
      });
    }
  }

  // 사용자 추가 API 호출
  Future<bool> _addUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.serverAddress}/api/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'page': 'users',
          'action': 'add',
          'format': 'json',
          ...AuthService.authData,
          'data': {
            'ID': userData['username'],
            'name': userData['name'],
            'email': userData['email'],
            'password': userData['password'],
            'role': userData['role'],
            'lang': userData['lang'],
            'flag': userData['status'] == '활성',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['code'] == 200) {
          return true;
        } else {
          setState(() {
            _errorMessage = '사용자 추가에 실패했습니다. 코드: ${data['code']}';
          });
          return false;
        }
      } else {
        setState(() {
          _errorMessage = '서버 응답 오류: ${response.statusCode}';
        });
        return false;
      }
    } catch (e) {
      setState(() {
        _errorMessage = '오류 발생: $e';
      });
      return false;
    }
  }

  // 사용자 수정 API 호출
  Future<bool> _updateUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.serverAddress}/api/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'page': 'users',
          'format': 'json',
          ...AuthService.authData,
          'code': userData['id'],
          'ID': userData['username'],
          'name': userData['name'],
          'email': userData['email'],
          'user_role': userData['role'],
          'lang': userData['lang'] ?? 'kor',
          'groups': userData['groups'] ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          return true;
        } else {
          setState(() {
            _errorMessage = '사용자 수정에 실패했습니다. 코드: ${data['code']}';
          });
          return false;
        }
      } else {
        setState(() {
          _errorMessage = '서버 응답 오류: ${response.statusCode}';
        });
        return false;
      }
    } catch (e) {
      setState(() {
        _errorMessage = '오류 발생: $e';
      });
      return false;
    }
  }

  // 사용자 삭제 API 호출
  Future<bool> _deleteUser(String userCode) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.serverAddress}/api/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'page': 'users',
          'action': 'delete',
          'format': 'json',
          ...AuthService.authData,
          'data': {'code': userCode},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['code'] == 200) {
          return true;
        } else {
          setState(() {
            _errorMessage = '사용자 삭제에 실패했습니다. 코드: ${data['code']}';
          });
          return false;
        }
      } else {
        setState(() {
          _errorMessage = '서버 응답 오류: ${response.statusCode}';
        });
        return false;
      }
    } catch (e) {
      setState(() {
        _errorMessage = '오류 발생: $e';
      });
      return false;
    }
  }

  // 사용자 상태 변경 API 호출
  Future<bool> _toggleUserStatusOnServer(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.serverAddress}/api/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'page': 'users',
          'action': 'update_status',
          'format': 'json',
          ...AuthService.authData,
          'data': {'code': userData['id'], 'flag': userData['status'] == '활성'},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['code'] == 200) {
          return true;
        } else {
          setState(() {
            _errorMessage = '사용자 상태 변경에 실패했습니다. 코드: ${data['code']}';
          });
          return false;
        }
      } else {
        setState(() {
          _errorMessage = '서버 응답 오류: ${response.statusCode}';
        });
        return false;
      }
    } catch (e) {
      setState(() {
        _errorMessage = '오류 발생: $e';
      });
      return false;
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_users);
      } else {
        _filteredUsers =
            _users.where((user) {
              final searchLower = query.toLowerCase();
              return user['username'].toString().toLowerCase().contains(
                    searchLower,
                  ) ||
                  user['name'].toString().toLowerCase().contains(searchLower) ||
                  user['email'].toString().toLowerCase().contains(
                    searchLower,
                  ) ||
                  user['role'].toString().toLowerCase().contains(searchLower) ||
                  user['lang'].toString().toLowerCase().contains(searchLower) ||
                  user['id'].toString().toLowerCase().contains(searchLower);
            }).toList();
      }
    });
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
            localizations.userManagement,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.userManagementDescription,
            style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 24),
          // 검색 및 필터링
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: localizations.searchUser,
                    hintText: localizations.searchUserHint,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onChanged: _filterUsers,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _showAddUserDialog();
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: Text(
                  localizations.addUser,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brandColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _fetchUsers,
                icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                label: Text(
                  localizations.refresh,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  alignment: Alignment.center,
                ),
              ),
            ],
          ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: 24),
          // 사용자 목록
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Card(child: _buildUserTable(localizations)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTable(AppLocalizations localizations) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(
              label: Text(
                localizations.code,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                "ID",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                localizations.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                localizations.email,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                localizations.language,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                localizations.role,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                localizations.registrationDate,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                localizations.status,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                localizations.actions,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          rows:
              _filteredUsers.map((user) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        user['id'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        user['username'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        user['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        user['email'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _getLanguageName(user['lang'], localizations),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _getRoleName(user['role'], localizations),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        user['lastLogin'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              user['status'] == 'active'
                                  ? Colors.green[100]
                                  : Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user['status'],
                          style: TextStyle(
                            color:
                                user['status'] == 'active'
                                    ? Colors.green[800]
                                    : Colors.red[800],
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                              size: 22,
                            ),
                            onPressed: () => _showEditUserDialog(user),
                            tooltip: localizations.edit,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 22,
                            ),
                            onPressed: () => _showDeleteUserDialog(user),
                            tooltip: localizations.delete,
                          ),
                          IconButton(
                            icon: Icon(
                              user['status'] == 'active'
                                  ? Icons.block
                                  : Icons.check_circle,
                              color:
                                  user['status'] == 'active'
                                      ? Colors.orange
                                      : Colors.green,
                              size: 22,
                            ),
                            onPressed: () => _toggleUserStatus(user),
                            tooltip:
                                user['status'] == 'active'
                                    ? localizations.deactivate
                                    : localizations.activate,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  String _getLanguageName(String langCode, AppLocalizations localizations) {
    switch (langCode) {
      case 'kor':
        return localizations.korean;
      case 'eng':
        return localizations.english;
      case 'chn':
        return localizations.chinese;
      default:
        return langCode;
    }
  }

  String _getRoleName(String role, AppLocalizations localizations) {
    switch (role) {
      case 'admin':
        return localizations.admin;
      case 'operator':
        return localizations.operator;
      case 'user':
        return localizations.user;
      case 'installer':
        return localizations.installer;
      default:
        return role;
    }
  }

  void _showAddUserDialog() {
    final localizations = AppLocalizations.of(context)!;
    final usernameController = TextEditingController();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'user';
    String selectedLang = 'kor';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.addUser),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: localizations.username,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: localizations.name,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: localizations.email,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: localizations.password,
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: localizations.role,
                      border: const OutlineInputBorder(),
                    ),
                    value: selectedRole,
                    items: [
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text(localizations.admin),
                      ),
                      DropdownMenuItem(
                        value: 'operator',
                        child: Text(localizations.operator),
                      ),
                      DropdownMenuItem(
                        value: 'user',
                        child: Text(localizations.user),
                      ),
                      DropdownMenuItem(
                        value: 'installer',
                        child: Text(localizations.installer),
                      ),
                    ],
                    onChanged: (value) {
                      selectedRole = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: localizations.language,
                      border: const OutlineInputBorder(),
                    ),
                    value: selectedLang,
                    items: [
                      DropdownMenuItem(
                        value: 'kor',
                        child: Text(localizations.korean),
                      ),
                      DropdownMenuItem(
                        value: 'eng',
                        child: Text(localizations.english),
                      ),
                      DropdownMenuItem(
                        value: 'chn',
                        child: Text(localizations.chinese),
                      ),
                    ],
                    onChanged: (value) {
                      selectedLang = value!;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.cancel),
              ),
              TextButton(
                onPressed: () async {
                  if (usernameController.text.isNotEmpty &&
                      nameController.text.isNotEmpty) {
                    final userData = {
                      'username': usernameController.text,
                      'name': nameController.text,
                      'email': emailController.text,
                      'password': passwordController.text,
                      'role': selectedRole,
                      'lang': selectedLang,
                      'status': 'active',
                    };

                    final messenger = ScaffoldMessenger.of(context);
                    final userAddedMessage = localizations.userAdded;

                    Navigator.of(context).pop();

                    // 로딩 표시
                    setState(() {
                      _isLoading = true;
                      _errorMessage = '';
                    });

                    // 서버에 사용자 추가 요청
                    final success = await _addUser(userData);

                    if (success) {
                      // 성공 시 사용자 목록 새로고침
                      await _fetchUsers();

                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(userAddedMessage),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(_errorMessage),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                child: Text('추가'),
              ),
            ],
          ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    final localizations = AppLocalizations.of(context)!;
    final usernameController = TextEditingController(text: user['username']);
    final nameController = TextEditingController(text: user['name']);
    final emailController = TextEditingController(text: user['email']);
    String selectedRole = user['role'];
    String selectedLang = user['lang'] ?? 'kor';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.editUser),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: localizations.username,
                      border: const OutlineInputBorder(),
                    ),
                    enabled: false, // 사용자 ID는 수정 불가
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: localizations.name,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: localizations.email,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: localizations.role,
                      border: const OutlineInputBorder(),
                    ),
                    value: selectedRole,
                    items: [
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text(localizations.admin),
                      ),
                      DropdownMenuItem(
                        value: 'operator',
                        child: Text(localizations.operator),
                      ),
                      DropdownMenuItem(
                        value: 'user',
                        child: Text(localizations.user),
                      ),
                      DropdownMenuItem(
                        value: 'installer',
                        child: Text(localizations.installer),
                      ),
                    ],
                    onChanged: (value) {
                      selectedRole = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: localizations.language,
                      border: const OutlineInputBorder(),
                    ),
                    value: selectedLang,
                    items: [
                      DropdownMenuItem(
                        value: 'kor',
                        child: Text(localizations.korean),
                      ),
                      DropdownMenuItem(
                        value: 'eng',
                        child: Text(localizations.english),
                      ),
                      DropdownMenuItem(
                        value: 'chn',
                        child: Text(localizations.chinese),
                      ),
                    ],
                    onChanged: (value) {
                      selectedLang = value!;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.cancel),
              ),
              TextButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final userData = {
                      'id': user['id'],
                      'username': usernameController.text,
                      'name': nameController.text,
                      'email': emailController.text,
                      'role': selectedRole,
                      'lang': selectedLang,
                    };

                    final messenger = ScaffoldMessenger.of(context);
                    final editSuccessMessage = localizations.userEditedSuccess;

                    Navigator.of(context).pop();

                    setState(() {
                      _isLoading = true;
                      _errorMessage = '';
                    });

                    final success = await _updateUser(userData);

                    if (success) {
                      await _fetchUsers();

                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(editSuccessMessage),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(_errorMessage),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                child: Text(localizations.save),
              ),
            ],
          ),
    );
  }

  void _showDeleteUserDialog(Map<String, dynamic> user) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.deleteUser),
            content: Text(localizations.deleteUserConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.cancel),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  final messenger = ScaffoldMessenger.of(context);
                  final deleteSuccessMessage = localizations.userDeletedSuccess;

                  setState(() {
                    _isLoading = true;
                    _errorMessage = '';
                  });

                  final success = await _deleteUser(user['id']);

                  if (success) {
                    await _fetchUsers();

                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(deleteSuccessMessage),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(_errorMessage),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  localizations.delete,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) async {
    // 상태 변경
    final newStatus = user['status'] == 'active' ? '비활성' : '활성';

    // 로딩 표시
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // 서버에 상태 변경 요청
    final userData = {'id': user['id'], 'status': newStatus};

    final success = await _toggleUserStatusOnServer(userData);

    if (success) {
      // 성공 시 사용자 목록 새로고침
      await _fetchUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${user['name']} 사용자가 ${newStatus == '활성' ? '활성화' : '비활성화'}되었습니다.',
            ),
            backgroundColor: newStatus == '활성' ? Colors.green : Colors.orange,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }
}
