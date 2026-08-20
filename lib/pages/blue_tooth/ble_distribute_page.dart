import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/blue_tooth/controller/main_ble_distribute_controller.dart';

class BleDistributePage extends StatefulWidget {
  const BleDistributePage(
      {Key? key, required this.ssid, required this.password, required this.mac})
      : super(key: key);
  final String ssid;
  final String password;
  final String mac;

  @override
  State<BleDistributePage> createState() => _BleDistributePageState();
}

class _BleDistributePageState extends State<BleDistributePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MainBleDistributeController(
            context: context,
            mac: widget.mac,
            ssid: widget.ssid,
            password: widget.password),
        builder: (context, child) {
          return Consumer<MainBleDistributeController>(
              builder: (context, controller, child) {
            return Scaffold(
              appBar: AppBar(
                title: Text(TR.current.bluetooth),
              ),
              body: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 200,
                    child: const Text(''),
                  ),
                  Expanded(
                      child: ListView.builder(
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          controller.logs[index],
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                    itemCount: controller.logs.length,
                  ))
                ],
              ),
            );
          });
        });
  }
}
