import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

import 'controller/device_alarm_controller.dart';

// ignore: must_be_immutable
class DeviceAlarmPage extends StatefulWidget {
  const DeviceAlarmPage(
      {Key? key, required this.deviceId, required this.channel})
      : super(key: key);

  final String deviceId;
  final int channel;

  @override
  State<DeviceAlarmPage> createState() => _DeviceAlarmPageState();
}

class _DeviceAlarmPageState extends State<DeviceAlarmPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) =>
            DeviceAlarmController(context: context, deviceId: widget.deviceId),
        builder: (context, child) {
          return Consumer<DeviceAlarmController>(
              builder: (context, controller, child) {
            return Scaffold(
                appBar: AppBar(
                  title: Text(TR.current.alarm),
                ),
                body: ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      final section = controller.dataSource[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (section.title?.isNotEmpty == true)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 5, bottom: 8),
                                child: Text(
                                  section.title!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: _buildSectionItems(section.items),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: controller.dataSource.length));
          });
        });
  }

  List<Widget> _buildSectionItems(List<ListTile> items) {
    List<Widget> widgets = [];
    for (int i = 0; i < items.length; i++) {
      widgets.add(items[i]);
      if (i != items.length - 1) {
        widgets.add(const Divider(
          height: 1,
          indent: 15,
          endIndent: 15,
        ));
      }
    }
    return widgets;
  }

  @override
  void dispose() {
    KToast.dismissInDispose();
    super.dispose();
  }
}
