import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quanlynv/api/firebase_api.dart';
import '../models/MyModel.dart';

class AddNotifyPage extends StatefulWidget {
  @override
  _AddNotifyPageState createState() => _AddNotifyPageState();
}

class _AddNotifyPageState extends State<AddNotifyPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  List<MyModel> models = [];

  @override
  void initState() {
    super.initState();
    _getAllDataFromFirestore();
  }

  Future<void> _getAllDataFromFirestore() async {
    String? currentId = FirebaseAuth.instance.currentUser?.uid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('members')
        .where('id', isNotEqualTo: currentId)
        .get();
    setState(() {
      models = querySnapshot.docs
          .map((doc) => MyModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Add notification"),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder(
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return ListView.builder(
                      itemCount: models.length,
                      itemBuilder: (context, index) {
                        final model = models[index];
                        return ListTile(
                          title: Text(model.email),
                          subtitle: Text(model.status),
                          leading: Checkbox(
                            value: model.selected,
                            onChanged: (value) {
                              setState(() {
                                model.selected = value!;
                              });
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Lấy danh sách token từ các người dùng đã chọn
                List<String> selectedTokens = models
                    .where((model) => model.selected)
                    .map((model) => model.token)
                    .toList();

                String title = _titleController.text;
                String content = _contentController.text;

                // Thực hiện push thông báo đến các người dùng đã chọn
                await FirebaseApi().sendNotificationAdmin(selectedTokens, title, content);
              },
              child: Text('Push'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
