import 'dart:developer';
import 'package:chat_app/helper/dialogs.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/messages.dart';
import 'package:flutter/material.dart';

class MessageBox extends StatefulWidget {
  const MessageBox({super.key, required this.message});
  final Message message;

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  String time = 'Not seen yet';
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    if (widget.message.read.isNotEmpty){
      time = MyDateUtil.getFormattedTime(
          context: context, time: widget.message.read);
    }
      
    return InkWell(
      onLongPress: () => _showBottomSheet(),
      child: isMe ? _showGreenBox() : _showBlueBox(),
    );
  }

  Widget _showMessage() {
    return widget.message.type == Type.text
        ? Text(
            widget.message.msg,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: widget.message.msg,
              placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  )),
              errorWidget: (context, url, error) => const Icon(
                Icons.image,
                size: 70,
              ),
            ),
          );
  }

  Widget _showGreenBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: mq.width * .04),
            Icon(
              Icons.done_all,
              color:
                  widget.message.read.isNotEmpty ? Colors.blue : Colors.black,
            ),
            const SizedBox(
              width: 2,
            ),

            // sent time
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
              padding: EdgeInsets.all(widget.message.type == Type.image
                  ? mq.width * .03
                  : mq.width * .04),
              margin: EdgeInsets.symmetric(
                  horizontal: mq.width * .04, vertical: mq.height * .01),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 218, 255, 176),
                  border: Border.all(color: Colors.lightGreen),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30))),
              child: _showMessage()),
        ),
      ],
    );
  }

  Widget _showBlueBox() {
    // update the last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      log('message read update');
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),

            // height: widget.message.type == Type.image ? mq.height*.3 : null,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightBlue),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: _showMessage(),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  _showBottomSheet() {
    return showModalBottomSheet(
      // backgroundColor: Colors.grey,

      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      // useSafeArea: true,
      builder: (context) {
        return SizedBox(
            height: mq.height * 0.4,
            width: mq.width,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buttonBuilder(Icons.copy, 'Copy', Colors.blueAccent),
                  const Divider(),
                  _buttonBuilder(Icons.edit, 'Edit Message', Colors.blueAccent),
                  _buttonBuilder(
                      Icons.delete, 'Delete Message', Colors.redAccent),
                  const Divider(),
                  _buttonBuilder(
                      Icons.remove_red_eye,
                      'Sent at ${MyDateUtil.getFormattedTime(context: context, time: widget.message.sent)}',
                      Colors.blueAccent),
                  _buttonBuilder(Icons.remove_red_eye, 'Read at : $time',
                      Colors.greenAccent),
                ],
              ),
            ));
      },
    );
  }

  Widget _buttonBuilder(IconData iconData, String title, Color iconColor) {
    return TextButton.icon(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(10),
        ),
        onPressed: () {
          if (iconData == Icons.copy) {
            FlutterClipboard.copy(widget.message.msg);
            Dialogs.showSnackBar(context, 'Message Copied!');
            FlutterClipboard.paste();
          }
          if (iconData == Icons.edit) {
            Dialogs.showSnackBar(context, 'Message Edited!');
          }
          if (iconData == Icons.delete) {
            setState(() {
              APIs.deleteMessage(widget.message);
            });
            Dialogs.showSnackBar(context, 'Message Deleted!');
          }
          Navigator.pop(context);
        },
        icon: Icon(
          iconData,
          color: iconColor,
        ),
        label: Text(
          title,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ));
  }
}
