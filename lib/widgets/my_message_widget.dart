import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/models/message_model.dart';
import 'package:gossip_globe/providers/authentication_provider.dart';
import 'package:gossip_globe/widgets/display_message_type.dart';
import 'package:gossip_globe/widgets/message_reply_preview.dart';
import 'package:gossip_globe/widgets/stacked_reactions.dart';
import 'package:provider/provider.dart';
import 'package:swipe_to/swipe_to.dart';

class MyMessageWidget extends StatelessWidget {
  const MyMessageWidget({
    super.key,
    required this.message,
    required this.onRightSwipe,
    required this.isGroupChat,
    this.viewOnly = false,
  });

  final MessageModel message;
  final Function() onRightSwipe;
  final bool isGroupChat;
  final bool viewOnly;
  

  @override
  Widget build(BuildContext context) {

bool messageSeen() {
      final uid = context.read<AuthenticationProvider>().userModel!.uid;
      bool isSeen = false;
      if (isGroupChat) {
        List<String> isSeenByList = message.isSeenBy;
        if (isSeenByList.contains(uid)) {
          // remove our uid then check again
          isSeenByList.remove(uid);
        }
        isSeen = isSeenByList.isNotEmpty ? true : false;
      } else {
        isSeen = message.isSeen ? true : false;
      }

      return isSeen;
    }



    final isReplying = message.repliedTo.isNotEmpty;
    final time = formatDate(message.timeSent, [hh, ':', nn, ' ', am]);
    final padding = message.reactions.isNotEmpty ? const EdgeInsets.only(left: 20.0, bottom: 25.0) : EdgeInsets.only(bottom: 0.0);

    return SwipeTo(
      onRightSwipe: (details){
        onRightSwipe();
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          minWidth: MediaQuery.of(context).size.width * 0.3,
        ),
        child: Stack(
          children: [
            Padding(
              padding: padding,
              child: Card(
                elevation: 5,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0),
                  ),
                ),
                color: Colors.deepPurple,
                child: Padding(
                  padding: message.messageType == MessageEnum.text ? const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0) :
                  const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if(isReplying) ...[
                        //MessageReplyPreview(message: message, viewOnly: viewOnly,),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorDark.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(message.repliedTo, style: const TextStyle(color: Colors.white70,fontWeight: FontWeight.bold),),
                                DisplayMessageType(message: message.repliedMessage, type: message.repliedMessageType, color: Colors.white, maxLines: 1, overFlow: TextOverflow.ellipsis, viewOnly: viewOnly,),
                                //Text(message.repliedMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white,),),
                              ],
                            ),
                          ),
                        ),
                      ],
                      DisplayMessageType(message: message.message, type: message.messageType, color: Colors.white, maxLines: 1, overFlow: TextOverflow.ellipsis, viewOnly: viewOnly,),
                      //Text(message.message, style: const TextStyle(color: Colors.white),),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(time, style: const TextStyle(color: Colors.white60, fontSize: 10.0),),
                          const SizedBox(width: 5.0,),
                          Icon(messageSeen() ? Icons.done_all : Icons.done, color: messageSeen() ? Colors.blue : Colors.white60, size: 15,),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 90,
              child: StackedReactionsWidget(message: message, size: 20, onTap: (){}),
            )
          ],
        ),
        ),
        
      ),
    );
  }
}

// Positioned(
//                 bottom: 4, right: 10, child: Row(
//                   children: [
//                     Text(time, style: const TextStyle(color: Colors.white60, fontSize: 10.0),),
//                     const SizedBox(width: 5.0,),
//                      Icon(messageSeen() ? Icons.done_all : Icons.done, color: messageSeen() ? Colors.blue : Colors.white60, size: 15,),
//                   ],
//                 ),)