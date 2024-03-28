import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController extends GetxController {
  Completer<GoogleMapController> googleMapController = Completer();
  // List<Placemark> placeAddress = [];
  Position? defaultPosition;
  List<Position> nearbyPositionList = [];
  dynamic markers;

  bool statusPermission = false;
  bool isLoading = false;

  @override
  void onInit() async {
    await getCurrentLocation();
    super.onInit();
  }

  Future<bool> getPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      Geolocator.openLocationSettings();
      return false;
    }
    return true;
  }

  Future<void> getCurrentLocation() async {
    statusPermission = await getPermission();
    if (statusPermission) {
      defaultPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      markers = {
        Marker(markerId: MarkerId('0'), position: LatLng(defaultPosition!.latitude, defaultPosition!.longitude)),
      };
      // await getAddress();
    }

    update();
  }

  Future<void> getNearbyArea({required String areaName}) async {
    triggeredLoading();

    // listMap = await api.getNearestArea(
    //     longitude: defaultPosition!.longitude, latitude: defaultPosition!.latitude, areaName: areaName);
    //
    // convertMarkers();

    triggeredLoading();
    update();
  }

  void triggeredLoading() {
    isLoading = !isLoading;
    update();
  }

}