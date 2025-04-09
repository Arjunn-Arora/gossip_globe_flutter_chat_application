import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/models/user_model.dart';
import 'package:gossip_globe/providers/authentication_provider.dart';
import 'package:gossip_globe/utilities/global_methods.dart';
import 'package:gossip_globe/widgets/app_bar_back_button.dart';
import 'package:gossip_globe/widgets/group_details_card.dart';
import 'package:gossip_globe/widgets/settings_list_tile.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  bool isDarkMode = false;
  void getThemeMode() async{
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    if(savedThemeMode == AdaptiveThemeMode.dark){
      setState(() {
        isDarkMode = true;
      });
    } else{
      setState(() {
        isDarkMode = false;
      });
    }
  }

@override
void initState() {
  super.initState();
  getThemeMode();
}

  @override
  Widget build(BuildContext context) {
    final uid = ModalRoute.of(context)!.settings.arguments as String;


    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: (){
          Navigator.pop(context);
        }),
        centerTitle: true,
        title: Text('Profile Screen'),
      ),
      body: StreamBuilder(
        stream: context.read<AuthenticationProvider>().userStream(userID: uid),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userModel =
              UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoDetailsCard(userModel: userModel,),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('Settings', style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.bold),),
                  ),
                  const SizedBox(height: 10,),
                  Card(
                    child: Column(
                      children: [
                        SettingsListTile(
                          title: 'Account',
                          icon: Icons.person,
                          iconContainerColor: Colors.deepPurple,
                          onTap: () {
                            Navigator.pushNamed(context, '/edit_profile', arguments: uid);
                          },
                        ),
                        SettingsListTile(
                          title: 'Media',
                          icon: Icons.image,
                          iconContainerColor: Colors.green,
                          onTap: () {
                            Navigator.pushNamed(context, '/edit_profile', arguments: uid);
                          },
                        ),
                        SettingsListTile(
                          title: 'Notifications',
                          icon: Icons.notifications,
                          iconContainerColor: Colors.red,
                          onTap: () {
                            Navigator.pushNamed(context, '/edit_profile', arguments: uid);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Card(
                    child: Column(
                      children: [
                        SettingsListTile(
                          title: 'Help',
                          icon: Icons.help,
                          iconContainerColor: Colors.yellow,
                          onTap: () {
                            Navigator.pushNamed(context, '/edit_profile', arguments: uid);
                          },
                        ),
                        SettingsListTile(
                          title: 'Share',
                          icon: Icons.share,
                          iconContainerColor: Colors.blue,
                          onTap: () {
                            Navigator.pushNamed(context, '/edit_profile', arguments: uid);
                          },
                        ),
                        SettingsListTile(
                          title: 'Notifications',
                          icon: Icons.notifications,
                          iconContainerColor: Colors.red,
                          onTap: () {
                            Navigator.pushNamed(context, '/edit_profile', arguments: uid);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            isDarkMode
                                ? Icons.nightlight_round
                                : Icons.wb_sunny_rounded,
                            color: isDarkMode ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                      title: const Text('Change theme'),
                      trailing: Switch(
                          value: isDarkMode,
                          onChanged: (value) {
                            // set the isDarkMode to the value
                            setState(() {
                              isDarkMode = value;
                            });
                            // check if the value is true
                            if (value) {
                              // set the theme mode to dark
                              AdaptiveTheme.of(context).setDark();
                            } else {
                              // set the theme mode to light
                              AdaptiveTheme.of(context).setLight();
                            }
                          }),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Column(
                      children: [
                        SettingsListTile(
                          title: 'Logout',
                          icon: Icons.logout_outlined,
                          iconContainerColor: Colors.red,
                          onTap: () {
                            showMyAnimatedDialog(
                              context: context,
                              title: 'Logout',
                              content: 'Are you sure you want to logout?',
                              textAction: 'Logout',
                              onActionTap: (value) {
                                if (value) {
                                  // logout
                                  context
                                      .read<AuthenticationProvider>()
                                      .logout()
                                      .whenComplete(() {
                                    Navigator.pop(context);
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      Constants.loginScreen,
                                      (route) => false,
                                    );
                                  });
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}