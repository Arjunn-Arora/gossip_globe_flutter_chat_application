import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/authentication/landing_screen.dart';
import 'package:gossip_globe/authentication/login_screen.dart';
import 'package:gossip_globe/authentication/otp_screen.dart';
import 'package:gossip_globe/authentication/user_information_screen.dart';
import 'package:gossip_globe/firebase_options.dart';
import 'package:gossip_globe/main_screens/chat_screen.dart';
import 'package:gossip_globe/main_screens/friend_requests_screen.dart';
import 'package:gossip_globe/main_screens/friends_screen.dart';
import 'package:gossip_globe/main_screens/group_information_screen.dart';
import 'package:gossip_globe/main_screens/group_settings_screen.dart';
import 'package:gossip_globe/main_screens/home_screen.dart';
import 'package:gossip_globe/main_screens/profile_screen.dart';
import 'package:gossip_globe/main_screens/settings_screen.dart';
import 'package:gossip_globe/providers/authentication_provider.dart';
import 'package:gossip_globe/providers/chat_provider.dart';
import 'package:gossip_globe/providers/group_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider(),),
      ],
      child: MyApp(savedThemeMode: savedThemeMode),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.savedThemeMode});

  final AdaptiveThemeMode? savedThemeMode;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      dark: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Gossip Globe',
        theme: theme,
        darkTheme: darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: Constants.landingScreen,
        routes: {
        Constants.loginScreen: (context) => const LoginScreen(),
        Constants.otpScreen: (context) => const OTPScreen(),
        Constants.userInformationScreen: (context) => const UserInformationScreen(),
        Constants.homeScreen: (context) => const HomeScreen(),
        Constants.landingScreen: (context) => const LandingScreen(),
        Constants.profileScreen: (context) => const ProfileScreen(),
        Constants.settingsScreen: (context) => const SettingsScreen(),
        Constants.friendsScreen: (context) => const FriendsScreen(),
        Constants.friendRequestsScreen: (context) => const FriendRequestsScreen(),
        Constants.chatScreen: (context) => const ChatScreen(),
        Constants.groupSettingsScreen: (context) => const GroupSettingsScreen(),
        Constants.groupInformationScreen: (context) => const GroupInformationScreen(),
        },
      ),
    );
  }
}


