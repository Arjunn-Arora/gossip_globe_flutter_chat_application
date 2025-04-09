import 'package:flutter/material.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/models/user_model.dart';
import 'package:gossip_globe/providers/authentication_provider.dart';
import 'package:gossip_globe/providers/group_provider.dart';
import 'package:gossip_globe/utilities/global_methods.dart';
import 'package:gossip_globe/widgets/friend_widget.dart';
import 'package:gossip_globe/widgets/settings_list_tile.dart';
import 'package:gossip_globe/widgets/settings_switch_list_tile.dart';
import 'package:provider/provider.dart';

class GroupSettingsScreen extends StatefulWidget {
  const GroupSettingsScreen({super.key});

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {

String getGroupAdminsNames({required GroupProvider groupProvider, required String uid}) {
    if (groupProvider.groupMembersList.isEmpty) {
      return 'To asign Admin roles, Please add group members in the previous screen';
    } else {
      List<String> groupAdminsNames = [];

      // get the list of group admins
      List<UserModel> groupAdminsList = groupProvider.groupAdminsList;

      // get a list of names from the group admins list
      List<String> groupAdminsNamesList =
          groupAdminsList.map((groupAdmin) {return groupAdmin.uid == uid ? 'You' : groupAdmin.name;}).toList();

      // add these names to the groupAdminsNames list
      groupAdminsNames.addAll(groupAdminsNamesList);

      return groupAdminsNames.length == 2
          ? '${groupAdminsNames[0]} and ${groupAdminsNames[1]}'
          : groupAdminsNames.length > 2
              ? '${groupAdminsNames.sublist(0, groupAdminsNames.length - 1).join(', ')} and ${groupAdminsNames.last}'
              : 'You';
    }
  }

  Color getAdminsContainerColor({required GroupProvider groupProvider}) {
    if (groupProvider.groupMembersList.isEmpty) {
      return Theme.of(context).disabledColor;
    } else {
      return Theme.of(context).cardColor;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Group Settings'),
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SettingsSwitchListTile(
                    title: 'Edit Group Settings',
                    subtitle: 'Only group admins can edit group settings',
                    value: groupProvider.groupModel.editSettings,
                    onChanged: (value) {
                      groupProvider.setEditSettings(value: value);
                    },
                    icon: Icons.edit,
                    iconContainerColor: Colors.red),
                const SizedBox(height: 10),
                SettingsSwitchListTile(
                    title: 'Approve New Members',
                    subtitle:
                        'Only group admins can approve new members to join',
                    value: groupProvider.groupModel.approveMembers,
                    onChanged: (value) {
                      groupProvider.setApproveNewMembers(value: value);
                    },
                    icon: Icons.approval,
                    iconContainerColor: Colors.green),
                const SizedBox(height: 10),
                groupProvider.groupModel.approveMembers
                    ? SettingsSwitchListTile(
                        title: 'Request To Join',
                        subtitle:
                            'Only group admins can Approve incoming request to join the group',
                        value: groupProvider.groupModel.requestToJoing,
                        onChanged: (value) {
                          groupProvider.setRequestToJoin(value: value);
                        },
                        icon: Icons.request_page,
                        iconContainerColor: Colors.deepPurple)
                    : const SizedBox.shrink(),
                const SizedBox(height: 10),
                SettingsSwitchListTile(
                    title: 'Admins Send Message',
                    subtitle:
                        'Only group admins can send messages to the group',
                    value: groupProvider.groupModel.lockMessages,
                    onChanged: (value) {
                      groupProvider.setLockMessages(value: value);
                    },
                    icon: Icons.request_page,
                    iconContainerColor: Colors.blue),
                const SizedBox(height: 10),
                Card(
                  color: getAdminsContainerColor(groupProvider: groupProvider),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: SettingsListTile(
                        title: 'Group Admins',
                        subtitle:
                            getGroupAdminsNames(groupProvider: groupProvider, uid: uid),
                        onTap: () {
                          if (groupProvider.groupMembersList.isEmpty) {
                            showSnackBar('No Admins Found', context);
                            return;
                          }
                          showBottomSheet(
                              context: context,
                              builder: (context) {
                                return SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.9,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Select Group Admins',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'Done',
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: groupProvider
                                                .groupMembersList.length,
                                            itemBuilder: (context, index) {
                                              final friend = groupProvider
                                                  .groupMembersList[index];
                                              return FriendWidget(
                                                  friend: friend,
                                                  viewType:
                                                      FriendViewType.groupView,
                                                  isAdminView: true);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        icon: Icons.admin_panel_settings,
                        iconContainerColor: Colors.orange),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );

  }
}