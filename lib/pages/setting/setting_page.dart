import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/models/user_instance.dart';
import 'package:fcloudsdk_example/pages/account/account_cancellation_page.dart';
import 'package:fcloudsdk_example/pages/reset_pwd/reset_pwd_page.dart';
import 'package:fcloudsdk_example/utils/common_path.dart';
import 'package:fcloudsdk_example/utils/upload_log_utils.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

typedef GetTitle = String Function(BuildContext context);

class _SettingPageState extends State<SettingPage> {
  List<GetTitle> dataSource = [
    (context) => TR.current.resetPwd,
    (context) => TR.current.accountCancel,
    (context) => TR.current.version,
    (context) => TR.current.toolsFeedbackLog,
    // (context) => TR.current.customerServiceCenter,
  ];

  String _versionInfo = '';

  @override
  void initState() {
    super.initState();

    _queryVersionInfo();
  }

  _queryVersionInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      // String appName = packageInfo.appName;
      // String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      _versionInfo += 'app版本: $version($buildNumber)';

      String sdkInfo = await JFApi.xcSDKInit.getSDKVersionInfo();
      _versionInfo +=
          '\n${TR.current.sdkVersion}: ${sdkInfo.split('number=')[1]}';

      setState(() {});
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.setting),
        centerTitle: true,
      ),
      body: ListView.separated(
          itemBuilder: (context, index) {
            final title = dataSource.elementAt(index)(context);
            return ListTile(
              title: Text(title),
              subtitle: (title == '版本信息' || title == 'Version')
                  ? Text(_versionInfo)
                  : null,
              trailing: (title != '版本信息' && title != 'Version')
                  ? const Icon(Icons.navigate_next_outlined)
                  : null,
              onTap: () {
                String title = dataSource.elementAt(index)(context);
                onTap(context, title);
              },
            );
          },
          separatorBuilder: (context, index) {
            return const Divider(
              color: Colors.grey,
            );
          },
          itemCount: dataSource.length),
    );
  }

  void onTap(BuildContext context, String title) async {
    switch (title) {
      case "重置账号密码":
      case "Reset Password":
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return const ResetPwdPage();
        }));
        break;
      case "账号注销":
      case "Account Cancellation":
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return AccountCancellationPage(
              userDetail: UserInfo.instance.userDetail);
        }));
        break;
      // case "登出":
      //   KToast.show();
      //   Future.delayed(const Duration(seconds: 1), () async {
      //     ///延迟2秒,模拟接口请求 后期可以删掉
      //     UserInfo.instance.quit().then((value) {
      //       KToast.show(status: '已登出');
      //       Navigator.pop(context);
      //     });
      //   });
      //   break;

      case "反馈日志":
      case "Feedback Log":
        //日志存在的文件夹
        String sourcePath = await kDirectoryPath();
        String targetPath = '$sourcePath/log_XCloudSDK.log.zip';
        String zipFilePath = await UploadLogUtil.createZipFile(
          sourcePath,
          targetPath,
        );
        if (zipFilePath.isEmpty) {
          return;
        }
        Share.shareXFiles([XFile(zipFilePath)]);
        break;

      case "客服中心":
      case "Customer Service Center":
        // TODO: 跳转客服中心
        break;
    }
  }
}
