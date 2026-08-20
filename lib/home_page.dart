import 'package:flutter/material.dart';

import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_setting/device_list_page.dart';

import 'pages/account/account_info_page.dart';
import 'pages/album/album_page.dart';

///登录之后首页
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  bool _isHideBottomBar = false;
  late final DeviceListPage deviceListPage;
  late final AlbumPage albumPage;
  late final AccountInfoPage accountInfoPage;

  @override
  void initState() {
    deviceListPage = const DeviceListPage();
    albumPage = AlbumPage(
      onChangeEditStatus: (bool edit) {
        setState(() {
          _isHideBottomBar = edit;
        });
      },
    );
    accountInfoPage = const AccountInfoPage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [deviceListPage, albumPage, accountInfoPage]),
      bottomNavigationBar: _isHideBottomBar
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  if (index == 1) {
                    //更新数据
                    AlbumPage.update();
                  }
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: TR.current.device,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.photo_album),
                  label: TR.current.album,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: TR.current.mine,
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
