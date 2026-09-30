import 'package:flutter/foundation.dart';
import 'package:fcloudsdk_example/api/door_lock_api.dart';

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
        if (_groups.isNotEmpty && _currentGroup == null) {
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
}
