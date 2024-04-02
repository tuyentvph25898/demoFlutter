import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../models/MyModel.dart';
import 'chat_page.dart';
import 'login_page.dart';



class MembersPage extends StatefulWidget {
  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  List<MyModel> models = [];

  @override
  void initState() {
    super.initState();
    // _getAllDataFromFirestore();
    getAllMembers().listen((List<MyModel> updateMember) {
      setState(() {
        models = updateMember;
      });
    });
  }

  Stream<List<MyModel>> getAllMembers() {
    String? currentId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('members')
        .where('id', isNotEqualTo: currentId)
        .snapshots()
        .map((event) =>
        event.docs.map((e) => MyModel.fromMap(e.data())).toList());
  }

  // Future<void> _getAllDataFromFirestore() async {
  //   String? currentId = FirebaseAuth.instance.currentUser?.uid;
  //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection('members')
  //       .where('id', isNotEqualTo: currentId)
  //       .get();
  //   setState(() {
  //     models = querySnapshot.docs
  //         .map((doc) => MyModel.fromMap(doc.data() as Map<String, dynamic>))
  //         .toList();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Members"),
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
              onPressed: () {
                _showLogoutConfirmationDialog(context);
              },
            ),
          ),
        ],
      ),
      body: _member(),
    );
  }

  Widget _member() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: models.length,
          itemBuilder: (context, index) {
            var model = models[index];
            return InkWell(
              onTap: () async {
                FirebaseFirestore.instance
                    .collection('chatrooms')
                    .where('users',
                        arrayContains: FirebaseAuth.instance.currentUser?.uid)
                    .get()
                    .then((value) async {
                      print(value.toString());

                      DocumentSnapshot? chatroomDoc;
                      for (DocumentSnapshot snp in value.docs) {
                        Map<String, dynamic> data = snp.data() as Map<String, dynamic>;
                        List<String> users = (data['users'] as List<dynamic>).map((item) => item as String).toList();

                        if (users.contains(model.id)) {
                          chatroomDoc = snp;
                        }
                      }

                      if (chatroomDoc == null) {
                        // tao chatroom moi

                        final id = FirebaseFirestore.instance.collection('chatrooms').doc().id;
                        final chatroomData = {'users':[FirebaseAuth.instance.currentUser?.uid, model.id], 'id': id};
                        FirebaseFirestore.instance.collection('chatrooms').doc(id).set(chatroomData);
                        chatroomDoc = await FirebaseFirestore.instance.collection('chatrooms').doc(id).get();
                      }
                      // chuyen trang sang chat
                      Map<String, dynamic> chatroom = chatroomDoc.data() as Map<String, dynamic>;
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChatPage(email: model.email, chatroomId: chatroom['id'], status: model.status, token: model.token,)));
                });
              },
              child: ListTile(
                title: Text(model.email),
                subtitle: Text(model.status),
              ),
            );
          },
        )
      ],
    );
  }

  void _signOut() async {
    try {
      FirebaseFirestore.instance.collection('members').doc(FirebaseAuth.instance.currentUser?.uid).update(
          {'status': "offline"});
      await FirebaseAuth.instance.signOut();
      // Điều hướng người dùng đến trang đăng nhập
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );

    } catch (e) {
      print("Lỗi khi đăng xuất: $e");
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Đăng xuất"),
          content: Text("Bạn có muốn đăng xuất không?"),
          actions: <Widget>[
            TextButton(
              child: Text("Không"),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
            TextButton(
              child: Text("Có"),
              onPressed: () {
                // Thực hiện đăng xuất ở đây
                _signOut(); // Ví dụ gọi hàm đăng xuất _signOut
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
          ],
        );
      },
    );
  }
}
