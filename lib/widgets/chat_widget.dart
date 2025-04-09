import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:gossip_globe/models/group_model.dart';
import 'package:gossip_globe/models/last_message_model.dart';
import 'package:gossip_globe/providers/authentication_provider.dart';
import 'package:gossip_globe/utilities/global_methods.dart';
import 'package:gossip_globe/widgets/unread_message_counter.dart';
import 'package:provider/provider.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({
    super.key,
    this.chat,
    required this.onTap,
    this.group,
    required this.isGroup,
  });

  final LastMessageModel? chat;
  final GroupModel? group;
  final bool isGroup;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthenticationProvider>().userModel!.uid;
    final lastMessage = chat != null ? chat!.message : group!.lastMessage;
    final senderUID = chat != null ? chat!.senderUID : group!.senderUID;
    final contactUID = chat != null ? chat!.contactUID : group!.groupId;
    final timesent = chat != null ? chat!.timeSent : group!.timeSent;
    final dateTime = formatDate(timesent, [hh, ':', mm, ' ', am]);
    final imageUrl = chat != null ? chat!.contactImage : group!.groupImage;
    final name = chat != null ? chat!.contactName : group!.groupName;
    final messageType = chat != null ? chat!.messageType : group!.messageType;

    return ListTile(
      leading: userImageWidget(imageUrl: imageUrl, radius: 40, onTap: () {}),
      contentPadding: EdgeInsets.zero,
      title: Text(name),
      subtitle: Row(
        children: [
          uid == senderUID
              ? const Text(
                  'You:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : const SizedBox(),
          const SizedBox(width: 5),
          messageToShow(type: messageType, message: lastMessage),
        ],
      ),
      trailing: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(dateTime),
            UnreadMessageCounter(
                contactUID: contactUID, uid: uid, isGroup: isGroup),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
