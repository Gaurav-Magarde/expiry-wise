class UserModel {
  UserModel({
    required this.photoUrl,
    required this.userType,
    required this.name,
    required this.email,
    required this.updatedAt,
    required this.id,
  });
  final String name;
  final String email;
  final String updatedAt;
  final String id;
  final String userType;
  final String photoUrl;

  factory UserModel.empty() {
    return UserModel(updatedAt:'',photoUrl: '', userType: '', name: '', email: '', id: '');
  }

  Map<String, Object?> toMap() {
    return {
      'updated_at':updatedAt,
      'name': name,
      'email': email,
      'id': id,
      'user_type': userType,
      'photo_url': photoUrl,
      'is_synced' : 0,
      'is_deleted' : 0
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? id,
    String? userType,
    String? photoUrl,
    String? updatedAt,
  }) {
    return UserModel(
      updatedAt: updatedAt??this.updatedAt,
      photoUrl: photoUrl ?? this.photoUrl,
      userType: userType ?? this.userType,
      name: name ?? this.name,
      email: email ?? this.email,
      id: id ?? this.id,
    );
  }

  static UserModel fromMap(Map<String, dynamic> first) {
    return UserModel(
      updatedAt:first['updated_at']??'',
      photoUrl: first['photo_url']??'',
      userType: first['user_type']??'',
      name: first['name']??'',
      email: first['email']??'',
      id: first['id']??'',
    );
  }


}
