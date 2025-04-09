import 'package:flutter/material.dart';
import 'package:gossip_globe/providers/chat_provider.dart';
import 'package:provider/provider.dart';

class UnreadMessageCounter extends StatelessWidget {
  const UnreadMessageCounter(
      {super.key,
      required this.contactUID,
      required this.uid,
      required this.isGroup});

  final String uid;
  final String contactUID;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: context.read<ChatProvider>().getUnreadMessagesStream(
              userId: uid,
              contactUID: contactUID,
              isGroup: isGroup,
            ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const SizedBox();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }
          final unreadMessages = snapshot.data!;
          return unreadMessages > 0
              ? Container(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.red,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          spreadRadius: 1,
                          blurRadius: 6.0,
                          offset: Offset(0, 1),
                        ),
                      ]),
                  child: Text(unreadMessages.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                      )),
                )
              : const SizedBox();
        });
  }
}
