import 'package:get/get_navigation/src/routes/get_route.dart';

import '../modules/map/map_screen.dart';

class AppRoutes {
  static String map = '/map';
}

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.map, page: () => MapScreen()),
  ];
}