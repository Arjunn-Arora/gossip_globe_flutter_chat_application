import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/models/message_model.dart';
import 'package:gossip_globe/models/message_reply_model.dart';
import 'package:gossip_globe/providers/chat_provider.dart';
import 'package:gossip_globe/utilities/global_methods.dart';
import 'package:gossip_globe/widgets/display_message_type.dart';
import 'package:provider/provider.dart';

class MessageReplyPreview extends StatelessWidget {
  const MessageReplyPreview({super.key, this.replyMessageModel, this.message, this.viewOnly = false});

  final MessageReplyModel? replyMessageModel;
  final MessageModel? message;
  final bool viewOnly;

  @override
  Widget build(BuildContext context) {
      final type = replyMessageModel != null ? replyMessageModel!.messageType : message!.messageType;
      final chatProvider = context.read<ChatProvider>();
    return IntrinsicHeight(
      child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.1),
          ),
          child: Row(
            children: [
              Container(
                width: 5,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              buildNameAndMessage(type),
             replyMessageModel != null ? const Spacer() : const SizedBox(),
              replyMessageModel != null ?
              closeButton(chatProvider, context) : const SizedBox(),
            ],
          ),
        ),
    );
  }

  InkWell closeButton(ChatProvider chatProvider, BuildContext context) {
    return InkWell(
              onTap: (){
                chatProvider.setMessageReplyModel(null);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.1), width: 1),
                ),
                padding: const EdgeInsets.all(2.0),
                child: const Icon(Icons.close)
                ),
            );
  }

  Column buildNameAndMessage(MessageEnum type) {
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getTitle(),
                const SizedBox(height: 5),
                replyMessageModel != null ? messageToShow(type: type, message: replyMessageModel!.message) :
                DisplayMessageType(message: message!.repliedMessage, type: message!.repliedMessageType, color: Colors.white, maxLines: 1, overFlow: TextOverflow.ellipsis, viewOnly: viewOnly,),
              ],
            );
  }

  Widget getTitle(){
    if(replyMessageModel != null){
      bool isMe = replyMessageModel!.isMe;
      return Text(
            isMe ? 'You' : replyMessageModel!.senderName,
            style:
                GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue),
          );
    } else{
      return Text(message!.repliedTo, style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue),);
    }
  }

}
