import 'package:date_format/date_format.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gossip_globe/models/message_model.dart';
import 'package:gossip_globe/models/message_reply_model.dart';
import 'package:gossip_globe/providers/authentication_provider.dart';
import 'package:gossip_globe/providers/chat_provider.dart';
import 'package:gossip_globe/providers/group_provider.dart';
import 'package:gossip_globe/utilities/global_methods.dart';
import 'package:gossip_globe/widgets/contact_message_widget.dart';
import 'package:gossip_globe/widgets/my_message_widget.dart';
import 'package:gossip_globe/widgets/reactions_dialog.dart';
import 'package:gossip_globe/widgets/stacked_reactions.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key, required this.contactUID, required this.groupId});

  final String contactUID;
  final String groupId;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {

  final ScrollController _scorerController = ScrollController();

@override
void dispose() {
  _scorerController.dispose();
  super.dispose();
}

showReactionsDialog({required MessageModel message, required bool isMe}){
  showDialog(context: context, builder: (context) => ReactionsDialog(
    isMyMessage: isMe,
    message: message,
    onReactionsTap: (reactions){
      if(reactions == '➕'){
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pop(context);
          showEmojiContainer(messageId: message.messageId);
        });
            
        } else{
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context);
            sendReactionToMessage(reaction: reactions, messageId: message.messageId);
          });
          
          
        }
    },
    onContextMenuTap: (item){
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
        onContextMenyClicked(item: item, message: message);
      });
      
    },
  ),);
}

void sendReactionToMessage(
      {required String reaction, required String messageId}) {
    // get the sender uid
    final senderUID = context.read<AuthenticationProvider>().userModel!.uid;

    context.read<ChatProvider>().sendReactionToMessage(
          senderUID: senderUID,
          contactUID: widget.contactUID,
          messageId: messageId,
          reaction: reaction,
          groupId: widget.groupId.isNotEmpty,
        );
  }

