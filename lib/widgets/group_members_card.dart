import 'package:flutter/material.dart';
import 'package:gossip_globe/models/user_model.dart';
import 'package:gossip_globe/providers/group_provider.dart';
import 'package:gossip_globe/utilities/global_methods.dart';

class GroupMembersCard extends StatefulWidget {
  const GroupMembersCard({
    super.key,
    required this.isAdmin,
    required this.groupProvider,
  });

  final bool isAdmin;
  final GroupProvider groupProvider;

  @override
  State<GroupMembersCard> createState() => _GroupMembersCardState();
}

class _GroupMembersCardState extends State<GroupMembersCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          FutureBuilder<List<UserModel>>(future: widget.groupProvider.getGroupMembersDataFromFirestore(isAdmin: false), builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator());
            }
            if(snapshot.hasError){
              return const Center(child: Text('Something went wrong'));
            }
            if(snapshot.data!.isEmpty){
              return const Center(child: Text('No Members Found!!'));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index){
                final member = snapshot.data![index];
                return ListTile(
                  leading: userImageWidget(imageUrl: member.image, radius: 40, onTap: (){}),
                  title: Text(member.name),
                  subtitle: Text(member.aboutMe),
                  trailing: widget.groupProvider.groupModel.adminsUIDs.contains(member.uid) ? const Icon(Icons.admin_panel_settings, color: Colors.deepPurple,) : const SizedBox(),
                  onTap: !widget.isAdmin ? null : (){
                    showMyAnimatedDialog(context: context, title: 'Remove Member', content: 'Are you sure you want to remove ${member.name} from Group?', textAction: 'Remove', onActionTap: (value) async{
                      if(value){
                       await widget.groupProvider.removeGroupMember(groupMember: member);
                       setState(() {
                         
                       });
                      }
                    });
                  },
                );
              },
            );
          }),
        ],
      ),
    );
  }
}