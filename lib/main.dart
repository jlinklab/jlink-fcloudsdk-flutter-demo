import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:xcloudsdk_flutter/api/sdk_init/model.dart';
import 'package:xcloudsdk_flutter/xcloud.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';

import 'package:xcloudsdk_flutter_example/models/user_instance.dart';
import 'package:xcloudsdk_flutter_example/utils/app_config.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

import 'common/named_route.dart';
import 'pages/device_setting/viewmodel/device_list_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  UserInfo.instance.init();
  await _sdkInit();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const JFApp());
}

///SDK 初始化
///app 鉴权信息用的是funsdk demo
///请将开放平台获取到的appkey等信息填写
Future<void> _sdkInit() async {
  Directory? directory;
  String appKey = AppConfig.appKey();
  String appSecret = AppConfig.appSecret();
  String uuid = AppConfig.uuid();
  int moveCard = AppConfig.moveCard();
  if (Platform.isIOS) {
    directory = await getApplicationDocumentsDirectory();
  } else if (Platform.isAndroid) {
    directory = await getExternalStorageDirectory();
  } else if (Platform.operatingSystem == 'ohos') {
    directory = await getExternalStorageDirectory();
  } else {
    print('不支持当前平台');
  }
  SDKInit sdkInit = SDKInit(
      platUUID: uuid,
      platAppKey: appKey,
      platAppSecret: appSecret,
      platMovedCard: moveCard,
      tempPath: '/${directory!.path}/',
      configPath: '/${directory.path}/');
  await XCloudSDK.init(sdkInit);

  return Future.value();
}

class JFApp extends StatefulWidget {
  const JFApp({Key? key}) : super(key: key);

  @override
  State<JFApp> createState() => _JFAppState();
}

class _JFAppState extends State<JFApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserInfo.instance,
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (context) => DevListViewModel(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: goRouter,
        theme: ThemeData.light(useMaterial3: false),
        localizationsDelegates: const [
          TR.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: TR.delegate.supportedLocales,
        builder: KToast.init(),
      ),
    );
  }
}
