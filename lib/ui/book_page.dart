import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:reader_helper/app/app_controller.dart';
import 'package:reader_helper/app/db_manager.dart';
import 'package:reader_helper/entity/book_entity.dart';
import 'package:reader_helper/entity/db/collect_entity.dart';
import 'package:reader_helper/ui/chapter_widget.dart';
import 'package:reader_helper/ui/detail_widget.dart';

/// @author yi1993
/// @created at 2022/5/9
/// @description: 书籍详情
class BookPage extends StatefulWidget {
  final String tag;
  final BookEntity book;

  const BookPage({
    Key? key,
    required this.tag,
    required this.book,
  }) : super(key: key);

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  final ValueNotifier<bool> _notifier = ValueNotifier(false);
  List<String> tabs = ['目录', '详情'];
  late AppController appController;

  @override
  void initState() {
    super.initState();
    appController = Get.find<AppController>();
    _scrollController = ScrollController();
    _tabController = TabController(length: tabs.length, vsync: this);
    getCollectStatus();
  }

  getCollectStatus() async {
    CollectEntity? item = await DbManager().isCollect(
      book: widget.book.name!,
    );
    _notifier.value = item != null;
  }

  cancelOrConfirmCollect() async {
    CollectEntity? item = await DbManager().isCollect(
      book: widget.book.name!,
    );
    if (item == null) {
      await DbManager().insertCollect(
        item: CollectEntity(
          book: widget.book.name!,
          date: DateTime.now().millisecondsSinceEpoch,
          data: json.encode(widget.book.toJson()),
          sort: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } else {
      await DbManager().deleteCollect(
        book: widget.book.name!,
      );
    }
    await getCollectStatus();
    List<CollectEntity>? data = await DbManager().getCollect();
    appController.setBooks(data: data ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          List<Widget> children = List.empty(growable: true);
          children.add(SliverAppBar(
            title: Text(
              widget.book.name ?? '',
            ),
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
            pinned: true,
            expandedHeight: 800.w,
            actions: [
              ValueListenableBuilder<bool>(
                valueListenable: _notifier,
                builder: (context, data, child) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: 60.w,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        cancelOrConfirmCollect();
                      },
                      child: Icon(
                        Icons.star,
                        color: data ? Colors.red : Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Hero(
                tag: widget.tag,
                child: Image(
                  image: CachedNetworkImageProvider(widget.book.picUrl ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            bottom: TabBar(
                controller: _tabController,
                tabs: tabs
                    .map((e) => Tab(
                          text: e,
                        ))
                    .toList()),
          ));
          return children;
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            ChapterWidget(
              book: widget.book,
            ),
            DetailWidget(
              book: widget.book,
            ),
          ],
        ),
      ),
    );
  }
}
