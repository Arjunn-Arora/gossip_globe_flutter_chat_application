import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/main_screens/friend_requests_screen.dart';
import 'package:gossip_globe/models/user_model.dart';
import 'package:gossip_globe/providers/authentication_provider.dart';
import 'package:gossip_globe/providers/group_provider.dart';
import 'package:gossip_globe/utilities/global_methods.dart';
import 'package:provider/provider.dart';

class GroupStatusWidget extends StatelessWidget {
  const GroupStatusWidget({
    super.key,
    required this.isAdmin,
    required this.groupProvider,
  });

  final bool isAdmin;
  final GroupProvider groupProvider;

  @override
  Widget build(BuildContext context) {
    return Row(
                 children: [
                  InkWell(
                    onTap: !isAdmin ? null : (){
                      showMyAnimatedDialog(context: context, 
                      title: 'Change Group Type', 
                      content: 'Are you sure you want to change the group type to ${groupProvider.groupModel.isPrivate ? 'Public' : 'Private'}?', 
                      textAction: 'Change', 
                      onActionTap: (value){
    if(value){
      groupProvider.changeGroupType();
    }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
    color: isAdmin ? Colors.greenAccent : Colors.deepPurple,
    borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(groupProvider.groupModel.isPrivate ? 'Private' : 'Public', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  GetRequestWidget(groupProvider: groupProvider, isAdmin: isAdmin,), 
                 ],
               );
  }
}


class ProfileStatusWidget extends StatelessWidget {
  const ProfileStatusWidget({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  final UserModel userModel;
  final UserModel currentUser;

  @override
  Widget build(BuildContext context) {
    return Row(
                 children: [
                  FriendRequestButton(
                  currentUser: currentUser,
                  userModel: userModel,
                ),
                const SizedBox(height: 10),
                 FriendsButton(
                     currentUser: currentUser, userModel: userModel),
                 ],
               );
  }
}

class FriendsButton extends StatelessWidget {
  const FriendsButton({super.key, required this.currentUser, required this.userModel});

  final UserModel currentUser;
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    Widget buildFriendsButton() {
    if (currentUser.uid == userModel.uid && userModel.friendsUIDs.isNotEmpty) {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.45,
        child: ElevatedButton(
          onPressed: () {
            //show friends
            Navigator.pushNamed(context, Constants.friendsScreen);
          },
          child: Text(
            'View Friends'.toUpperCase(),
            style: GoogleFonts.openSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    } else {
      if (currentUser.uid != userModel.uid) {
        if (userModel.friendRequestsUIDs.contains(currentUser.uid)) {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: ElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .cancelFriendRequest(
                      friendID: userModel.uid,
                    )
                    .whenComplete(() {
                  showSnackBar('Friend Request Cancelled!!', context);
                });
              },
              child: Text(
                'Cancel Friend request'.toUpperCase(),
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        } else if (userModel.sentFriendRequestsUIDs.contains(currentUser.uid)) {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.45,
            child: ElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .acceptFriendRequest(
                      friendID: userModel.uid,
                    )
                    .whenComplete(() {
                  showSnackBar(
                      'You are now friends with ${userModel.name}', context);
                });
              },
              child: Text(
                'Accept Friend request'.toUpperCase(),
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        } else if (userModel.friendsUIDs.contains(currentUser.uid)) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Unfriend',
                          textAlign: TextAlign.center,
                        ),
                        content: Text(
                          'Are you sure you want to Unfriend ${userModel.name}?',
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await context
                                  .read<AuthenticationProvider>()
                                  .removeFriend(
                                    friendID: userModel.uid,
                                  )
                                  .whenComplete(() {
                                showSnackBar('Friend Removed!!', context);
                              });
                            },
                            child: const Text('Unfriend'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Unfriend'.toUpperCase(),
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pushNamed(context, Constants.chatScreen,
                        arguments: {
                          Constants.contactUID: userModel.uid,
                          Constants.contactName: userModel.name,
                          Constants.contactImage: userModel.image,
                          Constants.groupId: ''
                        });
                  },
                  child: Text(
                    'Chat'.toUpperCase(),
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: ElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .sendFriendRequest(
                      friendID: userModel.uid,
                    )
                    .whenComplete(() {
                  showSnackBar('Friend Request Sent!!', context);
                });
              },
              child: Text(
                'Send Friend request'.toUpperCase(),
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }
      } else {
        return const SizedBox.shrink();
      }
    }
  }
    return buildFriendsButton();
  }
}


class FriendRequestButton extends StatelessWidget {
  const FriendRequestButton({super.key, required this.currentUser, required this.userModel});

  final UserModel currentUser;
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    Widget buildFriendRequestsButton() {
    if (currentUser.uid == userModel.uid &&
        userModel.friendRequestsUIDs.isNotEmpty) {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: ElevatedButton(
          onPressed: () {
            //show friend requests
            Navigator.pushNamed(context, Constants.friendRequestsScreen);
          },
          child: Text(
            'View Friend Requests'.toUpperCase(),
            style:
                GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
    return buildFriendRequestsButton();
  }
}


class GetRequestWidget extends StatelessWidget {
  const GetRequestWidget({super.key, required this.groupProvider, required this.isAdmin});

  final GroupProvider groupProvider;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    Widget getRequestWidget(){
    if(isAdmin){
      if(groupProvider.groupModel.awaitingApprovalUIDs.isNotEmpty){
        return InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context){
              return FriendRequestsScreen(groupId: groupProvider.groupModel.groupId,);
            }));
          },
          child: const CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.orangeAccent,
                  child: Icon(Icons.person_add,
                  size: 18,
                  color: Colors.white,
                  ),
                ),
        );
      } else{
        return const SizedBox();
      }
    } else{
      return const SizedBox();
    }
  }
    return getRequestWidget();
  }
}