import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/language/door_lock_language_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'door_lock_language_controller.dart';

///语言设置
class DoorLockLanguagePage extends StatelessWidget {
  final String deviceId;
  final DoorLockSetConfig initSetConfig;

  const DoorLockLanguagePage({
    super.key,
    required this.deviceId,
    required this.initSetConfig,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockLanguageController(
        context: context,
        deviceId: deviceId,
        initSetConfig: initSetConfig,
      ),
      child: Consumer<DoorLockLanguageController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop: !controller.writing,
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7F9),
              appBar: AppBar(title: const Text('语言设置')),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    child: ListTile(
                      title: const Text('当前语言'),
                      trailing: Text(controller.currentLanguageText),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('切换语言'),
                  ),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0;
                            i < controller.supportedLanguages.length;
                            i++) ...[
                          if (i > 0)
                            const Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                            ),
                          _languageItem(
                            context,
                            controller,
                            controller.supportedLanguages[i],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _languageItem(
    BuildContext context,
    DoorLockLanguageController controller,
    DoorLockLanguage language,
  ) {
    final selected = controller.currentLanguage == language;
    return ListTile(
      title: Text(doorLockLanguageName(language)),
      trailing: selected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: controller.writing || selected
          ? null
          : () => _confirmChange(context, controller, language),
    );
  }

  Future<void> _confirmChange(
    BuildContext context,
    DoorLockLanguageController controller,
    DoorLockLanguage language,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('提示'),
        content: Text('确定要将门锁语言切换为“${doorLockLanguageName(language)}”吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.changeLanguage(language);
    }
  }
}
