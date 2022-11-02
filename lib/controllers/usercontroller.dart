import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import '../constants/app_colors.dart';


class UserController extends GetxController {

  final storage = GetStorage();
  var username = "";
  String uToken = "";
  String promoterId = "";
  String promoterUsername = "";
  String profileImage = "";
  String nameOnGhanaCard = "";
  String email = "";
  String phoneNumber = "";
  String fullName = "";
  String nextOfKin = "";
  String nextOfKinPhoneNumber = "";
  String frontGhanaCard = "";
  String backGhanaCard = "";
  String referral = "";
  String uniqueCode = "";
  late bool verified;
  bool isVerified = false;
  late String updateUserName;
  late String updateEmail;
  late String updatePhone;
  bool isUpdating = true;
  var dio = Dio();
  bool hasUploadedFrontCard = false;
  bool hasUploadedBackCard = false;

  late List profileDetails = [];

  late List allUsers = [];
  late List phoneNumbers = [];
  late List driversUniqueCodes = [];
  late List allDrivers = [];
  late List driversNames = [];
  late List passengerNames = [];
  late List passengersUniqueCodes = [];
  late List allPassengers = [];
  List promoterPassengers = [];


  bool isLoading = true;
  bool isOpened = false;
  bool isUploading = false;
  late Timer _timer;
  File? image;


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    if (storage.read("userToken") != null) {
      uToken = storage.read("userToken");
    }
    if (storage.read("username") != null) {
      username = storage.read("username");
    }

  }

  File? profileImageUpload;
  File? frontCard;
  File? backCard;


  // Future getFromGalleryForProfilePic() async{
  //   try {
  //     final myImage  = await ImagePicker().pickImage(source: ImageSource.gallery);
  //     if(myImage == null) return;
  //     final imageTemporary = File(myImage.path);
  //     image = imageTemporary;
  //     update();
  //     if(image != null){
  //       _uploadAndUpdateProfilePic(image!);
  //     }
  //   } on PlatformException catch (e) {
  //     if (kDebugMode) {
  //       print("Error");
  //     }
  //   }
  //
  // }
  //
  // Future getFromCameraForProfilePic() async{
  //   try {
  //     final myImage  = await ImagePicker().pickImage(source: ImageSource.camera);
  //     if(myImage == null) return;
  //     final imageTemporary = File(myImage.path);
  //     image = imageTemporary;
  //     update();
  //     if(image != null){
  //       _uploadAndUpdateProfilePic(image!);
  //     }
  //   } on PlatformException catch (e) {
  //     if (kDebugMode) {
  //       print("Error");
  //     }
  //   }
  //
  // }

  //profile card


  // void _uploadAndUpdateProfilePic(File file) async {
  //   try {
  //     isUpdating = true;
  //     //updating user profile details
  //     String fileName = file.path.split('/').last;
  //     var formData1 = FormData.fromMap({
  //       'profile_pic':
  //       await MultipartFile.fromFile(file.path, filename: fileName),
  //     });
  //     var response = await dio.put(
  //       'https://taxinetghana.xyz/update_passenger_profile/',
  //       data: formData1,
  //       options: Options(headers: {
  //         "Authorization": "Token $uToken",
  //         "HttpHeaders.acceptHeader": "accept: application/json",
  //       }, contentType: Headers.formUrlEncodedContentType),
  //     );
  //     if (response.statusCode != 200) {
  //       Get.snackbar("Sorry", response.data.toString(),
  //           colorText: Colors.white,
  //           snackPosition: SnackPosition.BOTTOM,
  //           backgroundColor: Colors.red);
  //     } else {
  //       Get.snackbar("Hurray 😀", "Your profile picture was updated",
  //           colorText: Colors.white,
  //           snackPosition: SnackPosition.BOTTOM,
  //           backgroundColor: primaryColor,
  //           duration: const Duration(seconds: 5));
  //     }
  //   } on DioError catch (e) {
  //     Get.snackbar("Sorry", e.toString(),
  //         colorText: Colors.white,
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: snackColor);
  //   } finally {
  //     isUpdating = false;
  //   }
  // }


  Future<void> getUserProfile(String token) async {
    try {
      isLoading = true;
      update();
      const profileLink = "https://taxinetghana.xyz/promoter_profile/";
      var link = Uri.parse(profileLink);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $token"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        profileDetails = jsonData;
        for (var i in profileDetails) {
          profileImage = i['promoter_profile_pic'];
          email = i['get_email'];
          phoneNumber = i['get_phone_number'];
          fullName = i['get_full_name'];
          promoterId = i['user'].toString();
          promoterUsername = i['get_username'];
        }
        update();
        storage.write("verified", "Verified");
        storage.write("profile_id", promoterId);
        storage.write("profile_name", fullName);
        storage.write("profile_pic", profileImage);
        storage.write("passenger_username", promoterUsername);
      }
      else{
        if (kDebugMode) {
          print(response.body);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getMyPassengers(String token,String username) async {
    try {
      isLoading = true;
      update();
      final profileLink = "https://taxinetghana.xyz/get_all_my_passengers/$username/";
      var link = Uri.parse(profileLink);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $token"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        profileDetails = jsonData;
        promoterPassengers.assignAll(jsonData);

        update();
      }
      else{
        if (kDebugMode) {
          print(response.body);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  updateProfileDetails(String updateUserName, String updateEmail,String fullName, String updatePhone) async {
    const updateUrl = "https://taxinetghana.xyz/update_username/";
    final myUrl = Uri.parse(updateUrl);
    http.Response response = await http.put(
      myUrl,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $uToken"
      },
      body: {
        "username": updateUserName,
        "email": updateEmail,
        "full_name": fullName,
        "phone_number": updatePhone
      },
    );
    if (response.statusCode == 200) {
      Get.snackbar("Hurray 😀", "Your profile was updated",
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: primaryColor,
          colorText: defaultTextColor1);
      update();
      isUpdating = false;
    } else {
      Get.snackbar("Sorry 😢", response.body,
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: defaultTextColor1);
    }
  }

}
