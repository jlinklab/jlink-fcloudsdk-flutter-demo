import 'package:flutter/material.dart';
import 'package:fcloudsdk/wifi/wifi_platform_interface.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/blue_tooth/ble_distribute_page.dart';

///蓝牙配网 输入WIFI信息
class BleWifiInfoInputPage extends StatefulWidget {
  const BleWifiInfoInputPage({Key? key, required this.mac}) : super(key: key);

  final String mac;

  @override
  State<BleWifiInfoInputPage> createState() => _BleWifiInfoInputPageState();
}

class _BleWifiInfoInputPageState extends State<BleWifiInfoInputPage> {
  String wifiName = '';
  final TextEditingController textEditingController =
      TextEditingController(text: '');

  @override
  void initState() {
    _getWifiInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.routeSetting),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Text('WIFI_NAME: $wifiName'),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: textEditingController,
              decoration: InputDecoration(hintText: TR.current.wifiPwdHint),
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return BleDistributePage(
                    ssid: wifiName,
                    password: textEditingController.text,
                    mac: widget.mac,
                  );
                }));
                if (result != null) {
                  Navigator.of(context).pop(result);
                }
              },
              child: Text(TR.current.startAdd)),
        ],
      ),
    );
  }

  void _getWifiInfo() async {
    String ssid = await WifiPlatform.instance.getSSID();
    setState(() {
      wifiName = ssid;
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
}
