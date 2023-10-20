// To parse this JSON data, do
//
//     final chatUserModel = chatUserModelFromJson(jsonString);

import 'dart:convert';

ChatUserModel chatUserModelFromJson(String str) =>
    ChatUserModel.fromJson(json.decode(str));

String chatUserModelToJson(ChatUserModel data) => json.encode(data.toJson());

class ChatUserModel {
  String? image;
  String? about;
  String? name;
  String? createdAt;
  bool? isOnline;
  String? id;
  String? lastActive;
  String? email;
  String? pushToken;

  ChatUserModel({
    this.image,
    this.about,
    this.name,
    this.createdAt,
    this.isOnline,
    this.id,
    this.lastActive,
    this.email,
    this.pushToken,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) => ChatUserModel(
        image: json["image"] ?? "",
        about: json["about"] ?? "",
        name: json["name"] ?? "",
        createdAt: json["created_at"] ?? "",
        isOnline: json["is_online"] ?? "",
        id: json["id"] ?? "",
        lastActive: json["last_active"] ?? "",
        email: json["email"] ?? "",
        pushToken: json["push_token"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "about": about,
        "name": name,
        "created_at": createdAt,
        "is_online": isOnline,
        "id": id,
        "last_active": lastActive,
        "email": email,
        "push_token": pushToken,
      };
}
