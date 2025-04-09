import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/models/user_model.dart';
import 'package:gossip_globe/providers/authentication_provider.dart';
import 'package:gossip_globe/utilities/assets_manager.dart';
import 'package:gossip_globe/utilities/global_methods.dart';
import 'package:gossip_globe/widgets/app_bar_back_button.dart';
import 'package:gossip_globe/widgets/display_user_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {

final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
final TextEditingController _nameController = TextEditingController();
File? finalfileImage;
  String userImage = '';


@override
void dispose(){
  _btnController.stop();
  super.dispose();
}

void selectImage(bool fromCamera) async {
    finalfileImage = await pickImage(
      fromCamera: fromCamera,
      onFail: (String message) {
        showSnackBar(message, context);
      },
    );
    //crop the image
    await cropImage(finalfileImage?.path);
    popContext();
  }

  popContext() {
    Navigator.pop(context);
  }

  Future<void> cropImage(filePath) async {
    if (filePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );

      if (croppedFile != null) {
        setState(() {
          finalfileImage = File(croppedFile.path);
        });
      }
    }
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                selectImage(true);
              },
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
            ),
            ListTile(
              onTap: () {
                selectImage(false);
              },
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: (){
          Navigator.pop(context);
        }),
        title: const Text('Add Your Information'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            children: [
              DisplayUserImage(finalfileImage: finalfileImage, radius: 60, onPressed: (){showBottomSheet();}),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  )
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: RoundedLoadingButton(controller: _btnController, onPressed: (){
                  //save user information
                  if(_nameController.text.isEmpty || _nameController.text.length < 3){
                    showSnackBar('Please enter your name', context);
                    _btnController.reset();
                    return;
                  }
                  saveUserDataToFireStore();
                },
                successIcon: Icons.check,
                successColor: Colors.green,
                errorColor: Colors.red,
                color: Theme.of(context).primaryColor,
                child: const Text('Continue', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveUserDataToFireStore() async {
    final authProvider = context.read<AuthenticationProvider>();

    // Ensure uid and phoneNumber are correctly retrieved
    if (authProvider.uid == null || authProvider.phoneNumber == null) {
      showSnackBar('Error: User authentication data is missing.', context);
      _btnController.error();
      return;
    }

    UserModel userModel = UserModel(
      uid: authProvider.uid!,
      name: _nameController.text.trim(),
      phoneNumber: authProvider.phoneNumber!,
      image: '',
      token: '',
      aboutMe: 'Hey there, I\'m using Gossip Globe!',
      lastSeen: '',
      createdAt: '',
      isOnline: true,
      friendsUIDs: [],
      friendRequestsUIDs: [],
      sentFriendRequestsUIDs: [],
    );

    authProvider.saveUserDataToFireStore(
      userModel: userModel,
      fileImage: finalfileImage,
      onSuccess: () async {
        _btnController.success();
        // save user data to shared preferences
        await authProvider.saveUserDataToSharedPreferences();

        // Navigate to home screen
        navigateToHomeScreen();
      },
      onFail: () async {
        _btnController.error();
        showSnackBar('Failed to save user data', context);
        await Future.delayed(const Duration(seconds: 1));
        _btnController.reset();
      },
    );
  }

  void navigateToHomeScreen() {
    // navigate to home screen and remove all previous screens
    Navigator.of(context).pushNamedAndRemoveUntil(
      Constants.homeScreen,
      (route) => false,
    );
  }

}