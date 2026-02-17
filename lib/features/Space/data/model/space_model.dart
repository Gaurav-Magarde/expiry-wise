class SpaceModel {
  final String id;
  final String userId;
  final String name;
  final String updatedAt;

  SpaceModel({required this.userId,required this.updatedAt, required this.name, required this.id});

  Map<String, dynamic> getMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'is_synced': 0,
      'is_deleted': 0,
      'updated_at':updatedAt
    };
  }

  factory SpaceModel.fromMap({required Map<String, dynamic> map, String? userId}) {
    return SpaceModel(updatedAt: map['updated_at']??'', userId: userId??'', name: map['name']??'', id: map['id']);
  }

   Map<String, dynamic> toMap() {
    return {'user_id': userId, 'name': name, 'id': id,'updated_at': updatedAt,'is_deleted':0};
  }
}
