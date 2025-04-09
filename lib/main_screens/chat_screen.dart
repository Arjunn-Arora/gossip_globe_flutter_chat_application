import 'package:flutter/material.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/widgets/bottom_chat_field.dart';
import 'package:gossip_globe/widgets/chat_app_bar.dart';
import 'package:gossip_globe/widgets/chat_list.dart';
import 'package:gossip_globe/widgets/group_chat_app_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final contactUID = arguments[Constants.contactUID];
    final contactName = arguments[Constants.contactName];
    final contactImage = arguments[Constants.contactImage];
    final groupId = arguments[Constants.groupId];
    final isGroupChat = groupId.isNotEmpty ? true : false;

    return Scaffold(
      appBar: AppBar(
        title: isGroupChat
            ? GroupChatAppBar(groupUID: groupId)
            : ChatAppBar(
                contactUID: contactUID,
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ChatList(contactUID: contactUID, groupId: groupId), 
              ),
            BottomChatField(contactUID: contactUID, groupID: groupId, contactName: contactName, contactImage: contactImage,),
          ],
        ),
      ),
    );
  }
}