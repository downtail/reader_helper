import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// @author yi1993
/// @created at 2022/4/15
/// @description: 网络请求通用widget

class DataBuilder<T> extends StatefulWidget {
  final Future<T?> Function() maker;
  final Widget Function(void Function() retryTask, T data) builder;
  final double? width;
  final double? height;
  final bool canRefresh;
  final bool canRetry;
  final void Function(Object? err)? errHandler;
  final Widget? emptyView;
  final Widget? errorView;
  final Widget? loadView;
  final bool isDialogMode;

  const DataBuilder({
    Key? key,
    required this.maker,
    required this.builder,
    this.width,
    this.height,
    this.canRefresh = false,
    this.canRetry = true,
    this.errHandler,
    this.emptyView,
    this.errorView,
    this.loadView,
    this.isDialogMode = false,
  }) : super(key: key);

  @override
  State createState() {
    return DataState<T>();
  }
}

class DataState<T> extends State<DataBuilder<T>> {
  late Future<T?> task;
  late double requiredWidth;
  late double requiredHeight;

  @override
  void initState() {
    super.initState();
    task = widget.maker();
    requiredWidth = widget.width ?? 0;
    requiredHeight = widget.height ?? 0;
  }

  void retryTask() {
    setState(() {
      task = widget.maker();
    });
  }

  @override
  void didUpdateWidget(covariant DataBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    task = widget.maker();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T?>(
      future: task,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none) {
          autoClose(context: context);
          return SizedBox(
            width: requiredWidth,
            height: requiredHeight,
            child: widget.emptyView,
          );
        } else if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.active) {
          return SizedBox(
            width: requiredWidth,
            height: requiredHeight,
            child: widget.loadView ??
                Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 6.w,
                  ),
                ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            autoClose(context: context);
            if (widget.errHandler != null) {
              widget.errHandler!(snapshot.error);
            }
            var err = snapshot.error;
            if (err is DioError) {}
            return SizedBox(
              width: requiredWidth,
              height: requiredHeight,
              child: GestureDetector(
                onTap: () {
                  if (widget.canRetry) {
                    retryTask();
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: Center(
                  child: widget.errorView,
                ),
              ),
            );
          } else {
            T? data = snapshot.data;
            if (data == null) {
              autoClose(context: context);
              return SizedBox(
                width: requiredWidth,
                height: requiredHeight,
                child: widget.emptyView,
              );
            }
            return ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: requiredWidth,
                minHeight: requiredHeight,
              ),
              child: widget.canRefresh
                  ? GestureDetector(
                      onTap: () {
                        retryTask();
                      },
                      child: widget.builder(retryTask, data),
                    )
                  : widget.builder(retryTask, data),
            );
          }
        } else {
          autoClose(context: context);
          if (widget.emptyView != null) {
            return widget.emptyView!;
          }
          return SizedBox(
            width: requiredWidth,
            height: requiredHeight,
          );
        }
      },
    );
  }

  void autoClose({
    required BuildContext context,
  }) {
    if (widget.isDialogMode) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.of(context).pop(null);
      });
    }
  }
}
