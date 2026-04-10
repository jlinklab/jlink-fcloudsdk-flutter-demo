import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/models/user_instance.dart';
import 'package:xcloudsdk_flutter_example/pages/alarm_message/alarm_message_list_page.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/model/model.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/viewmodel/device_list_view_model.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';
import '../../common/code_prase.dart';

class DeviceListPage extends StatefulWidget {
  const DeviceListPage({Key? key}) : super(key: key);

  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    context.read<DevListViewModel>().onRefresh();
    super.initState();
  }

  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  context.pushNamed('addDevice').then((value) {
                    context.read<DevListViewModel>().onRefresh();
                  });
                },
                icon: const Icon(Icons.add)),
          ],
          title: Text(TR.current.deviceList),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: TR.current.myDevice),
              Tab(text: TR.current.shareDevice),
            ],
          )),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DeviceTabPage(
            type: 0,
          ),
          DeviceTabPage(
            type: 1,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class DeviceTabPage extends StatefulWidget {
  final int type;

  const DeviceTabPage({Key? key, required this.type}) : super(key: key);

  @override
  State<DeviceTabPage> createState() => _DeviceTabPageState();
}

class _DeviceTabPageState extends State<DeviceTabPage> {
  @override
  Widget build(BuildContext context) {
    return Selector<DevListViewModel, List<Device>>(
      //数据改变时是否需要重新build. Device 中的变量发生改变
      shouldRebuild: (pre, curr) => true,
      selector: (_, devList) =>
          widget.type == 0 ? devList.mineDevs : devList.shareDevs,
      builder: (context, devices, _) {
        return RefreshIndicator(
            child: devices.isEmpty
                ? Center(
                    child: Text(TR.current.noDevice),
                  )
                : Builder(builder: (context) {
                    return ListView.separated(
                      itemBuilder: (context, index) {
                        Device device = devices[index];
                        return Column(
                          children: [
                            ListTile(
                              title: Text(device.nickname ?? device.uuid),
                              subtitle: Text(device.uuid),
                              leading: Icon(
                                Icons.online_prediction_rounded,
                                color: device.state > 0
                                    ? Colors.blueAccent
                                    : Colors.grey,
                              ),
                              trailing: ElevatedButton(
                                  onPressed: () {
                                    onDelete(device.uuid, context);
                                  },
                                  child: Text(TR.current.delete)),
                            ),
                            Row(
                              children: [
                                const SizedBox(width: 16),
                                ElevatedButton(
                                    onPressed: () {
                                      context.pushNamed('preview',
                                          pathParameters: {
                                            'devId': device.uuid
                                          });
                                    },
                                    child: Text(TR.current.preview)),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) {
                                        return AlarmMessageListPage(
                                            deviceId: device.uuid);
                                      }));
                                    },
                                    child: Text(TR.current.message)),
                                const SizedBox(width: 16),
                              ],
                            )
                          ],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          color: Colors.grey,
                        );
                      },
                      itemCount: devices.length,
                    );
                  }),
            onRefresh: () => context.read<DevListViewModel>().onRefresh());
      },
    );
  }

  void onDelete(String uuid, BuildContext context) {
    showDialog(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("警告"),
            content: const SingleChildScrollView(
              child: ListBody(
                children: [
                  Text("确定要删除设备嘛"),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () {
                        _onGetPhoneToken(uuid);
                      },
                      child: const Text("确定")),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("取消")),
                ],
              )
            ],
          );
        });
  }

  _onGetPhoneToken(String deviceID) {
    KToast.show();
    JFApi.xcAlarmMessage.xcGetPhoneToken().then((value) {
      KToast.dismiss();
      Map<String, dynamic> response = value;
      String token = response['token'];
      _onCancelAlarmSubscribe(deviceID, token);
    }).catchError((error) {
      KToast.show(status: KErrorMsg(error));
      //失败也要删除
      _toDelete(deviceID);
    });
  }

  _onCancelAlarmSubscribe(String deviceID, String token) {
    KToast.show();
    AlarmSubscribebaseBody body = AlarmSubscribebaseBody(sn: deviceID);
    List<AlarmSubscribebaseBody> bodyList = [];
    bodyList.add(body);

    String userId = context.read<UserInfo>().userId;
    AlarmUnsubscribe model =
        AlarmUnsubscribe.byUserId(snlist: bodyList, userId: userId);
    JFApi.xcAlarmMessage.xcUnsubscribeDevicesAlarmMessages(model).then((value) {
      KToast.dismiss();
      _toDelete(deviceID);
    }).catchError((error) {
      KToast.show(status: KErrorMsg(error));
      //取消失败也要删除
      _toDelete(deviceID);
    });
  }

  _toDelete(String deviceID) {
    KToast.show();
    JFApi.xcAccount.xcRemoveDevice(deviceID).then((value) {
      KToast.dismiss();
      Navigator.of(context).pop();
      context.read<DevListViewModel>().deleteDev(deviceID, widget.type);
    }).catchError((error) {
      KToast.show(status: KErrorMsg(error));
    });
  }
}
