import 'dart:developer';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/user_chat_model.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // for storing all the users
  List<ChatUser> _list = [];

  // for storing the search item
  final List<ChatUser> _searchList = [];

  bool isSearching = false;

  // for storing the email
  TextEditingController email = TextEditingController();
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    // log(APIs.me)

    // for updating user active status according to lifecycle events
    // resume -- active or online
    // pause -- inactive or offline

    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message : $message');
      if(APIs.auth.currentUser != null){
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')){
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding the keyboard when tap on screen
      onTap: () => Focus.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          // if searching is on then back button is pressed then close the search tab first
          // else close the current screen
          if (isSearching) {
            setState(() {
              isSearching = !isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: isSearching
                ? TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search user',
                      hintStyle: TextStyle(fontSize: 17, letterSpacing: .5),
                    ),
                    onChanged: (value) {
                      // search logic
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchList.add(i);
                          setState(() {
                            _searchList;
                          });
                        }
                      }
                    },
                  )
                : const Text('We Chat'),
            leading: const Icon(CupertinoIcons.home),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isSearching = !isSearching;
                  });
                },
                icon: Icon(isSearching ? Icons.cancel : Icons.search),
              ),
              IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProfileScreen(user: APIs.me))),
                  icon: const Icon(Icons.more_vert))
            ],
          ),
          body: StreamBuilder(
              stream: APIs.getMyUsersId(),

              //get id of only known users
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());

                  //if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return StreamBuilder(
                        stream: APIs.getAllUsers(
                            snapshot.data?.docs.map((e) => e.id).toList() ??
                                []),

                        //get only those user, who's ids are provided
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            //if data is loading
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                            // return const Center(
                            //     child: CircularProgressIndicator());

                            //if some or all data is loaded then show it
                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              _list = data
                                      ?.map((e) => ChatUser.fromJson(e.data()))
                                      .toList() ??
                                  [];

                              if (_list.isNotEmpty) {
                                return _showList();
                              } else {
                                return const Center(
                                  child: Text('No Connections Found!',
                                      style: TextStyle(fontSize: 20)),
                                );
                              }
                          }
                        });
                }
              }),
          floatingActionButton: Container(
            // color: Colors.lightGreen,
            margin: const EdgeInsets.only(bottom: 20, right: 10),
            child: FloatingActionButton(
              backgroundColor: Colors.lightGreen,
              onPressed: () => showDialog(
                context: context,
                builder: (context) => _addUser(),
              ),
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
        ),
      ),
    );
  }

  Widget _showList() {
    return ListView.builder(
        padding: EdgeInsets.only(top: mq.height * .01),
        itemCount: _list.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return ChatUserCard(user: _list[index]);
        });
  }

  Widget _addUser() {
    return AlertDialog(
      actions: [
        TextButton(
            onPressed: () async {
              if (email.text.isNotEmpty && await APIs.addChatUser(email.text)) {
                // ignore: use_build_context_synchronously
                Dialogs.showSnackBar(context, 'User added succesfully');
              } else {
                // ignore: use_build_context_synchronously
                Dialogs.showSnackBar(context, 'Check the email');
              }
              // ignore: use_build_context_synchronously
              Navigator.pop(context, 'Add');
              email.clear();
            },
            child: const Text('Add')),
        TextButton(
            onPressed: () {
              Navigator.pop(context, 'Cancel');
              email.clear();
            },
            child: const Text('Cancel')),
      ],
      title: const Row(children: [
        Icon(
          CupertinoIcons.person_add_solid,
          color: Colors.blueAccent,
        ),
        SizedBox(
          width: 5,
        ),
        Text('Add user')
      ]),
      content: TextFormField(
          controller: email,
          decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.email,
                color: Colors.blueAccent,
              ),
              hintText: 'Enter email',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))))),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
