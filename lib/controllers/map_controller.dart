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

  bool statusAbsent = false;
  String message = 'Memproses...';

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

        // Calculate distance every time user location updated or moved
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

  Future<bool> absentManual() async {
    checkUserInMarkLocation(
      userLocation: LatLng(defaultPosition!.latitude, defaultPosition!.longitude),
      markLocation: markLocation!.position,
    );
    update();
    return statusAbsent;
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
      statusAbsent = true;
    } else {
      message = 'User LUAR radius.';
      statusAbsent = false;
    }
  }

  void stopLocationUpdates() {
    // if (positionStreamSubscription != null) {
    //   positionStreamSubscription!.cancel();
    //   positionStreamSubscription = null;
    // }
    // if (positionStreamSubscription != null) {
    //   positionStreamSubscription!.cancel();
    // }
    markLocation = null;
    update();
  }

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
    }
    triggeredLoading();
  }

  void updateMarkers({required Marker marker, required LatLng latLng}) {
    markers.add(marker);
    selectedPosition = latLng;
    print("markers: $markers");
    update();
  }

  Future<bool> captureLocationMarker({bool withCurrentData = false}) async {
    triggeredLoading();

    if (withCurrentData) {
      markLocation =
          Marker(markerId: MarkerId('1'), position: LatLng(defaultPosition!.latitude, defaultPosition!.longitude));
      updateMarkers(marker: markLocation!, latLng: selectedPosition!);

      // calculate distance when user click the button
      checkUserInMarkLocation(
        userLocation: LatLng(defaultPosition!.latitude, defaultPosition!.longitude),
        markLocation: markLocation!.position,
      );

      triggeredLoading();
      return true;
    } else {
      if (selectedPosition != null) {
        markLocation = Marker(markerId: MarkerId('1'), position: selectedPosition!);

        // calculate distance when user click the button
        checkUserInMarkLocation(
          userLocation: LatLng(defaultPosition!.latitude, defaultPosition!.longitude),
          markLocation: markLocation!.position,
        );

        updateMarkers(marker: markLocation!, latLng: selectedPosition!);
        triggeredLoading();
        return true;
      }
    }

    triggeredLoading();
    return false;
  }

  void triggeredLoading() {
    isLoading = !isLoading;
    update();
  }
}
