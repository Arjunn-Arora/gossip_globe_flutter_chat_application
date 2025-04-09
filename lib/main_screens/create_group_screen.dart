import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/models/group_model.dart';
import 'package:gossip_globe/providers/authentication_provider.dart';
import 'package:gossip_globe/providers/group_provider.dart';
import 'package:gossip_globe/utilities/global_methods.dart';
import 'package:gossip_globe/widgets/app_bar_back_button.dart';
import 'package:gossip_globe/widgets/display_user_image.dart';
import 'package:gossip_globe/widgets/friends_list.dart';
import 'package:gossip_globe/widgets/group_type_list_tile.dart';
import 'package:gossip_globe/widgets/settings_list_tile.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {

  File? finalfileImage;
  String userImage = '';
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();

  void selectImage(bool fromCamera) async {
    finalfileImage = await pickImage(
      fromCamera: fromCamera,
      onFail: (String message) {
        showSnackBar(message, context);
      },
    );
    //crop the image
    await cropImage(finalfileImage?.path);
    popContext();
  }

  popContext() {
    Navigator.pop(context);
  }

  Future<void> cropImage(filePath) async {
    if (filePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );

      if (croppedFile != null) {
        setState(() {
          finalfileImage = File(croppedFile.path);
        });
      }
    }
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                selectImage(true);
              },
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
            ),
            ListTile(
              onTap: () {
                selectImage(false);
              },
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  void diispose() {
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  GroupType groupValue = GroupType.private;

  void createGroup() {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final groupProvider = context.read<GroupProvider>();

    if (_groupNameController.text.isEmpty) {
      showSnackBar('Group name is required', context);
      return;
    }

    if (_groupNameController.text.length < 3) {
      showSnackBar('Group name must be at least 3 characters long', context);
      return;
    }

    if (_groupDescriptionController.text.isEmpty) {
      showSnackBar('Group description is required', context);
      return;
    }

    GroupModel groupModel = GroupModel(
      creatorUID: uid,
      groupName: _groupNameController.text,
      groupDescription: _groupDescriptionController.text,
      groupImage: '',
      lastMessage: '',
      senderUID: '',
      messageType: MessageEnum.text,
      messageId: '',
      timeSent: DateTime.now(),
      groupId: '',
      createdAt: DateTime.now(),
      isPrivate: groupValue == GroupType.private ? true : false,
      editSettings: true,
      approveMembers: false,
      lockMessages: false,
      requestToJoing: false,
      membersUIDs: [],
      adminsUIDs: [],
      awaitingApprovalUIDs: [],
    );

    groupProvider.createGroup(
        newGroupModel: groupModel,
        fileImage: finalfileImage,
        onSuccess: () {
          showSnackBar('Group created successfully', context);
          Navigator.pop(context);
        },
        onFail: (error) {
          showSnackBar(error, context);
        });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create Group'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              child: context.watch<GroupProvider>().isSloading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : IconButton(
                      onPressed: () {
                        createGroup();
                      },
                      icon: const Icon(Icons.check),
                    ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DisplayUserImage(
                    finalfileImage: finalfileImage,
                    radius: 60,
                    onPressed: showBottomSheet),
                const SizedBox(width: 10),
                buildGroupType()
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _groupNameController,
              maxLength: 25,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Group Name',
                label: Text('Group Name'),
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _groupDescriptionController,
              maxLength: 100,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Group Description',
                label: Text('Group Description'),
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: SettingsListTile(
                    title: 'Group Settings',
                    onTap: () {
                      Navigator.pushNamed(
                          context, Constants.groupSettingsScreen);
                    },
                    icon: Icons.settings,
                    iconContainerColor: Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Selected Group Members:',
              style: GoogleFonts.openSans(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CupertinoSearchTextField(
              placeholder: 'Search',
              onChanged: (value) {
                // Perform search operation here
              },
            ),
            const SizedBox(height: 10),
            const Expanded(
                child: FriendsList(viewType: FriendViewType.groupView)),
          ],
        ),
      ),
    );
  }

  Column buildGroupType() {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: GroupTypeListTile(
            title: GroupType.private.name,
            value: GroupType.private,
            groupValue: groupValue,
            onChanged: (value) {
              setState(() {
                groupValue = value!;
              });
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: GroupTypeListTile(
            title: GroupType.public.name,
            value: GroupType.public,
            groupValue: groupValue,
            onChanged: (value) {
              setState(() {
                groupValue = value!;
              });
            },
          ),
        ),
      ],
    );

  }
}