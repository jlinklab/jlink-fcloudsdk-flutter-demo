// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:fcloudsdk_example/common/match.dart';
import 'package:fcloudsdk_example/pages/add_device/add_device_fill_device_name_page.dart';
import 'package:fcloudsdk_example/pages/add_device/models/add_device_center.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';


///重置用户名密码界面
class ResetDeviceRandomLoginNameAndPasswordPage extends StatefulWidget {
  final DeviceAddModel model;
  const ResetDeviceRandomLoginNameAndPasswordPage({Key? key, required this.model}) : super(key: key);

  @override
  State<ResetDeviceRandomLoginNameAndPasswordPage> createState() => _ResetDeviceRandomLoginNameAndPasswordPageState();
}

class _ResetDeviceRandomLoginNameAndPasswordPageState extends State<ResetDeviceRandomLoginNameAndPasswordPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _pwdAgainController = TextEditingController();


  @override
  void initState() {
    super.initState();
  }

  _onChange() {
    final deviceLoginName = _nameController.text;
    final deviceLoginPwd = _pwdController.text;
    final deviceLoginPwdAgain = _pwdAgainController.text;
    if (deviceLoginName.isEmpty || deviceLoginPwd.isEmpty || deviceLoginPwdAgain.isEmpty) {
      KToast.show(status: '请完善用户信息');
      return;
    }

    if (deviceLoginName == deviceLoginPwd) {
      KToast.show(status: '登录名不能密码相同');
      return;
    }

    if (deviceLoginPwd != deviceLoginPwdAgain) {
      KToast.show(status: '两次密码不一致');
      return;
    }

    if (JFMatch.kIsValidDeviceLoginName(deviceLoginName) == false) {
      KToast.show(status: '登录名格式不符');
      return;
    }

    if (JFMatch.kIsValidDevicePwd(deviceLoginPwd) == false) {
      KToast.show(status: '密码格式不符');
      return;
    }


    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
      DeviceAddModel model = DeviceAddModel();
      return AddDeviceFillDeviceNamePage(model: model,);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置设备用户名和密码'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                icon:  Icon(Icons.book),
                hintText: '请填写设备登录名',
              ),
            ),
            const Text('4-15位长度 包含数字和字母, 不支持下列的字符 admin、root、system、user、guest、select、delete'),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _pwdController,
              decoration: const InputDecoration(
                icon:  Icon(Icons.password),
                hintText: '请填写设备密码',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _pwdAgainController,
              decoration: const InputDecoration(
                icon:  Icon(Icons.password),
                hintText: '请再次填写设备密码',
              ),
            ),
            const Text('8~64个字符,只能包含字母和数字,至少有一个字母,至少有一个数字'),
            const SizedBox(
              height: 40,
            ),
            InkWell(
              onTap: () {
                _onChange();
              },
              child: Container(
                height: 42.0,
                margin: const EdgeInsets.only(left: 15, right: 15),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Text('修改',
                  style: TextStyle(color: Colors.white, fontSize: 22.0),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pwdController.dispose();
    super.dispose();
  }
}
