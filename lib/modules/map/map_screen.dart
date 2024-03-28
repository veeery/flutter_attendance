import 'package:flutter/material.dart';
import 'package:flutter_attendance/controllers/map_controller.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants/app_size_utils.dart';

class MapScreen extends StatelessWidget {
  final MapController controller = Get.find<MapController>();

  @override
  Widget build(BuildContext context) {
    AppSizeUtil.init(context: context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () {
          controller.stopLocationUpdates();
          Get.back();
          return Future.value(true);
        },
        child: SafeArea(
          child: SizedBox(
            width: 100.w,
            height: 100.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                GetBuilder<MapController>(
                  builder: (_) {
                    return SizedBox(
                      width: 100.w,
                      height: 100.h,
                      child: Stack(
                        children: [
                          buildMapView(),
                          if (controller.markLocation == null) buildSetUpLocation(),
                          if (controller.markLocation != null) buildAbsentByRadius(),
                          if (controller.markLocation != null) buildWidgetAbsentManual(),
                          if (controller.markLocation != null) buildStatusAbsent(),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMapView() {
    return GoogleMap(
      markers: controller.markers,
      mapType: MapType.normal,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      initialCameraPosition: CameraPosition(
          target: LatLng(controller.defaultPosition!.latitude, controller.defaultPosition!.longitude), zoom: 14.476),
      onMapCreated: (GoogleMapController googleController) {
        controller.googleMapController.complete(googleController);
        controller.startLocationUpdates1(googleController);
        // controller.startLocationUpdates();
      },
      circles: {
        if (controller.markers.isNotEmpty)
          Circle(
            circleId: CircleId('markerCircle'),
            center: controller.markers.first.position,
            radius: int.parse(controller.radiusText.text).toDouble(),
            fillColor: Colors.red.withOpacity(0.5),
            strokeColor: Colors.red,
            strokeWidth: 1,
          ),
      },
      onTap: (LatLng location) {
        if (controller.markLocation != null) return;
        controller.markers.clear();
        Marker marker = Marker(
          markerId: MarkerId(location.toString()),
          position: location,
        );
        controller.updateMarkers(marker: marker, latLng: location);
      },
    );
  }

  Widget buildWidgetAbsentManual() {
    return Positioned(
      bottom: 9.h,
      left: 5.w,
      child: Container(
        width: 80.w,
        height: 5.h,
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(1.h),
        ),
        child: TextButton(
          child: Text('Absent Manual', style: TextStyle(color: Colors.black)),
          onPressed: () async {
            bool status = await controller.absentManual();
            if (status) {
              Get.snackbar('Berhasil', 'Anda Dalam radius', backgroundColor: Colors.green, colorText: Colors.white);
            } else {
              Get.snackbar('Error', 'Tidak dalam radius', backgroundColor: Colors.red, colorText: Colors.white);
            }
          },
        ),
      ),
    );
  }

  Widget buildAbsentByRadius() {
    return Positioned(
      bottom: 2.5.h,
      left: 5.w,
      child: Container(
        width: 80.w,
        height: 5.h,
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(1.h),
        ),
        child: TextButton(
          child: Text('Abort Location', style: TextStyle(color: Colors.black)),
          onPressed: () {
            controller.stopLocationUpdates();
          },
        ),
      ),
    );
  }

  Widget buildStatusAbsent() {
    return Positioned(
      top: 1.6.h,
      left: 5.w,
      child: Container(
        width: 80.w,
        height: 10.h,
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(1.h),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('You Pinned Location'),
            Text('latitude :${controller.markLocation?.position.latitude}'),
            Text('longitude :${controller.markLocation?.position.longitude}'),
            Text('Message : ${controller.message}'),
            controller.statusAbsent
                ? Text('Absent dapat dilakukan', style: TextStyle(color: Colors.green))
                : Text('Absent Tidak dapat dilakukan', style: TextStyle(color: Colors.red)),
            // Text('Status Absent  : ${controller.statusAbsent ? 'Absent' : 'Present'}'),
          ],
        ),
      ),
    );
  }

  Widget buildSetUpLocation() {
    return Positioned(
      bottom: 7.h,
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
            TextButton(
                onPressed: () {
                  Get.defaultDialog(
                    title: 'Set Up Location',
                    content: Column(
                      children: [
                        Text('Are you sure to set up this location?'),
                        SizedBox(height: 2.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () async {
                                Get.back();

                                bool status = await controller.captureLocationMarker(
                                    withCurrentData: controller.markers.first.markerId.value == 'list' ? true : false);

                                if (status) {
                                  Get.snackbar('Success', 'Location has been set up',
                                      backgroundColor: Colors.green[200]);
                                } else {
                                  Get.snackbar('Error', 'Failed to set up location', backgroundColor: Colors.red[200]);
                                }
                              },
                              child: Text('Yes'),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text('No'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                child: Text('OK')),
          ],
        ),
      ),
    );
  }
}
