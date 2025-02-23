class UserModel {
  final String? email;
  final String? password;
  final String? token;

  UserModel({
    this.email,
    this.password,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
} 