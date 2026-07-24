import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/register/model/model.dart';
import 'package:xcloudsdk_flutter_example/pages/register/register_with_phone_get_area_code_page.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

import '../../common/code_prase.dart';
import '../../models/user_instance.dart';

class SmsLoginPage extends StatefulWidget {
  const SmsLoginPage({super.key});

  @override
  State<SmsLoginPage> createState() => _SmsLoginPageState();
}

class _SmsLoginPageState extends State<SmsLoginPage> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  String areaCode = "+86";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.smsLogin),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(
              height: 50.0,
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                TR.current.phoneRule,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () async {
                    AreaCodeModel result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => RegisterWithPhoneGetAreaCodePage(
                                  login: true,
                                )));
                    areaCode = result.head!;
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 10.0),
                    child: Text(areaCode),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 95,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: TR.current.phone,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(50),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                      ),
                    ),
                    controller: phoneController,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 170,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: TR.current.codeHint,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(50),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                      ),
                    ),
                    controller: codeController,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _getVerCode();
                  },
                  child: Text(TR.current.getCode),
                ),
              ],
            ),
            const SizedBox(
              height: 35.0,
            ),
            InkWell(
              onTap: () {
                _login();
              },
              child: Container(
                width: MediaQuery.of(context).size.width - 50,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  TR.current.login,
                  style: const TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getVerCode() async {
    final phone = "$areaCode:${phoneController.text}";
    KToast.show();
    JFApi.xcAccount
        .xcSmsLoginToGetCode(phone: phone)
        .then((value) => KToast.show(status: "验证码发送成功"))
        .catchError((error) => KToast.show(status: kErrorMsg(error)));
  }

  _login() async {
    final code = codeController.text;
    final phone = "$areaCode:${phoneController.text}";
    KToast.show();
    JFApi.xcAccount
        .xcSmsLoginAndGetDevList(phone: phone, verCode: code)
        .then((value) {
      KToast.dismiss();
      final json = value;
      context.read<UserInfo>().login(
          userId: json['userId'], loginType: LoginType.phone, phoneNum: phone);
    }).catchError((error) => KToast.show(status: kErrorMsg(error)));
  }
}
