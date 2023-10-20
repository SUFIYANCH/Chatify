// To parse this JSON data, do
//
//     final messageModel = messageModelFromJson(jsonString);

import 'dart:convert';

MessageModel messageModelFromJson(String str) =>
    MessageModel.fromJson(json.decode(str));

String messageModelToJson(MessageModel data) => json.encode(data.toJson());

class MessageModel {
  String? msg;
  String? toId;
  String? read;
  Type? type;
  String? fromId;
  String? sent;

  MessageModel({
    this.msg,
    this.toId,
    this.read,
    this.type,
    this.fromId,
    this.sent,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        msg: json["msg"],
        toId: json["toId"],
        read: json["read"],
        type: json["type"] == Type.image.name ? Type.image : Type.text,
        fromId: json["fromId"],
        sent: json["sent"],
      );

  Map<String, dynamic> toJson() => {
        "msg": msg,
        "toId": toId,
        "read": read,
        "type": type!.name,
        "fromId": fromId,
        "sent": sent,
      };
}

enum Type { text, image }
