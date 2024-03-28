import 'package:flutter/material.dart';
import 'package:flutter_attendance/controllers/map_controller.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants/app_size_utils.dart';

class MapScreen extends StatelessWidget {
  final MapController controller = Get.put(MapController());

  @override
  Widget build(BuildContext context) {
    AppSizeUtil.init(context: context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          width: 100.w,
          height: 100.h,
          child: Stack(
            children: [
              GetBuilder<MapController>(
                builder: (controller) {
                  if (!controller.statusPermission) return Text('Permission Denied');
                  return GoogleMap(
                    markers: controller.markers,
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(controller.defaultPosition!.latitude, controller.defaultPosition!.longitude),
                        zoom: 14.476),
                    onMapCreated: (GoogleMapController googleController) {
                      controller.googleMapController.complete(googleController);
                    },
                  );
                },
              )
              // GoogleMap(initialCameraPosition: CameraPosition(target: LatLng(0, 0), zoom: 14.476)),
            ],
          ),
        ),
      ),
    );
  }

// Widget MapView() {
//   return SizedBox(
//     width: 100.w,
//     height: 100.h,
//     child: Stack(
//       children: [
//         GoogleMap(
//           markers: controller.markers,
//           mapType: MapType.normal,
//           myLocationEnabled: true,
//           initialCameraPosition: CameraPosition(
//               target: LatLng(controller.defaultPosition!.latitude, controller.defaultPosition!.longitude),
//               zoom: 14.476),
//           onMapCreated: (GoogleMapController googleController) {
//             controller.googleMapController.complete(googleController);
//           },
//         ),
//         Positioned(
//           top: 1.4.h,
//           left: 2.w,
//           child: AppButton(
//             title: "Hospital",
//             onTap: () async => await controller.getNearbyArea(areaName: "hospital"),
//           ),
//         ),
//         Positioned(
//           top: 1.4.h,
//           left: 25.w,
//           child: AppButton(
//             title: "Restaurant",
//             onTap: () async => await controller.getNearbyArea(areaName: "restaurant"),
//           ),
//         ),
//         Positioned(
//           bottom: 2.1.h,
//           left: 2.w,
//           child: MapAddress(),
//         ),
//         controller.isLoading ? const AppLoading() : Container(),
//       ],
//     ),
//   );
// }
}
