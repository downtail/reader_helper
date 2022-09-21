import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:reader_helper/app/app_controller.dart';
import 'package:reader_helper/entity/book_entity.dart';
import 'package:reader_helper/http/data_builder.dart';
import 'package:reader_helper/http/data_manager.dart';
import 'package:reader_helper/ui/chapter_entity.dart';
import 'package:reader_helper/ui/helper_page.dart';

/// @author yi1993
/// @created at 2022/5/10
/// @description:
class ChapterWidget extends StatefulWidget {
  final BookEntity book;

  const ChapterWidget({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  State<ChapterWidget> createState() => _ChapterWidgetState();
}

class _ChapterWidgetState extends State<ChapterWidget> with AutomaticKeepAliveClientMixin {
  late AppController appController;

  @override
  void initState() {
    super.initState();
    appController = Get.find<AppController>();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.book.path == null) {
      return const SizedBox.expand();
    }
    return DataBuilder<List<ChapterEntity>>(
      maker: () => DataManager().getBookChapters(
        book: widget.book,
        method: appController.targetMethod.value,
      ),
      builder: (retryTask, data) {
        return Scrollbar(
          thumbVisibility: true,
          thickness: 20.w,
          child: ListView.separated(
            padding: EdgeInsets.all(
              60.w,
            ),
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              var chapter = data[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HelperPage(
                        book: widget.book,
                        chapters: data,
                        position: index,
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  height: 100.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          chapter.chapterName ?? '',
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(
                height: 20.w,
              );
            },
            itemCount: data.length,
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive {
    return true;
  }
}
