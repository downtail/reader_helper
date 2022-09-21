import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:reader_helper/ui/book_fragment.dart';
import 'package:reader_helper/ui/manage_fragment.dart';
import 'package:reader_helper/ui/setting_fragment.dart';

/// @author yi1993
/// @created at 2022/5/7
/// @description: 首页
class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final ValueNotifier<int> _indexNotifier = ValueNotifier(0);
  List<Widget> children = const [
    BookFragment(),
    ManageFragment(),
    SettingFragment(),
  ];
  late PageController _pageController;

  void initialization() async {
    FlutterNativeSplash.remove();
  }

  @override
  void initState() {
    super.initState();
    initialization();
    _pageController = PageController(
      initialPage: _indexNotifier.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView(
              controller: _pageController,
              children: children,
              onPageChanged: (index) {
                _indexNotifier.value = index;
                _pageController.jumpToPage(index);
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: kBottomNavigationBarHeight,
            child: Container(
              width: double.infinity,
              height: kBottomNavigationBarHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: _indexNotifier,
                builder: (context, value, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            _indexNotifier.value = 0;
                            _pageController.jumpToPage(0);
                          },
                          child: Center(
                            child: Text(
                              '书架',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: _indexNotifier.value == 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            _indexNotifier.value = 1;
                            _pageController.jumpToPage(1);
                          },
                          child: Center(
                            child: Text(
                              '管理',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: _indexNotifier.value == 1 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            _indexNotifier.value = 2;
                            _pageController.jumpToPage(2);
                          },
                          child: Center(
                            child: Text(
                              '设置',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: _indexNotifier.value == 2 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
