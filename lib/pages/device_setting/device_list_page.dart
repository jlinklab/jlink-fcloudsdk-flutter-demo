import 'dart:async';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fcloudsdk/api/api_center.dart';
import '../../api/share_api.dart';
import '../../common/code_prase.dart';
import '../../common/event.dart';
import '../../generated/l10n.dart';
import '../../manager/device_manager.dart';
import '../../manager/push_manager.dart';
import '../../models/user_instance.dart';
import '../../views/toast/toast.dart';
import '../alarm_message/alarm_message_list_page.dart';
import '../cloud/device_cloud_service_manager.dart';
import '../cloud/model/device_cloud.dart';
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
      shouldRebuild: (pre, curr) => true,
      selector: (_, devList) =>
          widget.type == 0 ? devList.mineDevs : devList.shareDevs,
      builder: (context, devices, _) {
        return RefreshIndicator(
          child: devices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.devices_other_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(TR.current.noDevice,
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    return _DeviceCard(
                      device: devices[index],
                      type: widget.type,
                    );
                  },
                  itemCount: devices.length,
                ),
          onRefresh: () => context.read<DevListViewModel>().onRefresh(),
        );
      },
    );
  }
}

/// 设备卡片组件，包含设备信息、云服务状态和操作按钮
class _DeviceCard extends StatelessWidget {
  final Device device;
  final int type;

  const _DeviceCard({Key? key, required this.device, required this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cloudService = DeviceCloudServiceManager.instance
        .getCloudService(deviceId: device.uuid);
    final isOnline = device.state > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.pushNamed('preview', pathParameters: {
            'devId': device.uuid,
            'type': type.toString(),
            'pid': device.pid.isNotEmpty ? device.pid : '-1'
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 第一行：设备名称 + 在线状态
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (device.nickname != null && device.nickname!.isNotEmpty)
                          ? device.nickname!
                          : device.uuid,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (cloudService != null)
                    _buildCloudBadge(cloudService.cloudServerStatus),
                ],
              ),
              const SizedBox(height: 8),
              // 第二行：设备序列号
              Text(
                device.uuid,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              // 第三行：操作按钮
              Row(
                children: [
                  _ActionButton(
                    icon: Icons.videocam,
                    label: TR.current.preview,
                    onTap: () {
                      context.pushNamed('preview', pathParameters: {
                        'devId': device.uuid,
                        'type': type.toString(),
                        'pid': device.pid.isNotEmpty ? device.pid : '-1',
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.notifications_outlined,
                    label: TR.current.message,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              AlarmMessageListPage(deviceId: device.uuid)));
                    },
                  ),
                  if (!device.fromShare) ...[
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.share_outlined,
                      label: TR.current.share,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => DeviceSharePage(device: device)));
                      },
                    ),
                  ],
                  const Spacer(),
                  _ActionButton(
                    icon: Icons.delete_outline,
                    label: TR.current.delete,
                    isDestructive: true,
                    onTap: () => onDeleteDialog(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 云服务状态标签
  Widget _buildCloudBadge(CloudServerStatus status) {
    Color bgColor;
    Color iconColor;
    IconData iconData;

    switch (status) {
      case CloudServerStatus.active:
        bgColor = const Color(0xFF12B5B0).withValues(alpha: 0.1);
        iconColor = const Color(0xFF12B5B0);
        iconData = Icons.cloud;
        break;
      case CloudServerStatus.notPurchased:
        bgColor = const Color(0xFFF27900).withValues(alpha: 0.1);
        iconColor = const Color(0xFFF27900);
        iconData = Icons.cloud_queue;
        break;
      case CloudServerStatus.expired:
        bgColor = const Color(0xFFEF5756).withValues(alpha: 0.1);
        iconColor = const Color(0xFFEF5756);
        iconData = Icons.cloud_queue;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 16,
      ),
    );
  }

  void onDeleteDialog(BuildContext context) {
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
                      Navigator.of(context).pop();
                      _toDelete(context);
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
      },
    );
  }

  _toDelete(BuildContext context) async {
    final Device? dev = DeviceManager.instance.getDevice(deviceId: device.uuid);
    if (dev == null) {
      KToast.show(status: '设备不存在');
      return;
    }
    final viewModel = context.read<DevListViewModel>();
    KToast.show();
    try {
      if (dev.fromShare) {
        await shareAPI.refuseSharedDevice((dev as SharedDevice).shareId);
      } else {
        await JFApi.xcAccount.xcRemoveDevice(device.uuid);
      }
      await PushManager.instance.unsubscribe(device.uuid);
      await viewModel.deleteDev(device.uuid, type);
      KToast.dismiss();
    } catch (error) {
      KToast.show(status: kErrorMsg(error));
    }
  }
}

/// 操作按钮组件
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : Colors.blue;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
