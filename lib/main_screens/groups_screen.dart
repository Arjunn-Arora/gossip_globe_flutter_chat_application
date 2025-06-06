import 'package:flutter/material.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/main_screens/private_group_screen.dart';
import 'package:gossip_globe/main_screens/public_group_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(
                  text: Constants.private.toUpperCase(),
                ),
                Tab(
                  text: Constants.public.toUpperCase(),
                ),
              ],
            ),
          ),
          body: const TabBarView(children: [
            PrivateGroupScreen(),
            PublicGroupScreen(),
          ]),
        ));

  }
}