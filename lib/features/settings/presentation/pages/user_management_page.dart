import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
// import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/user_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final List<Map<String, dynamic>> _pendingUsers = [];
  bool _isLoading = false;
  String _errorMessage = '';
  late UserService _userService;

  @override
  void initState() {
    super.initState();
    _userService = UserService(baseUrl: ApiConstants.serverAddress);
    _loadData();
  }

  Future<void> _loadData() async {
    await AuthService.initAuthData();
    _fetchUsers();
    _fetchPendingUsers();
  }

  // 서버에서 사용자 목록을 가져오는 함수
  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final users = await _userService.getUsers();

      setState(() {
        _users.clear();
        _users.addAll(users);
        _filteredUsers = List.from(_users);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // 미승인 사용자 목록을 가져오는 함수
  Future<void> _fetchPendingUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final pendingUsers = await _userService.getPendingUsers();

      setState(() {
        _pendingUsers.clear();
        _pendingUsers.addAll(pendingUsers);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // 사용자 추가 API 호출
  Future<bool> _addUser(Map<String, dynamic> userData) async {
    try {
      return await _userService.addUser(userData);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      return false;
    }
  }

  // 사용자 수정 API 호출
  Future<bool> _updateUser(Map<String, dynamic> userData) async {
    try {
      return await _userService.updateUser(userData);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      return false;
    }
  }

  // 사용자 삭제 API 호출
  Future<bool> _deleteUser(String userCode, String userID) async {
    try {
      return await _userService.deleteUser(userCode, userID);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      return false;
    }
  }

  // 사용자 승인 API 호출
  Future<bool> _approveUser(Map<String, dynamic> userData) async {
    try {
      return await _userService.approveUser(userData);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _fetchPendingUsers();
                  _showPendingUsersDialog();
                },
                icon: const Icon(Icons.approval, color: Colors.white, size: 20),
                label: Text(
                  localizations.pendingUserApproval,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columnSpacing: 16,
                horizontalMargin: 16,
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
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        );
      },
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
      case 'guest':
        return 'Guest';
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
    bool isActive = true;

    // 유효성 검사 상태를 저장할 변수들
    final Map<String, String> errors = {
      'username': '',
      'name': '',
      'email': '',
      'password': '',
    };

    // StatefulBuilder를 사용하여 다이얼로그 내부 상태 관리
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
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
                            errorText:
                                errors['username']!.isNotEmpty
                                    ? errors['username']
                                    : null,
                            errorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: localizations.name,
                            border: const OutlineInputBorder(),
                            errorText:
                                errors['name']!.isNotEmpty
                                    ? errors['name']
                                    : null,
                            errorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: localizations.email,
                            border: const OutlineInputBorder(),
                            errorText:
                                errors['email']!.isNotEmpty
                                    ? errors['email']
                                    : null,
                            errorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: localizations.password,
                            border: const OutlineInputBorder(),
                            errorText:
                                errors['password']!.isNotEmpty
                                    ? errors['password']
                                    : null,
                            errorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
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
                              value: 'installer',
                              child: Text(localizations.installer),
                            ),
                            DropdownMenuItem(
                              value: 'user',
                              child: Text(localizations.user),
                            ),
                            DropdownMenuItem(
                              value: 'guest',
                              child: Text('Guest'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
                            });
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
                            setState(() {
                              selectedLang = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: Text(localizations.activationStatus),
                          value: isActive,
                          onChanged: (value) {
                            setState(() {
                              isActive = value;
                            });
                          },
                          activeColor: Colors.green,
                          contentPadding: EdgeInsets.zero,
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
                        // 유효성 검사 수행
                        bool isValid = true;
                        final newErrors = Map<String, String>.from(errors);

                        if (usernameController.text.isEmpty) {
                          newErrors['username'] = '사용자 ID를 입력해주세요';
                          isValid = false;
                        } else {
                          newErrors['username'] = '';
                        }

                        if (nameController.text.isEmpty) {
                          newErrors['name'] = '이름을 입력해주세요';
                          isValid = false;
                        } else {
                          newErrors['name'] = '';
                        }

                        if (emailController.text.isEmpty) {
                          newErrors['email'] = '이메일을 입력해주세요';
                          isValid = false;
                        } else {
                          newErrors['email'] = '';
                        }

                        if (passwordController.text.isEmpty) {
                          newErrors['password'] = '비밀번호를 입력해주세요';
                          isValid = false;
                        } else {
                          newErrors['password'] = '';
                        }

                        // 오류가 있으면 상태 업데이트
                        if (!isValid) {
                          setState(() {
                            errors.addAll(newErrors);
                          });
                          return;
                        }

                        final userData = {
                          'username': usernameController.text,
                          'name': nameController.text,
                          'email': emailController.text,
                          'password': passwordController.text,
                          'role': selectedRole,
                          'lang': selectedLang,
                          'status': isActive ? 'active' : 'inactive',
                        };

                        final messenger = ScaffoldMessenger.of(context);
                        final userAddedMessage = localizations.userAdded;

                        Navigator.of(context).pop();

                        // 로딩 표시
                        this.setState(() {
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
                      },
                      child: Text(localizations.save),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    final localizations = AppLocalizations.of(context)!;
    final usernameController = TextEditingController(text: user['username']);
    final nameController = TextEditingController(text: user['name']);
    final emailController = TextEditingController(text: user['email']);
    final commentController = TextEditingController(
      text: user['comment'] ?? '',
    );
    String selectedRole =
        (user['role'] == null || user['role'] == '') ? 'user' : user['role'];
    String selectedLang = user['lang'] ?? 'kor';
    bool isActive = user['status'] == 'active';

    // 유효성 검사 상태를 저장할 변수들
    final Map<String, String> errors = {'name': '', 'email': '', 'comment': ''};

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
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
                            errorText:
                                errors['name']!.isNotEmpty
                                    ? errors['name']
                                    : null,
                            errorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: localizations.email,
                            border: const OutlineInputBorder(),
                            errorText:
                                errors['email']!.isNotEmpty
                                    ? errors['email']
                                    : null,
                            errorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            labelText: localizations.comment,
                            border: const OutlineInputBorder(),
                            errorText:
                                errors['comment']!.isNotEmpty
                                    ? errors['comment']
                                    : null,
                            errorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                          // maxLines: 3,
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
                              value: 'installer',
                              child: Text(localizations.installer),
                            ),
                            DropdownMenuItem(
                              value: 'user',
                              child: Text(localizations.user),
                            ),
                            DropdownMenuItem(
                              value: 'guest',
                              child: Text('Guest'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
                            });
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
                            setState(() {
                              selectedLang = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: Text(localizations.activationStatus),
                          value: isActive,
                          onChanged: (value) {
                            setState(() {
                              isActive = value;
                            });
                          },
                          activeColor: Colors.green,
                          contentPadding: EdgeInsets.zero,
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
                        // 유효성 검사 수행
                        bool isValid = true;
                        final newErrors = Map<String, String>.from(errors);

                        if (nameController.text.isEmpty) {
                          newErrors['name'] = '이름을 입력해주세요';
                          isValid = false;
                        } else {
                          newErrors['name'] = '';
                        }

                        if (emailController.text.isEmpty) {
                          newErrors['email'] = '이메일을 입력해주세요';
                          isValid = false;
                        } else {
                          newErrors['email'] = '';
                        }

                        // 오류가 있으면 상태 업데이트
                        if (!isValid) {
                          setState(() {
                            errors.addAll(newErrors);
                          });
                          return;
                        }

                        final userData = {
                          'id': user['id'],
                          'username': usernameController.text,
                          'name': nameController.text,
                          'email': emailController.text,
                          'role': selectedRole,
                          'lang': selectedLang,
                          'status': isActive ? 'active' : 'inactive',
                          'comment': commentController.text,
                        };

                        final messenger = ScaffoldMessenger.of(context);
                        final editSuccessMessage =
                            localizations.userEditedSuccess;

                        Navigator.of(context).pop();

                        this.setState(() {
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
                      },
                      child: Text(localizations.save),
                    ),
                  ],
                ),
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

                  final success = await _deleteUser(
                    user['id'],
                    user['username'],
                  );

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

  // 미승인 사용자 목록 다이얼로그
  void _showPendingUsersDialog() {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.pendingUserApproval),
            content: SizedBox(
              // width: MediaQuery.of(context).size.width * 0.5,
              width: 492,
              height: MediaQuery.of(context).size.height * 0.6,
              child:
                  _pendingUsers.isEmpty
                      ? Center(child: Text(localizations.noPendingUsers))
                      : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var user in _pendingUsers)
                              Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${localizations.registrationDate}: ${user['regdate']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            'ID: ${user['username']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${localizations.name}: ${user['name']}',
                                      ),
                                      Text(
                                        '${localizations.email}: ${user['email']}',
                                      ),
                                      if (user['comment'] != null &&
                                          user['comment'].isNotEmpty)
                                        Text(
                                          '${localizations.comment}: ${user['comment']}',
                                        ),
                                      const SizedBox(height: 16),
                                      _buildApprovalForm(user),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.cancel),
              ),
            ],
          ),
    );
  }

  // 승인 폼 위젯
  Widget _buildApprovalForm(Map<String, dynamic> user) {
    final localizations = AppLocalizations.of(context)!;
    final dbNameController = TextEditingController();
    bool isActive = true;

    return StatefulBuilder(
      builder:
          (context, setState) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: dbNameController,
                decoration: InputDecoration(
                  labelText: localizations.dbName,
                  border: const OutlineInputBorder(),
                  hintText: localizations.enterUserDbName,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: Text(localizations.activationStatus),
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                  });
                },
                activeColor: Colors.green,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final userData = {
                      'id': user['id'],
                      'username': user['username'],
                      'db_name': dbNameController.text,
                      'flag': isActive,
                    };

                    // 비동기 작업 전에 context와 localizations 저장
                    final currentContext = context;

                    final success = await _approveUser(userData);

                    if (success) {
                      // 성공 시 목록 새로고침
                      await _fetchPendingUsers();
                      await _fetchUsers();

                      if (mounted && currentContext.mounted) {
                        ScaffoldMessenger.of(currentContext).showSnackBar(
                          SnackBar(
                            content: Text(localizations.userApproved),
                            backgroundColor: Colors.green,
                          ),
                        );

                        // 현재 카드 제거
                        setState(() {
                          _pendingUsers.removeWhere(
                            (item) => item['id'] == user['id'],
                          );
                        });

                        // 모든 미승인 사용자가 처리되었으면 다이얼로그 닫기
                        if (_pendingUsers.isEmpty) {
                          Navigator.of(currentContext).pop();
                        }
                      }
                    } else {
                      if (mounted && currentContext.mounted) {
                        ScaffoldMessenger.of(currentContext).showSnackBar(
                          SnackBar(
                            content: Text(_errorMessage),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(localizations.approve),
                ),
              ),
            ],
          ),
    );
  }
}
