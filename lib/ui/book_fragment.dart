import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:reader_helper/app/app_controller.dart';
import 'package:reader_helper/app/db_manager.dart';
import 'package:reader_helper/custom_colors.dart';
import 'package:reader_helper/entity/book_entity.dart';
import 'package:reader_helper/entity/db/collect_entity.dart';
import 'package:reader_helper/http/data_manager.dart';
import 'package:reader_helper/http/http_dialog.dart';
import 'package:reader_helper/ui/chapter_entity.dart';
import 'package:reader_helper/ui/helper_page.dart';
import 'package:reader_helper/ui/search_page.dart';

/// @author yi1993
/// @created at 2022/5/7
/// @description: 书架
class BookFragment extends StatefulWidget {
  const BookFragment({Key? key}) : super(key: key);

  @override
  State<BookFragment> createState() => _BookFragmentState();
}

class _BookFragmentState extends State<BookFragment> with AutomaticKeepAliveClientMixin {
  late AppController appController;
  final ValueNotifier<bool> removeNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    appController = Get.find<AppController>();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          left: 0,
          top: kToolbarHeight + MediaQuery.of(context).padding.top,
          right: 0,
          bottom: kBottomNavigationBarHeight,
          child: _getBookView(),
        ),
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          height: kToolbarHeight + MediaQuery.of(context).padding.top,
          child: _getTopView(),
        ),
        ValueListenableBuilder<bool>(
            valueListenable: removeNotifier,
            builder: (context, data, child) {
              return Visibility(
                visible: data,
                child: Positioned(
                  left: 0,
                  right: 0,
                  bottom: kBottomNavigationBarHeight,
                  height: 200.w,
                  child: DragTarget<CollectEntity>(
                    builder: (
                      context,
                      candidateData,
                      rejectedData,
                    ) {
                      return Container(
                        width: MediaQuery.of(context).size.height,
                        height: 200.w,
                        decoration: const BoxDecoration(color: Colors.red),
                        child: const Center(
                          child: Text(
                            '删除?',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                    onWillAccept: (data) => true,
                    onAccept: (data) async {
                      await DbManager().deleteCollect(
                        book: data.book,
                      );
                      List<CollectEntity>? list = await DbManager().getCollect();
                      appController.setBooks(data: list ?? []);
                    },
                  ),
                ),
              );
            }),
      ],
    );
  }

  @override
  bool get wantKeepAlive {
    return true;
  }

  Widget _getTopView() {
    return Container(
      width: double.infinity,
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              height: kToolbarHeight,
              margin: EdgeInsets.only(
                top: 40.w,
                bottom: 40.w,
                left: 100.w,
                right: 100.w,
              ),
              decoration: BoxDecoration(
                color: CustomColors.colorF5F5F5,
                borderRadius: BorderRadius.circular(
                  60.w,
                ),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const SearchPage();
                      },
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 80.w,
                      ),
                      child: const Icon(
                        Icons.search,
                        color: CustomColors.color999999,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 80.w,
                      ),
                      child: const Text(
                        '搜索',
                        style: TextStyle(
                          fontSize: 14,
                          color: CustomColors.color999999,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getBookView() {
    return Container(
      color: CustomColors.colorF0F0F0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(
            () => Expanded(
              child: GridView.builder(
                itemCount: appController.books.length,
                padding: EdgeInsets.only(
                  left: 20.w,
                  top: 40.w,
                  right: 20.w,
                  bottom: 80.w,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 30.w,
                  crossAxisSpacing: 30.w,
                  mainAxisExtent: 720.w,
                ),
                itemBuilder: (context, index) {
                  var book = appController.books[index];
                  var item = BookEntity.fromJson(json.decode(book.data));
                  var child = InkWell(
                    onTap: () {
                      openTargetBook(
                        item: appController.books[index],
                        book: item,
                      );
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30.w,
                        ),
                      ),
                      elevation: 10.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          item.picUrl == null
                              ? SvgPicture.asset(
                                  'assets/blank.svg',
                                  width: double.infinity,
                                  height: 500.w,
                                  fit: BoxFit.cover,
                                )
                              : Image(
                                  image: CachedNetworkImageProvider(item.picUrl!),
                                  width: double.infinity,
                                  height: 500.w,
                                  fit: BoxFit.cover,
                                ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(
                              left: 20.w,
                              top: 20.w,
                              right: 20.w,
                            ),
                            child: Text(
                              '${item.name}',
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(
                              left: 20.w,
                              top: 20.w,
                              right: 20.w,
                            ),
                            child: Text(
                              '作者：${item.author}',
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  return LongPressDraggable<CollectEntity>(
                    feedback: SizedBox(
                      width: (MediaQuery.of(context).size.width - 100.w) / 3,
                      height: 720.w,
                      child: Material(
                        color: Colors.transparent,
                        child: child,
                      ),
                    ),
                    childWhenDragging: const SizedBox.shrink(),
                    child: child,
                    data: appController.books[index],
                    onDragStarted: () {
                      removeNotifier.value = true;
                    },
                    onDragEnd: (details) {
                      removeNotifier.value = false;
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  openTargetBook({
    required CollectEntity item,
    required BookEntity book,
  }) async {
    int? bookOriginal = book.original;
    String bookPath = book.path!;
    int methodCode = bookOriginal ?? 0;
    if (bookOriginal == null || bookOriginal == 0) {
      if (bookPath.startsWith('https://book.qidian.com/info/')) {
        methodCode = 1;
      } else if (bookPath.startsWith('https://www.biqugesk.org/biquge/')) {
        methodCode = 2;
      }
      if (bookOriginal != methodCode) {
        book.original = methodCode;
        item.data = json.encode(book.toJson());
        await DbManager().modifyOriginal(
          item: item,
        );
      }
    }
    var targetMethod = appController.getTargetMethod(
      code: methodCode,
    );
    if (targetMethod == null) {
      Fluttertoast.showToast(msg: '获取资源失败');
      return;
    }
    var data = await requestByDialog<List<ChapterEntity>>(
      context: context,
      maker: () => DataManager().getBookChapters(
        book: book,
        method: targetMethod,
      ),
    );
    if (data == null) {
      Fluttertoast.showToast(msg: '获取章节失败');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HelperPage(
          book: book,
          chapters: data,
        ),
      ),
    );
  }
}
