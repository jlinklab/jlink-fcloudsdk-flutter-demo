import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk_example/pages/door_lock/model/user_manager_ui.dart';
import 'package:flutter/material.dart';

///设置下的用户管理入口页
class DoorLockUserManagerPage extends StatelessWidget {
  final List<UserManagerUI> userManagerUIList;
  final void Function(UserManagerUI item) onUserManagerTap;

  const DoorLockUserManagerPage({
    super.key,
    required this.userManagerUIList,
    required this.onUserManagerTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = userManagerUIList
        .where((item) => item.type != JvssOperateType.settings)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(title: const Text('用户管理')),
      body: items.isEmpty
          ? const Center(child: Text('暂无可用用户管理功能'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  color: Colors.white,
                  child: ListTile(
                    leading: Icon(
                      item.icon,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(item.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => onUserManagerTap(item),
                  ),
                );
              },
            ),
    );
  }
}
