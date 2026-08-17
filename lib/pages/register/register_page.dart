// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk_example/common/match.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/register/register_with_phone_get_area_code_page.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import '../../common/code_prase.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwdController = TextEditingController();

  Timer? timer;
  String userId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(TR.current.mailRegister),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.email_outlined),
                        hintText: TR.current.mailHint,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: pwdController,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.password_outlined),
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
                        register(context);
                      },
                      child: Text(TR.current.check),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return RegisterWithPhoneGetAreaCodePage(
                            login: false,
                          );
                        }));
                      },
                      child: SizedBox(
                          width: 140,
                          child:
                              Center(child: Text(TR.current.goPhoneRegister))),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    const Divider(),
                    InkWell(
                      onTap: () {
                        context.pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 12.0),
                        child: Text(
                          TR.current.goLogin,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void register(BuildContext context) async {
    if (emailController.text.isEmpty || pwdController.text.isEmpty) {
      KToast.show(status: '请完善信息');
      return;
    }

    if (JFMatch.kIsValidAccountEmail(emailController.text) == false) {
      KToast.show(status: '邮箱格式不正确');
      return;
    }

    if (JFMatch.kIsValidAccountPwd(pwdController.text) == false) {
      KToast.show(status: '密码格式不正确,请重新输入');
      return;
    }

    KToast.show();
    JFApi.xcAccount
        .xcEmailRegister(
            email: emailController.text, password: pwdController.text)
        .then((value) {
      KToast.dismiss();
      userId = value;
      if (kDebugMode) {
        print('emailRegister $userId');
      }
      checkUserIsActivated(userId);
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  void checkUserIsActivated(String userId) async {
    if (userId.isEmpty) {
      KToast.show(status: 'userId 为空');
      return;
    }
    //轮询检测是否注册成功
    KToast.show();
    timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      var register =
          await AccountAPI.instance.xcCheckUserIsActivated(userId: userId);
      if (register) {
        KToast.dismiss();
        timer.cancel();
        context.pop();
      }
    });
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    KToast.dismissInDispose();
    super.dispose();
  }
}
