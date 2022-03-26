import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.teal.shade700,
          title: const Text(
            'Messages',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('uid', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 37, 114, 40),
                backgroundColor: Colors.grey,
                strokeWidth: 10,
              ),
            );
          }
          return ListView.builder(
            itemCount: (snapshot.data! as dynamic).docs.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      friendUid: (snapshot.data! as dynamic)
                          .docs[index]['uid']
                          .toString(),
                      friendName: (snapshot.data! as dynamic).docs[index]
                          ['username'],
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Card(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    color: const Color.fromARGB(255, 45, 91, 110),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          (snapshot.data! as dynamic).docs[index]['photoUrl'],
                        ),
                        radius: 16,
                      ),
                      title: Text(
                        (snapshot.data! as dynamic).docs[index]['username'],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
