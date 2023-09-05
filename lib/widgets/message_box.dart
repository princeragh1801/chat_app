import 'dart:developer';
import 'package:chat_app/helper/dialogs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';


class MessageBox extends StatefulWidget {
  const MessageBox({super.key, required this.message});
  final Message message;

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  String time = 'Not seen yet';
  final messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    if (widget.message.read.isNotEmpty) {
      time = MyDateUtil.getFormattedTime(
          context: context, time: widget.message.read);
    }

    return InkWell(
      onLongPress: () => _showBottomSheet(isMe),
      child: isMe ? _showGreenBox() : _showBlueBox(),
    );
  }

  Widget _showImageDialog() {
    return Expanded(
      child: AlertDialog(
        content: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: CachedNetworkImage(
            imageUrl: widget.message.msg,
            placeholder: (context, url) => const Padding(
                padding: EdgeInsets.all(3),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                )),
            errorWidget: (context, url, error) => const Icon(
              Icons.image,
              size: 70,
            ),
          ),
        ),
        actions: [
          TextButton.icon(
              onPressed: () {
                GallerySaver.saveImage(widget.message.msg);
                Dialogs.showSnackBar(context, 'Saved to gallery!');
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.save,
                color: Colors.greenAccent,
              ),
              label: const Text('Save to gallery'))
        ],
      ),
    );
  }

  Widget _showImage() {
    return InkWell(
      onTap: () async {
        return await showDialog(
            context: context, builder: (context) => _showImageDialog());
      },
      child: ClipRRect(
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
      ),
    );
  }

  Widget _showMessage() {
    return widget.message.type == Type.text
        ? Text(
            widget.message.msg,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          )
        : _showImage();
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
              color: widget.message.read.isNotEmpty ? Colors.blue : null,
            ),
            const SizedBox(
              width: 2,
            ),

            // sent time
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(
                fontSize: 13,
              ),
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
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  _showBottomSheet(bool isMe) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      // useSafeArea: true,
      builder: (context) {
        return ListView(
          children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                  vertical: mq.height * .015, horizontal: mq.width * .4),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),
            widget.message.type == Type.text
                ? OptionItem(
                    name: 'Copy',
                    icon: const Icon(
                      Icons.copy_all_outlined,
                      color: Colors.blue,
                      size: 26,
                    ),
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then((value) {
                        Navigator.pop(context);

                        Dialogs.showSnackBar(context, 'Text Copied!');
                      });
                    },
                  )
                : OptionItem(
                    icon: const Icon(Icons.download_rounded,
                        color: Colors.blue, size: 26),
                    name: 'Save Image',
                    onTap: () async {
                      try {
                        log('Image Url: ${widget.message.msg}');
                        await GallerySaver.saveImage(widget.message.msg,
                                albumName: 'We Chat')
                            .then((success) {
                          //for hiding bottom sheet
                          Navigator.pop(context);
                          if (success != null && success) {
                            Dialogs.showSnackBar(
                                context, 'Image Successfully Saved!');
                          }
                        });
                      } catch (e) {
                        log('ErrorWhileSavingImg: $e');
                      }
                    }),
            //separator or divider
            if (isMe)
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

            //edit option
            if (widget.message.type == Type.text && isMe)
              OptionItem(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                  name: 'Edit Message',
                  onTap: () {
                    //for hiding bottom sheet
                    Navigator.pop(context);

                    _showMessageUpdateDialog();
                  }),

            //delete option
            if (isMe)
              OptionItem(
                  icon: const Icon(Icons.delete_forever,
                      color: Colors.red, size: 26),
                  name: 'Delete Message',
                  onTap: () async {
                    await APIs.deleteMessage(widget.message).then((value) {
                      //for hiding bottom sheet
                      Navigator.pop(context);
                    });
                  }),

            //separator or divider
            Divider(
              color: Colors.black54,
              endIndent: mq.width * .04,
              indent: mq.width * .04,
            ),

            //sent time
            OptionItem(
                icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                name:
                    'Sent At: ${MyDateUtil.getFormattedTime(context: context, time: widget.message.sent)}',
                onTap: () {}),

            //read time
            OptionItem(
                icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                name: widget.message.read.isEmpty
                    ? 'Read At: Not seen yet'
                    : 'Read At: ${MyDateUtil.getFormattedTime(context: context, time: widget.message.read)}',
                onTap: () {}),
          ],
        );
      },
    );
  }

  //dialog for updating message content
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;
    // final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text(' Update Message')
                ],
              ),

              //content
              content: TextFormField(
                // controller: controller,
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                // onChanged: (value) => updatedMsg = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context, 'cancel');
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),

                //update button
                MaterialButton(
                    onPressed: () async{
                        await APIs.updateMessage(widget.message, updatedMsg);
                        // ignore: use_build_context_synchronously
                        Dialogs.showSnackBar(context, 'Message edited!');

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Update',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}

class OptionItem extends StatelessWidget {
  const OptionItem(
      {super.key, required this.name, required this.icon, required this.onTap});
  final String name;
  final VoidCallback onTap;
  final Icon icon;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        // color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}
