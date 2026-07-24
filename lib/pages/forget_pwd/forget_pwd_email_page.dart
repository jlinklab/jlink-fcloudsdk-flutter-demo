import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';

import '../../common/code_prase.dart';
import '../../views/toast/toast.dart';

class ResetPwdByEmail extends StatefulWidget {
  const ResetPwdByEmail({Key? key}) : super(key: key);

  @override
  State<ResetPwdByEmail> createState() => _ResetPwdByEmailState();
}

class _ResetPwdByEmailState extends State<ResetPwdByEmail> {
  Timer? timer;

  _sendEmail() async {
    if (_emailController.text.isEmpty) {
      KToast.show(status: '请先填邮箱或手机号');
      return;
    }

    try {
      final userId = await JFApi.xcAccount
          .xcForgetPwdToResetPwdBySendEmail(email: _emailController.text);
      KToast.show(status: '请查看邮件');
      _checkUserIsActivated(userId);
    } catch (error) {
      KToast.show(status: kErrorMsg(error));
    }
  }

  _checkUserIsActivated(String userId) async {
    if (userId.isEmpty) {
      KToast.show(status: 'userId 为空');
      return;
    }

    timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        KToast.show();
        int result =
            await JFApi.xcAccount.checkResetPwdIsActivated(userId: userId);
        if (result >= 0) {
          KToast.show(status: '密码重置成功');
          timer.cancel();
          // context.pop;w
          // ignore: use_build_context_synchronously
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (error) {
        error as XCloudAPIException;
        if (error.code == -604065) {
          ///表示未激活,继续循环检测
        } else {
          KToast.dismiss();
          timer.cancel();
          KToast.show(status: kErrorMsg(error.code));
        }
      }
    });
  }

  final TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('忘记密码'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.email),
                  hintText: '邮箱',
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    _sendEmail();
                  },
                  child: const Text('发送邮件')),
            ],
          ),
        ));
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
