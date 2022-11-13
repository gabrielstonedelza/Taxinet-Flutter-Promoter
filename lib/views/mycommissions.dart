import 'package:animate_do/animate_do.dart';
import "package:flutter/material.dart";
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../constants/app_colors.dart';
import '../controllers/commissioncontroller.dart';

class MyCommissions extends StatefulWidget {

  const MyCommissions({Key? key}) : super(key: key);

  @override
  State<MyCommissions> createState() => _MyCommissionsState();
}

class _MyCommissionsState extends State<MyCommissions> {
  var items;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text("Commissions"),
          backgroundColor:primaryColor,
        ),
        backgroundColor: primaryColor,
        body: GetBuilder<CommissionController>(builder:(salaryController){
          return ListView.builder(
              itemCount: salaryController.commissions != null ? salaryController.commissions.length : 0,
              itemBuilder: (context,index){
                items = salaryController.commissions[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10,),
                  child: SlideInUp(
                    animate: true,
                    child: Card(
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(

                            leading: const Icon(Icons.access_time_filled),
                            title: Padding(
                              padding: const EdgeInsets.only(top:8.0),
                              child: Text("₵${items['amount']}",style:const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top:10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom:10.0),
                                    child: Text(items['date_paid']),
                                  ),
                                  Text(items['time_paid'].toString().split(".").first),
                                ],
                              ),
                            )
                        )
                    ),
                  ),
                );
              }
          );
        })
    );
  }
}
