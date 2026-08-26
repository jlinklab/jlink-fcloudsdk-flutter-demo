import 'package:flutter/material.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk_example/pages/device_pwd_setting/model/model.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

typedef InputCompletion = void Function(String name, String pwd);

class DevicePwdInput extends StatefulWidget {
  final String deviceId;
  final InputCompletion completion;
  final Function onFindPwd;
  final Function onCancel;

  const DevicePwdInput(
      {Key? key,
      required this.completion,
      required this.onFindPwd,
      required this.deviceId,
      required this.onCancel})
      : super(key: key);

  @override
  State<DevicePwdInput> createState() => _DevicePwdInputState();
}

class _DevicePwdInputState extends State<DevicePwdInput> {
  late final TextEditingController nameController;
  late final TextEditingController pwdController;
  bool _isShowFindBackPwdButton = false;

  @override
  void initState() {
    nameController = TextEditingController();
    pwdController = TextEditingController();

    _checkDeviceAbility();
    super.initState();
  }

  ///如果question == 1 || question == 2 || verifyQRCode == 1 || verifyQRCode == 2 则需要显示找回密码
  _checkDeviceAbility() {
    JFApi.xcDevice
        .xcDeviceSafeAbilityNotLogin(deviceId: widget.deviceId)
        .then((value) {
      GetSafetyAbilityModel model =
          GetSafetyAbilityModel.fromJson(Map<String, dynamic>.from(value));
      int questionAbility = -1;
      int verifyQRCode = -1;
      if (model.getSafetyAbility != null) {
        if (model.getSafetyAbility!.question != null) {
          questionAbility = model.getSafetyAbility!.question!;
        }
        if (model.getSafetyAbility!.verifyQRCode != null) {
          verifyQRCode = model.getSafetyAbility!.verifyQRCode!;
        }
      }
      setState(() {
        _isShowFindBackPwdButton = questionAbility == 1 ||
            questionAbility == 2 ||
            verifyQRCode == 1 ||
            verifyQRCode == 2;
      });
    }).catchError((error) {
      ///获取失败不做提示
      // KToast.show(status: kErrorMsg(error));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(18))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('设备密码错误'),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              icon: Icon(Icons.person),
              hintText: "请输入用户名",
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: pwdController,
            decoration: const InputDecoration(
              icon: Icon(Icons.password),
              hintText: "请输入密码",
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                  onPressed: () {
                    widget.completion(nameController.text, pwdController.text);
                  },
                  child: const Text("登录设备")),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onCancel();
                  },
                  child: const Text("取消"))
            ],
          ),
          Offstage(
            offstage: !_isShowFindBackPwdButton,
            child: Column(
              children: [
                const Divider(),
                InkWell(
                  onTap: () {
                    widget.onFindPwd();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    child: const Text(
                      '找回设备密码',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                const Divider(),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    pwdController.dispose();
    KToast.dismissInDispose();
    super.dispose();
  }
}
