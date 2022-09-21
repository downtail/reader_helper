import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:reader_helper/app/app_controller.dart';
import 'package:reader_helper/app/db_manager.dart';
import 'package:reader_helper/custom_colors.dart';
import 'package:reader_helper/entity/book_entity.dart';
import 'package:reader_helper/entity/db/collect_entity.dart';
import 'package:reader_helper/entity/db/record_entity.dart';
import 'package:reader_helper/http/data_builder.dart';
import 'package:reader_helper/http/data_manager.dart';
import 'package:reader_helper/http/http_dialog.dart';
import 'package:reader_helper/ui/chapter_entity.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// @author yi1993
/// @created at 2022/5/12
/// @description: 阅读页面
class HelperPage extends StatefulWidget {
  final BookEntity book;
  final List<ChapterEntity> chapters;
  final int? position;

  const HelperPage({
    Key? key,
    required this.book,
    required this.chapters,
    this.position,
  }) : super(key: key);

  @override
  State<HelperPage> createState() => _HelperPageState();
}

class _HelperPageState extends State<HelperPage> {
  late BookEntity mBook;
  late List<ChapterEntity> mChapters;
  late int? mPosition;
  late ItemScrollController itemScrollController;
  late ItemPositionsListener itemPositionsListener;
  late ItemScrollController chapterScrollController;
  late ValueNotifier<int> indexNotifier;
  late AppController appController;
  bool isRecurrence = true;
  late ValueNotifier<bool> _menuNotifier;

  @override
  void initState() {
    super.initState();
    mBook = widget.book;
    mChapters = widget.chapters;
    mPosition = widget.position;
    itemScrollController = ItemScrollController();
    itemPositionsListener = ItemPositionsListener.create();
    itemPositionsListener.itemPositions.addListener(() {
      setLocation();
    });
    chapterScrollController = ItemScrollController();
    indexNotifier = ValueNotifier(mPosition ?? 0);
    _menuNotifier = ValueNotifier(false);
    appController = Get.find<AppController>();
    modifyLatestTime();
  }

  modifyLatestTime() async {
    CollectEntity? item = await DbManager().isCollect(
      book: mBook.name!,
    );
    if (item != null) {
      item.sort = DateTime.now().millisecondsSinceEpoch;
      await DbManager().modifyOriginal(
        item: item,
      );
    }
    List<CollectEntity>? data = await DbManager().getCollect();
    appController.setBooks(data: data ?? []);
  }

  modifyOriginal() async {
    CollectEntity? item = await DbManager().isCollect(
      book: mBook.name!,
    );
    if (item != null) {
      item.data = json.encode(mBook.toJson());
      await DbManager().modifyOriginal(
        item: item,
      );
    }
    List<CollectEntity>? data = await DbManager().getCollect();
    appController.setBooks(data: data ?? []);
  }

