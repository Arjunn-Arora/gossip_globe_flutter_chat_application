import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gossip_globe/providers/authentication_provider.dart';
import 'package:gossip_globe/utilities/assets_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _phoneNumberController = TextEditingController();
  

Country selectedCountry = Country(
  phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: 'India',
    displayName: 'India',
    displayNameNoCountryCode: 'IN',
    e164Key: '',
);

  @override
void dispose(){
  _phoneNumberController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                width: 200,
                child: Lottie.asset(AssetsManager.chatBubble),
              ),
              Text('Gossip Globe', style: GoogleFonts.openSans(fontSize: 28, fontWeight: FontWeight.w500),),
              const SizedBox(height: 20),
              Text('Add your phone number to get started', textAlign: TextAlign.center, style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w400),),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                onChanged: (value) {
                  setState(() {
                    _phoneNumberController.text = value;
                  });
                },
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Phone Number',
                  prefixIcon: Container(
                    padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
                    child: InkWell(
                      onTap: (){
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          onSelect: (Country country) {
                            setState(() {
                              selectedCountry = country;
                            },
                            );
                          }
                        );
                      },
                      child: Text(
                        '${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}',
                        style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  suffixIcon: _phoneNumberController.text.length > 9 ? 
                  authProvider.isLoading ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Colors.green,),
                  ) :
                  InkWell(
                    onTap: (){
                      authProvider.signInWithPhoneNumber(phoneNumber: '+${selectedCountry.phoneCode}${_phoneNumberController.text}', context: context);
                    },
                    child: Container(
                      height: 35,
                      width: 35,
                      margin: const EdgeInsets.all(10.0),
                      decoration:const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: const Icon(Icons.done, color: Colors.white, size: 25,),
                    ),
                  ) : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}