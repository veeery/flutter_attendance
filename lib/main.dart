import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'constants/app_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: AppRoutes.mapSetting,
      getPages: AppPages.pages,
    );
  }
}