void onContextMenyClicked(
      {required String item, required MessageModel message}) {
    switch (item) {
      case 'Reply':
        // set the message reply to true
        final messageReply = MessageReplyModel(
          message: message.message,
          senderUID: message.senderUID,
          senderName: message.senderName,
          senderImage: message.senderImage,
          messageType: message.messageType,
          isMe: true,
        );

        context.read<ChatProvider>().setMessageReplyModel(messageReply);
        break;
      case 'Copy':
        // copy message to clipboard
        Clipboard.setData(ClipboardData(text: message.message));
        showSnackBar('Message copied to clipboard', context);
        break;
       case 'Delete':
        final currentUserId =
            context.read<AuthenticationProvider>().userModel!.uid;
        final groupProvider = context.read<GroupProvider>();

        if (widget.groupId.isNotEmpty) {
          if (groupProvider.isSenderOrAdmin(
              message: message, uid: currentUserId)) {
            showDeleteBottomSheet(
              message: message,
              currentUserId: currentUserId,
              isSenderOrAdmin: true,
            );
            return;
          } else {
            showDeleteBottomSheet(
              message: message,
              currentUserId: currentUserId,
              isSenderOrAdmin: false,
            );
            return;
          }
        }
        showDeleteBottomSheet(
          message: message,
          currentUserId: currentUserId,
          isSenderOrAdmin: true,
        );
         break;
    }
  }

  void showDeleteBottomSheet({
    required MessageModel message,
    required String currentUserId,
    required bool isSenderOrAdmin,
  }) {
    showModalBottomSheet(
        context: context,
        isDismissible: false,
        builder: (context) {
          return Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
            return SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 20.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (chatProvider.isLoading) const LinearProgressIndicator(),
                    ListTile(
                      leading: const Icon(Icons.delete),
                      title: const Text('Delete for me'),
                      onTap: chatProvider.isLoading
                          ? null
                          : () async {
                              await chatProvider
                                  .deleteMessage(
                                currentUserId: currentUserId,
                                contactUID: widget.contactUID,
                                messageId: message.messageId,
                                messageType: message.messageType.name,
                                isGroupChat: widget.groupId.isNotEmpty,
                                deleteForEveryone: false,
                              )
                                  .whenComplete(() {
                                Navigator.pop(context);
                              });
                            },
                    ),
                    isSenderOrAdmin
                        ? ListTile(
                            leading: const Icon(Icons.delete_forever),
                            title: const Text('Delete for everyone'),
                            onTap: chatProvider.isLoading
                                ? null
                                : () async {
                                    await chatProvider
                                        .deleteMessage(
                                      currentUserId: currentUserId,
                                      contactUID: widget.contactUID,
                                      messageId: message.messageId,
                                      messageType: message.messageType.name,
                                      isGroupChat: widget.groupId.isNotEmpty,
                                      deleteForEveryone: true,
                                    )
                                        .whenComplete(() {
                                      Navigator.pop(context);
                                    });
                                  },
                          )
                        : const SizedBox.shrink(),
                    ListTile(
                      leading: const Icon(Icons.cancel),
                      title: const Text('cancel'),
                      onTap: chatProvider.isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  void showEmojiContainer({required String messageId}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 300,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            Navigator.pop(context);
            // add emoji to message
            sendReactionToMessage(
              reaction: emoji.emoji,
              messageId: messageId,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return StreamBuilder<List<MessageModel>>(stream: context.read<ChatProvider>().getMessagesStream(userId: uid, contactUID: widget.contactUID, isGroup: widget.groupId,),
               builder: (context, snapshot){
                if(snapshot.hasError){
                  return const Center(child: Text('Something went wrong'),);
                }
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator(),);
                }
                if(snapshot.data!.isEmpty){
                  return Center(child: Text('Start a conversation', textAlign: TextAlign.center, style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),),);
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scorerController.animateTo(
                    _scorerController.position.minScrollExtent,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  );
                });
                if(snapshot.hasData){
                  final messagesList = snapshot.data!;
                  return GroupedListView<dynamic, DateTime>(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    reverse: true,
                    controller: _scorerController,
                    elements: messagesList,
                    groupBy: (element){
                      return DateTime(element.timeSent.year, element.timeSent.month, element.timeSent.day);
                    },
                    groupHeaderBuilder: (dynamic groupedByValue) =>
                      SizedBox(height: 40, child: buildDateTime(groupedByValue)),
                    itemBuilder: (context, dynamic element){

                      final padding1 = element.reactions.isEmpty ? 8.0 : 20.0;
                      final padding2 = element.reactions.isEmpty ? 8.0 : 25.0;
    
                      // if(!element.isSeen && element.senderUID != uid){
                      //   context.read<ChatProvider>().setMessageAsSeen(groupId: widget.groupId, 
                      //   messageId: element.messageId, 
                      //   contactUID: widget.contactUID, 
                      //   userId: uid);
                      // }

                      final message = element as MessageModel;

                      if(widget.groupId.isNotEmpty){
                        context.read<ChatProvider>().setMessageStatus(
                          currentUserId: uid,
                         contactUID: widget.contactUID,
                          messageId: message.messageId,
                           isSeenByList: message.isSeenBy,
                            isGroupChat: widget.groupId.isNotEmpty,
                            );
                      } else{
                        if(message.isSeen && message.senderUID != uid){
                          context.read<ChatProvider>().setMessageStatus(
                            currentUserId: uid,
                            contactUID: widget.contactUID,
                            messageId: message.messageId,
                            isSeenByList: message.isSeenBy,
                            isGroupChat: widget.groupId.isNotEmpty,  
                          );
                        };
                      }
    
    
                      final isMe = element.senderUID == uid;
                      bool deletedByCurrentUser = message.deletedBy.contains(uid);
              return deletedByCurrentUser
                  ? const SizedBox.shrink()
                  : isMe ? Stack(
                        children: [
                          InkWell(
                          onLongPress: (){
                            showReactionsDialog(message: element, isMe: isMe);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 8.0, bottom: isMe ? padding1 : padding2),
                            child: MyMessageWidget(message: element, onRightSwipe: (){
                              final messageReply = MessageReplyModel(message: element.message, 
                              senderUID: element.senderUID, 
                              senderName: element.senderName, 
                              senderImage: element.senderImage,
                               messageType: element.messageType, 
                               isMe: isMe);
                               context.read<ChatProvider>().setMessageReplyModel(messageReply);
                            },
                            //isViewOnly: false,
                            //isMe: isMe,
                            isGroupChat: widget.groupId.isNotEmpty,
                            ),
                          ),
                        ),
                        Positioned(bottom: isMe ? 4 : 0, right: isMe ? 90 : 250, child: StackedReactionsWidget(message: element, size: 20, onTap: (){})),
                        ], 
                      ) 
                      : 
                      Stack(
                        children: [
                          InkWell(
                          onLongPress: (){
                            showReactionsDialog(message: element, isMe: isMe);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 8.0, bottom: isMe ? padding1 : padding2),
                            child: ContactMessageWidget(message: element, onRightSwipe: (){
                              final messageReply = MessageReplyModel(message: element.message, 
                              senderUID: element.senderUID, 
                              senderName: element.senderName, 
                              senderImage: element.senderImage,
                               messageType: element.messageType, 
                               isMe: isMe);
                               context.read<ChatProvider>().setMessageReplyModel(messageReply);
                            },
                            //isViewOnly: false,
                            //isMe: isMe,
                            isGroupChat: widget.groupId.isNotEmpty,
                            ),
                          ),
                        ),
                        ], 
                      );
                    },
                    useStickyGroupSeparators: true, // optional
                    itemComparator: (item1, item2){var firstItem = item1.timeSent;
                     var secondItem = item2.timeSent; 
                     return secondItem!.compareTo(firstItem!);}, // optional
                     groupComparator: (value1, value2) => value2.compareTo(value1),
                    floatingHeader: true, // optional
                    order: GroupedListOrder.ASC, // optional
                    //footer: Text("Widget at the bottom of list"), // optional
                  );
                }
                return const SizedBox.shrink();
               });
  }

  Center buildDateTime(groupedByValue) {
    return Center(
                      child: Card(
                        elevation: 2,
                        child: Padding(padding: const EdgeInsets.all(8.0),
                        child: Text(formatDate(groupedByValue.timeSent, [M, ' ', d]),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                          fontWeight: FontWeight.bold,
                        ),),),
                      ),
                    );
  }
}