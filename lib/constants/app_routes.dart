
import 'package:flutter_attendance/modules/map/map_setting_screen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../modules/map/map_screen.dart';

class AppRoutes {
  static String map = '/map';
  static String mapSetting = '/map-setting';
}

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.map, page: () => MapScreen()),
    GetPage(name: AppRoutes.mapSetting, page: () => MapSettingScreen()),
  ];
}