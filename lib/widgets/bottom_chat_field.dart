import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/providers/authentication_provider.dart';
import 'package:gossip_globe/providers/chat_provider.dart';
import 'package:gossip_globe/providers/group_provider.dart';
import 'package:gossip_globe/utilities/global_methods.dart';
import 'package:gossip_globe/widgets/message_reply_preview.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField(
      {super.key,
      required this.contactUID,
      required this.groupID,
      required this.contactName,
      required this.contactImage});

  final String contactUID;
  final String groupID;
  final String contactName;
  final String contactImage;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  FlutterSoundRecord? _soundRecord;
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  File? finalFileImage;
  String filePath = '';

  bool isSendingAudio = false;
  bool isRecording = false;
  bool isShowSendButton = false;
  bool isShowEmojiPicker = false;

  

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _soundRecord = FlutterSoundRecord();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _soundRecord?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiPicker = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiPicker = true;
    });
  }

  void showKeyboard() {
    setState(() {
      _focusNode.requestFocus();
    });
  }
  void hideKeyboard() {
    setState(() {
      _focusNode.unfocus();
    });
  }

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiPicker) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  void selectImage(bool fromCamera) async {
    finalFileImage = await pickImage(
      fromCamera: fromCamera,
      onFail: (String message) {
        showSnackBar(message, context);
      },
    );

    // crop image
    await cropImage(finalFileImage?.path);

    popContext();
  }

  Future<bool> checkMicrophonePermission() async {
    bool hasPermission = await Permission.microphone.isGranted;
    final status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      hasPermission = true;
    } else {
      hasPermission = false;
    }
    return hasPermission;
  }

  void startRecording() async {
    final hasPermission = await checkMicrophonePermission();
    if (hasPermission) {
      var tempDir = await getTemporaryDirectory();
      filePath = '${tempDir.path}/flutter_sound.aac';
      await _soundRecord?.start(
        path: filePath,
      );
      setState(() {
        isRecording = true;
      });
    }
  }

  void stopRecording() async {
    await _soundRecord?.stop();
    setState(() {
      isRecording = false;
      isSendingAudio = true;
    });
    sendFileMessage(messageType: MessageEnum.audio);
  }

  //select a video file from device
  // void selectVideo() async {
  //   File? fileVideo = await pickVideo(
  //     onFail: (String message) {
  //       showSnackBar(message, context);
  //     },
  //   );

  //   popContext();

  //   if (fileVideo != null) {
  //     filePath = fileVideo.path;
  //     // send video message to firestore
  //     sendFileMessage(
  //       messageType: MessageEnum.video,
  //     );
  //   }
  // }

  popContext() {
    Navigator.pop(context);
  }

  Future<void> cropImage(croppedFilePath) async {
    if (croppedFilePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: croppedFilePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );

      if (croppedFile != null) {
        filePath = croppedFile.path;
        // send image message to firestore
        sendFileMessage(
          messageType: MessageEnum.image,
        );
      }
    }
  }

  void sendFileMessage({
    required MessageEnum messageType,
  }) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    final chatProvider = context.read<ChatProvider>();

    chatProvider.sendFileMessage(
      sender: currentUser,
      contactUID: widget.contactUID,
      contactName: widget.contactName,
      contactImage: widget.contactImage,
      file: File(filePath),
      messageType: messageType,
      groupId: widget.groupID,
      onSucess: () {
        _textEditingController.clear();
        _focusNode.unfocus();
        setState(() {
          isSendingAudio = false;
        });
      },
      onError: (error) {
        setState(() {
          isSendingAudio = false;
        });
        showSnackBar(error, context);
      },
    );
  }

  void sendTextMessage() {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendTextMessage(
        sender: currentUser,
        contactUID: widget.contactUID,
        contactName: widget.contactName,
        contactImage: widget.contactImage,
        message: _textEditingController.text,
        messageType: MessageEnum.text,
        groupId: widget.groupID,
        onSucess: () {
          _textEditingController.clear();
          _focusNode.unfocus();
        },
        onError: (error) {
          showSnackBar(error, context);
        });
  }

  @override
  Widget build(BuildContext context) {
    return widget.groupID.isNotEmpty
        ? buildLoackedMessages()
        : buildBottomChatField();
  }

  buildisMember(bool isLocked) {
    return isLocked
        ? const SizedBox(
            height: 50,
            child: Center(
              child: Text(
                'Messages are locked, only admins can send messages',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        : buildBottomChatField();
  }

  Widget buildLoackedMessages() {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    final groupProvider = context.read<GroupProvider>();
    // check if is admin
    final isAdmin = groupProvider.groupModel.adminsUIDs.contains(uid);

    // chec if is member
    final isMember = groupProvider.groupModel.membersUIDs.contains(uid);

    // check is messages are locked
    final isLocked = groupProvider.groupModel.lockMessages;
    return isAdmin
        ? buildBottomChatField()
        : isMember
            ? buildisMember(isLocked)
            : SizedBox(
                height: 60,
                child: Center(
                  child: TextButton(
                    onPressed: () async {
                      // send request to join group
                      await groupProvider
                          .sendRequestToJoinGroup(
                        groupId: groupProvider.groupModel.groupId,
                        uid: uid,
                        groupName: groupProvider.groupModel.groupName,
                        groupImage: groupProvider.groupModel.groupImage,
                      )
                          .whenComplete(() {
                        showSnackBar('Request sent', context);
                      });
                      print('request to join group');
                    },
                    child: const Text(
                      'You are not a member of this group, \n click here to send request to join',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
  }

  Consumer<ChatProvider> buildBottomChatField() {
    return Consumer<ChatProvider>(
    builder: (context, chatProvider, child) {
      final messageReply = chatProvider.messageReplyModel;
      final isMessageReply = messageReply != null;
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Theme.of(context).cardColor,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                isMessageReply
                    ? MessageReplyPreview(replyMessageModel: messageReply,)
                    : const SizedBox.shrink(),
                Row(
                  children: [
                    IconButton(onPressed: toggleEmojiKeyboardContainer, icon: Icon(isShowEmojiPicker ? Icons.keyboard_alt : Icons.emoji_emotions_outlined),),
                    IconButton(
                      onPressed: isSendingAudio
                          ? null
                          : () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return SizedBox(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: const Icon(Icons.camera),
                                              title: const Text('Camera'),
                                              onTap: () {
                                                selectImage(true);
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.image),
                                              title: const Text('Gallery'),
                                              onTap: () {
                                                selectImage(false);
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                  Icons.video_camera_back),
                                              title: const Text('Video'),
                                              onTap: () {
                                                //selectVideo();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                      icon: const Icon(Icons.attachment),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _textEditingController,
                        focusNode: _focusNode,
                        decoration: const InputDecoration.collapsed(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Type a message',
                        ),
                        onChanged: (value) {
                          setState(() {
                            isShowSendButton = value.isNotEmpty;
                          });
                        },
                        onTap: (){hideEmojiContainer();},
                      ),
                    ),
                    GestureDetector(
                      onTap: isShowSendButton ? sendTextMessage : null,
                      onLongPress: isShowSendButton ? null : startRecording,
                      onLongPressUp: stopRecording,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.deepPurple,
                        ),
                        margin: const EdgeInsets.all(5),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: isShowSendButton
                              ? const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                )
                              : const Icon(Icons.mic, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          isShowEmojiPicker
              ? SizedBox(
                  height: 280,
                  child: EmojiPicker(
                    onEmojiSelected: (category, Emoji emoji) {
                      _textEditingController.text =
                          _textEditingController.text + emoji.emoji;
                          if(!isShowSendButton){
                            setState(() {
                              isShowSendButton = true;
                            });
                          }
                    },
                    onBackspacePressed: () {
                      _textEditingController.text = _textEditingController
                          .text.characters
                          .skipLast(1)
                          .toString();
                    },
                    // config: const Config(
                    //   columns: 7,
                    //   emojiSizeMax: 32.0,
                    //   verticalSpacing: 0,
                    //   horizontalSpacing: 0,
                    //   initCategory: Category.RECENT,
                    //   bgColor: Color(0xFFF2F2F2),
                    //   indicatorColor: Colors.blue,
                    //   iconColor: Colors.grey,
                    //   iconColorSelected: Colors.blue,
                    //   progressIndicatorColor: Colors.blue,
                    //   backspaceColor: Colors.blue,
                    //   showRecentsTab: true,
                    //   recentsLimit: 28,
                    //   noRecentsText: 'No Recents',
                    //   noRecentsStyle: const TextStyle(fontSize: 20, color: Colors.black26),
                    //   tabIndicatorAnimDuration: kTabScrollDuration,
                    //   categoryIcons: const CategoryIcons(),
                    //   buttonMode: ButtonMode.MATERIAL,
                    // ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      );
    },
  );
  }
}
