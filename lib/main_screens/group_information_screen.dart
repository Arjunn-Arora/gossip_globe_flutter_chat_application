import 'package:flutter/material.dart';
import 'package:gossip_globe/providers/authentication_provider.dart';
import 'package:gossip_globe/providers/group_provider.dart';
import 'package:gossip_globe/utilities/global_methods.dart';
import 'package:gossip_globe/widgets/add_members.dart';
import 'package:gossip_globe/widgets/app_bar_back_button.dart';
import 'package:gossip_globe/widgets/exit_group_card.dart';
import 'package:gossip_globe/widgets/group_details_card.dart';
import 'package:gossip_globe/widgets/group_members_card.dart';
import 'package:gossip_globe/widgets/settings_and_media.dart';
import 'package:gossip_globe/widgets/settings_list_tile.dart';
import 'package:provider/provider.dart';

class GroupInformationScreen extends StatefulWidget {
  const GroupInformationScreen({super.key});

  @override
  State<GroupInformationScreen> createState() => _GroupInformationScreenState();
}

class _GroupInformationScreenState extends State<GroupInformationScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    bool isMember =
        context.read<GroupProvider>().groupModel.membersUIDs.contains(uid);
    return Consumer<GroupProvider>(builder: (context, groupProvider, child){
      bool isAdmin = groupProvider.groupModel.adminsUIDs.contains(uid);
      return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: (){
          Navigator.pop(context);
        }),
        centerTitle: true,
        title: const Text('Group Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InfoDetailsCard(groupProvider: groupProvider,isAdmin: isAdmin,),
              const SizedBox(height: 10,),
              SettingsAndMedia(groupProvider: groupProvider, isAdmin: isAdmin,),
              const SizedBox(height: 10,),
              AddMembers(groupProvider: groupProvider,isAdmin: isAdmin,onPressed: (){
                showAddMembersBottomSheet(
                      context: context,
                      groupMembersUIDs: groupProvider.groupModel.membersUIDs,
                    );
              },),
              const SizedBox(height: 20),
                isMember
                    ? Column(
                        children: [
                          GroupMembersCard(
                            isAdmin: isAdmin,
                            groupProvider: groupProvider,
                          ),
                          const SizedBox(height: 10),
                          ExitGroupCard(
                            uid: uid,
                          )
                        ],
                      )
                    : const SizedBox(),
            ],
          ),
        ),
      ),
    );
    });
  }
}







