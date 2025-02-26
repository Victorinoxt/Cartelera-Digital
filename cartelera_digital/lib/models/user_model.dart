class User {
  final String id;
  final String username;
  final String role;
  final DateTime lastLogin;
  final bool isActive;

  User({
    required this.id,
    required this.username,
    required this.role,
    required this.lastLogin,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      lastLogin: DateTime.parse(json['lastLogin'] as String),
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'lastLogin': lastLogin.toIso8601String(),
      'isActive': isActive,
    };
  }
}
