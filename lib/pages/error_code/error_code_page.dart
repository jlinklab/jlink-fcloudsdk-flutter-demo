import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

/// 错误码查询页面
///
/// 迁移自 Android demo 的 CheckErrorCodeActivity：
/// 输入错误码，遍历 EFUN_ERROR 常量表按绝对值匹配，
/// 显示字段名及已有中文描述；提示文本中携带开放平台文档中心链接。
class ErrorCodePage extends StatefulWidget {
  const ErrorCodePage({Key? key}) : super(key: key);

  @override
  State<ErrorCodePage> createState() => _ErrorCodePageState();
}

class _ErrorCodePageState extends State<ErrorCodePage> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 是否中文环境，决定文档链接语言
  bool get _isCn =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'zh';

  /// 点击查询错误码
  void _onCheck() {
    String checkErrorId = _controller.text.trim();
    try {
      int.tryParse(checkErrorId);
    } catch (e) {
      KToast.show(status: TR.current.inputRightErrorCode);
      return;
    }
    if (checkErrorId.isEmpty || int.tryParse(checkErrorId) == null) {
      KToast.show(status: TR.current.inputRightErrorCode);
      return;
    }

    //先清空结果，查不到则保持空白（与 Android 行为一致）
    setState(() {
      _result = '';
    });

    int iCheckErrorId = int.parse(checkErrorId);
    Map<String, String> map = {};
    map.addAll(errorCodeMapNet);
    map.addAll(errorCodeMapAccount);
    map.addAll(errorCodeMapDevice);
    map.addAll(errorCodeMapGeneral);
    map.addAll(errorCodeMapAlarm);
    map.addAll(errorCodeMapUrlPlay);
    map.addAll(errorCodeMapMediaTraffic);
    for (String key in map.keys) {
      if (int.tryParse(key)?.abs() == iCheckErrorId.abs()) {
        String? desc = kErrorCodeDesc(key);
        _result = desc ?? '';
        break;
      }
    }
    setState(() {});
  }

  /// 打开开放平台错误码文档
  Future<void> _openDocumentationCenter() async {
    //开放平台错误码文档链接
    final uri = Uri.parse(
        'https://docs.jftech.com/docs?menusId=ab0ed73834f54368be3e375075e27fb2'
            '&siderId=39094be901e94a0daae61055787c8b5b&lang=${_isCn ? 'zh' : 'en'}');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        KToast.show(status: TR.current.openLinkFailed);
      }
    } catch (e) {
      //鸿蒙端无可用浏览器/系统拦截隐式启动时会抛 PlatformException
      KToast.show(status: TR.current.openLinkFailed);
    }
  }

  /// 提示文本，其中文档中心部分为可点击链接
  Widget _buildHintText() {
    String hintText = TR.current.pleaseCheckErrorCode;
    String goDocText = TR.current.visitOpenPlatformDocumentationCenter;
    int startIndex = hintText.indexOf(goDocText);
    if (startIndex < 0) {
      return Text(hintText,
          style: const TextStyle(fontSize: 16, color: Color(0xFF9D9CA0)));
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: hintText.substring(0, startIndex)),
          TextSpan(
            text: goDocText,
            style: const TextStyle(
              color: Color(0xFF0091EA),
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = _openDocumentationCenter,
          ),
          TextSpan(text: hintText.substring(startIndex + goDocText.length)),
        ],
        style: const TextStyle(fontSize: 16, color: Color(0xFF9D9CA0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.errorCode),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: _buildHintText(),
            ),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              decoration: InputDecoration(
                hintText: TR.current.enterErrorCode,
                border: const OutlineInputBorder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onCheck,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(TR.current.check),
                ),
              ),
            ),
            Text(
              _result,
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
