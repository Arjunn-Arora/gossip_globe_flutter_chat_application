import 'package:flutter/material.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/providers/authentication_provider.dart';
import 'package:gossip_globe/utilities/assets_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {

@override
void initState(){
  checkAuthentication();
  super.initState();
}

void checkAuthentication() async {
    final authProvider = context.read<AuthenticationProvider>();
    bool isAuthenticated = await authProvider.checkAuthenticationState();
    navigate(isAuthenticated: isAuthenticated);
  }
  navigate({required bool isAuthenticated}){
    if(isAuthenticated){
      Navigator.pushReplacementNamed(context, Constants.homeScreen);
    }else{
      Navigator.pushReplacementNamed(context, Constants.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
            height: 400,
            width: 200,
            child: Column(
              children: [
                LottieBuilder.asset(AssetsManager.chatBubble),
                const LinearProgressIndicator(),
              ],
            ),
          ),
        
      ),
    );
  }
  
  
}