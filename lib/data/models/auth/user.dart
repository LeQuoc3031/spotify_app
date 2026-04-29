import 'package:spotify_app/domain/entities/auth/user.dart';

class UserModel extends UserEntity {
  UserModel({
    super.userId,
    required super.fullName,
    required super.email,
    required super.avatarUrl,
    super.biography,
    super.birthday,
    super.gender,
    super.phone,
    super.imageURL,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      fullName: json['fullName'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      biography: json['biography'],
      birthday: json['birthday'],
      gender: json['gender'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'avatarUrl': avatarUrl,
      'biography': biography,
      'birthday': birthday,
      'gender': gender,
      'phone': phone,
    };
  }

  @override
  UserModel copyWith({
    String? userId,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? biography,
    String? birthday,
    String? gender,
    String? phone,
    String? imageURL,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      biography: biography ?? this.biography,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      imageURL: imageURL ?? this.imageURL,
    );
  }
}
