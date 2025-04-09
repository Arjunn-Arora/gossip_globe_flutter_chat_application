import 'package:flutter/material.dart';
import 'package:gossip_globe/main_screens/group_settings_screen.dart';
import 'package:gossip_globe/providers/group_provider.dart';
import 'package:gossip_globe/utilities/global_methods.dart';
import 'package:gossip_globe/widgets/settings_list_tile.dart';

class SettingsAndMedia extends StatelessWidget {
  const SettingsAndMedia({
    super.key,
    required this.groupProvider,
    required this.isAdmin,
  });

  final bool isAdmin;
  final GroupProvider groupProvider;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          children: [
            SettingsListTile(title: 'Media', onTap: (){}, icon: Icons.image, iconContainerColor: Colors.deepPurple),
            Divider(
              thickness: 0.5,
              color: Colors.grey,
            ),
            SettingsListTile(title: 'Group Settings', onTap: (){
              if(!isAdmin){
                showSnackBar('Only Admin can change group settings', context);
              } else{
                groupProvider.updateGroupAdminsList().whenComplete((){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const GroupSettingsScreen()));
                });
              }
            }, icon: Icons.settings, iconContainerColor: Colors.deepPurple),
          ],
        ),
      ),
    );
  }
}