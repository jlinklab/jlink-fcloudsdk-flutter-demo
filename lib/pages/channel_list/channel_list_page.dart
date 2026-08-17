import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xcloudsdk_flutter/manager/device_config_manager.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/manager/device_property_manager.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/model/model.dart';

/// NVR 通道列表页面
/// 显示 NVR 设备的通道列表，包括通道号、通道名、通道状态
/// 点击某个通道进入该通道的预览页面
class ChannelListPage extends StatefulWidget {
  const ChannelListPage({
    Key? key,
    required this.deviceId,
    required this.type,
    required this.pid,
  }) : super(key: key);

  final String deviceId;
  final int type;
  final String pid;

  @override
  State<ChannelListPage> createState() => _ChannelListPageState();
}

/// 通道信息数据模型
class _ChannelInfo {
  final int channelIndex;
  final String channelName;
  final FrontDeviceStatus status;

  _ChannelInfo({
    required this.channelIndex,
    required this.channelName,
    this.status = FrontDeviceStatus.none,
  });
}

class _ChannelListPageState extends State<ChannelListPage> {
  List<_ChannelInfo> _channels = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadChannelInfo();
  }

  /// 加载通道信息
  Future<void> _loadChannelInfo() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      // 1. 获取通道名称列表（command 1048）
      List<String> channelNames = [];
      try {
        final response =
            await DeviceConfigManager.getConfigToObject<List<String>>(
          deviceId: widget.deviceId,
          command: 1048,
          commandName: DeviceJsonName.channelTitle,
        );
        if (response.isNotEmpty) {
          channelNames = response;
        }
      } catch (e) {
        // 获取通道名称失败，尝试其他方式
      }

      // 2. 获取通道数
      int channelCount = channelNames.length;
      if (channelCount == 0) {
        channelCount = await DevicePropertyManager.instance
            .getNvrChannelCountAsync(deviceId: widget.deviceId);
      }

      // 3. 获取通道状态列表
      List<FrontDeviceStatus> channelStates = [];
      if (channelCount > 0) {
        channelStates = await DevicePropertyManager.instance.getChannelStates(
          deviceId: widget.deviceId,
          channelCount: channelCount,
        );
      }

      // 4. 如果获取不到通道名称，使用默认名称
      if (channelNames.isEmpty) {
        for (int i = 0; i < channelCount; i++) {
          channelNames.add('${TR.current.channel} $i');
        }
      }

      // 5. 构建通道列表
      _channels = List.generate(channelCount, (i) {
        return _ChannelInfo(
          channelIndex: i,
          channelName:
              i < channelNames.length ? channelNames[i] : '${TR.current.channel} $i',
          status: i < channelStates.length
              ? channelStates[i]
              : FrontDeviceStatus.none,
        );
      });
    } catch (e) {
      _errorMsg = e.toString();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 跳转到指定通道的预览页面
  void _goToPreview(int channel) {
    context.pushNamed('preview', pathParameters: {
      'devId': widget.deviceId,
      'type': widget.type.toString(),
      'pid': widget.pid,
    });
  }

  /// 获取通道状态的显示文本
  String _getStatusText(FrontDeviceStatus status) {
    switch (status) {
      case FrontDeviceStatus.connected:
        return TR.current.channelOnline;
      case FrontDeviceStatus.offline:
      case FrontDeviceStatus.iplimit:
        return TR.current.channelOffline;
      case FrontDeviceStatus.noConfig:
        return TR.current.channelNoConfig;
      case FrontDeviceStatus.noLogin:
        return TR.current.channelNoLogin;
      case FrontDeviceStatus.noConnect:
        return TR.current.channelNoConnect;
      case FrontDeviceStatus.loginFailed:
        return TR.current.channelLoginFailed;
      case FrontDeviceStatus.sleep:
        return TR.current.channelSleep;
      case FrontDeviceStatus.unKnown:
      case FrontDeviceStatus.none:
        return TR.current.channelUnknown;
    }
  }

  /// 获取通道状态的颜色
  Color _getStatusColor(FrontDeviceStatus status) {
    switch (status) {
      case FrontDeviceStatus.connected:
        return Colors.green;
      case FrontDeviceStatus.offline:
      case FrontDeviceStatus.iplimit:
        return Colors.red;
      case FrontDeviceStatus.loginFailed:
        return Colors.orange;
      case FrontDeviceStatus.noConfig:
      case FrontDeviceStatus.noLogin:
      case FrontDeviceStatus.noConnect:
        return Colors.grey;
      case FrontDeviceStatus.sleep:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.channelList),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMsg != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMsg!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadChannelInfo,
              child: Text(TR.current.retry),
            ),
          ],
        ),
      );
    }

    if (_channels.isEmpty) {
      return Center(
        child: Text(TR.current.loadChannelFailed),
      );
    }

    return ListView.separated(
      itemCount: _channels.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final channel = _channels[index];
        return _ChannelItem(
          channel: channel,
          statusText: _getStatusText(channel.status),
          statusColor: _getStatusColor(channel.status),
          onTap: () => _goToPreview(channel.channelIndex),
        );
      },
    );
  }
}

/// 通道列表项组件
class _ChannelItem extends StatelessWidget {
  const _ChannelItem({
    Key? key,
    required this.channel,
    required this.statusText,
    required this.statusColor,
    required this.onTap,
  }) : super(key: key);

  final _ChannelInfo channel;
  final String statusText;
  final Color statusColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isOnline = channel.status == FrontDeviceStatus.connected;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: statusColor,
        child: Text(
          '${channel.channelIndex}',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        channel.channelName,
        style: TextStyle(
          fontSize: 16,
          color: isOnline ? null : Colors.grey,
        ),
      ),
      subtitle: Text(
        '${TR.current.channel} ${channel.channelIndex}',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 14,
              color: statusColor,
            ),
          ),
          if (isOnline) ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ],
      ),
    );
  }
}
