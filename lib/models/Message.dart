import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  final String id;
  final String content;
  final String sender;
  final Timestamp timestamp;

  Message({required this.id, required this.content, required this.sender, required this.timestamp});

  factory Message.fromMap(Map<String, dynamic> data) {
    return Message(
      id: data['id'],
      content: data['content'], sender: data['sender'], timestamp: data['timestamp'],
    );
  }
}
