
import 'package:animate_do/animate_do.dart';
import "package:flutter/material.dart";
import "package:get/get.dart";
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/app_colors.dart';
import '../controllers/usercontroller.dart';


class MyPassengers extends StatefulWidget {
  const MyPassengers({Key? key}) : super(key: key);

  @override
  State<MyPassengers> createState() => _MyPassengersState();
}

class _MyPassengersState extends State<MyPassengers> {
  final UserController userController = Get.find();
  var items;
  bool isBlocked = false;
  late List allBlockedUsers = [];
  late List blockedUsernames = [];
  bool isLoading = true;
  late Timer _timer;
  List passengersRequests = [];
  bool isSearching = false;
  bool hasData = false;

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
  Future<void> getPassengersRequest(String id)async {
    final passengerRequestLink = "https://taxinetghana.xyz/get_passengers_requests/$id/";
    var link = Uri.parse(passengerRequestLink);
    http.Response res = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    });
    if(res.statusCode == 200){
      var jsonData = jsonDecode(res.body);
      // print(jsonData.length);
      passengersRequests = jsonDecode(res.body);
      setState(() {
        isSearching = false;
        hasData = true;
      });
    }
  }

  @override
  void initState(){
    super.initState();
    fetchBlockedAgents();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchBlockedAgents();
    });
    // print(controller.allDrivers);
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor:Colors.transparent,
          elevation:0,
          title: const Text("Your Passengers",),
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon:const Icon(Icons.arrow_back,color:defaultTextColor2)
          ),
          actions: [
            IconButton(
                onPressed: () {
                  // Get.to(()=> const SearchDriver());
                },
                icon:const Icon(Icons.search,color:defaultTextColor2)
            )
          ],
        ),
        body:  GetBuilder<UserController>(builder:(controller){
          return ListView.builder(
            itemCount: controller.promoterPassengers != null ? controller.promoterPassengers.length : 0,
            itemBuilder: (BuildContext context, int index) {
              items = controller.promoterPassengers[index];
              return SlideInUp(
                animate:true,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: (){
                        // print(controller.allDrivers[index]['user']);
                        showMaterialModalBottomSheet(
                          context: context,
                          isDismissible: true,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.vertical(
                                  top: Radius.circular(25.0))),
                          bounce: true,
                          builder: (context) => SingleChildScrollView(
                            controller: ModalScrollController.of(context),
                            child: SizedBox(
                                height: 500,
                                child: Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: ListView(
                                      children: [
                                        const SizedBox(height:10),
                                        const Center(
                                            child: Text("Other Info",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold))
                                        ),
                                        ListTile(
                                            title: const Text("Email",),
                                            subtitle: Text(items['get_passengers_email'])
                                        ),
                                        const Divider(),
                                        // const SizedBox(height:5),
                                        ListTile(
                                            title: const Text("Phone Number",),
                                            subtitle: Text(items['get_passengers_phone_number'])
                                        ),
                                        ListTile(
                                            title: const Text("Next of kin",),
                                            subtitle: Text(items['next_of_kin'])
                                        ),
                                        // const SizedBox(height:5),
                                        const Divider(),
                                        // const SizedBox(height:5),
                                        ListTile(
                                            title: const Text("Next of kin number",),
                                            subtitle: Text(items['next_of_kin_number'])
                                        ),
                                        const Divider(),
                                        // const SizedBox(height:5),
                                        ListTile(
                                            title: const Text("Referral",),
                                            subtitle: Text(items['referral'])
                                        ),
                                        const Divider(),
                                        // const SizedBox(height:5),

                                        const Divider(),
                                        // const SizedBox(height:5),
                                        ListTile(
                                            title: const Text("Unique Code",),
                                            subtitle: Text(items['unique_code'])
                                        ),
                                      ],
                                    )
                                )
                            ),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(items['passenger_profile_pic']),
                      ),
                      title: Text(items['get_passengers_full_name']),
                      subtitle: Text(items['username']),
                      trailing:  IconButton(
                        onPressed: () async {
                          Get.snackbar("Please wait", "getting data",
                              duration: const Duration(seconds: 2),
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.grey,
                              colorText: defaultTextColor1);
                          getPassengersRequest(controller.promoterPassengers[index]['user'].toString());
                          await Future.delayed(const Duration(seconds: 3));
                          Get.snackbar("${controller.promoterPassengers[index]['username']}'s request", passengersRequests.length.toString(),
                              snackStyle: SnackStyle.FLOATING,
                              duration: const Duration(seconds: 2),
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.grey,
                              colorText: defaultTextColor1);
                        },
                        icon: const Icon(Icons.access_time_outlined)
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
