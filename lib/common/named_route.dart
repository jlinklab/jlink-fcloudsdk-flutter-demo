import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:xcloudsdk_flutter_example/home_page.dart';
import 'package:xcloudsdk_flutter_example/models/user_instance.dart';
import 'package:xcloudsdk_flutter_example/pages/add_device/add_device_page.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/device_config_page.dart';
import 'package:xcloudsdk_flutter_example/pages/add_device/wifi_config_page.dart';
import 'package:xcloudsdk_flutter_example/pages/login/login_page.dart';
import 'package:xcloudsdk_flutter_example/pages/media_realplay/media_multi_play_page.dart';
import 'package:xcloudsdk_flutter_example/pages/media_realplay/media_realplay_page.dart';
import 'package:xcloudsdk_flutter_example/pages/play_back/play_back_page.dart';
import 'package:xcloudsdk_flutter_example/pages/record/record_list_page.dart';
import 'package:xcloudsdk_flutter_example/pages/register/register_page.dart';
import 'package:xcloudsdk_flutter_example/pages/setting/setting_page.dart';

final GoRouter goRouter = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      name: 'register',
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      name: 'addDevice',
      path: '/addDevice',
      builder: (context, state) => const AddDevicePage(),
    ),
    GoRoute(
      path: '/play_back',
      builder: (context, state) => const PlayBackPage(),
    ),
    GoRoute(
      name: 'wifi_config',
      path: '/wifi_config',
      builder: (context, state) => const WIFIConfigPage(),
    ),
    GoRoute(
      name: 'setting',
      path: '/setting',
      builder: (context, state) => const SettingPage(),
    ),

    ///这种写法更适合推送消息跳转. 将信息转换为一个 Url, 直接跳转
    GoRoute(
      name: 'preview',
      path: '/preview/:devId',
      builder: (context, state) => MediaRealPlayPage(
        deviceId: state.pathParameters['devId'] ?? '',
      ),
    ),
    GoRoute(
        name: 'device_config',
        path: '/device_config/:devId/:channel',
        builder: (context, state) => DeviceConfigPage(
              deviceId: state.pathParameters['devId'] ?? '',
              channel: int.tryParse(state.pathParameters['channel']!) ?? -1,
            )),
    GoRoute(
      name: 'card_record',
      path: '/card_record/:devId',
      builder: (context, state) => RecordListPage(
        deviceId: state.pathParameters['devId'] ?? '',
      ),
    ),

    GoRoute(
      name: 'preview_multi',
      path: '/preview_multi/:devId',
      builder: (context, state) => MediaMultiPlayPage(
        deviceId: state.pathParameters['devId'] ?? '',
      ),
    ),
  ],

  // redirect to the login page if the user is not logged in
  redirect: (BuildContext context, GoRouterState state) {
    if (state.matchedLocation == '/register') {
      return null;
    }
    //read 获取值 不监听
    final bool loggedIn = context.read<UserInfo>().isLogin;
    if (!loggedIn) {
      return '/login';
    }

    // if the user is logged in but still on the login page, send them to
    // the home page
    final bool loggingIn = state.matchedLocation == '/login';
    if (loggingIn) {
      return '/';
    }

    // no need to redirect at all
    return null;
  },
  //用户信息改变时,重新刷新路由
  refreshListenable: UserInfo.instance,
  observers: [routeObserver],
);

///创建一个全局路由监听对象
RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
