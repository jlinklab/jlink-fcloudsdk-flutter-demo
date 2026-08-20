import 'package:flutter/material.dart';

import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/common/match.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/forget_pwd/forget_pwd_email_page.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

class ForgetPwdPage extends StatefulWidget {
  const ForgetPwdPage({Key? key}) : super(key: key);

  @override
  State<ForgetPwdPage> createState() => _ForgetPwdPageState();
}

class _ForgetPwdPageState extends State<ForgetPwdPage> {
  final TextEditingController _mailOrPhoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  _onSendCode() {
    if (_mailOrPhoneController.text.isEmpty) {
      KToast.show(status: '请先填邮箱或手机号');
      return;
    }
    KToast.show();
    JFApi.xcAccount
        .xcForgetPwdToGetCode(phoneOrEmail: _mailOrPhoneController.text)
        .then((value) {
      KToast.show(status: '验证码请求成功');
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  _onResetPwd() {
    if (_mailOrPhoneController.text.isEmpty) {
      KToast.show(status: '请先填邮箱或手机号');
      return;
    }
    if (_codeController.text.isEmpty) {
      KToast.show(status: '请先填写验证码');
      return;
    }
    if (_pwdController.text.isEmpty) {
      KToast.show(status: '请先填写新密码');
      return;
    }
    if (JFMatch.kIsValidAccountPwd(_pwdController.text) == false) {
      KToast.show(status: '密码格式不正确');
      return;
    }

    KToast.show();
    AccountAPI.instance
        .xcForgetPwdToResetPwd(
            phoneOrEmail: _mailOrPhoneController.text,
            newPassword: _pwdController.text,
            verCode: _codeController.text)
        .then((value) {
      KToast.show(status: '重置成功，去登录试试吧！');
      //退到首页
      Navigator.popUntil(context, (route) => route.isFirst);
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  _onResetPwdByEmail() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ResetPwdByEmail()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(TR.current.forgotPwd),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  TR.current.phoneRule,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              TextField(
                controller: _mailOrPhoneController,
                decoration: InputDecoration(
                  icon: const Icon(Icons.mail),
                  hintText: TR.current.mailPhone,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                final width = constraints.maxWidth;
                const pWidth = 120.0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: width - pWidth,
                      child: TextField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.verified),
                          hintText: TR.current.codeHint,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: pWidth,
                      child: TextButton(
                        onPressed: () {
                          _onSendCode();
                        },
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.blue)),
                        child: Text(
                          TR.current.getCode,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _pwdController,
                decoration: InputDecoration(
                  icon: const Icon(Icons.password),
                  hintText: TR.current.newPwd,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(TR.current.pwdRule),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    _onResetPwd();
                  },
                  child: Container(
                      alignment: Alignment.center,
                      width: 200,
                      child: Text(TR.current.reset))),
              ElevatedButton(
                  onPressed: () {
                    _onResetPwdByEmail();
                  },
                  child: Container(
                      alignment: Alignment.center,
                      width: 200,
                      child: const Text('邮件找回密码'))),
            ],
          ),
        ));
  }
}
