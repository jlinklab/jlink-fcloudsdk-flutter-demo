import 'package:fcloudsdk/utils/extensions.dart';
import 'package:fcloudsdk_example/api/device_api.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/manager/user_group_manager.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/models/user_room.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';

///移动设备到特定房间
class MoveDevicePage extends StatefulWidget {
  const MoveDevicePage({super.key, required this.deviceNo});

  final String deviceNo;

  @override
  State<MoveDevicePage> createState() => _MoveDevicePageState();
}

class _MoveDevicePageState extends State<MoveDevicePage> {
  UserRoom? checkedRoom;
  List<UserRoom> rooms = [];

  Device? get _device =>
      DeviceManager.instance.getDevice(deviceId: widget.deviceNo);

  ///设备所属家庭组，设备上没有该字段时兜底用当前家庭组
  String get _userGroupId {
    final String groupId = _device?.userGroupId ?? '';
    return groupId.isNotEmpty
        ? groupId
        : UserGroupManager.instance.currentGroupId;
  }

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  ///进页拉取设备所属家庭组下的房间，拉完后按设备当前房间定位勾选项
  Future<void> _loadRooms() async {
    final device = _device;
    if (device == null) {
      KToast.show(status: '获取设备信息失败');
      return;
    }
    await UserGroupManager.instance.requestRoom(_userGroupId);
    final List<UserRoom> list = UserGroupManager.instance.getUserRooms();
    if (!mounted) {
      return;
    }
    setState(() {
      rooms = list;
      checkedRoom = list.firstWhereOrNull((e) => e.id == device.roomId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        title: const Text('设备位置'),
        actions: [
          IconButton(
            onPressed: _moveDevice,
            icon: const Icon(Icons.check_rounded, color: Color(0xFF1E1E1E)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 16),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          UserRoom room = rooms[index];
          return ListTile(
            tileColor: Colors.white,
            title: Text(room.roomName ?? ''),
            trailing: checkedRoom?.id == room.id
                ? const Icon(Icons.check, color: Color(0xFF00B294))
                : null,
            onTap: () {
              setState(() {
                checkedRoom = room;
              });
            },
          );
        },
      ),
    );
  }

  ///提交设备所在房间，成功后回写设备上的房间信息
  Future<void> _moveDevice() async {
    final room = checkedRoom;
    final device = _device;
    if (room == null || device == null) {
      return;
    }
    KToast.show();
    try {
      await deviceAPI.moveDeviceToRoom(
        roomId: room.id ?? '',
        userGroupId: _userGroupId,
        deviceNos: [widget.deviceNo],
      );
      device.roomId = room.id;
      device.roomName = room.roomName;
      KToast.show(status: '设置成功');
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }
  }
}
