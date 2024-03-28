import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_attendance/constants/app_size_utils.dart';
import 'package:flutter_attendance/controllers/map_controller.dart';
import 'package:get/get.dart';

import '../../constants/app_routes.dart';

class MapSettingScreen extends StatelessWidget {
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
            alignment: Alignment.center,
            children: [
              GetBuilder<MapController>(
                builder: (_) {
                  if (!controller.statusPermission) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on),
                        const Text('Please enable location service'),
                        TextButton(
                            onPressed: () async => await controller.getPermission(), child: Text('Go to Setting'))
                      ],
                    );
                  }
                  if (controller.isLoading) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        SizedBox(height: 2.h),
                        const Text('Loading...'),
                      ],
                    );
                  }
                  return Container(
                    width: 100.w,
                    height: 100.h,
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (int.parse(controller.radiusText.text) == 0) {
                              Get.snackbar('Error', 'Please set up location first', backgroundColor: Colors.red[200]);
                            } else {
                              if (controller.statusPermission) {
                                await controller.getCurrentLocation();
                                // controller.startLocationUpdates();
                                Get.toNamed(AppRoutes.map);
                              }
                              ;
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                          ),
                          child: SizedBox(width: 100.w, child: Text('Set Up Location')),
                        ),
                        TextField(
                          controller: controller.radiusText,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            hintText: 'exp: 50 meter',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2.w),
                              borderSide: BorderSide(color: Colors.red, width: 2.w),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                if (int.parse(controller.radiusText.text) == 0) {
                                  Get.snackbar('Error', 'Please set up location first',
                                      backgroundColor: Colors.red[200]);
                                } else {
                                  Get.snackbar('Success', 'Location has been set up',
                                      backgroundColor: Colors.green[200]);
                                }
                              },
                              icon: Text('OK'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
