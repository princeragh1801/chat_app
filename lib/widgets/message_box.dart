import 'dart:developer';

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
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(mq.height*.01),
      child: Flexible(
        
          child: APIs.user.uid == widget.message.fromId
              ? _showGreenBox()
              : _showBlueBox()),
    );
  }

  Widget _showGreenBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.done_all,
              color:
                  widget.message.read.isNotEmpty ? Colors.blue : Colors.black,
            ),
            // Text(MyDateUtil.getFormattedTime(
            //     context: context, time: widget.message.sent).toString()),
          ],
        ),
        Container(
          padding: EdgeInsets.all(mq.width * 0.02),
          decoration: BoxDecoration(
              color: Colors.lightGreenAccent,
              border: Border.all(),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(mq.width * 0.03),
                  topRight: Radius.circular(mq.width * 0.03),
                  bottomLeft: Radius.circular(mq.width * 0.03))),
          child: Text(
            widget.message.msg,
            style: const TextStyle(fontSize: 17),
          ),
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
        Container(
          padding: EdgeInsets.all(mq.width * 0.02),
          decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              border: Border.all(),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(mq.width * 0.03),
                  topRight: Radius.circular(mq.width * 0.03),
                  bottomRight: Radius.circular(mq.width * 0.03))),
          child: Text(
            widget.message.msg,
            style: const TextStyle(fontSize: 17),
          ),
        ),
        // Text(MyDateUtil.getFormattedTime(
        //     context: context, time: widget.message.sent)),
      ],
    );
  }
}
