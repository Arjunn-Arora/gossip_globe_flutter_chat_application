import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/models/message_model.dart';
import 'package:gossip_globe/utilities/global_methods.dart';
import 'package:gossip_globe/widgets/display_message_type.dart';
import 'package:swipe_to/swipe_to.dart';

class ContactMessageWidget extends StatelessWidget {
  const ContactMessageWidget({super.key, required this.message, required this.onRightSwipe, required this.isGroupChat, this.viewOnly = false,});

  final MessageModel message;
  final Function() onRightSwipe;
  final bool isGroupChat;
  final bool viewOnly;

  @override
  Widget build(BuildContext context) {
    final time = formatDate(message.timeSent, [hh, ':', nn, ' ', am]);
    final isReplying = message.repliedTo.isNotEmpty;
    final senderName = message.senderName == 'You' ? message.senderName  : 'You';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SwipeTo(
      onRightSwipe: (details) {
        onRightSwipe();
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            minWidth: MediaQuery.of(context).size.width * 0.3,
          ),
          child: Row(
            children: [
              if(isGroupChat)
                Padding(padding: const EdgeInsets.only(right: 5),
                child: userImageWidget(imageUrl: message.senderImage, radius: 20, onTap: (){}),
                ),
              Flexible(
                child: Card(
                  elevation: 5,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    ),
                  ),
                  color: Theme.of(context).cardColor,
                  child: Stack(
                    children: [
                      Padding(
                        padding: message.messageType == MessageEnum.text ? const EdgeInsets.fromLTRB(10.0, 5.0, 20.0, 20.0) :
                      const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if(isReplying) ...[
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade500,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(senderName, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),),
                                      DisplayMessageType(message: message.repliedMessage, type: message.repliedMessageType, color: Colors.black, maxLines: 1, overFlow: TextOverflow.ellipsis, viewOnly: viewOnly,),
                                      //Text(message.repliedMessage, style: const TextStyle(color: Colors.black),),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            DisplayMessageType(message: message.message, type: message.messageType, color: isDarkMode ? Colors.white : Colors.black, maxLines: 1, overFlow: TextOverflow.ellipsis, viewOnly: viewOnly,),
                            //Text(message.message, style: const TextStyle(color: Colors.black),),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 4, right: 10, child: Text(time, style: TextStyle(color:isDarkMode ? Colors.white60 : Colors.grey.shade500, fontSize: 10.0),),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}