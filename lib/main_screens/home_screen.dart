import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/main_screens/create_group_screen.dart';
import 'package:gossip_globe/main_screens/my_chats_screen.dart';
import 'package:gossip_globe/main_screens/groups_screen.dart';
import 'package:gossip_globe/main_screens/people_screen.dart';
import 'package:gossip_globe/providers/authentication_provider.dart';
import 'package:gossip_globe/providers/group_provider.dart';
import 'package:gossip_globe/utilities/global_methods.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver, TickerProviderStateMixin {

  int currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final List<Widget> pages = const [
    MyChatsScreen(),
    GroupsScreen(),
    PeopleScreen(),
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

@override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state){
      case AppLifecycleState.resumed:
      context.read<AuthenticationProvider>().updateUserStatus(value: true);
      break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      context.read<AuthenticationProvider>().updateUserStatus(value: false);
      break;
      default:
      break;
    }
    super.didChangeAppLifecycleState(state);
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>(); 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gossip Globe'),
        actions:[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: 
            userImageWidget(imageUrl: authProvider.userModel!.image, radius: 20, onTap: (){
              //navigate to profile screen
              Navigator.pushNamed(context, Constants.profileScreen, arguments: authProvider.userModel!.uid);
            },
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index){
          setState(() {
            currentIndex = index;
          });
        },
        children: pages,
      ),
      floatingActionButton: currentIndex == 1
            ? FloatingActionButton(
                onPressed: () {
                  context.read<GroupProvider>().clearGroupMembersList().whenComplete((){
                    Navigator.of(context).push(MaterialPageRoute(builder: (builder) => const CreateGroupScreen(),),);
                  });
                },
                child: const Icon(CupertinoIcons.chat_bubble_2_fill),
              )
            : null,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.chat_bubble_2), 
          label: 'Chats',
          ),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.group), 
          label: 'Groups',
          ),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.globe), 
          label: 'People',
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index){
          _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}