import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController extends GetxController {
  Completer<GoogleMapController> googleMapController = Completer();
  StreamSubscription<Position>? positionStreamSubscription;
  Position? defaultPosition;

  dynamic markers;
  Marker? markLocation;
  Marker? myLocation;
  LatLng? selectedPosition;

  bool statusPermission = false;
  bool isLoading = false;

  String message = '';

  TextEditingController radiusText = TextEditingController();

  @override
  void onInit() async {
    await getPermission();
    super.onInit();
  }

  void startLocationUpdates1(GoogleMapController googleController) {
    final geolocator = GeolocatorPlatform.instance;
    update();
    positionStreamSubscription = geolocator.getPositionStream().listen(
      (Position position) {
        update();

        print('Updated location: $position');
        defaultPosition = position;

        if (markLocation != null) {
          checkUserInMarkLocation(
            userLocation: LatLng(position.latitude, position.longitude),
            markLocation: markLocation!.position,
          );
          update();
        }
      },
    );
  }

  double calculateDistance(LatLng position, LatLng markLocation) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((markLocation.latitude - position.latitude) * p) / 2 +
        c(position.latitude * p) *
            c(markLocation.latitude * p) *
            (1 - c((markLocation.longitude - position.longitude) * p)) /
            2;

    return 12742 * asin(sqrt(a));
  }

  void checkUserInMarkLocation({required LatLng userLocation, required LatLng markLocation}) {
    double distance = calculateDistance(userLocation, markLocation) * 1000;

    if (distance <= int.parse(radiusText.text)) {
      message = 'User DALAM radius.';
    } else {
      message = 'User LUAR radius.';
    }
  }

  void startLocationUpdates() {
    positionStreamSubscription = Geolocator.getPositionStream(
            locationSettings:
                LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: int.parse(radiusText.text)))
        .listen(
      (Position position) {
        print('Updated location: $position');
        defaultPosition = position;

        if (markLocation != null) {
          double _degreeToRadian(double degree) {
            return degree * pi / 180;
          }

          final userLatLng = LatLng(position.latitude, position.longitude);

          final centerLatLng = LatLng(markLocation!.position.latitude, markLocation!.position.longitude);

          final dLat = _degreeToRadian(centerLatLng.latitude - userLatLng.latitude);
          final dLon = _degreeToRadian(centerLatLng.longitude - userLatLng.latitude);

          final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(_degreeToRadian(userLatLng.latitude)) *
                  cos(_degreeToRadian(centerLatLng.latitude)) *
                  sin(dLon / 2) *
                  sin(dLon / 2);
          final c = 2 * atan2(sqrt(a), sqrt(1 - a));

          final distance = 6371000 * c;

          // user in area
          if (distance <= int.parse(radiusText.text)) {
            message = 'You entered the area';
          } else {
            // user out of area
            message = 'You exited the area';
          }
        }

        print('checkUserInMarkLocation 8');
      },
    );
  }

  // void stopLocationUpdates() {
  //   if (positionStreamSubscription != null) {
  //     positionStreamSubscription!.cancel();
  //     positionStreamSubscription = null;
  //   }
  // }
  //
  // @override
  // void dispose() {
  //   if (positionStreamSubscription != null) {
  //     positionStreamSubscription!.cancel();
  //   }
  //   super.dispose();
  // }

  void goToLocation(LatLng latLng) async {
    final GoogleMapController controller = await googleMapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  Future<bool> getPermission() async {
    triggeredLoading();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        statusPermission = false;
        triggeredLoading();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      Geolocator.openLocationSettings();
      statusPermission = false;
      triggeredLoading();
      return false;
    }
    statusPermission = true;
    triggeredLoading();
    return true;
  }

  Future<void> getCurrentLocation() async {
    triggeredLoading();
    // statusPermission = await getPermission();
    if (statusPermission) {
      defaultPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      markers = {
        Marker(markerId: MarkerId('list'), position: LatLng(defaultPosition!.latitude, defaultPosition!.longitude)),
      };
      // markers = Marker(markerId: MarkerId('list'), position: LatLng(defaultPosition!.latitude, defaultPosition!.longitude)),
      myLocation = Marker(
          markerId: MarkerId('myLocation'), position: LatLng(defaultPosition!.latitude, defaultPosition!.longitude));
      // await getAddress();
    }
    triggeredLoading();
  }

  void updateMarkers({required Marker marker, required LatLng latLng}) {
    markers.add(marker);
    selectedPosition = latLng;
    print("markers: $markers");
    update();
  }

  Future<bool> captureLocationMarker() async {
    triggeredLoading();
    if (selectedPosition != null) {
      markLocation = Marker(markerId: MarkerId('1'), position: selectedPosition!);
      updateMarkers(marker: markLocation!, latLng: selectedPosition!);
      triggeredLoading();
      return true;
    }
    triggeredLoading();
    return false;
  }

  void triggeredLoading() {
    isLoading = !isLoading;
    update();
  }
}
