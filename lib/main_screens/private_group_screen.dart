import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/models/group_model.dart';
import 'package:gossip_globe/providers/authentication_provider.dart';
import 'package:gossip_globe/providers/group_provider.dart';
import 'package:gossip_globe/widgets/chat_widget.dart';
import 'package:provider/provider.dart';

class PrivateGroupScreen extends StatefulWidget {
  const PrivateGroupScreen({super.key});

  @override
  State<PrivateGroupScreen> createState() => _PrivateGroupScreenState();
}

class _PrivateGroupScreenState extends State<PrivateGroupScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return SafeArea(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoSearchTextField(
            onChanged: (value) {},
          ),
        ),
        StreamBuilder<List<GroupModel>>(
            stream: context
                .read<GroupProvider>()
                .getPrivateGroupsStream(userID: uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No groups found'),
                );
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final groupModel = snapshot.data![index];

                    return ChatWidget(
                        group: groupModel,
                        isGroup: true,
                        onTap: () {
                          context.read<GroupProvider>().setGroupModel(groupModel: groupModel).whenComplete((){
                            Navigator.pushNamed(context, Constants.chatScreen,
                              arguments: {
                                Constants.contactUID: groupModel.groupId,
                                Constants.contactName: groupModel.groupName,
                                Constants.contactImage: groupModel.groupImage,
                                Constants.groupId: groupModel.groupId,
                              });
                          });
                        });
                  },
                ),
              );
            })
      ],
    ));

  }
}