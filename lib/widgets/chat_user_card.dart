import 'package:chat_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width*.04, vertical: 4),
      // color: Colors.blueGrey.shade100,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {},
        child: const ListTile(
          leading: CircleAvatar(
              child: Icon(CupertinoIcons.person)),
          title: Text('Name', style: TextStyle(fontWeight: FontWeight.w600),),
          subtitle: Text(
            'Hello',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text('12:00 PM', style: TextStyle(color: Colors.black54),),
        ),
      ),
    );
  }
}
