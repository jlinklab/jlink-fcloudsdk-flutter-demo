import 'package:flutter/material.dart';

import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/common/match.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/models/user_instance.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

class ResetPwdPage extends StatefulWidget {
  const ResetPwdPage({Key? key}) : super(key: key);

  @override
  State<ResetPwdPage> createState() => _ResetPwdPageState();
}

class _ResetPwdPageState extends State<ResetPwdPage> {
  final TextEditingController _editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  _onResetPwd() {
    if (_editingController.text.isEmpty) {
      KToast.show(status: '请先填写密码');
      return;
    }

    if (JFMatch.kIsValidAccountPwd(_editingController.text) == false) {
      KToast.show(status: '密码格式不正确');
      return;
    }

    KToast.show();
    JFApi.xcAccount
        .xcResetAccountPwd(newPassword: _editingController.text)
        .then((value) {
      KToast.show(status: '账户密码重置成功,请重新登陆');
      //退出 重新登录
      UserInfo.instance.quit(false).catchError((error) {
        KToast.show(status: '退出失败，请重试');
      });
      KToast.dismiss();
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(TR.current.resetPwd),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _editingController,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.person),
                    hintText: TR.current.newPwd,
                  ),
                ),
                const SizedBox(
                  height: 10,
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
                        child: Text(TR.current.reset)))
              ],
            ),
          ),
        ));
  }
}
