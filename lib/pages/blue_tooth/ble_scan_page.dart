// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/add_device/models/scanned_device.dart';
import 'package:fcloudsdk_example/pages/blue_tooth/ble_wifi_info_input_page.dart';
import 'package:fcloudsdk_example/pages/blue_tooth/controller/main_ble_scan_controller.dart';

class BleScanPage extends StatefulWidget {
  const BleScanPage({Key? key}) : super(key: key);

  @override
  State<BleScanPage> createState() => _BleScanPageState();
}

class _BleScanPageState extends State<BleScanPage>
    with SingleTickerProviderStateMixin {
  bool isScanning = true;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MainBleScanController(context: context),
        builder: (context, child) {
          return Consumer<MainBleScanController>(
              builder: (context, controller, child) {
            return Scaffold(
              appBar: AppBar(
                title: Text(TR.current.bluetooth),
              ),
              body: controller.scannedBleDeviceList.isEmpty
                  ? Center(
                      child: controller.isScanning()
                          ? RotationTransition(
                              turns: _animation,
                              child: const SizedBox(
                                width: 100,
                                height: 100,
                                child: Icon(Icons.refresh, color: Colors.blue),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                controller.start();
                              },
                              child: Text(TR.current.restartScan)),
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) {
                        ScannedDevice device =
                            controller.scannedBleDeviceList[index];
                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return BleWifiInfoInputPage(
                                  mac: device.bleDevice!.uuid);
                            }));
                            if (result != null) {
                              Navigator.of(context).pop(result);
                            }
                          },
                          child: ListTile(
                            title: Text(device.onGetDeviceName()),
                          ),
                        );
                      },
                      itemCount: controller.scannedBleDeviceList.length,
                    ),
            );
          });
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
