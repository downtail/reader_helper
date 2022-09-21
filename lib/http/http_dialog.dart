import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reader_helper/http/data_builder.dart';

/// @author yi1993
/// @created at 2022/5/6
/// @description:

Future<T?> requestByDialog<T>({
  required BuildContext context,
  required Future<T?> Function() maker,
}) async {
  var data = await showDialog<T>(
    context: context,
    builder: (context) => UnconstrainedBox(
      child: Container(
        width: 400.w,
        height: 400.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            20.w,
          ),
          color: Colors.white,
        ),
        child: DataBuilder<T>(
          width: 400.w,
          height: 400.w,
          maker: maker,
          builder: (retryTask, data) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.of(context).pop(data);
            });
            return const SizedBox.shrink();
          },
          isDialogMode: true,
        ),
      ),
    ),
    barrierDismissible: false,
    barrierColor: Colors.black38,
  );
  return data;
}
