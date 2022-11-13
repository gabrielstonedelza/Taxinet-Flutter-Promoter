import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import "package:flutter/material.dart";
import "package:get/get.dart";
import 'package:get_storage/get_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:taxinet_promoter/views/accountblocked.dart';
import 'package:taxinet_promoter/views/mycommissions.dart';
import 'package:taxinet_promoter/views/mypassengers.dart';
import 'package:taxinet_promoter/views/register/registerview.dart';
import 'constants/app_colors.dart';
import 'controllers/commissioncontroller.dart';
import 'controllers/usercontroller.dart';
import 'controllers/walletcontroller.dart';

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
  final CommissionController commissionController = Get.find();
  final WalletController walletController = Get.find();
  bool hasInternet = false;
  late StreamSubscription internetSubscription;
  bool isBlocked = false;
  late List allBlockedUsers = [];
  late List blockedUsernames = [];
  bool isLoading = true;

  fetchBlockedAgents()async{
    const url = "https://taxinetghana.xyz/get_blocked_users/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink,);
    if(response.statusCode == 200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allBlockedUsers = json.decode(jsonData);
      for(var i in allBlockedUsers){
        if(!blockedUsernames.contains(i['get_username'])){
          blockedUsernames.add(i['get_username']);
        }
      }

    }

    setState(() {
      isLoading = false;
      allBlockedUsers = allBlockedUsers;
    });
  }

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

    fetchBlockedAgents();
    controller.getUserProfile(uToken);
    controller.getMyPassengers(uToken,username);
    commissionController.getAllCommission(uToken);
    walletController.getUserWallet(uToken);

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      controller.getUserProfile(uToken);
      controller.getMyPassengers(uToken,username);
      commissionController.getAllCommission(uToken);
      walletController.getUserWallet(uToken);
      fetchBlockedAgents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: blockedUsernames.contains(username) ? const Scaffold(
          body: AccountBlockNotification()
      ) :Scaffold(
        backgroundColor: primaryColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height:20),
            Center(child: GetBuilder<WalletController>(
                builder: (controller) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_balance_wallet),
                      const SizedBox(width:10),
                      walletController.isLoading ? const Center(
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 5,
                          backgroundColor: primaryColor
                        ),
                      ) :  Text(
                          "GHS ${walletController.wallet}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ],
                  );
                })),
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
            Padding(
              padding: const EdgeInsets.only(left:18.0,right:18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        Get.to(()=> const MyCommissions());
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
                                Image.asset("assets/images/commission.png",width:42),
                                const SizedBox(height:20),
                                const Text("Commissions",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black),)
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

                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),
          ]
        )
      ),
    );
  }
}
