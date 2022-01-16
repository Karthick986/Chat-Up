import 'package:chat_app/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatUs extends StatelessWidget {
  const ChatUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Up',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: ChatUsPage(),
    );
  }
}

class ChatUsPage extends StatefulWidget {
  const ChatUsPage({Key? key}) : super(key: key);

  @override
  _ChatUsPageState createState() => _ChatUsPageState();
}

class _ChatUsPageState extends State<ChatUsPage> {

  final TextEditingController _etChat = TextEditingController();

  void showLogout(context) {
    // set up the buttons
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('No'));
    Widget continueButton = TextButton(
        onPressed: () async {
          Navigator.pop(context);
          FirebaseAuth.instance.signOut().then((value) =>
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage())));
        },
        child: const Text('Yes'));

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: const Text(
        'Confirm Logout',
        style: TextStyle(fontSize: 18),
      ),
      content: const Text('Are you sure want to logout ?',
          style: TextStyle(fontSize: 15)),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  User? firebaseUser;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('Chats').snapshots();
    firebaseUser = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    _etChat.dispose();
    super.dispose();
  }

  void _addMessage(String message) {
    DateTime now = DateTime.now();
    FirebaseFirestore.instance.collection('Chats').doc(now.toString()).set({
      'uid': firebaseUser!.uid,
      'date': now.day.toString()+"/"+now.month.toString()+"/"+now.year.toString()+" - "+now.hour.toString()+":"+now.minute.toString(),
      'message': message
    });
    _etChat.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          automaticallyImplyLeading: false,
          title: const Text(
            'Chat Up',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          actions: [
            InkWell(
              child: const Padding(
                padding: EdgeInsets.only(right: 16.0, left: 16),
                child: Icon(Icons.logout),
              ),
              onTap: () {
                FocusScope.of(context).unfocus();
                showLogout(context);
              },
            )
          ],
        ),
        body: Column(
          children: [
        StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Chats').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return (!snapshot.hasData)
              ? Center(
            child: CircularProgressIndicator(),
          ) : Flexible(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: snapshot.data!.docs.map((document) {
                return document["uid"]==firebaseUser!.uid ? _buildChatUser(document["message"], document["date"]) : _buildChatFrnd(document["message"], document["date"]);
    }).toList()));
        }),
            Container(
              margin: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: _etChat,
                      minLines: 1,
                      maxLines: 4,
                      textAlignVertical: TextAlignVertical.bottom,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      decoration: InputDecoration(
                        fillColor: Colors.grey[200],
                        filled: true,
                        hintText: 'Type something',
                        focusedBorder: UnderlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(color: Colors.grey[200]!)),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Opacity(
                    opacity: _etChat.text.trim()=='' ? 0.5 : 1,
                    child: GestureDetector(
                      onTap: (){
                        if(_etChat.text.trim() != '') {
                          _addMessage(_etChat.text);
                        } else {
                          Fluttertoast.showToast(msg: "Write message to send!");
                        }
                      },
                      child: ClipOval(
                        child: Container(
                            color: Colors.blue,
                            padding: const EdgeInsets.all(10),
                            child: const Icon(Icons.send, color: Colors.white)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        )
    );
  }

  Widget _buildChatUser(String message, time){
    final double boxChatSize = MediaQuery.of(context).size.width/1.3;
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        alignment: WrapAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: boxChatSize),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: Border.all(
                    width: 1,
                    color: Colors.grey[300]!
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(12),
                ),
                color: Colors.grey[300]
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(message, style: const TextStyle(
                      color: Colors.black54,
                    fontSize: 16
                  )),
                ),
                Wrap(
                  children: [
                    const SizedBox(width: 4),
                    Icon(Icons.done_all, size: 11),
                    const SizedBox(width: 2),
                    Text(time, style: const TextStyle(
                        color: Colors.blue, fontSize: 10
                    )),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatFrnd(String message, String date){
    final double boxChatSize = MediaQuery.of(context).size.width/1.3;
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        children: [
          Container(
              constraints: BoxConstraints(maxWidth: boxChatSize),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color: Colors.grey[300]!
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(5),
                  )
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(message, style: const TextStyle(
                        color: Colors.black54,
                      fontSize: 16
                    )),
                  ),
                  Wrap(
                    children: [
                      const SizedBox(width: 2),
                      Text(date, style: const TextStyle(
                          color: Colors.black54, fontSize: 10
                      )),
                    ],
                  )
                ],
              )
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl){
    final double boxChatSize = MediaQuery.of(context).size.width/1.3;
    final double boxImageSize = (MediaQuery.of(context).size.width / 6);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        alignment: WrapAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: boxChatSize),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: Border.all(
                    width: 1,
                    color: Colors.grey[300]!
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(12),
                )
            ),
            child: SizedBox(
              width: boxImageSize,
              height: boxImageSize,
              child: ClipRRect(
                  borderRadius:
                  const BorderRadius.all(Radius.circular(8)),
                  child: Image.asset(imageUrl, width: boxImageSize, height: boxImageSize)),
            ),
          ),
        ],
      ),
    );
  }
}
