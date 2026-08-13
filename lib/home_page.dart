import 'package:flutter/material.dart';

import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/device_list_page.dart';

import 'pages/account/account_info_page.dart';
import 'pages/album/album_page.dart';
import 'pages/error_code/error_code_page.dart';

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
  late final ErrorCodePage errorCodePage;
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
    errorCodePage = const ErrorCodePage();
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
          children: [deviceListPage, albumPage, errorCodePage, accountInfoPage]),
      bottomNavigationBar: _isHideBottomBar
          ? null
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              currentIndex: _currentIndex,
              unselectedItemColor: const Color(0xFF757575),
              selectedItemColor: Colors.blueAccent,
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              selectedLabelStyle: const TextStyle(fontSize: 14),
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
                  activeIcon: const Icon(Icons.home)
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.photo_album),
                  label: TR.current.album,
                  activeIcon: const Icon(Icons.photo_album)
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.error_outline),
                  label: TR.current.errorCode,
                  activeIcon: const Icon(Icons.error_outline)
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: TR.current.mine,
                  activeIcon: const Icon(Icons.person)
                ),
              ],
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
