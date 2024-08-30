import 'dart:convert';
// Import for Platform class
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  final ChatUser myself = ChatUser(
    id: '1',
    firstName: 'Satyam',
  );
  final ChatUser bot = ChatUser(id: '2', firstName: 'Sarthi');

  final List<ChatMessage> allMessages = [];
  final List<ChatUser> typing = [];

  final myurl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyB2RejNv98F4JjZQCNkmJs1HXcmMMeJHhE';

  final header = {'Content-Type': 'application/json'};
  getdata(ChatMessage m) async {
    typing.add(bot);
    allMessages.insert(0, m);
    setState(() {});

    var data = {
      "contents": [
        {
          "parts": [
            {"text": m.text}
          ]
        }
      ]
    };

    await http
        .post(Uri.parse(myurl), headers: header, body: jsonEncode(data))
        .then((value) {
      if (value.statusCode == 200) {
        var result = jsonDecode((value.body));
        // print(result);
        print(result['candidates'][0]['content']['parts'][0]['text']);

        ChatMessage m1 = ChatMessage(
            user: bot,
            createdAt: DateTime.now(),
            text: result['candidates'][0]['content']['parts'][0]['text']);

        allMessages.insert(0, m1);
        setState(() {});
      } else {
        print("error occured");
      }
    }).catchError((e) {});
    typing.remove(bot);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: const Text(
          'Sarth: AI Bot',
          style: TextStyle(color: Colors.amber),
        ),
      ),
      body: DashChat(
        typingUsers: typing,
        currentUser: myself,
        onSend: (ChatMessage m) {
          getdata(m);
        },
        messages: allMessages,
        inputOptions: const InputOptions(
          alwaysShowSend: true,
          cursorStyle: CursorStyle(color: Colors.black),
        ),
        messageOptions: MessageOptions(
          currentUserContainerColor: Colors.black,
          avatarBuilder: (user, onAvatarTap, onAvatarLongPress) {
            return Center(
              child:
                  Image.asset('assets/images/Bot.jpeg', height: 40, width: 40),
            );
          },
        ),
      ),
    );
  }
}
