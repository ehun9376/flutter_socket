import 'package:flutter/material.dart';
import 'dart:convert';

// var colors = [ 'red', 'green', 'blue', 'purple', 'orange' ];
enum MessageType { message, history, color }

extension StrExt on String {
  Color convertToColor() {
    switch (this) {
      case "blue":
        return Colors.blue;
      case "red":
        return Colors.red;
      case "green":
        return Colors.green;
      case "purple":
        return Colors.purple;
      case "orange":
        return Colors.orange;

      default:
        return Colors.black;
    }
  }

  MessageType messageType() {
    switch (this) {
      case "message":
        return MessageType.message;
      case "history":
        return MessageType.history;
      case "color":
        return MessageType.color;
      default:
        return MessageType.message;
    }
  }
}

class MessageDataModel {
  late String name;
  late String time;
  late Color color;
  late String message;

  MessageDataModel(
      {required this.name,
      required this.message,
      required this.color,
      required this.time});

  factory MessageDataModel.fromJson(Map<String, dynamic> json) {
    return MessageDataModel(
        name: json['author'] as String,
        message: json["text"] as String,
        color: (json["color"] as String).convertToColor(),
        time: json["time"] as String);
  }
}

class MessageModel {
  late MessageType type;
  late List<MessageDataModel> data;
  late Color color;

  MessageModel({required this.type, required this.data, required this.color});

  factory MessageModel.fromJson(Map<String, dynamic> datajson) {
    List<MessageDataModel> data = [];
    Color color = Colors.black;
    MessageType type = (datajson['type'] as String).messageType();
    if (datajson["data"] is List) {
      for (var i in datajson["data"] as List) {
        data.add(MessageDataModel.fromJson(i));
      }
    } else {
      data.add(MessageDataModel.fromJson(datajson["data"]));
    }

    return MessageModel(type: type, data: data, color: color);
  }
}

class OnlyColorModel {
  late MessageType type;

  late Color color;

  OnlyColorModel({required this.type, required this.color});

  factory OnlyColorModel.fromJson(Map<String, dynamic> json) {
    return OnlyColorModel(
        type: (json['type'] as String).messageType(),
        color: (json['color'] as String).convertToColor());
  }
}
