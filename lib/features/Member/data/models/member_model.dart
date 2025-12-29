class MemberModel {
  final String name;
  final String userId;
  final String spaceID;
  final String id;
  final String role;
  final String photo;

  MemberModel({
    required this.role,
    required this.name,
    required this.spaceID,
    required this.id,
    required this.userId,
    required this.photo,
  });

  Map<String, dynamic> toMap() {
    return {
      "photo": photo,
      "name": name,
      'user_id': userId,
      'space_id': spaceID,
      'id': id,
      'role': role,
      "is_synced": 0,
      "is_deleted": 0,
    };
  }

  factory MemberModel.fromLocal(Map<String, dynamic> member) {
    return MemberModel(
      photo: member['photo'] ?? '',
      name: member['name'] ?? "",
      spaceID: member['space_id'] ?? "",
      id: member['id'] ?? "",
      userId: member['user_id'] ?? "",
      role: member['role'] ?? '',
    );
  }
}

enum MemberRole { admin, member }
