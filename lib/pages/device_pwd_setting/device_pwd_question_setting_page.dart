import 'package:flutter/material.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_pwd_setting/model/model.dart';
import 'package:fcloudsdk_example/views/rf_divider.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

///设置设备密码密保问题
class DevicePwdQuestionSettingPage extends StatefulWidget {
  final String deviceId;
  final int questionAbility;
  final int verifyQRCode;
  const DevicePwdQuestionSettingPage(
      {Key? key,
      required this.deviceId,
      required this.questionAbility,
      required this.verifyQRCode})
      : super(key: key);

  @override
  State<DevicePwdQuestionSettingPage> createState() =>
      _DevicePwdQuestionSettingPageState();
}

class _DevicePwdQuestionSettingPageState
    extends State<DevicePwdQuestionSettingPage> {
  final _textEditingControllerAns1 = TextEditingController();
  final _textEditingControllerAnsCon1 = TextEditingController();
  final _textEditingControllerAns2 = TextEditingController();
  final _textEditingControllerAnsCon2 = TextEditingController();
  final _textEditingControllerPhoneOrMail = TextEditingController();
  List<String> _questionList = [];
  String _question1 = '';
  String _question2 = '';
  int _codeCheckType = 0; //0 通过app发送， 1 通过email发送

  late final PwdQuestion _mainPwdQuestion;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      _onQueryDeviceSupportLanguage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.pwdQuestion),
        actions: [
          ElevatedButton(
              onPressed: () {
                _onSave();
              },
              child: Text(
                TR.current.save,
                style: const TextStyle(fontSize: 20),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                alignment: const FractionalOffset(0.01, 0.1),
                child: const Text('请完善下列信息,以便以后重置密码'),
              ),
              // const RFDivider(),
              // Container(
              //   height: 40,
              //   alignment: Alignment.centerLeft,
              //   child: const Text(
              //     '安全问题',
              //     style: TextStyle(color: Colors.blue),
              //   ),
              // ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        '问题1:',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () {
                          _onChange(context, _question1);
                        },
                        child: Container(
                            constraints: const BoxConstraints(minHeight: 50), //
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  _question1,
                                  maxLines: 5,
                                )),
                                const Icon(Icons.arrow_forward_ios_rounded)
                              ],
                            )),
                      ),
                      TextField(
                        controller: _textEditingControllerAns1,
                        decoration: const InputDecoration(
                            hintText: "问题1: 答案",
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                      TextField(
                        controller: _textEditingControllerAnsCon1,
                        decoration: const InputDecoration(
                            hintText: "问题1: 确认答案",
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        '问题2:',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () {
                          _onChange(context, _question2);
                        },
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 50), //
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                _question2,
                                maxLines: 5,
                              )),
                              const Icon(Icons.arrow_forward_ios_rounded)
                            ],
                          ),
                        ),
                      ),
                      TextField(
                        controller: _textEditingControllerAns2,
                        decoration: const InputDecoration(
                            hintText: "问题2: 答案",
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                      TextField(
                        controller: _textEditingControllerAnsCon2,
                        decoration: const InputDecoration(
                            hintText: "问题2: 确认答案",
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '联系方式',
                        style: TextStyle(color: Colors.blue),
                      ),
                      TextField(
                        controller: _textEditingControllerPhoneOrMail,
                        decoration: const InputDecoration(
                            hintText: "手机号或邮箱",
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                '选择验证码发送方式',
                style: TextStyle(color: Colors.blue),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _codeCheckType = 0;
                  });
                },
                child: Container(
                  constraints: const BoxConstraints(minHeight: 35), //
                  child: Row(
                    children: [
                      const Expanded(
                          child: Text(
                        '通过app发送',
                        maxLines: 5,
                      )),
                      Icon(_codeCheckType == 0
                          ? Icons.check_circle
                          : Icons.circle_outlined)
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _codeCheckType = 1;
                  });
                },
                child: Container(
                  constraints: const BoxConstraints(minHeight: 35), //
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '通过email发送',
                          maxLines: 5,
                        ),
                      ),
                      Icon(_codeCheckType == 1
                          ? Icons.check_circle
                          : Icons.circle_outlined)
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const RFDivider(),
              const SizedBox(
                height: 10,
              ),
              const Text(
                '请保存上述信息并存放在安全位置',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  _onSave();
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
                    TR.current.save,
                    style: const TextStyle(color: Colors.white, fontSize: 22.0),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingControllerAns1.dispose();
    _textEditingControllerAnsCon1.dispose();
    _textEditingControllerAns2.dispose();
    _textEditingControllerAnsCon2.dispose();
    KToast.dismissInDispose();
    super.dispose();
  }

  _onChange(BuildContext context, String question) {
    showDialog(
        useSafeArea: false,
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      final title = _questionList[index];
                      final isSelected =
                          title == _question1 || title == _question2;
                      return GestureDetector(
                          onTap: () {
                            if (isSelected) {
                              return;
                            }
                            Navigator.of(context).pop();
                            setState(() {
                              question == _question1
                                  ? _question1 = title
                                  : _question2 = title;
                            });
                          },
                          child: Container(
                            height: 50,
                            color: Colors.white,
                            child: ListTile(
                                title: Text(title),
                                trailing: Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: Colors.blue,
                                )),
                          ));
                    },
                    separatorBuilder: (context, index) {
                      return const RFDivider();
                    },
                    itemCount: _questionList.length,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 42.0,
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Text(
                      '取消',
                      style: TextStyle(color: Colors.white, fontSize: 22.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0 + MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
          );
        });
  }

  ///获取设备问题列表
  _queryQuestionList() {
    KToast.show();
    JFApi.xcDevice
        .xcDevicePwdQuestionList(deviceId: widget.deviceId)
        .then((value) {
      KToast.dismiss();
      _mainPwdQuestion = PwdQuestion.fromJson(value as Map<String, dynamic>);
      // _questionList = _mainPwdQuestion!.questionDelivery!
      //     .where((element) => element != '请选择一个问题 ')
      //     .toList();
      _queryHadSetQuestionList();
      _questionList = _mainPwdQuestion.questionDelivery!;
      _question1 = _questionList[1]; // 0
      _question2 = _questionList[2]; // 1
      setState(() {});
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  ///获取已经设置的问题列表
  _queryHadSetQuestionList() {
    KToast.show();
    JFApi.xcDevice
        .xcDevicePwdHadSetQuestionList(deviceId: widget.deviceId)
        .then((value) {
      KToast.dismiss();
      PwdQuestionHadSet pwdQuestionHadSet =
          PwdQuestionHadSet.fromJson(Map<String, dynamic>.from(value));
      if (pwdQuestionHadSet.getSafetyQuestion != null &&
          pwdQuestionHadSet.getSafetyQuestion!.question != null &&
          pwdQuestionHadSet.getSafetyQuestion!.question!.length == 2) {
        _question1 = pwdQuestionHadSet.getSafetyQuestion!.question![0];
        _question2 = pwdQuestionHadSet.getSafetyQuestion!.question![1];
      } else {
        //没有设置过问题
        //取问题列表中的第一个第二个
        _question1 = _questionList[0];
        _question2 = _questionList[1];
      }
      setState(() {});
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  ///查询设备支持的语言
  _onQueryDeviceSupportLanguage() {
    KToast.show();
    JFApi.xcDevice
        .xcDeviceSupportLanguage(deviceId: widget.deviceId)
        .then((value) {
      //List<String> languageList = value;
      ///TODOo... 遍历设备支持语言列表 判断当前设备语言是否支持
      ///...
      ///支持则直接设置，不支持除汉语环境均为 English
      String language = 'SimpChinese';

      ///这里先写死为汉语,测试的话 也可以使用'English'
      ///设置设备语言
      _onSetDeviceLanguage(language);

      ///设置设备语言
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  ///设置设备语言
  _onSetDeviceLanguage(String language) {
    KToast.show();
    JFApi.xcDevice
        .xcDeviceSetLanguage(deviceId: widget.deviceId, language: language)
        .then((value) {
      ///设置语言成功
      KToast.dismiss();
      _queryQuestionList();
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  ///保存
  _onSave() {
    if (_textEditingControllerAns1.text.isEmpty ||
        _textEditingControllerAnsCon1.text.isEmpty ||
        _textEditingControllerAns2.text.isEmpty ||
        _textEditingControllerAnsCon2.text.isEmpty ||
        _textEditingControllerPhoneOrMail.text.isEmpty) {
      KToast.show(status: '请先完善信息');
      return;
    }

    if (_textEditingControllerAns1.text != _textEditingControllerAnsCon1.text) {
      KToast.show(status: '问题1答案不一致');
      return;
    }

    if (_textEditingControllerAns2.text != _textEditingControllerAnsCon2.text) {
      KToast.show(status: '问题2答案不一致');
      return;
    }

    KToast.show();
    JFApi.xcDevice
        .xcSaveDevicePwdQuestionDetail(
            deviceId: widget.deviceId,
            answer1: _textEditingControllerAns1.text,
            answer1Index: _questionList.indexOf(_question1),
            answer2: _textEditingControllerAns2.text,
            answer2Index: _questionList.indexOf(_question2),
            phoneOrEmail: _textEditingControllerPhoneOrMail.text,
            codeCheckType: _codeCheckType)
        .then((value) {
      KToast.show(status: '保存成功');
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }
}
