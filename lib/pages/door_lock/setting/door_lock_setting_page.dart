import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_parse.dart';
import 'package:fcloudsdk_example/pages/door_lock/repository/door_lock_local.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/door_lock_config_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:flutter/material.dart';

///门锁设置首页
class DoorLockSettingPage extends StatefulWidget {
  final String deviceId;

  const DoorLockSettingPage({super.key, required this.deviceId});

  @override
  State<DoorLockSettingPage> createState() => _DoorLockSettingPageState();
}

class _DoorLockSettingPageState extends State<DoorLockSettingPage> {
  DoorLockSetConfig? _setConfig;

  @override
  void initState() {
    super.initState();
    final cachedRaw =
        DoorLockLocalCache.doorlockOnlineConfig(deviceId: widget.deviceId);
    if (cachedRaw.isNotEmpty) {
      _setConfig = parseRawToSetConfig(cachedRaw);
    }
    _queryConfig();
  }

  Future<void> _queryConfig() async {
    final rawList =
        await DoorLockHelper.instance.queryOnlineCongfig(widget.deviceId);
    if (!mounted || rawList == null || rawList.isEmpty) return;
    _setConfig = parseRawToSetConfig(rawList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(title: const Text('设置')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('锁具配置'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DoorLockConfigPage(
                        deviceId: widget.deviceId,
                        initSetConfig: _setConfig,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
