import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:reader_helper/app/app_controller.dart';
import 'package:reader_helper/app/sp_manager.dart';
import 'package:reader_helper/custom_colors.dart';
import 'package:reader_helper/entity/book_entity.dart';
import 'package:reader_helper/entity/method_entity.dart';
import 'package:reader_helper/http/data_manager.dart';
import 'package:reader_helper/http/http_dialog.dart';
import 'package:reader_helper/ui/book_page.dart';

/// @author yi1993
/// @created at 2022/5/7
/// @description: 搜索
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late AppController appController;

  late TextEditingController _textEditingController;
  final FocusNode _focusNode = FocusNode();
  late final ValueNotifier<List<BookEntity>> _notifier;

  @override
  void initState() {
    super.initState();
    appController = Get.find<AppController>();
    _textEditingController = TextEditingController();
    _notifier = ValueNotifier([]);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          currentFocus.focusedChild?.unfocus();
        }
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              left: 0,
              top: kToolbarHeight + MediaQuery.of(context).padding.top,
              right: 0,
              bottom: 0,
              child: _getBookView(),
            ),
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
              child: _getTopView(),
            ),
          ],
        ),
      ),
    );
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
          Padding(
            padding: EdgeInsets.only(
              left: 80.w,
              right: 20.w,
            ),
            child: GestureDetector(
              onTap: () async {
                MethodEntity? currentMethod = await showMenu(
                  context: context,
                  position: RelativeRect.fill,
                  items: appController.methods
                      .map((e) => CheckedPopupMenuItem<MethodEntity>(
                            value: e,
                            checked: appController.targetMethod.value.methodCode == e.methodCode,
                            padding: EdgeInsets.only(
                              left: 40.w,
                              right: 40.w,
                            ),
                            child: Text(e.methodName ?? ''),
                          ))
                      .toList(),
                );
                if (currentMethod != null) {
                  SpManager().setMethodCode(code: currentMethod.methodCode!);
                  appController.setCurrentMethod(method: currentMethod);
                }
              },
              child: Obx(() => Text(
                    '${appController.targetMethod.value.methodName}',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  )),
            ),
          ),
          Expanded(
            child: Container(
              height: kToolbarHeight - 80.w,
              margin: EdgeInsets.only(
                top: 40.w,
                bottom: 40.w,
                left: 60.w,
                right: 60.w,
              ),
              decoration: BoxDecoration(
                color: CustomColors.colorF5F5F5,
                borderRadius: BorderRadius.circular(
                  60.w,
                ),
              ),
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
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 80.w,
                      ),
                      child: TextField(
                        controller: _textEditingController,
                        focusNode: _focusNode,
                        decoration: null,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(
                          fontSize: 14,
                          color: CustomColors.color666666,
                        ),
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        maxLength: 15,
                        onChanged: (text) {},
                        onEditingComplete: () {},
                        onSubmitted: (text) {
                          _focusNode.unfocus();
                          searchBooksByKeyword(
                            keyword: text,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 80.w,
            ),
            child: GestureDetector(
              onTap: () {
                _focusNode.unfocus();
                searchBooksByKeyword(
                  keyword: _textEditingController.text,
                );
              },
              child: const Text(
                '搜索',
                style: TextStyle(
                  fontSize: 14,
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
      child: ValueListenableBuilder<List<BookEntity>?>(
        valueListenable: _notifier,
        builder: (context, data, child) {
          if (data == null) {
            return const SizedBox.expand();
          }
          return ListView.builder(
            padding: EdgeInsets.only(
              left: 40.w,
              top: 40.w,
              right: 40.w,
              bottom: 60.w,
            ),
            itemCount: data.length,
            itemExtent: 600.w,
            itemBuilder: (context, index) {
              var item = data[index];
              return GestureDetector(
                onTap: () {
                  if (item.path == null) {
                    Fluttertoast.showToast(msg: '获取资源失败');
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return BookPage(
                          tag: 'thumb$index',
                          book: item,
                        );
                      },
                    ),
                  );
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      30.w,
                    ),
                  ),
                  elevation: 8.w,
                  margin: EdgeInsets.only(
                    top: 30.w,
                    bottom: 30.w,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'thumb$index',
                        child: item.picUrl == null
                            ? SvgPicture.asset(
                                'assets/blank.svg',
                                height: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image(
                                image: CachedNetworkImageProvider(item.picUrl!),
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: 40.w,
                                top: 30.w,
                                right: 40.w,
                              ),
                              child: Text(
                                '${item.name}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CustomColors.color1A1A1A,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 40.w,
                                  top: 20.w,
                                  bottom: 20.w,
                                  right: 40.w,
                                ),
                                child: Text(
                                  '${item.description}',
                                  maxLines: 3,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: CustomColors.color1A1A1A,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 40.w,
                                bottom: 20.w,
                                right: 40.w,
                              ),
                              child: Text(
                                '${item.message}',
                                maxLines: 3,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: CustomColors.color1A1A1A,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 40.w,
                                bottom: 40.w,
                                right: 40.w,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '作者:${item.author}',
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: CustomColors.color1A1A1A,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${item.type}',
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: CustomColors.color1A1A1A,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${item.status}',
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: item.status == '完结' ? CustomColors.color42A5F5 : CustomColors.color18CE94,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    );
  }

  void searchBooksByKeyword({
    String? keyword,
  }) async {
    if (keyword == null || keyword.isEmpty) {
      Fluttertoast.showToast(msg: '请输入关键字');
      return;
    }
    var method = appController.targetMethod.value;
    if (method.methodCode == 0) {
      Fluttertoast.showToast(msg: '暂无来源');
      return;
    }
    var result = await requestByDialog<List<BookEntity>>(
      context: context,
      maker: () => DataManager().searchBooksByKeyword(
        keyword: keyword,
        method: method,
      ),
    );
    if (result == null) {
      Fluttertoast.showToast(msg: '解析网页失败');
      return;
    } else {
      _notifier.value = result;
    }
  }
}
