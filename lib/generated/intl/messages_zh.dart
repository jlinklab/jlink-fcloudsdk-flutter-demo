// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static String m0(account) => "确定取消分享给 ${account}？";

  static String m1(account) => "确定将设备分享给 ${account}？";

  static String m2(count) => "${count}秒后重新发送";

  static String m3(mail) => "将发送验证码到邮箱:${mail}中";

  static String m4(mail, phone) => "将发送验证码到邮箱:${mail}中和手机:${phone}上,填入其中一个即可";

  static String m5(phone) => "将发送验证码到${phone}上";

  static String m6(deviceId) => "${deviceId} 回放列表";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Recording_Times_Not_DURATION": MessageLookupByLibrary.simpleMessage(
      "录音时长至少要大于1秒",
    ),
    "TR_Audition": MessageLookupByLibrary.simpleMessage("试听"),
    "TR_File_Size_Exceed_Max_Size": MessageLookupByLibrary.simpleMessage(
      "文件大小超过最大限制",
    ),
    "TR_Please_Enter_Alarm_Tips": MessageLookupByLibrary.simpleMessage(
      "请输入报警提示语",
    ),
    "TR_Press_To_End_Record": MessageLookupByLibrary.simpleMessage("按下结束录音"),
    "TR_Press_To_Record": MessageLookupByLibrary.simpleMessage("按下后开始录音"),
    "TR_QR_Code_Has_Been_Used_Generate_Again":
        MessageLookupByLibrary.simpleMessage("二维码已被使用，请联系设备主账号再次生成"),
    "TR_Record_Prompt": MessageLookupByLibrary.simpleMessage("录制提示音"),
    "TR_Sex_Female": MessageLookupByLibrary.simpleMessage("女"),
    "TR_Sex_Male": MessageLookupByLibrary.simpleMessage("男"),
    "TR_Text_To_Voice": MessageLookupByLibrary.simpleMessage("文字转语音"),
    "TR_Upload_Prompt_Voice": MessageLookupByLibrary.simpleMessage("上传提示音"),
    "Upload_F": MessageLookupByLibrary.simpleMessage("上传失败"),
    "Upload_S": MessageLookupByLibrary.simpleMessage("上传成功"),
    "acceptFailed": MessageLookupByLibrary.simpleMessage("接受分享失败"),
    "acceptShare": MessageLookupByLibrary.simpleMessage("接受"),
    "acceptShareDevice": MessageLookupByLibrary.simpleMessage("接受设备分享"),
    "acceptSuccess": MessageLookupByLibrary.simpleMessage("接受分享成功"),
    "accountCancel": MessageLookupByLibrary.simpleMessage("账号注销"),
    "add": MessageLookupByLibrary.simpleMessage("添加"),
    "addConnectDevFailed": MessageLookupByLibrary.simpleMessage("配网失败"),
    "addDevice": MessageLookupByLibrary.simpleMessage("添加设备"),
    "addDeviceExisted": MessageLookupByLibrary.simpleMessage("设备已存在"),
    "alarm": MessageLookupByLibrary.simpleMessage("报警"),
    "alarmRecording": MessageLookupByLibrary.simpleMessage("报警录像"),
    "alarmScreenshot": MessageLookupByLibrary.simpleMessage("报警抓图"),
    "alarmSubscription": MessageLookupByLibrary.simpleMessage("报警订阅"),
    "album": MessageLookupByLibrary.simpleMessage("相册"),
    "areaCode": MessageLookupByLibrary.simpleMessage("区号选择"),
    "audio_ability_unsupport": MessageLookupByLibrary.simpleMessage("麦克风权限未开启"),
    "baseStationHumanDetectionSwitch": MessageLookupByLibrary.simpleMessage(
      "人形检测开关",
    ),
    "basicSetting": MessageLookupByLibrary.simpleMessage("基本设置"),
    "blueToothPermissionCancelTips": MessageLookupByLibrary.simpleMessage(
      "未获取到附近蓝牙设备扫描权限，将无法进行蓝牙配网、搜索等操作",
    ),
    "bluetooth": MessageLookupByLibrary.simpleMessage("蓝牙配网"),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cancelBtn": MessageLookupByLibrary.simpleMessage("取消"),
    "cancelShare": MessageLookupByLibrary.simpleMessage("取消分享"),
    "cancelShareContent": m0,
    "cancelShareFailed": MessageLookupByLibrary.simpleMessage("取消分享失败"),
    "cancelShareSuccess": MessageLookupByLibrary.simpleMessage("取消分享成功"),
    "check": MessageLookupByLibrary.simpleMessage("确定"),
    "clickToShare": MessageLookupByLibrary.simpleMessage("点击分享"),
    "cloudDownload": MessageLookupByLibrary.simpleMessage("云存下载管理"),
    "cloudList": MessageLookupByLibrary.simpleMessage("云回放"),
    "cloudVideo": MessageLookupByLibrary.simpleMessage("云短视频"),
    "codeHint": MessageLookupByLibrary.simpleMessage("验证码"),
    "confirmBtn": MessageLookupByLibrary.simpleMessage("确定"),
    "confirmShare": MessageLookupByLibrary.simpleMessage("确认分享"),
    "confirmShareContent": m1,
    "countDown": m2,
    "delete": MessageLookupByLibrary.simpleMessage("删除"),
    "dev": MessageLookupByLibrary.simpleMessage("关于设备"),
    "devInfo": MessageLookupByLibrary.simpleMessage("设备信息"),
    "devName": MessageLookupByLibrary.simpleMessage("请输入设备名称"),
    "devSN": MessageLookupByLibrary.simpleMessage("请输入设备序列号"),
    "device": MessageLookupByLibrary.simpleMessage("设备"),
    "deviceAddConnectBleSuccess": MessageLookupByLibrary.simpleMessage(
      "连接蓝牙设备成功！",
    ),
    "deviceAddConnectBleTip1": MessageLookupByLibrary.simpleMessage(
      "1.连接蓝牙设备成功！",
    ),
    "deviceAddConnectBleTip2": MessageLookupByLibrary.simpleMessage(
      "2.开始向设备发送配网信息...",
    ),
    "deviceAddConnectBleTip3": MessageLookupByLibrary.simpleMessage(
      "2.设备已成功接收配网信息！",
    ),
    "deviceAddConnectBleTip4": MessageLookupByLibrary.simpleMessage(
      "3.等待设备连接路由器...",
    ),
    "deviceAddConnectBleTip5": MessageLookupByLibrary.simpleMessage("3.配网成功！"),
    "deviceAddConnectBledDisconnected": MessageLookupByLibrary.simpleMessage(
      "蓝牙连接已断开",
    ),
    "deviceBluetoothCantConnect": MessageLookupByLibrary.simpleMessage(
      "无法连接蓝牙",
    ),
    "deviceFirmwareUpgrade": MessageLookupByLibrary.simpleMessage("设备固件升级"),
    "deviceList": MessageLookupByLibrary.simpleMessage("设备列表"),
    "deviceNoMemoryCard": MessageLookupByLibrary.simpleMessage("设备没有存储卡"),
    "deviceReset": MessageLookupByLibrary.simpleMessage("设备重置"),
    "deviceResetTip": MessageLookupByLibrary.simpleMessage("确定要恢复出厂设置吗？"),
    "deviceRestart": MessageLookupByLibrary.simpleMessage("设备重启"),
    "deviceRestartTip": MessageLookupByLibrary.simpleMessage("是否要重启设备？"),
    "deviceShare": MessageLookupByLibrary.simpleMessage("设备分享"),
    "download": MessageLookupByLibrary.simpleMessage("下载管理"),
    "factoryResetAndDeleteDev": MessageLookupByLibrary.simpleMessage(
      "恢复出厂设置并删除设备",
    ),
    "forgotPwd": MessageLookupByLibrary.simpleMessage("忘记密码"),
    "getCode": MessageLookupByLibrary.simpleMessage("获取验证码"),
    "goLogin": MessageLookupByLibrary.simpleMessage("已有帐号，去登录"),
    "goPhoneRegister": MessageLookupByLibrary.simpleMessage("试试手机号注册"),
    "goRegister": MessageLookupByLibrary.simpleMessage("没有账号，去注册"),
    "hd": MessageLookupByLibrary.simpleMessage("高清"),
    "image": MessageLookupByLibrary.simpleMessage("图片"),
    "imageFlipLeftRight": MessageLookupByLibrary.simpleMessage("图像左右翻转"),
    "imageFlipUpDown": MessageLookupByLibrary.simpleMessage("图像上下翻转"),
    "info": MessageLookupByLibrary.simpleMessage("用户信息"),
    "inputAccountHint": MessageLookupByLibrary.simpleMessage("输入用户名/手机号/邮箱"),
    "invalidShareQR": MessageLookupByLibrary.simpleMessage("无效的分享二维码"),
    "labelDevSN": MessageLookupByLibrary.simpleMessage("设备序列号"),
    "labelDeviceName": MessageLookupByLibrary.simpleMessage("设备名称"),
    "lanSearch": MessageLookupByLibrary.simpleMessage("局域网搜索设备"),
    "local": MessageLookupByLibrary.simpleMessage("zh"),
    "login": MessageLookupByLibrary.simpleMessage("登录"),
    "logout": MessageLookupByLibrary.simpleMessage("登出"),
    "mailHint": MessageLookupByLibrary.simpleMessage("邮箱"),
    "mailPhone": MessageLookupByLibrary.simpleMessage("邮箱/手机号"),
    "mailRegister": MessageLookupByLibrary.simpleMessage("邮箱注册"),
    "mailTip": m3,
    "mediaType": MessageLookupByLibrary.simpleMessage("媒体类型"),
    "memoryCardError": MessageLookupByLibrary.simpleMessage("存储卡异常"),
    "message": MessageLookupByLibrary.simpleMessage("消息"),
    "messageDetail": MessageLookupByLibrary.simpleMessage("消息详情"),
    "messageList": MessageLookupByLibrary.simpleMessage("消息列表"),
    "messageReporting": MessageLookupByLibrary.simpleMessage("消息上报"),
    "mine": MessageLookupByLibrary.simpleMessage("我的"),
    "myDevice": MessageLookupByLibrary.simpleMessage("我的设备"),
    "name": MessageLookupByLibrary.simpleMessage("用户名"),
    "nameHint": MessageLookupByLibrary.simpleMessage("用户名/邮箱/手机号"),
    "newPwd": MessageLookupByLibrary.simpleMessage("新密码"),
    "noDevice": MessageLookupByLibrary.simpleMessage("暂无设备"),
    "noFound": MessageLookupByLibrary.simpleMessage("未检测到设备"),
    "noPermissionTip": MessageLookupByLibrary.simpleMessage("暂无权限"),
    "noPhoneMailTip": MessageLookupByLibrary.simpleMessage(
      "您的账号未绑定任何邮箱或者手机号,点击注销按钮将直接注销账号",
    ),
    "noSDCardTips": MessageLookupByLibrary.simpleMessage("未检测到SD卡无法进行全天录像"),
    "noSharedAccount": MessageLookupByLibrary.simpleMessage("暂无已分享账号"),
    "normalAlarm": MessageLookupByLibrary.simpleMessage("普通报警"),
    "nothing": MessageLookupByLibrary.simpleMessage("什么也没有！"),
    "on": MessageLookupByLibrary.simpleMessage("开启"),
    "onlyFactoryReset": MessageLookupByLibrary.simpleMessage("仅恢复出厂设置"),
    "operator_failed": MessageLookupByLibrary.simpleMessage("操作失败"),
    "other": MessageLookupByLibrary.simpleMessage("其他"),
    "pendingShareDevices": MessageLookupByLibrary.simpleMessage("待接受的分享设备"),
    "permAlarmPush": MessageLookupByLibrary.simpleMessage("报警推送"),
    "permDeviceConfig": MessageLookupByLibrary.simpleMessage("设备配置"),
    "permIntercom": MessageLookupByLibrary.simpleMessage("对讲"),
    "permSdRecord": MessageLookupByLibrary.simpleMessage("SD卡录像"),
    "phone": MessageLookupByLibrary.simpleMessage("手机号"),
    "phoneMailTip": m4,
    "phoneRegister": MessageLookupByLibrary.simpleMessage("手机号注册"),
    "phoneRule": MessageLookupByLibrary.simpleMessage(
      "国外手机号要加区号，如：+1:80998098979",
    ),
    "phoneTip": m5,
    "preview": MessageLookupByLibrary.simpleMessage("预览"),
    "privacyPermissionBluetooth": MessageLookupByLibrary.simpleMessage(
      "访问蓝牙权限",
    ),
    "privacyPermissionDevNearbyContent": MessageLookupByLibrary.simpleMessage(
      "用于检索附近蓝牙设备或其他设备",
    ),
    "pwdFindBack": MessageLookupByLibrary.simpleMessage("找回设备密码"),
    "pwdHint": MessageLookupByLibrary.simpleMessage("密码"),
    "pwdQuestion": MessageLookupByLibrary.simpleMessage("设置密保问题"),
    "pwdRule": MessageLookupByLibrary.simpleMessage(
      "密码必须要8~64个字符，必须包含大写字母，小写字母和数字以及特殊字符。允许符号：\'!@#%^&*()_[]{}?/.<>, \'\' ; : -\'",
    ),
    "qrCodeShare": MessageLookupByLibrary.simpleMessage("二维码分享"),
    "qrScan": MessageLookupByLibrary.simpleMessage("请对准二维码"),
    "rebootFailed": MessageLookupByLibrary.simpleMessage("重启失败"),
    "rebootSuccess": MessageLookupByLibrary.simpleMessage("设备重启中..."),
    "recordAudio": MessageLookupByLibrary.simpleMessage("录像音频"),
    "recordClip": MessageLookupByLibrary.simpleMessage("录像段"),
    "recordList": m6,
    "recordMode": MessageLookupByLibrary.simpleMessage("录像开关"),
    "recordQuality": MessageLookupByLibrary.simpleMessage("录像画质"),
    "recordQualityBad": MessageLookupByLibrary.simpleMessage("较差"),
    "recordQualityBestGood": MessageLookupByLibrary.simpleMessage("最好"),
    "recordQualityGood": MessageLookupByLibrary.simpleMessage("好"),
    "recordQualityNormal": MessageLookupByLibrary.simpleMessage("一般"),
    "recordQualityVeryBad": MessageLookupByLibrary.simpleMessage("很差"),
    "recordQualityVeryGood": MessageLookupByLibrary.simpleMessage("很好"),
    "recordSetting": MessageLookupByLibrary.simpleMessage("录像设置"),
    "refuseFailed": MessageLookupByLibrary.simpleMessage("拒绝分享失败"),
    "refuseShare": MessageLookupByLibrary.simpleMessage("拒绝"),
    "refuseSuccess": MessageLookupByLibrary.simpleMessage("拒绝分享成功"),
    "reset": MessageLookupByLibrary.simpleMessage("重置"),
    "resetDevPwd": MessageLookupByLibrary.simpleMessage("重置设备密码"),
    "resetFailed": MessageLookupByLibrary.simpleMessage("恢复出厂设置失败"),
    "resetPwd": MessageLookupByLibrary.simpleMessage("重置账号密码"),
    "resetSuccess": MessageLookupByLibrary.simpleMessage("恢复出厂设置成功，重启中..."),
    "restartScan": MessageLookupByLibrary.simpleMessage("重新搜索"),
    "routeSetting": MessageLookupByLibrary.simpleMessage("路由器配置"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveFailed": MessageLookupByLibrary.simpleMessage("保存失败"),
    "saveSuccess": MessageLookupByLibrary.simpleMessage("保存成功"),
    "saving": MessageLookupByLibrary.simpleMessage("保存中..."),
    "scanShareDevice": MessageLookupByLibrary.simpleMessage("扫码添加分享设备"),
    "sceneAddDevice": MessageLookupByLibrary.simpleMessage("智能设备"),
    "sd": MessageLookupByLibrary.simpleMessage("标清"),
    "sdList": MessageLookupByLibrary.simpleMessage("卡存相册"),
    "sdkVersion": MessageLookupByLibrary.simpleMessage("当前SDK版本"),
    "search": MessageLookupByLibrary.simpleMessage("搜索"),
    "searchFailed": MessageLookupByLibrary.simpleMessage("搜索失败"),
    "selectAll": MessageLookupByLibrary.simpleMessage("全选"),
    "setting": MessageLookupByLibrary.simpleMessage("设置"),
    "share": MessageLookupByLibrary.simpleMessage("分享"),
    "shareAccepted": MessageLookupByLibrary.simpleMessage("已接受"),
    "shareDevice": MessageLookupByLibrary.simpleMessage("分享设备"),
    "shareExpired": MessageLookupByLibrary.simpleMessage("已过期"),
    "shareFailed": MessageLookupByLibrary.simpleMessage("分享失败"),
    "shareFrom": MessageLookupByLibrary.simpleMessage("分享来自"),
    "sharePending": MessageLookupByLibrary.simpleMessage("待接受"),
    "sharePermission": MessageLookupByLibrary.simpleMessage("分享权限"),
    "shareQRCode": MessageLookupByLibrary.simpleMessage("分享二维码"),
    "shareQRTips": MessageLookupByLibrary.simpleMessage("扫描二维码添加设备分享"),
    "shareRejected": MessageLookupByLibrary.simpleMessage("已拒绝"),
    "shareSuccess": MessageLookupByLibrary.simpleMessage("分享成功"),
    "shareTo": MessageLookupByLibrary.simpleMessage("分享给"),
    "sharedAccounts": MessageLookupByLibrary.simpleMessage("已分享账号"),
    "smsLogin": MessageLookupByLibrary.simpleMessage("短信登录"),
    "startAdd": MessageLookupByLibrary.simpleMessage("开始配网"),
    "startScan": MessageLookupByLibrary.simpleMessage("开始搜索"),
    "stopScan": MessageLookupByLibrary.simpleMessage("停止搜索"),
    "storageManagement": MessageLookupByLibrary.simpleMessage("存储管理"),
    "toolsFeedbackLog": MessageLookupByLibrary.simpleMessage("反馈日志"),
    "tr_common_download_management": MessageLookupByLibrary.simpleMessage(
      "下载管理",
    ),
    "tr_pet_function_record_start": MessageLookupByLibrary.simpleMessage(
      "点击开始录音",
    ),
    "tr_pet_function_recording_state": MessageLookupByLibrary.simpleMessage(
      "正在录音，再次点击结束录音",
    ),
    "tr_pet_setting_sound_record_function":
        MessageLookupByLibrary.simpleMessage("录制呼唤音"),
    "tr_recording": MessageLookupByLibrary.simpleMessage("录音中..."),
    "tr_settings_alarm_beep": MessageLookupByLibrary.simpleMessage("设备警铃"),
    "tr_settings_alarm_bell_customize": MessageLookupByLibrary.simpleMessage(
      "自定义语音",
    ),
    "tr_settings_alarm_bell_select": MessageLookupByLibrary.simpleMessage(
      "设备警铃选择",
    ),
    "userNotFound": MessageLookupByLibrary.simpleMessage("用户不存在"),
    "verCodeLogin": MessageLookupByLibrary.simpleMessage("验证码登录"),
    "version": MessageLookupByLibrary.simpleMessage("版本信息"),
    "video": MessageLookupByLibrary.simpleMessage("录像"),
    "wifi": MessageLookupByLibrary.simpleMessage("快速wifi配网"),
    "wifiPwdHint": MessageLookupByLibrary.simpleMessage("输入WIFI密码"),
  };
}
