import 'package:flutter/material.dart';

import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/add_device/manager/add_device_permission_manager.dart';
import 'package:fcloudsdk_example/pages/add_device/manager/global_ble_search_manager.dart';
import 'package:fcloudsdk_example/pages/home/device_list_page.dart';

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

    ///蓝牙搜索监听
    GlobalBleSearchManager.instance.init();
    _startBleScan();
    super.initState();
  }

  ///进入首页高频扫描蓝牙设备：设备列表页提前发现门锁等蓝牙设备，
  ///进入设备详情时蓝牙在线状态已就绪，无需再等待扫描；
  ///后续扫描由设备列表下拉刷新触发
  _startBleScan() async {
    ///仅读取权限状态，不触发系统授权弹窗；未授权则静默跳过
    await AddDevicePermissionUsecase.instance.checkOnlyBlue(onlyStatus: true);
    if (!AddDevicePermissionUsecase.instance.isCanBleSearch()) {
      return;
    }

    ///不是设备页就不扫描
    if (_currentIndex != 0) {
      return;
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        GlobalBleSearchManager.instance
            .startScanByDebounce(pageContext: context, retryCountMax: 4);
      }
    });
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
