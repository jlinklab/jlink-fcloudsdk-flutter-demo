import 'package:flutter/material.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/common/match.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/device_pwd_setting/model/model.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

///验证设置设备密码密保问题
class DevicePwdFindBackPage extends StatefulWidget {
  final String deviceId;
  const DevicePwdFindBackPage({Key? key, required this.deviceId})
      : super(key: key);

  @override
  State<DevicePwdFindBackPage> createState() => _DevicePwdFindBackPageState();
}

class _DevicePwdFindBackPageState extends State<DevicePwdFindBackPage> {
  final _textEditingControllerAns1 = TextEditingController();
  final _textEditingControllerAns2 = TextEditingController();
  final _textEditingControllerDeviceName = TextEditingController();
  final _textEditingControllerPwd = TextEditingController();
  final _textEditingControllerPwdCon = TextEditingController();
  late final PwdQuestionHadSet _pwdQuestionHadSet;

  String _question1 = '';
  String _question2 = '';

  @override
  void initState() {
    super.initState();
    _textEditingControllerDeviceName.text = 'admin';
    Future.delayed(Duration.zero, () {
      _queryHadSetQuestionList();
    });
  }

  ///获取已经设置的问题列表
  _queryHadSetQuestionList() {
    KToast.show();
    JFApi.xcDevice
        .xcDevicePwdHadSetQuestionList(deviceId: widget.deviceId)
        .then((value) {
      KToast.dismiss();
      _pwdQuestionHadSet = PwdQuestionHadSet.fromJson(value);
      setState(() {
        _question1 = _pwdQuestionHadSet.getSafetyQuestion!.question![0];
        _question2 = _pwdQuestionHadSet.getSafetyQuestion!.question![1];
      });
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.pwdFindBack),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('问题1:'),
              Text(_question1),
              TextField(
                controller: _textEditingControllerAns1,
                decoration: const InputDecoration(
                    hintText: "答案", hintStyle: TextStyle(color: Colors.grey)),
              ),
              const Text('问题2:'),
              Text(_question2),
              TextField(
                controller: _textEditingControllerAns2,
                decoration: const InputDecoration(
                    hintText: "答案", hintStyle: TextStyle(color: Colors.grey)),
              ),
              TextField(
                controller: _textEditingControllerDeviceName,
                decoration: const InputDecoration(
                    hintText: "设备登录名称(默认：admin)",
                    hintStyle: TextStyle(color: Colors.grey)),
              ),
              TextField(
                controller: _textEditingControllerPwd,
                decoration: const InputDecoration(
                    hintText: "新密码", hintStyle: TextStyle(color: Colors.grey)),
              ),
              TextField(
                controller: _textEditingControllerPwdCon,
                decoration: const InputDecoration(
                    hintText: "请确认新密码",
                    hintStyle: TextStyle(color: Colors.grey)),
              ),
              const Text('密码要求8~64个字符,只能包含字母和数字,至少有一个字母,至少有一个数字'),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  _onCheck();
                },
                child: Container(
                  height: 42.0,
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Text(
                    '确认重置',
                    style: TextStyle(color: Colors.white, fontSize: 22.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingControllerDeviceName.dispose();
    _textEditingControllerAns1.dispose();
    _textEditingControllerAns2.dispose();
    _textEditingControllerPwd.dispose();
    _textEditingControllerPwdCon.dispose();
    KToast.dismissInDispose();
    super.dispose();
  }

  ///验证密保问题
  _onCheck() {
    if (_textEditingControllerAns1.text.isEmpty ||
        _textEditingControllerAns2.text.isEmpty ||
        _textEditingControllerDeviceName.text.isEmpty ||
        _textEditingControllerPwd.text.isEmpty ||
        _textEditingControllerPwdCon.text.isEmpty) {
      KToast.show(status: '请先完善信息');
      return;
    }

    if (_textEditingControllerPwd.text != _textEditingControllerPwdCon.text) {
      KToast.show(status: '密码不一致');
      return;
    }

    if (JFMatch.kIsValidDevicePwd(_textEditingControllerPwd.text) == false) {
      KToast.show(status: '密码格式不正确');
      return;
    }

    KToast.show();
    JFApi.xcDevice
        .xcDeviceCheckPwdQuestion(
            deviceId: widget.deviceId,
            answer1: _textEditingControllerAns1.text,
            answer2: _textEditingControllerAns2.text)
        .then((value) {
      KToast.dismiss();
      int status = value['Ret'];
      if (status == 100) {
        //验证成功
        _onReset();
      } else if (status == 219) {
        //验证次数过多，需重启设备再尝试
        KToast.show(status: '验证次数过多，需重启设备再尝试');
      } else if (status == 220) {
        //答案错误
        KToast.show(status: '答案错误');
      } else {
        KToast.show(status: '验证出错');
      }
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  ///重置密码 不登录
  _onReset() {
    JFApi.xcDevice
        .xcDeviceResetPwdNotLogin(
            deviceId: widget.deviceId,
            userName: _textEditingControllerDeviceName.text,
            pwd: _textEditingControllerPwd.text)
        .then((value) {
      int status = value['Ret'];
      if (status == 100) {
        KToast.show(status: '重置成功!');
        Future.delayed(const Duration(seconds: 1), () {
          ///返回上一页
          Navigator.of(context).pop();
        });
      } else if (status == 103) {
        KToast.show(status: '数据格式错误');
      } else if (status == 205) {
        KToast.show(status: '用户名不存在');
      } else if (status == 206) {
        KToast.show(status: '用户名错误次数太多,需重启设备');
      } else if (status == 220) {
        KToast.show(status: '需要先回答安全问题或摄入正确的校验码');
      } else {
        KToast.show(status: '密码设置出错');
      }
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }
}
