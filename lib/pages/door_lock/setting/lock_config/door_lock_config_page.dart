import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk_example/common/named_route.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/auto_lock/door_lock_auto_lock_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/door_lock_config_controller.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/factory_reset/door_lock_factory_reset_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/human_sensor/door_lock_human_sensor_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/install_setting/door_lock_install_setting_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/language/door_lock_language_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/normal_open_mode/door_lock_normal_open_mode_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/opening_direction_self_check/door_opening_direction_self_check_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/pir_config/door_lock_pir_config_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/reset_button/door_lock_reset_button_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/stay_detective/door_lock_stay_detective_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/verify_manager_pwd/door_lock_verify_manager_pwd_page.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///锁具配置首页
class DoorLockConfigPage extends StatefulWidget {
  final String deviceId;
  final DoorLockSetConfig? initSetConfig;

  const DoorLockConfigPage({
    super.key,
    required this.deviceId,
    this.initSetConfig,
  });

  @override
  State<DoorLockConfigPage> createState() => _DoorLockConfigPageState();
}

class _DoorLockConfigPageState extends State<DoorLockConfigPage>
    with RouteAware {
  late DoorLockConfigController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  ///从二级配置页返回时重新获取最新配置
  @override
  void didPopNext() {
    super.didPopNext();
    controller.queryConfig();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockConfigController(
        context: context,
        deviceId: widget.deviceId,
        initSetConfig: widget.initSetConfig,
      ),
      child: Consumer<DoorLockConfigController>(
        builder: (context, pageController, _) {
          controller = pageController;
          return Scaffold(
            backgroundColor: const Color(0xFFF7F7F9),
            appBar: AppBar(title: const Text('锁具配置')),
            body: _buildBody(context, pageController),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, DoorLockConfigController controller) {
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(controller.loadError!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: controller.queryConfig,
              child: const Text('重新读取'),
            ),
          ],
        ),
      );
    }
    if (!controller.hasAnyConfig) {
      return const Center(child: Text('当前设备暂无可配置项'));
    }

    final children = <Widget>[];
    void addItem(Widget item) {
      if (children.isNotEmpty) {
        children.add(const Divider(height: 1, indent: 16, endIndent: 16));
      }
      children.add(item);
    }

    void addPirItem() {
      if (!controller.showPirConfig) return;
      addItem(_arrowItem(
        title: controller.pirConfigTitle,
        value: controller.pirConfigText,
        enabled: controller.setConfig?.pirConfig != null,
        onTap: () async {
          final initialConfig = controller.setConfig;
          if (initialConfig == null) return;
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => controller.showHumanDetection
                  ? DoorLockStayDetectivePage(
                      deviceId: widget.deviceId,
                      initSetConfig: initialConfig,
                    )
                  : DoorLockPirConfigPage(
                      deviceId: widget.deviceId,
                      initSetConfig: initialConfig,
                    ),
            ),
          );
          final currentConfig = controller.setConfig;
          if (currentConfig != null) {
            controller.updateSetConfig(currentConfig);
          }
        },
      ));
    }

    void addHumanSensorItem() {
      if (!controller.showHumanSensor) return;
      addItem(_arrowItem(
        title: '人体感应',
        value: controller.humanSensorText,
        enabled: controller.setConfig?.humanSensor != null,
        onTap: () async {
          final initialConfig = controller.setConfig;
          if (initialConfig == null) return;
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DoorLockHumanSensorPage(
                deviceId: widget.deviceId,
                initSetConfig: initialConfig,
              ),
            ),
          );
          final currentConfig = controller.setConfig;
          if (currentConfig != null) {
            controller.updateSetConfig(currentConfig);
          }
        },
      ));
    }

    if (controller.isIot) {
      addPirItem();
      addHumanSensorItem();
    }
    if (controller.showAutoLock) {
      addItem(_arrowItem(
        title: '自动关锁',
        value: controller.autoLockText,
        enabled: controller.setConfig?.autoLock != null,
        onTap: () async {
          final initialConfig = controller.setConfig;
          if (initialConfig == null) return;
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DoorLockAutoLockPage(
                deviceId: widget.deviceId,
                initSetConfig: initialConfig,
              ),
            ),
          );
          final currentConfig = controller.setConfig;
          if (currentConfig != null) {
            controller.updateSetConfig(currentConfig);
          }
        },
      ));
    }
    if (controller.showNormalOpen) {
      addItem(_arrowItem(
        title: '常开模式',
        value: controller.normalOpenText,
        enabled: controller.setConfig?.bleOpenMode != null,
        onTap: () async {
          final config = await Navigator.of(context).push<DoorLockSetConfig>(
            MaterialPageRoute(
              builder: (_) => DoorLockNormalOpenModePage(
                deviceId: widget.deviceId,
                initSetConfig: controller.setConfig!,
              ),
            ),
          );
          if (config != null) controller.updateSetConfig(config);
        },
      ));
    }
    if (controller.showVolume) {
      addItem(SwitchListTile(
        title: const Text('音量'),
        value: (controller.setConfig?.volumeControl ?? 0) > 0,
        onChanged: controller.setConfig?.volumeControl != null
            ? controller.updateVolumeEnabled
            : null,
      ));
      if ((controller.setConfig?.volumeControl ?? 0) > 0) {
        addItem(_arrowItem(
          title: '音量档位',
          value: controller.volumeText,
          enabled: true,
          onTap: () async {
            final options =
                controller.device.props?.contains('TwoLevelsVolume') == true
                    ? const {1: '低', 3: '高'}
                    : const {1: '低', 2: '中', 3: '高'};
            final level = await _selectOption(
              context,
              '音量档位',
              options,
              controller.setConfig?.volumeControl,
            );
            if (level != null) await controller.updateVolume(level);
          },
        ));
      }
    }
    if (controller.showLanguage) {
      addItem(_arrowItem(
        title: '语言设置',
        value: controller.languageText,
        enabled: controller.setConfig?.supportLans?.isNotEmpty == true,
        onTap: () async {
          final initialConfig = controller.setConfig;
          if (initialConfig == null) return;
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DoorLockLanguagePage(
                deviceId: widget.deviceId,
                initSetConfig: initialConfig,
              ),
            ),
          );
          final currentConfig = controller.setConfig;
          if (currentConfig != null) {
            controller.updateSetConfig(currentConfig);
          }
        },
      ));
    }
    if (controller.showFaceAlarmTone) {
      addItem(SwitchListTile(
        title: const Text('人脸验证提示音'),
        value: controller.setConfig?.faceAlarmTone == 1,
        onChanged: controller.setConfig?.faceAlarmTone != null
            ? controller.updateFaceAlarmTone
            : null,
      ));
    }
    if (controller.showUnlockMode) {
      addItem(_arrowItem(
        title: '开锁模式',
        value: controller.unlockModeText,
        enabled: controller.setConfig?.unlockMode != null,
        onTap: () async {
          final mode = await _selectOption(
            context,
            '开锁模式',
            const {0: '单独开锁', 1: '组合开锁'},
            controller.setConfig?.unlockMode,
          );
          if (mode != null) await controller.updateUnlockMode(mode);
        },
      ));
    }
    if (controller.showDeployDefense) {
      addItem(SwitchListTile(
        title: const Text('防撬报警'),
        value: controller.setConfig?.deployDefense == 1,
        onChanged: controller.setConfig?.deployDefense != null
            ? controller.updateDeployDefense
            : null,
      ));
    }
    if (controller.showSupportReverseLock) {
      addItem(SwitchListTile(
        title: const Text('支持反锁'),
        value: controller.setConfig?.supportDeadBol == 1,
        onChanged: controller.setConfig?.supportDeadBol != null
            ? controller.updateSupportReverseLock
            : null,
      ));
    }
    if (!controller.isIot) addPirItem();
    if (controller.showResetButton) {
      addItem(_arrowItem(
        title: '重置键',
        value: controller.resetButtonText,
        enabled: controller.setConfig?.resetButton != null,
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DoorLockResetButtonPage(
                deviceId: widget.deviceId,
                initSetConfig: controller.setConfig!,
              ),
            ),
          );
          final config = controller.setConfig;
          if (config != null) controller.updateSetConfig(config);
        },
      ));
    }
    if (controller.showOpeningDirectionSelfCheck) {
      addItem(_arrowItem(
        title: '开锁方向自检',
        value: '',
        enabled: true,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DoorOpeningDirectionSelfCheckPage(
                deviceId: widget.deviceId,
              ),
            ),
          );
        },
      ));
    }
    if (controller.showUnlockDirection) {
      addItem(_arrowItem(
        title: '开锁方向',
        value: controller.unlockDirectionText,
        enabled: controller.setConfig?.unlockDirection != null,
        onTap: () async {
          final direction = await _selectOption(
            context,
            '开锁方向',
            const {0: '左开', 1: '右开'},
            controller.setConfig?.unlockDirection,
          );
          if (direction != null) {
            await controller.updateUnlockDirection(direction);
          }
        },
      ));
    }
    if (controller.showInstallSettings) {
      addItem(_arrowItem(
        title: '安装设置',
        value: '',
        enabled: controller.setConfig != null,
        onTap: () async {
          if (!controller.hadInstallVerification) {
            final verified = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => DoorLockVerifyManagerPwdPage(
                  deviceId: widget.deviceId,
                ),
              ),
            );
            if (verified != true || !context.mounted) return;
            controller.markInstallSettingsVerified();
          }
          final initialConfig = controller.setConfig;
          if (initialConfig == null) return;
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DoorLockInstallSettingPage(
                deviceId: widget.deviceId,
                initSetConfig: initialConfig,
              ),
            ),
          );
          final currentConfig = controller.setConfig;
          if (currentConfig != null) {
            controller.updateSetConfig(currentConfig);
          }
        },
      ));
    }
    if (controller.showFactoryReset) {
      addItem(_arrowItem(
        title: '锁具恢复出厂设置',
        value: '',
        enabled: true,
        onTap: () {
          if (controller.device.doolockCmdStatus == DoolockCmdStatus.offline) {
            KToast.show(status: '当前设备离线，无法恢复出厂设置');
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  DoorLockFactoryResetPage(deviceId: widget.deviceId),
            ),
          );
        },
      ));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ],
    );
  }

  Widget _arrowItem({
    required String title,
    required String value,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return ListTile(
      enabled: enabled,
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: Color(0xFF777777))),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }

  Future<int?> _selectOption(
    BuildContext context,
    String title,
    Map<int, String> options,
    int? current,
  ) {
    return showDialog<int>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(title),
        children: options.entries
            .map((entry) => SimpleDialogOption(
                  onPressed: () => Navigator.of(dialogContext).pop(entry.key),
                  child: Row(
                    children: [
                      Expanded(child: Text(entry.value)),
                      if (entry.key == current)
                        const Icon(Icons.check, size: 20),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
