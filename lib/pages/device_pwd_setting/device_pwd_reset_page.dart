import 'package:flutter/material.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/common/match.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/device_pwd_setting/device_pwd_question_setting_page.dart';
import 'package:xcloudsdk_flutter_example/pages/device_pwd_setting/model/model.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

///重设设备密码
class DevicePwdResetPage extends StatefulWidget {
  final String deviceId;
  const DevicePwdResetPage({Key? key, required this.deviceId})
      : super(key: key);

  @override
  State<DevicePwdResetPage> createState() => _DevicePwdResetPageState();
}

class _DevicePwdResetPageState extends State<DevicePwdResetPage>
    with WidgetsBindingObserver {
  final _textEditingControllerDeviceLoginName = TextEditingController();
  final _textEditingControllerPwdOld = TextEditingController();
  final _textEditingControllerPwdNew = TextEditingController();
  final _textEditingControllerPwdNewCon = TextEditingController();
  bool _isShowSetPwdQuestionButton = false;
  final bool _iskeyBoardShow = false;
  int? _questionAbility;
  int? _verifyQRCode;

  @override
  void initState() {
    super.initState();
    _textEditingControllerDeviceLoginName.text = 'admin';
    _textEditingControllerPwdNew.text = '';
    Future.delayed(Duration.zero, () {
      _checkDeviceAbility();
    });

    // 添加 WidgetsBindingObserver 监听器
    WidgetsBinding.instance.addObserver(this);
  }

  ///获取设备安全能力级
  ///如果question == 1 || question == 2 || verifyQRCode == 1 || verifyQRCode == 2 则需要显示密保问题
  _checkDeviceAbility() {
    JFApi.xcDevice.xcDeviceSafeAbility(deviceId: widget.deviceId).then((value) {
      GetSafetyAbilityModel model =
          GetSafetyAbilityModel.fromJson(value as Map<String, dynamic>);
      _questionAbility = model.getSafetyAbility?.question;
      _verifyQRCode = model.getSafetyAbility?.verifyQRCode;
      setState(() {
        _isShowSetPwdQuestionButton = _questionAbility == 1 ||
            _questionAbility == 2 ||
            _verifyQRCode == 1 ||
            _verifyQRCode == 2;
      });
    }).catchError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.resetDevPwd),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _textEditingControllerDeviceLoginName,
              decoration: const InputDecoration(
                  hintText: '设备登录名称(默认: admin)',
                  hintStyle: TextStyle(color: Colors.grey)),
            ),
            TextField(
              controller: _textEditingControllerPwdOld,
              decoration: const InputDecoration(
                  hintText: '旧密码(可以为空)',
                  hintStyle: TextStyle(color: Colors.grey)),
            ),
            TextField(
              controller: _textEditingControllerPwdNew,
              decoration: const InputDecoration(
                  hintText: '新密码', hintStyle: TextStyle(color: Colors.grey)),
            ),
            TextField(
              controller: _textEditingControllerPwdNewCon,
              decoration: const InputDecoration(
                  hintText: '确认新密码', hintStyle: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text('密码要求8~64个字符,只能包含字母和数字,至少有一个字母,至少有一个数字'),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                _onCheckOldPwd();
              },
              child: Container(
                height: 42.0,
                margin: const EdgeInsets.only(left: 15, right: 15),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  TR.current.reset,
                  style: const TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ),
            ),
            const Spacer(),
            Visibility(
              visible: _isShowSetPwdQuestionButton && _iskeyBoardShow == false,
              child: InkWell(
                onTap: () {
                  _onSetQuestion();
                },
                child: Container(
                  height: 42.0,
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    TR.current.pwdQuestion,
                    style: const TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10 + MediaQuery.of(context).padding.bottom,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingControllerDeviceLoginName.dispose();
    _textEditingControllerPwdOld.dispose();
    _textEditingControllerPwdNew.dispose();
    _textEditingControllerPwdNewCon.dispose();
    // 移除监听器
    WidgetsBinding.instance.removeObserver(this);

    KToast.dismissInDispose();
    super.dispose();
  }

  // 键盘弹起时的回调
  @override
  void didChangeMetrics() {
    // final bottomInset = View.of(context).viewInsets.bottom; // 获取底部间隙
    // if (bottomInset > 0) {
    //   // 表示键盘打开状态，处理相应逻辑
    //   _iskeyBoardShow = true;
    // } else {
    //   // 表示键盘关闭状态，处理相应逻辑
    //   _iskeyBoardShow = false;
    // }
    // setState(() {});
  }

  _onCheckOldPwd() {
    if (_textEditingControllerDeviceLoginName.text.isEmpty ||
        // _textEditingControllerPwdOld.text.isEmpty ||//old密码可以为空
        _textEditingControllerPwdNew.text.isEmpty ||
        _textEditingControllerPwdNewCon.text.isEmpty) {
      KToast.show(status: '请先完善信息');
      return;
    }

    if (_textEditingControllerPwdNew.text !=
        _textEditingControllerPwdNewCon.text) {
      KToast.show(status: '新密码不一致');
      return;
    }

    if (JFMatch.kIsValidDevicePwd(_textEditingControllerPwdNew.text) == false) {
      KToast.show(status: '密码格式不正确');
      return;
    }

    ///验证旧密码是否正确
    KToast.show();
    JFApi.xcDevice
        .xcDeviceCheckOldPwdIsCorrect(
            deviceId: widget.deviceId,
            oldPwd: _textEditingControllerPwdOld.text,
            deviceLoginName: _textEditingControllerDeviceLoginName.text)
        .then((value) {
      KToast.dismiss();
      if (value == true) {
        _onReset();
      } else {
        KToast.show(status: '旧密码验证错误');
      }
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  ///重置密码
  _onReset() {
    KToast.show();
    JFApi.xcDevice
        .xcDeviceResetPwd(
            deviceId: widget.deviceId,
            oldPwd: _textEditingControllerPwdOld.text,
            newPwd: _textEditingControllerPwdNew.text,
            deviceLoginName: _textEditingControllerDeviceLoginName.text)
        .then((value) {
      KToast.show(status: '密码重置成功');

      ///重新保存到本地
      JFApi.xcDevice.xcSetLocalUserNameAndPwd(
          deviceId: widget.deviceId,
          userName: _textEditingControllerDeviceLoginName.text,
          pwd: _textEditingControllerPwdNew.text);
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  ///去设置设备密保问题
  _onSetQuestion() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return DevicePwdQuestionSettingPage(
          deviceId: widget.deviceId,
          questionAbility: _questionAbility!,
          verifyQRCode: _verifyQRCode!);
    }));
  }
}
