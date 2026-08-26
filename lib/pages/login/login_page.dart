// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/forget_pwd/forget_pwd_page.dart';
import 'package:fcloudsdk_example/models/user_instance.dart';
import 'package:fcloudsdk_example/pages/login/sms_login_page.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController nameController;
  late final TextEditingController pwdController;

  FocusNode node = FocusNode();
  late OverlayEntry overlayEntry;
  GlobalKey key = GlobalKey();
  List<String> existNameList = [];

  bool _visible = true;
  bool _collapsed = false;

  @override
  void initState() {
    nameController = TextEditingController();
    pwdController = TextEditingController();

    node.addListener(() {
      if (node.hasFocus) {
        overlayEntry = createOverlayEntry();
        Overlay.of(context).insert(overlayEntry);
        setState(() {
          _collapsed = true;
        });
      } else {
        overlayEntry.remove();
        setState(() {
          _collapsed = false;
        });
      }
    });

    Future.delayed(Duration.zero, () async {
      await UserInfo.instance
          .loadHistoryAccountList()
          .then((value) => existNameList = List.from(value));
    });

    ///自动登录 内部会用上次的登录信息登录
    Future.delayed(const Duration(seconds: 1), () {
      UserInfo.instance.autoLogin();
    });
    super.initState();
  }

  OverlayEntry createOverlayEntry() {
    RenderBox renderBox = key.currentContext?.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 5.0,
        width: size.width,
        child: Material(
          elevation: 4.0,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: existNameList.length,
            itemBuilder: (_, i) => InkWell(
              onTap: () {
                nameController.text = existNameList[i];
                node.unfocus();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 10.0),
                child: Text(existNameList[i]),
              ),
            ),
            separatorBuilder: (_, __) => const Divider(
              height: 0.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(TR.current.login),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: InkWell(
        onTap: () {
          if (node.hasFocus) {
            node.unfocus();
          }
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  TR.current.phoneRule,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  hintText: TR.current.nameHint,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                  ),
                  contentPadding: const EdgeInsets.only(
                    top: 0,
                    bottom: 0,
                  ),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          if (node.hasFocus) {
                            node.unfocus();
                          } else {
                            FocusScope.of(context).requestFocus(node);
                          }
                          _collapsed = !_collapsed;
                        });
                      },
                      icon: _collapsed
                          ? const Icon(Icons.arrow_drop_down)
                          : const Icon(Icons.arrow_drop_up)),
                ),
                focusNode: node,
                key: key,
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: pwdController,
                obscureText: !_visible,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.password),
                  hintText: TR.current.pwdHint,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                  ),
                  contentPadding: const EdgeInsets.only(
                    top: 0,
                    bottom: 0,
                  ),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _visible = !_visible;
                        });
                      },
                      icon: _visible
                          ? const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off)),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ForgetPwdPage())),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      TR.current.forgotPwd,
                      style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.red),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      login(context);
                    },
                    child: SizedBox(
                      width: 120,
                      child: Center(
                        child: Text(
                          TR.current.login,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SmsLoginPage()));
                    },
                    child: Container(
                      alignment: Alignment.centerRight,
                      width: 140,
                      child: Text(
                        TR.current.verCodeLogin,
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                            fontSize: 17.0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              const Divider(),
              InkWell(
                onTap: () {
                  context.pushNamed('register');
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  child: Text(TR.current.goRegister,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void login(BuildContext context) async {
    String loginName = nameController.text;
    String loginPwd = pwdController.text;
    if (loginName.isEmpty || loginPwd.isEmpty) {
      KToast.show(status: '请完善信息');
      return;
    }

    //登录接口
    KToast.show();
    JFApi.xcAccount
        .xcLoginAndGetDeviceList(userName: loginName, pwd: loginPwd)
        .then((value) {
      KToast.dismiss();
      final json = value;
      context.read<UserInfo>().login(
          userId: json['userId'],
          loginType: LoginType.normal,
          userName: loginName,
          pwd: loginPwd);
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    pwdController.dispose();
    KToast.dismissInDispose();
    super.dispose();
  }
}
