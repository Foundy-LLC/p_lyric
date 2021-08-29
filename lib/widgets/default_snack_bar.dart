import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<T?>? showSnackBar<T>(
  String message, {
  Duration duration = const Duration(seconds: 3),
}) async {
  return Get.showSnackbar<T>(DefaultSnackBar(
    message: message,
    duration: duration,
  ));
}

class DefaultSnackBar extends GetBar {
  DefaultSnackBar({
    Key? key,
    required String message,
    required Duration duration,
  }) : super(
          messageText: Text(
            message,
            style: Get.textTheme.bodyText2!.copyWith(
              height: 1.6,
              color: Colors.white,
            ),
          ),
          animationDuration: const Duration(milliseconds: 500),
          duration: duration,
          key: key,
        );
}
