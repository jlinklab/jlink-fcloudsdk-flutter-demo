import 'package:flutter/material.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/common/match.dart';
import 'package:xcloudsdk_flutter_example/pages/add_device/models/add_device_center.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

///填写设备名称页面
class AddDeviceFillDeviceNamePage extends StatefulWidget {
  final DeviceAddModel model;
  const AddDeviceFillDeviceNamePage({Key? key, required this.model})
      : super(key: key);

  @override
  State<AddDeviceFillDeviceNamePage> createState() =>
      _AddDeviceFillDeviceNamePageState();
}

class _AddDeviceFillDeviceNamePageState
    extends State<AddDeviceFillDeviceNamePage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  _onChange() {
    final deviceNickname = _nameController.text;
    if (JFMatch.kIsValidDeviceName(deviceNickname) == false) {
      KToast.show(status: '密码格式不符');
      return;
    }
    widget.model.deviceName = deviceNickname;

    ///调用最后的添加步骤
    DeviceAddCenter.instance.addDeviceWithModel(widget.model).then((value) {
      KToast.show(status: '添加成功');

      ///返回首页
      Navigator.popUntil(context, (route) => route.isFirst);
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置设备名称'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                icon: Icon(Icons.book),
                hintText: '请填写设备名称',
              ),
            ),
            const Text('4-16位长度中文、数字和字母'),
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
                child: const Text(
                  '确定',
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
    super.dispose();
  }
}
