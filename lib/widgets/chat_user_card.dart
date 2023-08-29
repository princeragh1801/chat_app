import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/models/user_chat_model.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/user_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.user});
  final ChatUser user;
  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  // last msg info message == null no message
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
        // color: Colors.blueGrey.shade100,
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          // navigating to chat screen
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatScreen(
                    user: widget.user,
                  ))),
          child: StreamBuilder(
            stream: APIs.getLastMessageDetail(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];

                return ListTile(
                  // profile photo
                  leading: InkWell(
                    onTap: () => showDialog(context: context, builder:(context) => _viewProfile(),),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .03),
                      child: CachedNetworkImage(
                        height: mq.height * .055,
                        width: mq.height * .055,
                        fit: BoxFit.cover,
                        imageUrl: widget.user.image,
                        
                        errorWidget: (context, url, error) => const Icon(
                          CupertinoIcons.person,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    widget.user.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  // this is fine
                  subtitle: _message != null
                      ? _message!.type == Type.text
                          ? _message!.fromId != widget.user.id
                              ? Text(
                                  'You : ${_message!.msg}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                )
                              : Text(
                                  _message!.msg,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                )
                          : _message!.fromId != widget.user.id
                              ? _imageMsgSend()
                              : _imageMsgRecieve()
                      : Text(
                          widget.user.about,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),

                  trailing: _message == null
                      ? null
                      : // show nothing
                      _message!.read.isEmpty &&
                              _message!.fromId != APIs.user.uid
                          ?
                          //show for unread message
                          Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: Colors.greenAccent.shade400,
                                  borderRadius: BorderRadius.circular(10)),
                            )
                          : Text(
                              MyDateUtil.getFormattedTime(
                                  context: context,
                                  time: _message != null
                                      ? _message!.sent
                                      : DateTime.now()
                                          .millisecondsSinceEpoch.toString()
                                          ),
                              style: const TextStyle(color: Colors.black54),
                            ),
                );
              
            },
          ),
        ));
  }

  Widget _imageMsgRecieve() {
    return const Row(
      children: [
        Icon(Icons.image),
        SizedBox(
          width: 5,
        ),
        Text('Photo')
      ],
    );
  }

  Widget _imageMsgSend() {
    return const Row(
      children: [
        Text('You : '),
        Icon(Icons.image),
        SizedBox(
          width: 5,
        ),
        Text('Photo')
      ],
    );
  }
  Widget _viewProfile() {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.user.name,style: const TextStyle(fontSize: 20),),
          IconButton(
            onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => ViewUserProfile(user: widget.user),)),
            icon: const Icon(Icons.info_outline, color: Colors.blueAccent,),
            )
        ],
      ),
      // icon: Icon(Icons.info),
      content: Stack(
        alignment: Alignment.center,
        children:[ ClipRRect(
          borderRadius: BorderRadius.circular(mq.height * .1),
          child: CachedNetworkImage(
            height: mq.height * .2,
            width: mq.height * .2,
            fit: BoxFit.cover,
            imageUrl: widget.user.image,
            placeholder: (context, url) => Icon(
              CupertinoIcons.person,
              size: mq.height * 0.05,
            ),
            errorWidget: (context, url, error) => const Icon(
              CupertinoIcons.person,
            ),
          ),
        ),]
      ),
    );
  }
}
