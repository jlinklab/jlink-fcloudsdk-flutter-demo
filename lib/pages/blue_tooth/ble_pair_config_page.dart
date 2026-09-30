import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller/main_ble_pair_config_controller.dart';

///门锁蓝牙配网页
///激活+昵称+添加服务器完成后进入：门锁初始化/等待锁端重置/真/假配网
class BlePairConfigPage extends StatefulWidget {
  const BlePairConfigPage({Key? key, required this.args}) : super(key: key);

  final BlePairConfigArgs args;

  @override
  State<BlePairConfigPage> createState() => _BlePairConfigPageState();
}

class _BlePairConfigPageState extends State<BlePairConfigPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainBlePairConfigController(
        context: context,
        args: widget.args,
      )..start(),
      child: Consumer<MainBlePairConfigController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('门锁配网')),
            body: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    controller.isDone
                        ? (controller.isFake ? '假配网完成' : '配网完成')
                        : (controller.isFail ? '失败' : controller.stage),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),

                ///等待锁端重置倒计时
                if (controller.waitResetCount > 0 && !controller.isDone)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          '等待锁端重置网络: ${controller.waitResetCount}s',
                          style: const TextStyle(color: Colors.orange),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '请在门锁上操作网络重置，等待指示灯变化',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.cancelWaitReset();
                            Navigator.of(context).pop();
                          },
                          child: const Text('取消等待'),
                        ),
                      ],
                    ),
                  ),

                ///日志
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.logs.length,
                    itemBuilder: (context, index) {
                      return Text(
                        controller.logs[index],
                        style: const TextStyle(fontSize: 13),
                      );
                    },
                  ),
                ),

                ///底部按钮
                if (controller.isFail)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('返回'),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => controller.retry(),
                            child: const Text('重试'),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (controller.isDone)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('完成'),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
