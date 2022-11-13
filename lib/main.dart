import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import "package:get/get.dart";
import 'package:taxinet_promoter/splash.dart';

import 'controllers/commissioncontroller.dart';
import 'controllers/logincontroller.dart';
import 'controllers/registrationcontroller.dart';
import 'controllers/usercontroller.dart';
import 'controllers/walletcontroller.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await GetStorage.init();
  Get.put(MyLoginController());
  Get.put(MyRegistrationController());
  Get.put(UserController());
  Get.put(CommissionController());
  Get.put(WalletController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.leftToRight,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
