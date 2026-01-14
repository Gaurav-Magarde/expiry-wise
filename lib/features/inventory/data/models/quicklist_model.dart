class QuickListModel {
  final String id;
  final String spaceId;
  final String title;
  final bool isCompleted;
  final bool isSynced;
  final String updatedAt;

  QuickListModel({
    required this.id,
    required this.spaceId,
    required this.title,
    required this.isCompleted,
    required this.isSynced,
    required this.updatedAt,
  });

  factory QuickListModel.fromMap({required Map<String,dynamic> map}){
    return QuickListModel(
      id: map['id']??'',
      spaceId: map['space_id']??'',
      title: map['title']??'',
        isCompleted: map['is_completed']!=null?map['is_completed']==0?true:false:false,
        isSynced: map['is_synced']!=null?map['is_synced']==0?true:false:false,
        updatedAt:map['updated_at']??''
    );
  }

  Map<String,dynamic> toMap(){
    return {
      'id': id,
      'space_id': spaceId,
      'title':title,
      'is_completed':isCompleted?1:0,
      'is_synced':isSynced?1:0,
      'updated_at':updatedAt
    };
  }
}
