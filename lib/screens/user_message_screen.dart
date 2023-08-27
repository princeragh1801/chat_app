import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/models/user_chat_model.dart';
import 'package:chat_app/widgets/message_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, required this.user});
  final UserChatModel user;
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Message> list = [];
  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .1),
              child: CachedNetworkImage(
                height: mq.height * .05,
                width: mq.height * .05,
                fit: BoxFit.cover,
                imageUrl: widget.user.image!,
                placeholder: (context, url) => Icon(
                  CupertinoIcons.person,
                  size: mq.height * 0.03,
                ),
                errorWidget: (context, url, error) => const Icon(
                  CupertinoIcons.person,
                ),
              ),
            ),
            title: Text(
              widget.user.name!,
              style: const TextStyle(fontSize: 17),
            ),
            subtitle: Text(
              'Last seen on ${MyDateUtil.getFormattedTime(context: context, time: widget.user.lastActive!)}',
              style: const TextStyle(fontSize: 10),
            ),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: APIs.getAllMessages(widget.user),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(
                        child: SizedBox(),
                      );

                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;

                      list =
                          data!.map((e) => Message.fromJson(e.data())).toList();
                      for (int i = 0; i < list.length; i++) {
                        log(list[i].msg);
                      }
                      if (list.isNotEmpty) {
                        return ListView.builder(
                          padding: EdgeInsets.all(mq.height*0.01),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                          return MessageBox(message: list[index]);
                        });
                      }
                      return const Center(
                        child: Text(
                          'Say 👋',
                          style: TextStyle(fontSize: 20),
                        ),
                      );
                  }
                },
              ),
            ),
          ],
        ),
        bottomSheet: BottomSheet(
            backgroundColor: Colors.white,
            onClosing: () {},
            builder: (context) {
              return _showBottomSheet();
            }));
  }

  Widget _showBottomSheet() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: mq.width * .85,
          padding: EdgeInsets.symmetric(
              horizontal: mq.width * 0.03, vertical: mq.height * 0.01),
          child: TextFormField(
            controller: _textController,
            decoration: InputDecoration(
                hintText: 'Type something here...',
                hintStyle: const TextStyle(color: Colors.lightBlueAccent),
                prefixIcon: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.lightBlueAccent,
                  ),
                ),
                suffixIcon: SizedBox(
                  width: mq.width * 0.25,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            // Pick an image.
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery, imageQuality: 80);
                          },
                          icon: const Icon(
                            Icons.photo_library_outlined,
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            // Pick an image.
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.camera, imageQuality: 80);
                          },
                          icon: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.lightBlueAccent,
                          ),
                        )
                      ]),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20))),
          ),
        ),
        CircleAvatar(
            radius: mq.width * 0.07,
            backgroundColor: Colors.lightGreen,
            child: IconButton(
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    APIs.sendMessage(widget.user, _textController.text);
                    _textController.clear();
                  }
                },
                icon: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: mq.height * 0.03,
                )))
      ],
    );
  }
}
