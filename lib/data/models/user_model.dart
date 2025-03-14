class UserModel {
  final String? email;
  final String? password;
  final String? token;
  final String? fullname;
  final String? profileImage;
  final String? id;
  final String? role;

  UserModel({
    this.email,
    this.password,
    this.token,
    this.fullname,
    this.profileImage,
    this.id,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return UserModel(
      email: user?['email'],
      token: json['token'],
      fullname: user?['fullname'],
      profileImage: user?['profileImage'],
      id: user?['id'],
      role: user?['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  String get initials {
    if (fullname == null || fullname!.isEmpty) return '';
    final names = fullname!.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return names[0][0].toUpperCase();
  }
} 