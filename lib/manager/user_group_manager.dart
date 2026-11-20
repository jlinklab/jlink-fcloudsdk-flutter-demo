import 'package:flutter/foundation.dart';
import 'package:fcloudsdk_example/api/door_lock_api.dart';
import 'package:fcloudsdk_example/api/home_api.dart';
import 'package:fcloudsdk_example/models/user_room.dart';

/// 家庭组数据（静默管理，UI不显示）
class UserGroup {
  String id;
  String groupName;
  String? location;
  int deviceNum;

  UserGroup({
    this.id = '',
    this.groupName = '',
    this.location,
    this.deviceNum = 0,
  });

  factory UserGroup.fromJson(Map<String, dynamic> json) {
    return UserGroup(
      id: json['id'] ?? '',
      groupName: json['groupName'] ?? '',
      location: json['location'],
      deviceNum: json['deviceNum'] ?? 0,
    );
  }
}

/// 家庭组管理器（单例）
/// demo不做家庭组UI，但静默获取默认家庭组ID供添加设备时使用
class UserGroupManager {
  static final UserGroupManager instance = UserGroupManager._();
  UserGroupManager._();

  /// 当前家庭组列表
  List<UserGroup> _groups = [];

  /// 当前家庭组下的房间列表，首位为 id 为空的「全部」占位
  final List<UserRoom> _rooms = [];

  /// [_rooms] 所属的家庭组ID，用于校验缓存是否属于目标家庭组
  /// 房间数据只在这一项与目标家庭组一致时才可复用，
  /// 否则会把其他家庭组（或切换账号前的上一个家庭组）的房间名渲染出来
  String _roomsGroupId = '';

  /// 当前选中的家庭组（默认第一个）
  UserGroup? _currentGroup;

  /// 获取当前家庭组ID（添加设备时使用）
  String get currentGroupId => _currentGroup?.id ?? '';

  /// 是否已加载家庭组
  bool get isLoaded => _groups.isNotEmpty;

  /// 从服务器刷新家庭组列表
  /// demo这里当前选中家庭判断比较粗糙，默认就是取第一个，因为demo在设备列表首页并没有 ’家庭/房间‘概念，获取当前家庭组ID仅为了在添加设备的时候传userGroupId
  /// 如果设备列表有 ’家庭/房间‘概念，需要在切换家庭后重新赋值_currentGroup
  Future<void> refreshUserGroups() async {
    try {
      final response = await doorlockAPI.getUserGroupListByPage({
        'page': 1,
        'limit': 999,
      });

      if (response != null && response['data'] != null) {
        _groups = (response['data'] as List)
            .map<UserGroup>((e) => UserGroup.fromJson(e))
            .toList();

        // 默认选中第一个
        if (_groups.isNotEmpty) {
          _currentGroup = _groups.first;
        }

        debugPrint('家庭组加载成功: ${_groups.length}个, 当前ID: $currentGroupId');
      }
    } catch (e) {
      debugPrint('获取家庭组列表失败: $e');
    }
  }

  /// 设置当前家庭组
  void setCurrentGroup(String groupId) {
    final group = _groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => UserGroup(),
    );
    if (group.id.isNotEmpty) {
      _currentGroup = group;
    }
  }

  /// 获取所有家庭组
  List<UserGroup> get allGroups => List.unmodifiable(_groups);

  /// 请求指定家庭组下的房间列表（默认房间 + 用户创建的房间）
  /// 返回是否成功获取到房间数据，供调用方决定是否重试
  Future<bool> requestRoom(String groupId) async {
    //家庭组ID为空时请求不到有效房间，直接返回，避免发无效请求
    if (groupId.isEmpty) {
      debugPrint('获取到全部房间 家庭组ID为空，跳过');
      return false;
    }
    try {
      //默认的房间与用户创建的房间互不依赖，并行请求，减少一次往返
      final List<UserRoomResponse> responses =
          await Future.wait<UserRoomResponse>([
        //默认的房间
        homeAPI.getRoomByGrop({
          'userGroupId': groupId,
          'page': 1,
          'limit': 999,
          'pid': null,
          'isDefault': true,
        }),
        //创建的房间
        homeAPI.getRoomByGrop({
          'userGroupId': groupId,
          'page': 1,
          'limit': 999,
          'pid': null,
          'isDefault': false,
        }),
      ]);
      _rooms.clear();
      _rooms.add(UserRoom(userGroupId: groupId, id: ''));
      _rooms.addAll(responses.first.rooms);
      _rooms.addAll(responses.last.rooms);
      _roomsGroupId = groupId;
      debugPrint('获取到全部房间-- ${_rooms.length}');
      return true;
    } catch (e) {
      debugPrint('获取到全部房间 失败 ${e.toString()}');
      return false;
    }
  }

  /// 获取有效房间列表，剔除 id 为空的「全部」占位
  /// [groupId] 传入时校验缓存归属：缓存不属于该家庭组则按「无缓存」处理返回空列表，
  /// 调用方此时应等待 [requestRoom] 拉取到该家庭组的房间后再渲染
  List<UserRoom> getUserRooms({String? groupId}) {
    if (groupId != null && groupId.isNotEmpty && groupId != _roomsGroupId) {
      return [];
    }
    return List.from(_rooms)..removeWhere((e) => e.id?.isEmpty ?? false);
  }

  /// 清空家庭组与房间缓存（登出时调用，避免下一个账号读到上一个账号的数据）
  void clear() {
    _groups = [];
    _currentGroup = null;
    _rooms.clear();
    _roomsGroupId = '';
  }
}
