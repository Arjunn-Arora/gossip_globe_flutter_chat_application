import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gossip_globe/models/user_model.dart';
import 'package:gossip_globe/providers/authentication_provider.dart';
import 'package:gossip_globe/providers/group_provider.dart';
import 'package:gossip_globe/utilities/global_methods.dart';
import 'package:gossip_globe/widgets/profile_widgets.dart';
import 'package:provider/provider.dart';

class InfoDetailsCard extends StatelessWidget {
  const InfoDetailsCard({
    super.key,
    this.groupProvider,
    this.isAdmin,
    this.userModel
  });

  final GroupProvider? groupProvider;
  final bool? isAdmin;
  final UserModel? userModel;

  @override
  Widget build(BuildContext context) {
  final currentUser = context.read<AuthenticationProvider>().userModel!;
  final profileImage = userModel != null ? userModel!.image : groupProvider!.groupModel.groupImage;
  final profileName = userModel != null ? userModel!.name : groupProvider!.groupModel.groupName;
  final aboutMe = userModel != null ? userModel!.aboutMe : groupProvider!.groupModel.groupDescription;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                userImageWidget(imageUrl: profileImage, radius: 50, onTap: (){}),
                const SizedBox(width: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(profileName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                //   userModel != null && currentUser.uid == userModel!.uid  ?
                // Text(
                //   currentUser.phoneNumber,
                //   style: GoogleFonts.openSans(
                //     fontSize: 20,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ) : const SizedBox.shrink(),
                    const SizedBox(height: 10,),
                    userModel != null ? ProfileStatusWidget(userModel: userModel!, currentUser: currentUser) :
                    GroupStatusWidget(isAdmin: isAdmin!, groupProvider: groupProvider!),
                  ],
                ),  
              ],
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            Text(userModel != null ? 'About Me' : 'Group Description', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
           Text(aboutMe, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
          ],
        ),
      ),
    );
  }
}

