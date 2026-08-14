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

  static String m0(level, isCharging) => "电量等级【${level}】,是否充电中【${isCharging}】";

  static String m1(account) => "确定取消分享给 ${account}？";

  static String m2(account) => "确定将设备分享给 ${account}？";

  static String m3(count) => "${count}秒后重新发送";

  static String m4(mail) => "将发送验证码到邮箱:${mail}中";

  static String m5(mail, phone) => "将发送验证码到邮箱:${mail}中和手机:${phone}上,填入其中一个即可";

  static String m6(phone) => "将发送验证码到${phone}上";

  static String m7(deviceId) => "${deviceId} 回放列表";

  static String m8(level) => "4G信号等级【${level}】";

  static String m9(level) => "WiFi信号等级【${level}】";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Done": MessageLookupByLibrary.simpleMessage("完成"),
    "Recording_Times_Not_DURATION": MessageLookupByLibrary.simpleMessage(
      "录音时长至少要大于1秒",
    ),
    "Show_traces": MessageLookupByLibrary.simpleMessage("显示智能踪迹"),
    "TR_Alert_Set_Alert_Line_Tip": MessageLookupByLibrary.simpleMessage(
      "请设置警戒线，拖动两端调整位置",
    ),
    "TR_Audition": MessageLookupByLibrary.simpleMessage("试听"),
    "TR_File_Size_Exceed_Max_Size": MessageLookupByLibrary.simpleMessage(
      "文件大小超过最大限制",
    ),
    "TR_Intelligent_Warning_Switch": MessageLookupByLibrary.simpleMessage(
      "智能警戒开关",
    ),
    "TR_Modify_S": MessageLookupByLibrary.simpleMessage("修改成功"),
    "TR_Please_Enter_Alarm_Tips": MessageLookupByLibrary.simpleMessage(
      "请输入报警提示语",
    ),
    "TR_Press_To_End_Record": MessageLookupByLibrary.simpleMessage("按下结束录音"),
    "TR_Press_To_Record": MessageLookupByLibrary.simpleMessage("按下后开始录音"),
    "TR_QR_Code_Has_Been_Used_Generate_Again":
        MessageLookupByLibrary.simpleMessage("二维码已被使用，请联系设备主账号再次生成"),
    "TR_Record_Prompt": MessageLookupByLibrary.simpleMessage("录制提示音"),
    "TR_Rule_Setting": MessageLookupByLibrary.simpleMessage("智能规则设置"),
    "TR_Sex_Female": MessageLookupByLibrary.simpleMessage("女"),
    "TR_Sex_Male": MessageLookupByLibrary.simpleMessage("男"),
    "TR_Show_Traces_Tip": MessageLookupByLibrary.simpleMessage(
      "视频中出现人时，会对人做画框或画线标记",
    ),
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
    "advanced_set": MessageLookupByLibrary.simpleMessage("高级设置"),
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
    "batteryInfo": m0,
    "blueToothPermissionCancelTips": MessageLookupByLibrary.simpleMessage(
      "未获取到附近蓝牙设备扫描权限，将无法进行蓝牙配网、搜索等操作",
    ),
    "bluetooth": MessageLookupByLibrary.simpleMessage("蓝牙配网"),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cancelBtn": MessageLookupByLibrary.simpleMessage("取消"),
    "cancelShare": MessageLookupByLibrary.simpleMessage("取消分享"),
    "cancelShareContent": m1,
    "cancelShareFailed": MessageLookupByLibrary.simpleMessage("取消分享失败"),
    "cancelShareSuccess": MessageLookupByLibrary.simpleMessage("取消分享成功"),
    "chargingNo": MessageLookupByLibrary.simpleMessage("否"),
    "chargingYes": MessageLookupByLibrary.simpleMessage("是"),
    "check": MessageLookupByLibrary.simpleMessage("确定"),
    "clickToShare": MessageLookupByLibrary.simpleMessage("点击分享"),
    "cloudDownload": MessageLookupByLibrary.simpleMessage("云存下载管理"),
    "cloudList": MessageLookupByLibrary.simpleMessage("云回放"),
    "cloudVideo": MessageLookupByLibrary.simpleMessage("云短视频"),
    "codeHint": MessageLookupByLibrary.simpleMessage("验证码"),
    "commonConfig": MessageLookupByLibrary.simpleMessage("通用配置"),
    "confirmBtn": MessageLookupByLibrary.simpleMessage("确定"),
    "confirmShare": MessageLookupByLibrary.simpleMessage("确认分享"),
    "confirmShareContent": m2,
    "countDown": m3,
    "customerServiceCenter": MessageLookupByLibrary.simpleMessage("客服中心"),
    "dayNightAuto": MessageLookupByLibrary.simpleMessage("自动切换"),
    "dayNightAutoTip": MessageLookupByLibrary.simpleMessage("根据环境光线自动切换日夜模式"),
    "dayNightDay": MessageLookupByLibrary.simpleMessage("强制白天"),
    "dayNightDayTip": MessageLookupByLibrary.simpleMessage("强制切换为白天模式"),
    "dayNightMode": MessageLookupByLibrary.simpleMessage("日夜切换"),
    "dayNightNight": MessageLookupByLibrary.simpleMessage("强制黑夜"),
    "dayNightNightTip": MessageLookupByLibrary.simpleMessage("强制切换为黑夜模式"),
    "dayNightSensitivity": MessageLookupByLibrary.simpleMessage("日夜切换灵敏度"),
    "dayNightTiming": MessageLookupByLibrary.simpleMessage("定时切换"),
    "dayNightTimingTip": MessageLookupByLibrary.simpleMessage("按设定时间段定时切换"),
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
    "deviceLanguage": MessageLookupByLibrary.simpleMessage("设备语言"),
    "deviceList": MessageLookupByLibrary.simpleMessage("设备列表"),
    "deviceNoMemoryCard": MessageLookupByLibrary.simpleMessage("设备没有存储卡"),
    "deviceReset": MessageLookupByLibrary.simpleMessage("设备重置"),
    "deviceResetTip": MessageLookupByLibrary.simpleMessage("确定要恢复出厂设置吗？"),
    "deviceRestart": MessageLookupByLibrary.simpleMessage("设备重启"),
    "deviceRestartTip": MessageLookupByLibrary.simpleMessage("是否要重启设备？"),
    "deviceShare": MessageLookupByLibrary.simpleMessage("设备分享"),
    "download": MessageLookupByLibrary.simpleMessage("下载管理"),
    "dynamic_alarm": MessageLookupByLibrary.simpleMessage("报警设置"),
    "endTime": MessageLookupByLibrary.simpleMessage("结束时间"),
    "factoryResetAndDeleteDev": MessageLookupByLibrary.simpleMessage(
      "恢复出厂设置并删除设备",
    ),
    "firmwareCheckUpdate": MessageLookupByLibrary.simpleMessage("检查更新"),
    "firmwareChecking": MessageLookupByLibrary.simpleMessage("正在检查..."),
    "firmwareCurrentVersion": MessageLookupByLibrary.simpleMessage("当前版本"),
    "firmwareDownloadFailed": MessageLookupByLibrary.simpleMessage("固件下载失败"),
    "firmwareDownloadFile": MessageLookupByLibrary.simpleMessage("正在下载固件"),
    "firmwareDownloadSuccess": MessageLookupByLibrary.simpleMessage("固件下载完成"),
    "firmwareDownloadingToFirmware": MessageLookupByLibrary.simpleMessage(
      "正在下载固件文件到本地",
    ),
    "firmwareLatest": MessageLookupByLibrary.simpleMessage("已是最新版本"),
    "firmwareLocalUpgrade": MessageLookupByLibrary.simpleMessage("本地升级"),
    "firmwareNewVersion": MessageLookupByLibrary.simpleMessage("新版本"),
    "firmwareNoLocalFile": MessageLookupByLibrary.simpleMessage("未找到本地固件文件"),
    "firmwareOnlineUpgrade": MessageLookupByLibrary.simpleMessage("在线升级"),
    "firmwarePidFail": MessageLookupByLibrary.simpleMessage("未获取到pid，无法执行检测更新"),
    "firmwareSelectLocalFile": MessageLookupByLibrary.simpleMessage("选择本地固件文件"),
    "firmwareSendFile": MessageLookupByLibrary.simpleMessage("正在发送固件到设备"),
    "firmwareUpgradeAvailable": MessageLookupByLibrary.simpleMessage("发现新版本"),
    "firmwareUpgradeConfirm": MessageLookupByLibrary.simpleMessage(
      "确认要升级设备固件吗？",
    ),
    "firmwareUpgradeFailed": MessageLookupByLibrary.simpleMessage("升级失败"),
    "firmwareUpgradeNow": MessageLookupByLibrary.simpleMessage("立即升级"),
    "firmwareUpgradeSuccess": MessageLookupByLibrary.simpleMessage(
      "升级成功，重启中...",
    ),
    "firmwareUpgradeTip": MessageLookupByLibrary.simpleMessage("升级过程中请勿断开设备电源"),
    "firmwareUpgrading": MessageLookupByLibrary.simpleMessage("正在升级"),
    "firmwareVersionCheckFailed": MessageLookupByLibrary.simpleMessage(
      "版本检查失败",
    ),
    "forgotPwd": MessageLookupByLibrary.simpleMessage("忘记密码"),
    "fullDuplexIntercom": MessageLookupByLibrary.simpleMessage("全双工对讲"),
    "getCode": MessageLookupByLibrary.simpleMessage("获取验证码"),
    "goLogin": MessageLookupByLibrary.simpleMessage("已有帐号，去登录"),
    "goPhoneRegister": MessageLookupByLibrary.simpleMessage("试试手机号注册"),
    "goRegister": MessageLookupByLibrary.simpleMessage("没有账号，去注册"),
    "hd": MessageLookupByLibrary.simpleMessage("高清"),
    "image": MessageLookupByLibrary.simpleMessage("图片"),
    "imageConfig": MessageLookupByLibrary.simpleMessage("图像配置"),
    "imageFlipLeftRight": MessageLookupByLibrary.simpleMessage("图像左右翻转"),
    "imageFlipUpDown": MessageLookupByLibrary.simpleMessage("图像上下翻转"),
    "info": MessageLookupByLibrary.simpleMessage("用户信息"),
    "inputAccountHint": MessageLookupByLibrary.simpleMessage("输入用户名/手机号/邮箱"),
    "inputDeviceNameHint": MessageLookupByLibrary.simpleMessage("请输入设备名称"),
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
    "mailTip": m4,
    "mediaType": MessageLookupByLibrary.simpleMessage("媒体类型"),
    "memoryCardError": MessageLookupByLibrary.simpleMessage("存储卡异常"),
    "message": MessageLookupByLibrary.simpleMessage("消息"),
    "messageDetail": MessageLookupByLibrary.simpleMessage("消息详情"),
    "messageList": MessageLookupByLibrary.simpleMessage("消息列表"),
    "messageReporting": MessageLookupByLibrary.simpleMessage("消息上报"),
    "micVolume": MessageLookupByLibrary.simpleMessage("麦克风音量"),
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
    "phoneMailTip": m5,
    "phoneRegister": MessageLookupByLibrary.simpleMessage("手机号注册"),
    "phoneRule": MessageLookupByLibrary.simpleMessage(
      "国外手机号要加区号，如：+1:80998098979",
    ),
    "phoneTip": m6,
    "preview": MessageLookupByLibrary.simpleMessage("预览"),
    "privacyPermissionBluetooth": MessageLookupByLibrary.simpleMessage(
      "访问蓝牙权限",
    ),
    "privacyPermissionDevNearbyContent": MessageLookupByLibrary.simpleMessage(
      "用于检索附近蓝牙设备或其他设备",
    ),
    "push_setting": MessageLookupByLibrary.simpleMessage("消息推送"),
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
    "recordList": m7,
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
    "selectPlaybackSpeed": MessageLookupByLibrary.simpleMessage("选择播放倍速"),
    "setDeviceName": MessageLookupByLibrary.simpleMessage("设置设备名称"),
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
    "signal4GLevel": m8,
    "smart_analyze_line_left": MessageLookupByLibrary.simpleMessage("从左到右"),
    "smart_analyze_line_middle": MessageLookupByLibrary.simpleMessage("双向"),
    "smart_analyze_line_right": MessageLookupByLibrary.simpleMessage("从右到左"),
    "smart_analyze_restore": MessageLookupByLibrary.simpleMessage("还原"),
    "smart_analyze_revoke": MessageLookupByLibrary.simpleMessage("撤销"),
    "smart_analyze_shape_concave": MessageLookupByLibrary.simpleMessage("凹型"),
    "smart_analyze_shape_l_sel": MessageLookupByLibrary.simpleMessage("L型"),
    "smart_analyze_shape_pentagram": MessageLookupByLibrary.simpleMessage(
      "五边形",
    ),
    "smart_analyze_shape_rectangle": MessageLookupByLibrary.simpleMessage("矩形"),
    "smart_analyze_shape_triangle": MessageLookupByLibrary.simpleMessage("三角形"),
    "smsLogin": MessageLookupByLibrary.simpleMessage("短信登录"),
    "speakerVolume": MessageLookupByLibrary.simpleMessage("喇叭音量"),
    "startAdd": MessageLookupByLibrary.simpleMessage("开始配网"),
    "startScan": MessageLookupByLibrary.simpleMessage("开始搜索"),
    "startTime": MessageLookupByLibrary.simpleMessage("开始时间"),
    "statusLightSwitch": MessageLookupByLibrary.simpleMessage("指示灯"),
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
    "tr_settings_alarm_alert_have_intersection":
        MessageLookupByLibrary.simpleMessage("区域边线存在交叉，请重新绘制"),
    "tr_settings_alarm_beep": MessageLookupByLibrary.simpleMessage("设备警铃"),
    "tr_settings_alarm_bell_customize": MessageLookupByLibrary.simpleMessage(
      "自定义语音",
    ),
    "tr_settings_alarm_bell_select": MessageLookupByLibrary.simpleMessage(
      "设备警铃选择",
    ),
    "type_alert_area": MessageLookupByLibrary.simpleMessage("警戒区域"),
    "type_alert_line": MessageLookupByLibrary.simpleMessage("警戒线"),
    "userNotFound": MessageLookupByLibrary.simpleMessage("用户不存在"),
    "verCodeLogin": MessageLookupByLibrary.simpleMessage("验证码登录"),
    "version": MessageLookupByLibrary.simpleMessage("版本信息"),
    "video": MessageLookupByLibrary.simpleMessage("录像"),
    "voiceTipSwitch": MessageLookupByLibrary.simpleMessage("提示音"),
    "waiting_buffering": MessageLookupByLibrary.simpleMessage("缓冲中..."),
    "wifi": MessageLookupByLibrary.simpleMessage("快速wifi配网"),
    "wifiPwdHint": MessageLookupByLibrary.simpleMessage("输入WIFI密码"),
    "wifiSignalLevel": m9,
  };
}
