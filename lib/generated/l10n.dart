// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class TR {
  TR();

  static TR? _current;

  static TR get current {
    assert(
      _current != null,
      'No instance of TR was loaded. Try to initialize the TR delegate before accessing TR.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<TR> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = TR();
      TR._current = instance;

      return instance;
    });
  }

  static TR of(BuildContext context) {
    final instance = TR.maybeOf(context);
    assert(
      instance != null,
      'No instance of TR present in the widget tree. Did you add TR.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static TR? maybeOf(BuildContext context) {
    return Localizations.of<TR>(context, TR);
  }

  /// `zh`
  String get local {
    return Intl.message('zh', name: 'local', desc: '', args: []);
  }

  /// `登录`
  String get login {
    return Intl.message('登录', name: 'login', desc: '', args: []);
  }

  /// `验证码登录`
  String get verCodeLogin {
    return Intl.message('验证码登录', name: 'verCodeLogin', desc: '', args: []);
  }

  /// `忘记密码`
  String get forgotPwd {
    return Intl.message('忘记密码', name: 'forgotPwd', desc: '', args: []);
  }

  /// `没有账号，去注册`
  String get goRegister {
    return Intl.message('没有账号，去注册', name: 'goRegister', desc: '', args: []);
  }

  /// `国外手机号要加区号，如：+1:80998098979`
  String get phoneRule {
    return Intl.message(
      '国外手机号要加区号，如：+1:80998098979',
      name: 'phoneRule',
      desc: '',
      args: [],
    );
  }

  /// `用户名/邮箱/手机号`
  String get nameHint {
    return Intl.message('用户名/邮箱/手机号', name: 'nameHint', desc: '', args: []);
  }

  /// `密码`
  String get pwdHint {
    return Intl.message('密码', name: 'pwdHint', desc: '', args: []);
  }

  /// `短信登录`
  String get smsLogin {
    return Intl.message('短信登录', name: 'smsLogin', desc: '', args: []);
  }

  /// `手机号`
  String get phone {
    return Intl.message('手机号', name: 'phone', desc: '', args: []);
  }

  /// `区号选择`
  String get areaCode {
    return Intl.message('区号选择', name: 'areaCode', desc: '', args: []);
  }

  /// `登出`
  String get logout {
    return Intl.message('登出', name: 'logout', desc: '', args: []);
  }

  /// `用户信息`
  String get info {
    return Intl.message('用户信息', name: 'info', desc: '', args: []);
  }

  /// `设置`
  String get setting {
    return Intl.message('设置', name: 'setting', desc: '', args: []);
  }

  /// `重置账号密码`
  String get resetPwd {
    return Intl.message('重置账号密码', name: 'resetPwd', desc: '', args: []);
  }

  /// `账号注销`
  String get accountCancel {
    return Intl.message('账号注销', name: 'accountCancel', desc: '', args: []);
  }

  /// `版本信息`
  String get version {
    return Intl.message('版本信息', name: 'version', desc: '', args: []);
  }

  /// `重置`
  String get reset {
    return Intl.message('重置', name: 'reset', desc: '', args: []);
  }

  /// `新密码`
  String get newPwd {
    return Intl.message('新密码', name: 'newPwd', desc: '', args: []);
  }

  /// `密码必须要8~64个字符，必须包含大写字母，小写字母和数字以及特殊字符。允许符号：'!@#%^&*()_[]{}?/.<>, '' ; : -'`
  String get pwdRule {
    return Intl.message(
      '密码必须要8~64个字符，必须包含大写字母，小写字母和数字以及特殊字符。允许符号：\'!@#%^&*()_[]{}?/.<>, \'\' ; : -\'',
      name: 'pwdRule',
      desc: '',
      args: [],
    );
  }

  /// `验证码`
  String get codeHint {
    return Intl.message('验证码', name: 'codeHint', desc: '', args: []);
  }

  /// `获取验证码`
  String get getCode {
    return Intl.message('获取验证码', name: 'getCode', desc: '', args: []);
  }

  /// `{count}秒后重新发送`
  String countDown(Object count) {
    return Intl.message(
      '$count秒后重新发送',
      name: 'countDown',
      desc: '',
      args: [count],
    );
  }

  /// `将发送验证码到邮箱:{mail}中和手机:{phone}上,填入其中一个即可`
  String phoneMailTip(Object mail, Object phone) {
    return Intl.message(
      '将发送验证码到邮箱:$mail中和手机:$phone上,填入其中一个即可',
      name: 'phoneMailTip',
      desc: '',
      args: [mail, phone],
    );
  }

  /// `将发送验证码到{phone}上`
  String phoneTip(Object phone) {
    return Intl.message(
      '将发送验证码到$phone上',
      name: 'phoneTip',
      desc: '',
      args: [phone],
    );
  }

  /// `将发送验证码到邮箱:{mail}中`
  String mailTip(Object mail) {
    return Intl.message(
      '将发送验证码到邮箱:$mail中',
      name: 'mailTip',
      desc: '',
      args: [mail],
    );
  }

  /// `您的账号未绑定任何邮箱或者手机号,点击注销按钮将直接注销账号`
  String get noPhoneMailTip {
    return Intl.message(
      '您的账号未绑定任何邮箱或者手机号,点击注销按钮将直接注销账号',
      name: 'noPhoneMailTip',
      desc: '',
      args: [],
    );
  }

  /// `邮箱注册`
  String get mailRegister {
    return Intl.message('邮箱注册', name: 'mailRegister', desc: '', args: []);
  }

  /// `邮箱`
  String get mailHint {
    return Intl.message('邮箱', name: 'mailHint', desc: '', args: []);
  }

  /// `确定`
  String get check {
    return Intl.message('确定', name: 'check', desc: '', args: []);
  }

  /// `试试手机号注册`
  String get goPhoneRegister {
    return Intl.message('试试手机号注册', name: 'goPhoneRegister', desc: '', args: []);
  }

  /// `已有帐号，去登录`
  String get goLogin {
    return Intl.message('已有帐号，去登录', name: 'goLogin', desc: '', args: []);
  }

  /// `手机号注册`
  String get phoneRegister {
    return Intl.message('手机号注册', name: 'phoneRegister', desc: '', args: []);
  }

  /// `用户名`
  String get name {
    return Intl.message('用户名', name: 'name', desc: '', args: []);
  }

  /// `邮箱/手机号`
  String get mailPhone {
    return Intl.message('邮箱/手机号', name: 'mailPhone', desc: '', args: []);
  }

  /// `设备`
  String get device {
    return Intl.message('设备', name: 'device', desc: '', args: []);
  }

  /// `相册`
  String get album {
    return Intl.message('相册', name: 'album', desc: '', args: []);
  }

  /// `我的`
  String get mine {
    return Intl.message('我的', name: 'mine', desc: '', args: []);
  }

  /// `什么也没有！`
  String get nothing {
    return Intl.message('什么也没有！', name: 'nothing', desc: '', args: []);
  }

  /// `删除`
  String get delete {
    return Intl.message('删除', name: 'delete', desc: '', args: []);
  }

  /// `分享`
  String get share {
    return Intl.message('分享', name: 'share', desc: '', args: []);
  }

  /// `全选`
  String get selectAll {
    return Intl.message('全选', name: 'selectAll', desc: '', args: []);
  }

  /// `取消全选`
  String get cancel {
    return Intl.message('取消全选', name: 'cancel', desc: '', args: []);
  }

  /// `媒体类型`
  String get mediaType {
    return Intl.message('媒体类型', name: 'mediaType', desc: '', args: []);
  }

  /// `其他`
  String get other {
    return Intl.message('其他', name: 'other', desc: '', args: []);
  }

  /// `图片`
  String get image {
    return Intl.message('图片', name: 'image', desc: '', args: []);
  }

  /// `录像`
  String get video {
    return Intl.message('录像', name: 'video', desc: '', args: []);
  }

  /// `设备列表`
  String get deviceList {
    return Intl.message('设备列表', name: 'deviceList', desc: '', args: []);
  }

  /// `我的设备`
  String get myDevice {
    return Intl.message('我的设备', name: 'myDevice', desc: '', args: []);
  }

  /// `分享设备`
  String get shareDevice {
    return Intl.message('分享设备', name: 'shareDevice', desc: '', args: []);
  }

  /// `预览`
  String get preview {
    return Intl.message('预览', name: 'preview', desc: '', args: []);
  }

  /// `消息`
  String get message {
    return Intl.message('消息', name: 'message', desc: '', args: []);
  }

  /// `暂无设备`
  String get noDevice {
    return Intl.message('暂无设备', name: 'noDevice', desc: '', args: []);
  }

  /// `添加设备`
  String get addDevice {
    return Intl.message('添加设备', name: 'addDevice', desc: '', args: []);
  }

  /// `添加`
  String get add {
    return Intl.message('添加', name: 'add', desc: '', args: []);
  }

  /// `请输入设备名称`
  String get devName {
    return Intl.message('请输入设备名称', name: 'devName', desc: '', args: []);
  }

  /// `请输入设备序列号`
  String get devSN {
    return Intl.message('请输入设备序列号', name: 'devSN', desc: '', args: []);
  }

  /// `快速wifi配网`
  String get wifi {
    return Intl.message('快速wifi配网', name: 'wifi', desc: '', args: []);
  }

  /// `蓝牙配网`
  String get bluetooth {
    return Intl.message('蓝牙配网', name: 'bluetooth', desc: '', args: []);
  }

  /// `局域网搜索设备`
  String get lanSearch {
    return Intl.message('局域网搜索设备', name: 'lanSearch', desc: '', args: []);
  }

  /// `未检测到设备`
  String get noFound {
    return Intl.message('未检测到设备', name: 'noFound', desc: '', args: []);
  }

  /// `请对准二维码`
  String get qrScan {
    return Intl.message('请对准二维码', name: 'qrScan', desc: '', args: []);
  }

  /// `输入WIFI密码`
  String get wifiPwdHint {
    return Intl.message('输入WIFI密码', name: 'wifiPwdHint', desc: '', args: []);
  }

  /// `开始配网`
  String get startAdd {
    return Intl.message('开始配网', name: 'startAdd', desc: '', args: []);
  }

  /// `开始搜索`
  String get startScan {
    return Intl.message('开始搜索', name: 'startScan', desc: '', args: []);
  }

  /// `停止搜索`
  String get stopScan {
    return Intl.message('停止搜索', name: 'stopScan', desc: '', args: []);
  }

  /// `重新搜索`
  String get restartScan {
    return Intl.message('重新搜索', name: 'restartScan', desc: '', args: []);
  }

  /// `路由器配置`
  String get routeSetting {
    return Intl.message('路由器配置', name: 'routeSetting', desc: '', args: []);
  }

  /// `消息详情`
  String get messageDetail {
    return Intl.message('消息详情', name: 'messageDetail', desc: '', args: []);
  }

  /// `消息列表`
  String get messageList {
    return Intl.message('消息列表', name: 'messageList', desc: '', args: []);
  }

  /// `云短视频`
  String get cloudVideo {
    return Intl.message('云短视频', name: 'cloudVideo', desc: '', args: []);
  }

  /// `普通报警`
  String get normalAlarm {
    return Intl.message('普通报警', name: 'normalAlarm', desc: '', args: []);
  }

  /// `报警`
  String get alarm {
    return Intl.message('报警', name: 'alarm', desc: '', args: []);
  }

  /// `设备信息`
  String get devInfo {
    return Intl.message('设备信息', name: 'devInfo', desc: '', args: []);
  }

  /// `重置设备密码`
  String get resetDevPwd {
    return Intl.message('重置设备密码', name: 'resetDevPwd', desc: '', args: []);
  }

  /// `关于设备`
  String get dev {
    return Intl.message('关于设备', name: 'dev', desc: '', args: []);
  }

  /// `设置密保问题`
  String get pwdQuestion {
    return Intl.message('设置密保问题', name: 'pwdQuestion', desc: '', args: []);
  }

  /// `保存`
  String get save {
    return Intl.message('保存', name: 'save', desc: '', args: []);
  }

  /// `找回设备密码`
  String get pwdFindBack {
    return Intl.message('找回设备密码', name: 'pwdFindBack', desc: '', args: []);
  }

  /// `云存下载管理`
  String get cloudDownload {
    return Intl.message('云存下载管理', name: 'cloudDownload', desc: '', args: []);
  }

  /// `下载管理`
  String get download {
    return Intl.message('下载管理', name: 'download', desc: '', args: []);
  }

  /// `云回放`
  String get cloudList {
    return Intl.message('云回放', name: 'cloudList', desc: '', args: []);
  }

  /// `卡存相册`
  String get sdList {
    return Intl.message('卡存相册', name: 'sdList', desc: '', args: []);
  }

  /// `{deviceId} 回放列表`
  String recordList(Object deviceId) {
    return Intl.message(
      '$deviceId 回放列表',
      name: 'recordList',
      desc: '',
      args: [deviceId],
    );
  }

  /// `录像设置`
  String get recordSetting {
    return Intl.message('录像设置', name: 'recordSetting', desc: '', args: []);
  }

  /// `存储管理`
  String get storageManagement {
    return Intl.message('存储管理', name: 'storageManagement', desc: '', args: []);
  }

  /// `存储卡异常`
  String get memoryCardError {
    return Intl.message('存储卡异常', name: 'memoryCardError', desc: '', args: []);
  }

  /// `设备没有存储卡`
  String get deviceNoMemoryCard {
    return Intl.message(
      '设备没有存储卡',
      name: 'deviceNoMemoryCard',
      desc: '',
      args: [],
    );
  }

  /// `很差`
  String get recordQualityVeryBad {
    return Intl.message('很差', name: 'recordQualityVeryBad', desc: '', args: []);
  }

  /// `较差`
  String get recordQualityBad {
    return Intl.message('较差', name: 'recordQualityBad', desc: '', args: []);
  }

  /// `一般`
  String get recordQualityNormal {
    return Intl.message('一般', name: 'recordQualityNormal', desc: '', args: []);
  }

  /// `好`
  String get recordQualityGood {
    return Intl.message('好', name: 'recordQualityGood', desc: '', args: []);
  }

  /// `很好`
  String get recordQualityVeryGood {
    return Intl.message(
      '很好',
      name: 'recordQualityVeryGood',
      desc: '',
      args: [],
    );
  }

  /// `最好`
  String get recordQualityBestGood {
    return Intl.message(
      '最好',
      name: 'recordQualityBestGood',
      desc: '',
      args: [],
    );
  }

  /// `高清`
  String get hd {
    return Intl.message('高清', name: 'hd', desc: '', args: []);
  }

  /// `标清`
  String get sd {
    return Intl.message('标清', name: 'sd', desc: '', args: []);
  }

  /// `录像开关`
  String get recordMode {
    return Intl.message('录像开关', name: 'recordMode', desc: '', args: []);
  }

  /// `录像画质`
  String get recordQuality {
    return Intl.message('录像画质', name: 'recordQuality', desc: '', args: []);
  }

  /// `录像段`
  String get recordClip {
    return Intl.message('录像段', name: 'recordClip', desc: '', args: []);
  }

  /// `录像音频`
  String get recordAudio {
    return Intl.message('录像音频', name: 'recordAudio', desc: '', args: []);
  }

  /// `未检测到SD卡无法进行全天录像`
  String get noSDCardTips {
    return Intl.message(
      '未检测到SD卡无法进行全天录像',
      name: 'noSDCardTips',
      desc: '',
      args: [],
    );
  }

  /// `基本设置`
  String get basicSetting {
    return Intl.message('基本设置', name: 'basicSetting', desc: '', args: []);
  }

  /// `图像左右翻转`
  String get imageFlipLeftRight {
    return Intl.message(
      '图像左右翻转',
      name: 'imageFlipLeftRight',
      desc: '',
      args: [],
    );
  }

  /// `图像上下翻转`
  String get imageFlipUpDown {
    return Intl.message('图像上下翻转', name: 'imageFlipUpDown', desc: '', args: []);
  }

  /// `开启`
  String get on {
    return Intl.message('开启', name: 'on', desc: '', args: []);
  }

  /// `人形检测开关`
  String get baseStationHumanDetectionSwitch {
    return Intl.message(
      '人形检测开关',
      name: 'baseStationHumanDetectionSwitch',
      desc: '',
      args: [],
    );
  }

  /// `报警订阅`
  String get alarmSubscription {
    return Intl.message('报警订阅', name: 'alarmSubscription', desc: '', args: []);
  }

  /// `报警录像`
  String get alarmRecording {
    return Intl.message('报警录像', name: 'alarmRecording', desc: '', args: []);
  }

  /// `报警抓图`
  String get alarmScreenshot {
    return Intl.message('报警抓图', name: 'alarmScreenshot', desc: '', args: []);
  }

  /// `消息上报`
  String get messageReporting {
    return Intl.message('消息上报', name: 'messageReporting', desc: '', args: []);
  }

  /// `当前SDK版本`
  String get sdkVersion {
    return Intl.message('当前SDK版本', name: 'sdkVersion', desc: '', args: []);
  }

  /// `设备已存在`
  String get addDeviceExisted {
    return Intl.message('设备已存在', name: 'addDeviceExisted', desc: '', args: []);
  }

  /// `智能设备`
  String get sceneAddDevice {
    return Intl.message('智能设备', name: 'sceneAddDevice', desc: '', args: []);
  }

  /// `连接蓝牙设备成功！`
  String get deviceAddConnectBleSuccess {
    return Intl.message(
      '连接蓝牙设备成功！',
      name: 'deviceAddConnectBleSuccess',
      desc: '',
      args: [],
    );
  }

  /// `1.连接蓝牙设备成功！`
  String get deviceAddConnectBleTip1 {
    return Intl.message(
      '1.连接蓝牙设备成功！',
      name: 'deviceAddConnectBleTip1',
      desc: '',
      args: [],
    );
  }

  /// `2.开始向设备发送配网信息...`
  String get deviceAddConnectBleTip2 {
    return Intl.message(
      '2.开始向设备发送配网信息...',
      name: 'deviceAddConnectBleTip2',
      desc: '',
      args: [],
    );
  }

  /// `2.设备已成功接收配网信息！`
  String get deviceAddConnectBleTip3 {
    return Intl.message(
      '2.设备已成功接收配网信息！',
      name: 'deviceAddConnectBleTip3',
      desc: '',
      args: [],
    );
  }

  /// `3.等待设备连接路由器...`
  String get deviceAddConnectBleTip4 {
    return Intl.message(
      '3.等待设备连接路由器...',
      name: 'deviceAddConnectBleTip4',
      desc: '',
      args: [],
    );
  }

  /// `3.配网成功！`
  String get deviceAddConnectBleTip5 {
    return Intl.message(
      '3.配网成功！',
      name: 'deviceAddConnectBleTip5',
      desc: '',
      args: [],
    );
  }

  /// `蓝牙连接已断开`
  String get deviceAddConnectBledDisconnected {
    return Intl.message(
      '蓝牙连接已断开',
      name: 'deviceAddConnectBledDisconnected',
      desc: '',
      args: [],
    );
  }

  /// `无法连接蓝牙`
  String get deviceBluetoothCantConnect {
    return Intl.message(
      '无法连接蓝牙',
      name: 'deviceBluetoothCantConnect',
      desc: '',
      args: [],
    );
  }

  /// `配网失败`
  String get addConnectDevFailed {
    return Intl.message(
      '配网失败',
      name: 'addConnectDevFailed',
      desc: '',
      args: [],
    );
  }

  /// `用于检索附近蓝牙设备或其他设备`
  String get privacyPermissionDevNearbyContent {
    return Intl.message(
      '用于检索附近蓝牙设备或其他设备',
      name: 'privacyPermissionDevNearbyContent',
      desc: '',
      args: [],
    );
  }

  /// `访问蓝牙权限`
  String get privacyPermissionBluetooth {
    return Intl.message(
      '访问蓝牙权限',
      name: 'privacyPermissionBluetooth',
      desc: '',
      args: [],
    );
  }

  /// `未获取到附近蓝牙设备扫描权限，将无法进行蓝牙配网、搜索等操作`
  String get blueToothPermissionCancelTips {
    return Intl.message(
      '未获取到附近蓝牙设备扫描权限，将无法进行蓝牙配网、搜索等操作',
      name: 'blueToothPermissionCancelTips',
      desc: '',
      args: [],
    );
  }

  /// `反馈日志`
  String get toolsFeedbackLog {
    return Intl.message('反馈日志', name: 'toolsFeedbackLog', desc: '', args: []);
  }

  /// `上传失败`
  String get Upload_F {
    return Intl.message('上传失败', name: 'Upload_F', desc: '', args: []);
  }

  /// `上传成功`
  String get Upload_S {
    return Intl.message('上传成功', name: 'Upload_S', desc: '', args: []);
  }

  /// `麦克风权限未开启`
  String get audio_ability_unsupport {
    return Intl.message(
      '麦克风权限未开启',
      name: 'audio_ability_unsupport',
      desc: '',
      args: [],
    );
  }

  /// `录音时长至少要大于1秒`
  String get Recording_Times_Not_DURATION {
    return Intl.message(
      '录音时长至少要大于1秒',
      name: 'Recording_Times_Not_DURATION',
      desc: '',
      args: [],
    );
  }

  /// `操作失败`
  String get operator_failed {
    return Intl.message('操作失败', name: 'operator_failed', desc: '', args: []);
  }

  /// `文件大小超过最大限制`
  String get TR_File_Size_Exceed_Max_Size {
    return Intl.message(
      '文件大小超过最大限制',
      name: 'TR_File_Size_Exceed_Max_Size',
      desc: '',
      args: [],
    );
  }

  /// `请输入报警提示语`
  String get TR_Please_Enter_Alarm_Tips {
    return Intl.message(
      '请输入报警提示语',
      name: 'TR_Please_Enter_Alarm_Tips',
      desc: '',
      args: [],
    );
  }

  /// `自定义语音`
  String get tr_settings_alarm_bell_customize {
    return Intl.message(
      '自定义语音',
      name: 'tr_settings_alarm_bell_customize',
      desc: '',
      args: [],
    );
  }

  /// `试听`
  String get TR_Audition {
    return Intl.message('试听', name: 'TR_Audition', desc: '', args: []);
  }

  /// `上传提示音`
  String get TR_Upload_Prompt_Voice {
    return Intl.message(
      '上传提示音',
      name: 'TR_Upload_Prompt_Voice',
      desc: '',
      args: [],
    );
  }

  /// `正在录音，再次点击结束录音`
  String get tr_pet_function_recording_state {
    return Intl.message(
      '正在录音，再次点击结束录音',
      name: 'tr_pet_function_recording_state',
      desc: '',
      args: [],
    );
  }

  /// `点击开始录音`
  String get tr_pet_function_record_start {
    return Intl.message(
      '点击开始录音',
      name: 'tr_pet_function_record_start',
      desc: '',
      args: [],
    );
  }

  /// `录音中...`
  String get tr_recording {
    return Intl.message('录音中...', name: 'tr_recording', desc: '', args: []);
  }

  /// `男`
  String get TR_Sex_Male {
    return Intl.message('男', name: 'TR_Sex_Male', desc: '', args: []);
  }

  /// `女`
  String get TR_Sex_Female {
    return Intl.message('女', name: 'TR_Sex_Female', desc: '', args: []);
  }

  /// `按下结束录音`
  String get TR_Press_To_End_Record {
    return Intl.message(
      '按下结束录音',
      name: 'TR_Press_To_End_Record',
      desc: '',
      args: [],
    );
  }

  /// `按下后开始录音`
  String get TR_Press_To_Record {
    return Intl.message(
      '按下后开始录音',
      name: 'TR_Press_To_Record',
      desc: '',
      args: [],
    );
  }

  /// `录制呼唤音`
  String get tr_pet_setting_sound_record_function {
    return Intl.message(
      '录制呼唤音',
      name: 'tr_pet_setting_sound_record_function',
      desc: '',
      args: [],
    );
  }

  /// `文字转语音`
  String get TR_Text_To_Voice {
    return Intl.message('文字转语音', name: 'TR_Text_To_Voice', desc: '', args: []);
  }

  /// `录制提示音`
  String get TR_Record_Prompt {
    return Intl.message('录制提示音', name: 'TR_Record_Prompt', desc: '', args: []);
  }

  /// `设备警铃`
  String get tr_settings_alarm_beep {
    return Intl.message(
      '设备警铃',
      name: 'tr_settings_alarm_beep',
      desc: '',
      args: [],
    );
  }

  /// `设备警铃选择`
  String get tr_settings_alarm_bell_select {
    return Intl.message(
      '设备警铃选择',
      name: 'tr_settings_alarm_bell_select',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<TR> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<TR> load(Locale locale) => TR.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
