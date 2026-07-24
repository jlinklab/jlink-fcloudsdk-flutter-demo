import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/common/match.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/register/model/model.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

class RegisterWithPhonePage extends StatefulWidget {
  final AreaCodeModel model;
  const RegisterWithPhonePage({Key? key, required this.model})
      : super(key: key);

  @override
  State<RegisterWithPhonePage> createState() => _RegisterWithPhonePageState();
}

class _RegisterWithPhonePageState extends State<RegisterWithPhonePage> {
  late final AreaCodeModel _model;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  @override
  void initState() {
    _model = widget.model;
    super.initState();
  }

  _onSendCode() {
    if (_phoneController.text.isEmpty) {
      KToast.show(status: '请先填手机号');
      return;
    }

    if (phoneNumberIsValid(_phoneController.text) == false) {
      KToast.show(status: '请检查手机号格式');
      return;
    }

    if (_model.country == '中国') {
      KToast.show();
      JFApi.xcAccount
          .xcRegisterToGetChinaPhoneCode(
              phoneNumber: '${_model.head}:${_phoneController.text}')
          .then((value) {
        KToast.show(status: '验证码请求成功');
      }).catchError((error) {
        KToast.show(status: kErrorMsg(error));
      });
    } else {
      KToast.show();
      JFApi.xcAccount
          .xcGetGlobalPhoneCode(
              phoneNumber: '${_model.head}:${_phoneController.text}',
              type: 're')
          .then((value) {
        KToast.show(status: '验证码请求成功');
      }).catchError((error) {
        KToast.show(status: kErrorMsg(error));
      });
    }
  }

  ///检测手机号是否符合要求
  bool phoneNumberIsValid(String phoneNumber) {
    if (_model.rule == null) {
      return true;
    }

    final regExp = '${_model.rule}';
    final result = RegExp(regExp).hasMatch(phoneNumber);
    return result;
  }

  _onResetPwd() {
    if (_phoneController.text.isEmpty) {
      KToast.show(status: '请先填手机号');
      return;
    }
    if (phoneNumberIsValid(_phoneController.text) == false) {
      KToast.show(status: '请检查手机号格式');
      return;
    }
    if (_codeController.text.isEmpty) {
      KToast.show(status: '请先填写验证码');
      return;
    }
    if (_userNameController.text.isEmpty) {
      KToast.show(status: '请先填写用户名');
      return;
    }

    if (JFMatch.kIsValidAccountUserName(_userNameController.text) == false) {
      KToast.show(status: '用户名格式不正确');
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

    final model = PhoneRegisterModel(
        username: _userNameController.text,
        phoneOrEmail: '${_model.head}:${_phoneController.text}',
        pwd: _pwdController.text);
    JFApi.xcAccount
        .xcRegisterWithPhone(model: model, verCode: _codeController.text)
        .then((value) {
      KToast.show(status: '注册成功，去登录试试吧！');
      while (context.canPop()) {
        context.pop();
      }
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false); // 阻止右划返回手势
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(TR.current.phoneRegister),
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                while (context.canPop()) {
                  context.pop();
                }
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    final width = constraints.maxWidth;
                    const pWidth = 54.0;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: pWidth,
                          child: Text('${_model.head}'),
                        ),
                        SizedBox(
                          width: width - pWidth,
                          child: TextField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              hintText: TR.current.phone,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(
                    height: 10,
                  ),
                  LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
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
                              icon: const Icon(Icons.code),
                              hintText: TR.current.codeHint,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: pWidth,
                          child: TextButton(
                            style: const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.blue)),
                            onPressed: () {
                              _onSendCode();
                            },
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
                    controller: _userNameController,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.person),
                      hintText: TR.current.name,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _pwdController,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.password),
                      hintText: TR.current.pwdHint,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
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
                        child: Text(TR.current.check)),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
