import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CommissionController extends GetxController{
  List commissions = [];
  bool isLoading = true;

  Future<void> getAllCommission(String token) async {
    try{
      isLoading = true;
      const url = "https://taxinetghana.xyz/get_promoter_commission/";
      var myLink = Uri.parse(url);
      final response =
      await http.get(myLink, headers: {"Authorization": "Token $token"});
      if (response.statusCode == 200) {
        final codeUnits = response.body.codeUnits;
        var jsonData = const Utf8Decoder().convert(codeUnits);
        commissions = json.decode(jsonData);
        update();
      } else {
        if (kDebugMode) {
          // print(response.body);
        }
      }
    }
    catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    finally {
      isLoading = false;
    }
  }
}