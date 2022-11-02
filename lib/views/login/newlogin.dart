import 'dart:async';

import "package:flutter/material.dart";
import 'package:get_storage/get_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:get/get.dart";
import '../../constants/app_colors.dart';
import '../../controllers/logincontroller.dart';
import '../../controllers/usercontroller.dart';

import '../nointernetconnection.dart';
import '../register/registerview.dart';
class NewLogin extends StatefulWidget {
  const NewLogin({Key? key}) : super(key: key);

  @override
  State<NewLogin> createState() => _NewLoginState();
}

class _NewLoginState extends State<NewLogin> {
  String username = "";
  String fullName = "";
  String profilePic = "";
  final UserController userController = Get.find();
  final MyLoginController loginData = Get.find();

  late final TextEditingController _passwordController;
  late final TextEditingController _usernameController;
  final _formKey = GlobalKey<FormState>();
  bool isObscured = true;
  bool isPosting = false;
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final storage = GetStorage();
  late StreamSubscription internetSubscription;
  bool hasInternet = false;

  String resetPasswordUrl = "https://taxinetghana.xyz/password-reset/";
  void _startPosting()async{
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }

  Future<void> _launchInBrowser(String url) async{
    if(await canLaunch(url)){
      await launch(url,forceSafariVC: false,forceWebView: false);
    }
    else{
      throw "Could not launch $url";
    }
  }
  final MyLoginController loginController = Get.find();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    internetSubscription = InternetConnectionChecker().onStatusChange.listen((status){
      final hasInternet = status == InternetConnectionStatus.connected;
      setState(()=> this.hasInternet = hasInternet);
    });
    if (storage.read("passenger_username") != null) {
      username = storage.read("passenger_username");
    }
    _passwordController = TextEditingController();
    _usernameController = TextEditingController();
    if (storage.read("profile_name") != null) {
      fullName = storage.read("profile_name");
    }
    if (storage.read("profile_pic") != null) {
      profilePic = storage.read("profile_pic");
    }
    loginController.getAllPromoters();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: hasInternet ? ListView(
          children: [
            const SizedBox(height: 40),
            profilePic != ""?  GetBuilder<UserController>(
              builder: (controller) {
                return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: NetworkImage(profilePic),
                            fit: BoxFit.contain
                        )
                    )
                );
              },
            ) : Container(),
            const SizedBox(height: 20),
            username != ""?
            Center(
                child: Text("Welcome back, ${username.capitalize}",style: const TextStyle(fontWeight: FontWeight.bold),)
            ) : Container(),
            username == "" ? const Center(
                child: Text("Login",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25))
            ) : Container(),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    username == "" ?   TextFormField(
                      controller: _usernameController,
                      focusNode: _usernameFocusNode,
                      decoration: InputDecoration(

                          labelText:
                          "Username",
                          labelStyle:
                          const TextStyle(
                              color:
                              muted),
                          focusColor:
                          muted,
                          fillColor:
                          muted,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color:
                                  muted,
                                  width:
                                  2),
                              borderRadius:
                              BorderRadius.circular(
                                  12)),
                          border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12))),
                      // cursorColor: Colors.black,
                      // style: const TextStyle(color: Colors.black),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: (value){
                        if(value!.isEmpty){
                          return "Enter username";
                        }
                        else{
                          return null;
                        }
                      },
                    ) : Container(),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: (){
                              setState(() {
                                isObscured = !isObscured;
                              });
                            },
                            icon: Icon(isObscured ? Icons.visibility : Icons.visibility_off,color: muted,),
                          ),
                          labelText:
                          "Password",
                          labelStyle:
                          const TextStyle(
                              color:
                              muted),
                          focusColor:
                          muted,
                          fillColor:
                          muted,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color:
                                  muted,
                                  width:
                                  2),
                              borderRadius:
                              BorderRadius.circular(
                                  12)),
                          border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12))),
                      // cursorColor: Colors.black,
                      // style: const TextStyle(color: Colors.black),
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      obscureText: isObscured,
                      validator: (value){
                        if(value!.isEmpty){
                          return "Enter password";
                        }
                        else{
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                        onTap: () async{
                          await _launchInBrowser("https://taxinetghana.xyz/password-reset/");
                        },
                        child: const Text("Forgot Password",style: TextStyle(fontWeight: FontWeight.bold,),)),
                    const SizedBox(height: 25,),
                    const SizedBox(
                        height: 20),
                    isPosting ? const Center(
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 5,
                        backgroundColor: primaryColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black
                        ),
                      ),
                    ):   RawMaterialButton(
                      onPressed: () {
                        _startPosting();
                        if (_formKey.currentState!.validate()) {
                          if(username == ""){
                            loginData.loginUser(_usernameController.text.trim(), _passwordController.text.trim());
                          }
                          if(username != ""){
                            loginData.loginUser(username, _passwordController.text.trim());
                          }

                        } else {
                          Get.snackbar("Error", "Something went wrong",
                              colorText: defaultTextColor1,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red
                          );
                          return;
                        }
                      },
                      // child: const Text("Send"),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                              8)),
                      elevation: 8,
                      fillColor:
                      primaryColor,
                      splashColor:
                      defaultColor,
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontWeight:
                          FontWeight
                              .bold,
                          fontSize: 20,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ) : const NoInternetConnection()
    );
  }
}
