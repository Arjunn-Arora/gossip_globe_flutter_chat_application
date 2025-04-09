import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/providers/authentication_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {

final controller = TextEditingController();
  final focusNode = FocusNode();
  String? otpCode;

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final phoneNumber = args[Constants.phoneNumber] as String;
    final verificationId = args[Constants.verificationId] as String;
    final authProvider = context.watch<AuthenticationProvider>(); 
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.openSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Text('Verification', style: GoogleFonts.openSans(fontSize: 28, fontWeight: FontWeight.w500),),
              const SizedBox(height: 50),
              Text('Enter the code sent to the number', style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w500),),
              const SizedBox(height: 50),
              Text(phoneNumber, style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w500),),
              const SizedBox(height: 50),
              SizedBox(height: 60, child: Pinput(
                length: 6,
                controller: controller,
                focusNode: focusNode,
                defaultPinTheme: defaultPinTheme,
                onCompleted: (pin){
                  setState(() {
                    otpCode = pin;
                  });
                  verifyOTPCode(verificationId: verificationId, otpCode: otpCode!,);
                },
                focusedPinTheme: defaultPinTheme.copyWith(
                  height: 68,
                  width: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
                  ),
                ),
                errorPinTheme: defaultPinTheme.copyWith(
                  height: 68,
                  width: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                ),
              ),
              ),
              const SizedBox(height: 30),
              authProvider.isLoading ? const CircularProgressIndicator() : const SizedBox.shrink(),
              authProvider.isSuccessful ? Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 30,),
              ) : const SizedBox.shrink(),
              authProvider.isLoading ? const SizedBox.shrink() :
              Text('Didn\'t receive the code?', style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w500),),
              const SizedBox(height: 10),
              authProvider.isLoading ? const SizedBox.shrink() :
              TextButton(onPressed: (){
                authProvider.resendCode(context: context, phone: phoneNumber);
              }, child: Text('Resend Code', style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w500),)),
            ],
          ),
        ),
      ),
    );
  }

void verifyOTPCode({
    required String verificationId,
    required String otpCode,
  }) async {
    final authProvider = context.read<AuthenticationProvider>();
    authProvider.verifyOTPCode(
      verificationId: verificationId,
      otpCode: otpCode,
      context: context,
      onSuccess: () async {
        bool userExists = await authProvider.checkUserExists();

        if (userExists) {
          await authProvider.getUserDataFromFireStore();
          await authProvider.getUserDataFromSharedPreferences();
          navigate(userExits: true);
        } else {
          navigate(userExits: false);
        }
      },
    );
  }
void navigate({required bool userExits}) {
    if (userExits) {
      // navigate to home and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(
        context,
        Constants.homeScreen,
        (route) => false,
      );
    } else {
      // navigate to user information screen
      Navigator.pushNamed(
        context,
        Constants.userInformationScreen,
      );
    }
  }

}