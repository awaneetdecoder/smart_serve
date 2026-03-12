class UserModel {
  final int    id;
  final String email;
  final String fullName;
  final String role;
  final String jwtToken; // ← this field was missing in your old file

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.jwtToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:       json['userId'] ?? json['id'] ?? 0,
      email:    json['email']    ?? '',
      fullName: json['fullName'] ?? '',
      role:     json['role']     ?? 'STUDENT',
      jwtToken: json['token']    ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id};

  bool get isAdmin => role.toUpperCase() == 'ADMIN';
}