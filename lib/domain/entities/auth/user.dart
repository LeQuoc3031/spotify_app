class UserEntity {
  String? userId;
  String? biography;
  String? birthday;
  String? fullName;
  String? gender;
  String? phone;  
  String? email;
  String? avatarUrl;
  String? imageURL;

  UserEntity({
    this.userId,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.biography,
    this.birthday,
    this.gender,
    this.phone,
    this.imageURL,
  });

  UserEntity copyWith({
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
    return UserEntity(
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
