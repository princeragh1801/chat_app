class UserChatModel {
  String? image;
  String? name;
  String? about;
  String? createdAt;
  bool? isOnline;
  String? lastActive;
  String? id;
  String? pushToken;
  String? email;

  UserChatModel(
      {this.image,
      this.name,
      this.about,
      this.createdAt,
      this.isOnline,
      this.lastActive,
      this.id,
      this.pushToken,
      this.email});

  UserChatModel.fromJson(Map<String, dynamic> json) {
    image = json['image']??'';
    name = json['name']??'';
    about = json['about']??'';
    createdAt = json['created_at']??'';
    isOnline = json['is_online']??'';
    lastActive = json['last_active']??'';
    id = json['id']??'';
    pushToken = json['push_token']??'';
    email = json['email']??'';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['about'] = about;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['last_active'] = lastActive;
    data['id'] = id;
    data['push_token'] = pushToken;
    data['email'] = email;
    return data;
  }
}
