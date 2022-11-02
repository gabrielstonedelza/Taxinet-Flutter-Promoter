import 'dart:async';

import "package:flutter/material.dart";
import "package:get/get.dart";
import 'package:get_storage/get_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lottie/lottie.dart';
import 'package:taxinet_promoter/views/mypassengers.dart';
import 'package:taxinet_promoter/views/nointernetconnection.dart';
import 'package:taxinet_promoter/views/register/registerview.dart';
import 'constants/app_colors.dart';
import 'controllers/usercontroller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final storage = GetStorage();
  late String username = "";
  late String uToken = "";
  late String userid = "";
  final UserController controller = Get.find();
  bool hasInternet = false;
  late StreamSubscription internetSubscription;

  late Timer _timer;

  @override
  void initState(){
    super.initState();
    internetSubscription = InternetConnectionChecker().onStatusChange.listen((status){
      final hasInternet = status == InternetConnectionStatus.connected;
      setState(()=> this.hasInternet = hasInternet);
    });
    if (storage.read("userToken") != null) {
      uToken = storage.read("userToken");
    }
    if (storage.read("username") != null) {
      username = storage.read("username");
    }
    if (storage.read("userid") != null) {
      userid = storage.read("userid");
    }
    controller.getUserProfile(uToken);
    controller.getMyPassengers(uToken,username);

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      controller.getUserProfile(uToken);
      controller.getMyPassengers(uToken,username);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: hasInternet ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height:20),
          Padding(
            padding: const EdgeInsets.only(left:18.0,right:18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      Get.to(()=> const Registration());
                    },
                    child: Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Container(
                        height:150,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/images/register.png",width:42),
                              const SizedBox(height:20),
                              const Text("Register Passenger",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black),)
                            ]
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width:20),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      Get.to(()=> const MyPassengers());
                    },
                    child: Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Container(
                        height:150,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/images/team1.png",width:42),
                              const SizedBox(height:20),
                              const Text("Your Passengers",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black),)
                            ]
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20,),
        ]
      ) : const NoInternetConnection()
    );
  }
}
