import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_constant';

final _fireStore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  final friendUid;
  final friendName;

  const ChatScreen({Key? key, this.friendUid, this.friendName})
      : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState(friendUid, friendName);
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final messagetextController = TextEditingController();

  late String messageText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser();
    //getCurrentUser();

    // final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // chats
    //     .where('users', isEqualTo: {friendName: null, currentUserId: null})
    //     .limit(1)
    //     .get()
    //     .then(
    //       (QuerySnapshot querySnapshot) {
    //         if (querySnapshot.docs.isNotEmpty) {
    //           chatDocId = querySnapshot.docs.single.id;
    //         } else {
    //           chats.add({
    //             'users': {currentUserId: null, friendUid: null}
    //           }).then((value) {
    //             chatDocId = value;
    //           });
    //           print(chatDocId.toString());
    //         }
    //       },
    //     )
    //     .catchError((error) {});
  }

  void checkUser() async {
    await chats
        .where('users', isEqualTo: {friendUid: null, currentUserId: null})
        .limit(1)
        .get()
        .then(
          (QuerySnapshot querySnapshot) async {
            if (querySnapshot.docs.isNotEmpty) {
              setState(() {
                chatDocId = querySnapshot.docs.single.id;
              });

              print(chatDocId);
            } else {
              await chats.add({
                'users': {currentUserId: null, friendUid: null}
              }).then((value) => {chatDocId = value});
            }
          },
        )
        .catchError((error) {});
  }

  // void getCurrentUser() {
  //   try {
  //     final user = _auth.currentUser!;
  //     if (user != null) {
  //       loggedInUser = user;
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  final friendUid;
  final friendName;
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  var chatDocId;

  _ChatScreenState(this.friendUid, this.friendName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        // actions: <Widget>[
        //   IconButton(
        //       icon: const Icon(Icons.close),
        //       onPressed: () {
        //         _auth.signOut();
        //         Navigator.pop(context);
        //       }),
        // ],
        title: Text(friendName),
        backgroundColor: const Color.fromARGB(255, 65, 67, 114),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(
              chatDocId: chatDocId,
              friendName: friendName,
              friendUid: friendUid,
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.black),
                      controller: messagetextController,
                      onChanged: (value) {
                        messageText = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messagetextController.clear();
                      FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatDocId)
                          .collection('messages')
                          .add({
                        'text': messageText,
                        'sender': currentUserId,
                        'ts': Timestamp.now(),
                      });
                      //Implement send functionality.
                    },
                    child: const Icon(
                      Icons.send_outlined,
                      color: Color.fromARGB(255, 8, 4, 92),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatefulWidget {
  var chatDocId;
  final friendUid;
  final friendName;
  MessageStream({this.chatDocId, this.friendName, this.friendUid});
  @override
  _MessageStreamState createState() => _MessageStreamState();
}

class _MessageStreamState extends State<MessageStream> {
  bool _isLoading = false;
  var userData = {};
  getData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid.toString())
          .get();

      userData = userSnap.data()!;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatDocId)
          .collection('messages')
          .orderBy('ts', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        List<MessageBubble> messageBubbles = [];
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data!.docs;

        for (var message in messages) {
          final messageText = message['text'];
          final messageSender = message['sender'];
          final Timestamp messageTime = message['ts'] as Timestamp;
          final currentUser = FirebaseAuth.instance.currentUser!.uid;
          if (currentUser == messageSender) {}

          final messageBubble = MessageBubble(
            text: messageText,
            sender: messageSender,
            isMe: currentUser == messageSender,
            time: messageTime,
            name: currentUser == messageSender
                ? userData['username']
                : widget.friendName,
          );
          messageBubbles.add(messageBubble);
        }

        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatefulWidget {
  final String sender;
  final String text;
  final Timestamp time;
  final String name;
  bool isMe;

  MessageBubble(
      {required this.text,
      required this.sender,
      required this.isMe,
      required this.name,
      required this.time});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            widget.name,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Material(
            borderRadius: widget.isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : const BorderRadius.only(
                    topRight: Radius.circular(40.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
            elevation: 10.0,
            color: widget.isMe
                ? Color.fromARGB(255, 8, 4, 92)
                : Colors.teal.shade800,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: Text(
                widget.text,
                style: TextStyle(
                  color: widget.isMe ? Colors.white : Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
