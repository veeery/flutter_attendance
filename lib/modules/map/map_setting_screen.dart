import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_attendance/constants/app_size_utils.dart';
import 'package:get/get.dart';

import '../../constants/app_routes.dart';
import '../../controllers/map_settings_controller.dart';

class MapSettingScreen extends StatelessWidget {
  final MapSettingController controller = Get.put(MapSettingController());

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
              GetBuilder<MapSettingController>(
                builder: (controller) {
                  return Container(
                    width: 100.w,
                    height: 100.h,
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (int.parse(controller.radiusText.text) == 0) {
                              Get.snackbar('Error', 'Please set up location first', backgroundColor: Colors.red[200]);
                            } else {
                              Get.toNamed(AppRoutes.map, arguments: controller.radiusText.text);
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
                                  Get.snackbar('Error', 'Please set up location first', backgroundColor: Colors.red[200]);
                                } else {
                                  Get.snackbar('Success', 'Location has been set up', backgroundColor: Colors.green[200]);
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
