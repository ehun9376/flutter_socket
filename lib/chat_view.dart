// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

import 'MessageModel/message_model.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChatPageState();
  }
}

class ChatPageState extends State<ChatPage> {
  late IOWebSocketChannel channel; //channel varaible for websocket
  late bool connected; // boolean value to track connection status

  List<MessageDataModel> msglist = [];

  Color localColor = Colors.black;

  String localName = "";

  TextEditingController msgtext = TextEditingController();

  @override
  void initState() {
    localName = "";
    connected = false;
    msgtext.text = "";
    channelconnect();
    super.initState();
  }

  channelconnect() {
    //function to connect
    try {
      channel =
          IOWebSocketChannel.connect("ws://web-socket-ehun.herokuapp.com/");
      channel.stream.listen(
        (message) {
          print(message);
          setState(() {
            if (message != "") {
              print(message);
              connected = true;
              setState(() {
                message = message.replaceAll(RegExp("'"), '"');
                var jsondata = json.decode(message);
                switch ((jsondata["type"] as String).messageType()) {
                  case MessageType.message:
                    var messageData = MessageModel.fromJson(jsondata);
                    msglist.addAll(messageData.data);

                    scollController.animateTo(
                        scollController.position.maxScrollExtent + 100,
                        duration: const Duration(seconds: 1),
                        curve: Curves.ease);
                    break;
                  case MessageType.history:
                    var messageData = MessageModel.fromJson(jsondata);
                    msglist.addAll(messageData.data);

                    scollController.animateTo(
                        scollController.position.maxScrollExtent,
                        duration: const Duration(seconds: 1),
                        curve: Curves.ease);
                    break;
                  case MessageType.color:
                    localColor = (jsondata['data'] as String).convertToColor();
                    break;
                }
              });
            }
          });
        },
        onDone: () {
          print("Web socket is closed");
          setState(() {
            connected = false;
          });
        },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (_) {
      print("error on connecting to websocket.");
    }
  }

  Future<void> sendmsg(String sendmsg) async {
    if (connected == true) {
      String msg = "$sendmsg";
      channel.sink.add(msg); //send message to reciever channel
    } else {
      channelconnect();
      print("Websocket is not connected.");
    }
  }

  var scollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Chat App Example"),
          leading: Icon(Icons.circle,
              color: connected ? Colors.greenAccent : Colors.redAccent),
          //if app is connected to node.js then it will be gree, else red.
          titleSpacing: 0,
        ),
        body: Container(
            child: Stack(
          children: [
            Positioned(
                top: 0,
                bottom: 70,
                left: 0,
                right: 0,
                child: Container(
                    padding: const EdgeInsets.all(15),
                    child: SingleChildScrollView(
                        controller: scollController,
                        child: Column(
                          children: [
                            Container(
                              child: const Text("Your Messages",
                                  style: const TextStyle(fontSize: 20)),
                            ),
                            Column(
                              children: msglist.map((onemsg) {
                                return Container(
                                    margin: EdgeInsets.only(
                                      //if is my message, then it has margin 40 at left
                                      left: onemsg.name == localName ? 40 : 0,
                                      right: onemsg.name == localName
                                          ? 0
                                          : 40, //else margin at right
                                    ),
                                    child: Card(
                                        color: onemsg.name == localName
                                            ? Colors.blue[100]
                                            : Colors.red[100],
                                        //if its my message then, blue background else red background
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(15),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(onemsg.name == localName
                                                  ? "ID: ME"
                                                  : "ID: ${onemsg.name}"),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 10, bottom: 10),
                                                child: Text(
                                                    "Message: ${onemsg.message}",
                                                    style: const TextStyle(
                                                        fontSize: 17)),
                                              ),
                                            ],
                                          ),
                                        )));
                              }).toList(),
                            )
                          ],
                        )))),
            Positioned(
              //position text field at bottom of screen
              bottom: 0, left: 0, right: 0,
              child: Container(
                  color: Colors.black12,
                  height: 70,
                  child: Row(
                    children: [
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.all(10),
                        child: TextField(
                          controller: msgtext,
                          decoration: InputDecoration(
                              hintText: localName == "" ? "請輸入姓名" : "請輸入訊息"),
                        ),
                      )),
                      Container(
                          margin: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            child: const Icon(Icons.send),
                            onPressed: () {
                              if (msgtext.text != "") {
                                if (localName == "") {
                                  setState(() {
                                    localName = msgtext.text;
                                  });
                                  sendmsg(msgtext.text);
                                } else {
                                  sendmsg(msgtext.text);
                                }
                                msgtext.text = "";
                              } else {
                                print("Enter message");
                              }
                            },
                          ))
                    ],
                  )),
            )
          ],
        )));
  }
}
