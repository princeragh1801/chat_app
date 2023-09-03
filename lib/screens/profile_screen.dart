import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/user_chat_model.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});
  final ChatUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? profileImg;
  int? selectRadio;

  setRadioVal(int val) {
    setState(() {
      selectRadio = val;
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    selectRadio = 1;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.user.name),
          ),
          body: Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
                width: mq.width,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: mq.height * 0.02,
                      ),
                      Stack(
                        children: [
                          profileImg != null
                              ?
                              // local image
                              ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(mq.height * .1),
                                  child: Image.file(
                                    File(profileImg!),
                                    width: mq.height * .2,
                                    height: mq.height * .2,
                                    fit: BoxFit.cover,
                                  ))
                              :
                              // image store from the server
                              ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(mq.height * .1),
                                  child: CachedNetworkImage(
                                    height: mq.height * .2,
                                    width: mq.height * .2,
                                    fit: BoxFit.cover,
                                    imageUrl: widget.user.image,
                                    placeholder: (context, url) => Icon(
                                      CupertinoIcons.person,
                                      size: mq.height * 0.05,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                      CupertinoIcons.person,
                                    ),
                                  ),
                                ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: MaterialButton(
                                onPressed: _showBottomSheet,
                                color: Colors.white,
                                shape: const CircleBorder(),
                                child: const Icon(Icons.edit),
                              ))
                        ],
                      ),
                      SizedBox(
                        height: mq.height * 0.01,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget.user.email),
                      ),
                      SizedBox(
                        height: mq.height * 0.02,
                      ),
                      SizedBox(
                        width: mq.width * 0.8,
                        child: TextFormField(
                          initialValue: widget.user.name,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              return null;
                            }
                            return 'Required field';
                          },
                          onSaved: (newValue) => APIs.me.name = newValue!,
                          decoration: const InputDecoration(
                              hintText: 'eg Prince Raghuwanshi',
                              label: Text('Name'),
                              prefixIcon: Icon(CupertinoIcons.person),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide:
                                      BorderSide(style: BorderStyle.solid))),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: mq.width * 0.8,
                        child: TextFormField(
                          initialValue: widget.user.about,
                          onSaved: (newValue) {
                            APIs.me.about = newValue!;
                          },
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              return null;
                            }
                            return 'Required field';
                          },
                          decoration: const InputDecoration(
                              hintText: "Hey I'm using We Chat",
                              label: Text('About'),
                              prefixIcon: Icon(Icons.info_outline),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide:
                                      BorderSide(style: BorderStyle.solid))),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // update button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _formKey.currentState!.save();
                              APIs.updateUserInfo().then((value) {
                                Dialogs.showSnackBar(context,
                                    'Information Updated successfully!');
                              });
                            });
                          }
                        },
                        icon: const Icon(Icons.change_circle_rounded),
                        label: const Text('UPDATE'),
                      ),
                      // TextButton.icon(onPressed: (){}, icon: const Icon(Icons.settings_display), label: const Text('Theme'))
                    ],
                  ),
                ),
              )),

          // logout button
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  // backgroundColor: Colors.lightBlueAccent
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              icon: const Icon(Icons.logout),
              label: const Text('LOGOUT'),
            ),
          )),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return SizedBox(
            height: mq.height * 0.3,
            child: ListView(
              padding: EdgeInsets.only(
                  top: mq.height * .03, bottom: mq.height * .05),
              children: [
                const Text(
                  'Pick your profile picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: mq.height * .02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          setState(() {
                            profileImg = image.path;
                          });
                          APIs.updateProfilePicture(File(profileImg!));
                          log('Image path : ${image.path} -- MineType : ${image.mimeType}');
                          // ignore: use_build_context_synchronously
                          Navigator.of(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        fixedSize: Size(mq.width * .3, mq.height * .15),
                        shape: const CircleBorder(),
                      ),
                      child: const Image(
                          image: AssetImage('assets/images/gallery.png')),
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          // Pick an image.
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera, imageQuality: 80);
                          if (image != null) {
                            setState(() {
                              profileImg = image.path;
                            });
                            APIs.updateProfilePicture(File(profileImg!));
                            log('Image path : ${image.path} -- MineType : ${image.mimeType}');
                            // ignore: use_build_context_synchronously
                            Navigator.of(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          fixedSize: Size(mq.width * .3, mq.height * .15),
                          shape: const CircleBorder(),
                        ),
                        child: const Image(
                            image: AssetImage('assets/images/camera.png')))
                  ],
                )
              ],
            ),
          );
        });
  }

  Widget iconButton() {
    return IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Select theme'),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                actions: [
                  RadioListTile(
                    title: const Text('Default (system)'),
                    value: 1,
                    groupValue: selectRadio,
                    onChanged: (val) {
                      ThemeMode.system;
                      setRadioVal(val!);
                    },
                  ),
                  RadioListTile(
                    title: const Text('Dark'),
                    value: 2,
                    groupValue: selectRadio,
                    onChanged: (val) {
                      ThemeMode.dark;
                      setRadioVal(val!);
                    },
                  ),
                  RadioListTile(
                    title: const Text('Light'),
                    value: 3,
                    groupValue: selectRadio,
                    onChanged: (val) {
                      ThemeMode.light;
                      setRadioVal(val!);
                    },
                  ),
                ],
              );
            },
          );
        },
        icon: const Icon(Icons.light_mode));
  }
}