  setLocation() async {
    var positions = itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      // Determine the first visible item by finding the item with the
      // smallest trailing edge that is greater than 0.  i.e. the first
      // item whose trailing edge in visible in the viewport.
      var itemPosition = positions
          .where((ItemPosition position) => position.itemTrailingEdge > 0)
          .reduce((ItemPosition min, ItemPosition position) => position.itemTrailingEdge < min.itemTrailingEdge ? position : min);
      indexNotifier.value = itemPosition.index;
      RecordEntity? item = await DbManager().isRecord(
        book: mBook.name!,
      );
      if (item == null || item.id == null) {
        await DbManager().insertRecord(
          item: RecordEntity(
            book: mBook.name!,
            position: itemPosition.index,
            alignment: itemPosition.itemLeadingEdge,
          ),
        );
      } else {
        item.position = itemPosition.index;
        item.alignment = itemPosition.itemLeadingEdge;
        await DbManager().modifyLocation(
          item: item,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: 120.w,
              child: TextButton(
                onPressed: () {
                  chapterScrollController.jumpTo(index: mChapters.length - 1);
                },
                child: const Text('去底部'),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: indexNotifier,
                builder: (context, data, child) {
                  return ScrollablePositionedList.builder(
                    itemCount: mChapters.length,
                    itemScrollController: chapterScrollController,
                    initialScrollIndex: data,
                    itemBuilder: (context, index) {
                      var item = mChapters[index];
                      return InkWell(
                        onTap: () {
                          itemScrollController.jumpTo(index: index);
                          Scaffold.of(context).closeEndDrawer();
                        },
                        child: Container(
                          width: double.infinity,
                          height: 120.w,
                          padding: EdgeInsets.only(
                            left: 40.w,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  item.chapterName ?? '',
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    color: index == data ? Colors.blue : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 120.w,
              child: TextButton(
                onPressed: () {
                  chapterScrollController.jumpTo(index: 0);
                },
                child: const Text('去顶部'),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                var flag = _menuNotifier.value;
                _menuNotifier.value = !flag;
              },
              child: Container(
                color: CustomColors.colorF8F8FA,
                child: DataBuilder<RecordEntity>(
                  maker: () => DbManager().isRecord(
                    book: mBook.name!,
                  ),
                  builder: (retryTask, lastPosition) {
                    return ScrollablePositionedList.builder(
                      padding: EdgeInsets.only(
                        left: 80.w,
                        right: 80.w,
                      ),
                      itemCount: mChapters.length,
                      itemBuilder: (context, index) {
                        return DataBuilder<String>(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height,
                          emptyView: Center(
                            child: Text(
                              '${mChapters[index].chapterName}\n暂无数据',
                            ),
                          ),
                          errorView: Center(
                            child: Text(
                              '${mChapters[index].chapterName}\n加载失败，点击重新加载',
                            ),
                          ),
                          maker: () => DataManager().getChapterContent(
                            chapter: mChapters[index],
                            method: appController.getTargetMethod(
                              code: mBook.original!,
                            ),
                          ),
                          builder: (retryTask, data) {
                            if (index == lastPosition.position && isRecurrence) {
                              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                isRecurrence = false;
                                itemScrollController.scrollTo(
                                  index: lastPosition.position,
                                  duration: const Duration(milliseconds: 1),
                                  alignment: lastPosition.alignment,
                                );
                              });
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '\n${mChapters[index].chapterName}\n',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  data,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      itemScrollController: itemScrollController,
                      itemPositionsListener: itemPositionsListener,
                      initialScrollIndex: mPosition ?? lastPosition.position,
                      initialAlignment: 0,
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ValueListenableBuilder<bool>(
              valueListenable: _menuNotifier,
              builder: (context, data, child) {
                return Visibility(
                  visible: data,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: kToolbarHeight + MediaQuery.of(context).padding.top,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 200.w,
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
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  Scaffold.of(context).openEndDrawer();
                                  _menuNotifier.value = !_menuNotifier.value;
                                },
                                child: const Center(
                                  child: Icon(Icons.menu),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  _menuNotifier.value = !_menuNotifier.value;
                                  transformSource();
                                },
                                child: const Center(
                                  child: Text(
                                    '换源',
                                    style: TextStyle(
                                      color: CustomColors.color42A5F5,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  transformSource() async {
    var children = appController.methods;
    var data = await showModalBottomSheet(
        context: context,
        builder: (context) {
          return UnconstrainedBox(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 1000.w,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (children[index].methodCode == mBook.original) {
                        return;
                      }
                      Navigator.of(context).pop(children[index]);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 140.w,
                      padding: EdgeInsets.only(
                        left: 40.w,
                        right: 40.w,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${children[index].methodName}',
                            style: TextStyle(
                              fontSize: 16,
                              color: children[index].methodCode == mBook.original ? CustomColors.color42A5F5 : CustomColors.color1A1A1A,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: CustomColors.colorF5F5F5,
                  );
                },
                itemCount: children.length,
              ),
            ),
          );
        });
    if (data != null) {
      if (data.methodCode == 0) {
        Fluttertoast.showToast(msg: '暂无来源');
        return;
      }
      var result = await requestByDialog<List<BookEntity>>(
        context: context,
        maker: () => DataManager().searchBooksByKeyword(
          keyword: mBook.name!,
          method: data,
        ),
      );
      if (result == null) {
        Fluttertoast.showToast(msg: '解析网页失败');
        return;
      } else {
        var item = result.firstWhere((element) => element.name == mBook.name, orElse: () => BookEntity());
        if (item.name != null) {
          var list = await requestByDialog<List<ChapterEntity>>(
            context: context,
            maker: () => DataManager().getBookChapters(
              book: item,
              method: data,
            ),
          );
          if (list == null) {
            Fluttertoast.showToast(msg: '获取章节失败');
            return;
          } else {
            mBook = item;
            mChapters = list;
            await modifyOriginal();
            setState(() {});
          }
        }
      }
    }
  }
}
