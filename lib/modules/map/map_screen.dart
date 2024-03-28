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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: 100.w,
          height: 100.h,
          child: Stack(
            children: [
              GetBuilder<MapController>(
                builder: (controller) {
                  // if (controller.markers == null) return Text('Set Up Location');
                  if (!controller.statusPermission) return Text('Permission Denied');
                  // return mapView();
                  return SizedBox(
                    width: 100.w,
                    height: 100.h,
                    child: Stack(
                      children: [
                        GoogleMap(
                          markers: controller.markers,
                          mapType: MapType.normal,
                          myLocationEnabled: true,
                          initialCameraPosition: CameraPosition(
                              target:
                                  LatLng(controller.defaultPosition!.latitude, controller.defaultPosition!.longitude),
                              zoom: 14.476),
                          onMapCreated: (GoogleMapController googleController) {
                            controller.googleMapController.complete(googleController);
                          },
                          circles: Set.from([
                            if (controller.markers.isNotEmpty)
                              Circle(
                                circleId: CircleId('myCircle'),
                                center: controller.markers.first.position,
                                // Mengikuti posisi marker pertama
                                radius: 1000,
                                // radius dalam meter
                                fillColor: Colors.red.withOpacity(0.5),
                                strokeColor: Colors.red,
                                strokeWidth: 1,
                              ),
                          ]),
                          onTap: (LatLng location) {
                            controller.markers.clear();
                            Marker marker = Marker(
                              markerId: MarkerId(location.toString()),
                              position: location,
                            );
                            controller.updateMarkers(marker: marker);
                          },
                        ),
                        Positioned(
                          bottom: 2.5.h,
                          left: 5.w,
                          child: Container(
                            width: 80.w,
                            height: 5.h,
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(1.h),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Set Up this Location?'),
                                TextButton(onPressed: () {}, child: Text('OK')),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mapView() {
    return SizedBox(
      width: 100.w,
      height: 100.h,
      child: Stack(
        children: [
          GoogleMap(
            markers: controller.markers,
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
                target: LatLng(controller.defaultPosition!.latitude, controller.defaultPosition!.longitude),
                zoom: 14.476),
            onMapCreated: (GoogleMapController googleController) {
              controller.googleMapController.complete(googleController);
            },
            onTap: (LatLng location) {
              controller.markers.clear();
              Marker marker = Marker(
                markerId: MarkerId(location.toString()),
                position: location,
              );
              controller.updateMarkers(marker: marker);
            },
          ),
        ],
      ),
    );
  }
}
