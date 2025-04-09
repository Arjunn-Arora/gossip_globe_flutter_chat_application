import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/widgets/app_bar_back_button.dart';
import 'package:gossip_globe/widgets/friends_list.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key, this.groupId  = ''});

  final String groupId;

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text('Requests'),
      ),
      body: Column(
        children: [
          // cupertinosearchbar
          CupertinoSearchTextField(
            placeholder: 'Search',
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              print(value);
            },
          ),

          Expanded(
              child: FriendsList(
            viewType: FriendViewType.friendRequests,
            groupId: widget.groupId,
          )),
        ],
      ),
    );

  }
}