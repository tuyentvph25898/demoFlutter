import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:quanlynv/api/firebase_api.dart';
import 'package:quanlynv/models/MyModel.dart';

import '../models/Message.dart';

class ChatPage extends StatefulWidget {
  final String email;
  final String chatroomId;
  final String status;
  final String token;

  const ChatPage({super.key, required this.email, required this.chatroomId, required this.status, required this.token});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  List<Message> messages = [];

  Stream<List<Message>> getMessages(String chatroomId) {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(widget.chatroomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((event) =>
        event.docs.map((e) => Message.fromMap(e.data())).toList());
  }

  @override
  void initState() {
    super.initState();
    getMessages(widget.chatroomId).listen((List<Message> updatedMessages) {
      setState(() {
        messages = updatedMessages;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.email),
        elevation: 10,
        shadowColor: Colors.black38,
        actions: [
          Padding(
            padding: EdgeInsets.all(10),
            child: IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.red,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: _chatroom(),
    );
  }

  Widget _chatroom() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final content = messages[index].content;
              final senderId = messages[index].sender;
              final currentUid = FirebaseAuth.instance.currentUser?.uid;
              return Align(
                alignment: senderId == currentUid ? Alignment.topRight : Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.all(5),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: senderId == currentUid ? Colors.blue : Colors.black12,

                  ),
                  child: Text(
                    content,
                    style: senderId == currentUid ? TextStyle(color: Colors.white) : TextStyle(color: Colors.black),
                  ),
                ),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            margin: EdgeInsets.only(left: 20, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                        hintText: "Aa",
                        hintStyle: const TextStyle(color: Colors.black38),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: Colors.red)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: Colors.red)),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 16)
                    ),

                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final messageId = await FirebaseFirestore.instance
                        .collection('chatrooms')
                        .doc(widget.chatroomId)
                        .collection('messages')
                        .doc()
                        .id;
                    await FirebaseFirestore.instance
                        .collection('chatrooms')
                        .doc(widget.chatroomId)
                        .collection('messages')
                        .doc(messageId)
                        .set({
                      'id': messageId,
                      'content': messageController.text,
                      'sender': FirebaseAuth.instance.currentUser?.uid,
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    final sender = FirebaseAuth.instance.currentUser?.email;
                    final mes = await FirebaseFirestore.instance
                        .collection('chatrooms')
                        .doc(widget.chatroomId)
                        .collection('messages')
                        .doc(messageId).get();
                    final mes1 = Message.fromMap(mes.data() as Map<String, dynamic>);
                    String? currentId = FirebaseAuth.instance.currentUser?.uid;
                    final us = await FirebaseFirestore.instance.collection('members').doc(currentId).get();
                    final us1 = MyModel.fromMap(us.data() as Map<String, dynamic>);

                    Map<String, dynamic> customData = {
                      'email': us1.email,
                      'chatroomId': widget.chatroomId,
                      'status': us1.status,
                      'token':us1.token,
                    };

                    if(widget.status == "offline"){
                      await FirebaseApi().sendNotification(widget.token, sender!, mes1.content, customData);
                    }
                    messageController.text = "";
                  },
                  icon: Icon(Icons.send),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
