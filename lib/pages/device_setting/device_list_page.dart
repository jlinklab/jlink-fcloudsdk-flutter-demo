import 'dart:async';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import '../../api/share_api.dart';
import '../../common/code_prase.dart';
import '../../common/event.dart';
import '../../generated/l10n.dart';
import '../../manager/device_manager.dart';
import '../../manager/push_manager.dart';
import '../../models/user_instance.dart';
import '../../views/toast/toast.dart';
import '../alarm_message/alarm_message_list_page.dart';
import '../share/device_share_page.dart';
import 'model/model.dart';
import 'viewmodel/device_list_view_model.dart';

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
    context.read<DevListViewModel>().onRefresh().then((_) {
      _checkPendingShares();
    });
    super.initState();
    _subscription = eventBus.on<RemoveDeviceUpdateEvent>().listen((_) {
      if (mounted) {
        context.read<DevListViewModel>().onRefresh();
      }
    });
  }

  /// 检查是否有待接受的分享设备，弹出弹窗
  void _checkPendingShares() {
    final pendingList = DeviceManager.instance.sharedNotAgreeDeviceList;
    if (pendingList.isEmpty || !mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => SizedBox(
          width: 400,
          child: AlertDialog(
            title: Text(TR.current.pendingShareDevices),
            content: SizedBox(
              width: double.maxFinite,
              child: pendingList.isEmpty
                  ? const SizedBox(
                      width: 50,
                      height: 50,
                      child: Center(child: Text("无待接受设备")),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: pendingList.length,
                      itemBuilder: (context, index) {
                        final device = pendingList[index];
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 5),
                          title: Text(
                            device.nickname ?? device.uuid,
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(
                            device.uuid,
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  try {
                                    await context
                                        .read<DevListViewModel>()
                                        .acceptShare(device);
                                    setState(() {
                                      pendingList.remove(device);
                                    });
                                    KToast.show(
                                        status: TR.current.acceptSuccess);
                                  } catch (e) {
                                    KToast.show(
                                        status:
                                            '${TR.current.acceptFailed}: $e');
                                  }
                                },
                                child: Text(TR.current.acceptShare),
                              ),
                              TextButton(
                                onPressed: () async {
                                  try {
                                    await context
                                        .read<DevListViewModel>()
                                        .refuseShare(device);
                                    setState(() {
                                      pendingList.remove(device);
                                    });
                                    KToast.show(
                                        status: TR.current.refuseSuccess);
                                  } catch (e) {
                                    KToast.show(
                                        status:
                                            '${TR.current.refuseFailed}: $e');
                                  }
                                },
                                child: Text(TR.current.refuseShare),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(TR.current.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  late TabController _tabController;
  late StreamSubscription _subscription;

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
    _subscription.cancel();
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
                                            'devId': device.uuid,
                                            'type': widget.type.toString(),
                                            'pid': device.pid.isNotEmpty ? device.pid : '-1',
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
                                if (!device.fromShare)
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(builder:
                                                (BuildContext context) {
                                          return DeviceSharePage(
                                              device: device);
                                        }));
                                      },
                                      child: Text(TR.current.share)),
                                const SizedBox(width: 16),
                              ],
                            ),
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
      KToast.show(status: kErrorMsg(error));
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
      KToast.show(status: kErrorMsg(error));
      //取消失败也要删除
      _toDelete(deviceID);
    });
  }

  _toDelete(String deviceID) async {
    final Device? device = DeviceManager.instance.getDevice(deviceId: deviceID);
    if (device == null) {
      KToast.show(status: '设备不存在');
      return;
    }
    KToast.show();
    try {
      if (device.fromShare) {
        await shareAPI.refuseSharedDevice((device as SharedDevice).shareId);
      } else {
        await JFApi.xcAccount.xcRemoveDevice(deviceID);
      }
      await PushManager.instance.unsubscribe(deviceID);
      Navigator.of(context).pop();
      DeviceManager.instance
          .removeDevice(deviceId: deviceID, type: widget.type);
      await DeviceManager.instance.refreshDeviceList();
      setState(() {});
      KToast.dismiss();
    } catch (error) {
      KToast.show(status: kErrorMsg(error));
    }
  }
}
