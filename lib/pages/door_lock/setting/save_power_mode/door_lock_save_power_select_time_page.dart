import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:flutter/material.dart';

///触发模式延时选择页
class DoorLockSavePowerSelectTimePage extends StatefulWidget {
  final int originDelay;

  const DoorLockSavePowerSelectTimePage({super.key, required this.originDelay});

  @override
  State<DoorLockSavePowerSelectTimePage> createState() =>
      _DoorLockSavePowerSelectTimePageState();
}

class _DoorLockSavePowerSelectTimePageState
    extends State<DoorLockSavePowerSelectTimePage> {
  static const List<int> _titles = [1, 3, 5, 10, 15, 30];

  int selectDelay = 0;
  bool selectCustom = false;
  double customDelay = 120;

  @override
  void initState() {
    initDataSource();
    super.initState();
  }

  initDataSource() {
    selectDelay = widget.originDelay;
    selectCustom = !_titles.contains(selectDelay ~/ 60);
    if (selectCustom) {
      customDelay = selectDelay.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(selectDelay);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        appBar: AppBar(
          title: Text(TR.current.TR_Common_Time),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(selectDelay),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                children: [
                  for (var e in _titles)
                    _optionItem(
                      title: '$e${TR.current.TR_Common_Minute}',
                      isSelected: (selectDelay ~/ 60) == e && !selectCustom,
                      onTap: () {
                        setState(() {
                          selectDelay = e * 60;
                          selectCustom = false;
                        });
                      },
                    ),
                  _optionItem(
                    title:
                        '${TR.current.TR_Common_Customize}(${toMinStr(customDelay.toInt())})',
                    isSelected: selectCustom,
                    onTap: () {
                      setState(() {
                        selectDelay = customDelay.toInt();
                        selectCustom = true;
                      });
                    },
                  ),
                  if (selectCustom)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Slider(
                        min: 10,
                        max: 30 * 60,
                        divisions: 179,
                        value: customDelay.clamp(10, 30 * 60),
                        label: toMinStr(customDelay.toInt()),
                        onChanged: (value) {
                          setState(() {
                            customDelay = value.roundToDouble();
                            selectDelay = customDelay.toInt();
                          });
                        },
                      ),
                    ),
                  if (selectCustom)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(toMin(10),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          Text(toMin(30 * 60),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      title: Text(title),
      trailing: Icon(
        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
      ),
    );
  }

  String toMin(int seconds) {
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  String toMinStr(int seconds) {
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}${TR.current.sMin}${(seconds % 60).toString().padLeft(2, '0')}${TR.current.sSec}';
  }
}
