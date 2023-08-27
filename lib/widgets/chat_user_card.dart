import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/user_chat_model.dart';
import 'package:chat_app/screens/user_message_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.user});
  final UserChatModel user;
  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    // final time = 
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      // color: Colors.blueGrey.shade100,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MessagesScreen(user: widget.user,))),
        child: ListTile(
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
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            widget.user.about!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Text(
            '12:00 AM',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}
