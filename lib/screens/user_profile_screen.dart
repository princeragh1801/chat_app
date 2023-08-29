import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/user_chat_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ViewUserProfile extends StatelessWidget {
  const ViewUserProfile({super.key, required this.user});
  final ChatUser user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      height: mq.height * .2,
                      width: mq.height * .2,
                      fit: BoxFit.cover,
                      imageUrl: user.image,
                      placeholder: (context, url) => Icon(
                        CupertinoIcons.person,
                        size: mq.height * 0.05,
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        CupertinoIcons.person,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(user.email),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'About : ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(user.about),
                    ],
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Joined on : 22 Nov 2017',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Text(MyDateUtil.),
                ],
              )
            ]),
      ),
    );
  }
}
