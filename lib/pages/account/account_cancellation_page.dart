import 'package:flutter/material.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/models/CountDown.dart';
import 'package:xcloudsdk_flutter_example/models/user_instance.dart';
import 'package:xcloudsdk_flutter_example/pages/account/model/model.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

class AccountCancellationPage extends StatefulWidget {
  final User userDetail;
  const AccountCancellationPage({Key? key, required this.userDetail})
      : super(key: key);

  @override
  State<AccountCancellationPage> createState() =>
      _AccountCancellationPageState();
}

class _AccountCancellationPageState extends State<AccountCancellationPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isDirectlyCancellation = true; //是否直接注销
  bool _isSendedCode = false;
  late final bool _isHasMail;
  late final bool _isHasPhone;
  String _tips = '';
  final Countdown _countdown = Countdown(count: 120); //计时器

  @override
  void initState() {
    _isHasMail =
        widget.userDetail.mail != null && widget.userDetail.mail!.isNotEmpty
            ? true
            : false;
    _isHasPhone =
        widget.userDetail.phone != null && widget.userDetail.phone!.isNotEmpty
            ? true
            : false;
    if (_isHasMail || _isHasPhone) {
      _isDirectlyCancellation = false;
    }

    super.initState();
  }

  ///注销 不需要验证码直接注销
  _accountCancellationWithoutCode() {
    KToast.show();
    JFApi.xcAccount.xcAccountCancellationWithoutCode().then((value) {
      KToast.show(status: '账号注销成功');
      _loginOut();
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  ///注销 需要验证码
  _accountCancellationWithCode() {
    if (_codeController.text.isEmpty) {
      KToast.show(status: '请填写验证码!');
      return;
    }

    if (_isSendedCode == false) {
      KToast.show(status: '请先发送验证码!');
      return;
    }

    KToast.show();
    AccountAPI.instance
        .xcAccountCancellationWithCode(verCode: _codeController.text)
        .then((value) {
      KToast.show(status: '账号注销成功');
      _loginOut();
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  ///发送验证码
  _sendCode() {
    KToast.show();
    AccountAPI.instance
        .xcAccountCancellationGetPhoneOrMailVerifyCode()
        .then((value) {
      _isSendedCode = true;
      _countdown.starCount(
          onCount: () => setState(() {}), onEnd: () => setState(() {}));
      KToast.show(status: '已发送验证码');
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  ///退出登录
  _loginOut() async {
    UserInfo.instance.quit(true);
    // UserInfo.instance.quit(true).then((value) {
    //   //返回到首页
    //   Navigator.popUntil(context, (route) => route.isFirst);
    // });
  }

  String _getTips() {
    if (_isHasMail && _isHasPhone) {
      _tips = TR.current
          .phoneMailTip(widget.userDetail.phone!, widget.userDetail.mail!);
    } else if (_isHasMail) {
      _tips = TR.current.mailTip(widget.userDetail.mail!);
    } else if (_isHasPhone) {
      _tips = TR.current.phoneTip(widget.userDetail.phone!);
    } else {
      _tips = TR.current.noPhoneMailTip;
    }
    return _tips;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(TR.current.accountCancel),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Center(
                  child: Text(
                _getTips(),
                textAlign: TextAlign.center,
              )),
              const SizedBox(
                height: 30,
              ),
              _isDirectlyCancellation
                  ? ElevatedButton(
                      onPressed: () {
                        _accountCancellationWithoutCode();
                      },
                      child: Text(TR.current.accountCancel))
                  : Column(
                      children: [
                        Container(
                          height: 60,
                          padding: const EdgeInsets.only(left: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _codeController,
                                  decoration: InputDecoration(
                                    hintText: TR.current.codeHint,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: TextButton(
                                    onPressed: () {
                                      if (_countdown.isCounting) {
                                        return;
                                      }
                                      _sendCode();
                                    },
                                    child: Text(_countdown.isCounting
                                        ? TR.current.countDown(_countdown.count)
                                        : TR.current.getCode)),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              _accountCancellationWithCode();
                            },
                            child: Text(TR.current.accountCancel))
                      ],
                    )
            ],
          ),
        ));
  }

  @override
  void dispose() {
    _codeController.dispose();
    _countdown.stop();
    super.dispose();
  }
}
