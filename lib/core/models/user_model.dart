class UserModel {
  final String id;
  final String username;
  final String name;
  final String email;
  final String role;
  final String lastLogin;
  final String status;
  final String lang;
  final String comment;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.role,
    required this.lastLogin,
    this.status = 'active',
    this.lang = 'kor',
    this.comment = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['code'] ?? '',
      username: json['ID'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      lastLogin: json['regdate'] ?? '-',
      status: json['flag'] == true ? 'active' : 'inactive',
      lang: json['lang'] ?? 'kor',
      comment: json['comment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'role': role,
      'lastLogin': lastLogin,
      'status': status,
      'lang': lang,
      'comment': comment,
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'code': id,
      'ID': username,
      'name': name,
      'email': email,
      'role': role,
      'regdate': lastLogin,
      'flag': status == 'active',
      'lang': lang,
      'comment': comment,
    };
  }
}
