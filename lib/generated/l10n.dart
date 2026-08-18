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

  /// `取消`
  String get cancel {
    return Intl.message('取消', name: 'cancel', desc: '', args: []);
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

  /// `客服中心`
  String get customerServiceCenter {
    return Intl.message(
      '客服中心',
      name: 'customerServiceCenter',
      desc: '',
      args: [],
    );
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

  /// `下载管理`
  String get tr_common_download_management {
    return Intl.message(
      '下载管理',
      name: 'tr_common_download_management',
      desc: '',
      args: [],
    );
  }

  /// `分享权限`
  String get sharePermission {
    return Intl.message('分享权限', name: 'sharePermission', desc: '', args: []);
  }

  /// `分享给`
  String get shareTo {
    return Intl.message('分享给', name: 'shareTo', desc: '', args: []);
  }

  /// `输入用户名/手机号/邮箱`
  String get inputAccountHint {
    return Intl.message(
      '输入用户名/手机号/邮箱',
      name: 'inputAccountHint',
      desc: '',
      args: [],
    );
  }

  /// `搜索`
  String get search {
    return Intl.message('搜索', name: 'search', desc: '', args: []);
  }

  /// `用户不存在`
  String get userNotFound {
    return Intl.message('用户不存在', name: 'userNotFound', desc: '', args: []);
  }

  /// `搜索失败`
  String get searchFailed {
    return Intl.message('搜索失败', name: 'searchFailed', desc: '', args: []);
  }

  /// `确认分享`
  String get confirmShare {
    return Intl.message('确认分享', name: 'confirmShare', desc: '', args: []);
  }

  /// `确定将设备分享给 {account}？`
  String confirmShareContent(Object account) {
    return Intl.message(
      '确定将设备分享给 $account？',
      name: 'confirmShareContent',
      desc: '',
      args: [account],
    );
  }

  /// `点击分享`
  String get clickToShare {
    return Intl.message('点击分享', name: 'clickToShare', desc: '', args: []);
  }

  /// `分享成功`
  String get shareSuccess {
    return Intl.message('分享成功', name: 'shareSuccess', desc: '', args: []);
  }

  /// `分享失败`
  String get shareFailed {
    return Intl.message('分享失败', name: 'shareFailed', desc: '', args: []);
  }

  /// `对讲`
  String get permIntercom {
    return Intl.message('对讲', name: 'permIntercom', desc: '', args: []);
  }

  /// `SD卡录像`
  String get permSdRecord {
    return Intl.message('SD卡录像', name: 'permSdRecord', desc: '', args: []);
  }

  /// `设备配置`
  String get permDeviceConfig {
    return Intl.message('设备配置', name: 'permDeviceConfig', desc: '', args: []);
  }

  /// `报警推送`
  String get permAlarmPush {
    return Intl.message('报警推送', name: 'permAlarmPush', desc: '', args: []);
  }

  /// `二维码分享`
  String get qrCodeShare {
    return Intl.message('二维码分享', name: 'qrCodeShare', desc: '', args: []);
  }

  /// `分享二维码`
  String get shareQRCode {
    return Intl.message('分享二维码', name: 'shareQRCode', desc: '', args: []);
  }

  /// `扫描二维码添加设备分享`
  String get shareQRTips {
    return Intl.message('扫描二维码添加设备分享', name: 'shareQRTips', desc: '', args: []);
  }

  /// `设备分享`
  String get deviceShare {
    return Intl.message('设备分享', name: 'deviceShare', desc: '', args: []);
  }

  /// `已分享账号`
  String get sharedAccounts {
    return Intl.message('已分享账号', name: 'sharedAccounts', desc: '', args: []);
  }

  /// `暂无已分享账号`
  String get noSharedAccount {
    return Intl.message('暂无已分享账号', name: 'noSharedAccount', desc: '', args: []);
  }

  /// `已接受`
  String get shareAccepted {
    return Intl.message('已接受', name: 'shareAccepted', desc: '', args: []);
  }

  /// `待接受`
  String get sharePending {
    return Intl.message('待接受', name: 'sharePending', desc: '', args: []);
  }

  /// `已拒绝`
  String get shareRejected {
    return Intl.message('已拒绝', name: 'shareRejected', desc: '', args: []);
  }

  /// `已过期`
  String get shareExpired {
    return Intl.message('已过期', name: 'shareExpired', desc: '', args: []);
  }

  /// `取消分享`
  String get cancelShare {
    return Intl.message('取消分享', name: 'cancelShare', desc: '', args: []);
  }

  /// `确定取消分享给 {account}？`
  String cancelShareContent(Object account) {
    return Intl.message(
      '确定取消分享给 $account？',
      name: 'cancelShareContent',
      desc: '',
      args: [account],
    );
  }

  /// `取消分享成功`
  String get cancelShareSuccess {
    return Intl.message(
      '取消分享成功',
      name: 'cancelShareSuccess',
      desc: '',
      args: [],
    );
  }

  /// `取消分享失败`
  String get cancelShareFailed {
    return Intl.message(
      '取消分享失败',
      name: 'cancelShareFailed',
      desc: '',
      args: [],
    );
  }

  /// `待接受的分享设备`
  String get pendingShareDevices {
    return Intl.message(
      '待接受的分享设备',
      name: 'pendingShareDevices',
      desc: '',
      args: [],
    );
  }

  /// `接受`
  String get acceptShare {
    return Intl.message('接受', name: 'acceptShare', desc: '', args: []);
  }

  /// `拒绝`
  String get refuseShare {
    return Intl.message('拒绝', name: 'refuseShare', desc: '', args: []);
  }

  /// `接受分享成功`
  String get acceptSuccess {
    return Intl.message('接受分享成功', name: 'acceptSuccess', desc: '', args: []);
  }

  /// `接受分享失败`
  String get acceptFailed {
    return Intl.message('接受分享失败', name: 'acceptFailed', desc: '', args: []);
  }

  /// `拒绝分享成功`
  String get refuseSuccess {
    return Intl.message('拒绝分享成功', name: 'refuseSuccess', desc: '', args: []);
  }

  /// `拒绝分享失败`
  String get refuseFailed {
    return Intl.message('拒绝分享失败', name: 'refuseFailed', desc: '', args: []);
  }

  /// `暂无权限`
  String get noPermissionTip {
    return Intl.message('暂无权限', name: 'noPermissionTip', desc: '', args: []);
  }

  /// `扫码添加分享设备`
  String get scanShareDevice {
    return Intl.message(
      '扫码添加分享设备',
      name: 'scanShareDevice',
      desc: '',
      args: [],
    );
  }

  /// `无效的分享二维码`
  String get invalidShareQR {
    return Intl.message('无效的分享二维码', name: 'invalidShareQR', desc: '', args: []);
  }

  /// `接受设备分享`
  String get acceptShareDevice {
    return Intl.message(
      '接受设备分享',
      name: 'acceptShareDevice',
      desc: '',
      args: [],
    );
  }

  /// `分享来自`
  String get shareFrom {
    return Intl.message('分享来自', name: 'shareFrom', desc: '', args: []);
  }

  /// `设备名称`
  String get labelDeviceName {
    return Intl.message('设备名称', name: 'labelDeviceName', desc: '', args: []);
  }

  /// `设备序列号`
  String get labelDevSN {
    return Intl.message('设备序列号', name: 'labelDevSN', desc: '', args: []);
  }

  /// `二维码已被使用，请联系设备主账号再次生成`
  String get TR_QR_Code_Has_Been_Used_Generate_Again {
    return Intl.message(
      '二维码已被使用，请联系设备主账号再次生成',
      name: 'TR_QR_Code_Has_Been_Used_Generate_Again',
      desc: '',
      args: [],
    );
  }

  /// `设备重启`
  String get deviceRestart {
    return Intl.message('设备重启', name: 'deviceRestart', desc: '', args: []);
  }

  /// `设备重置`
  String get deviceReset {
    return Intl.message('设备重置', name: 'deviceReset', desc: '', args: []);
  }

  /// `设备固件升级`
  String get deviceFirmwareUpgrade {
    return Intl.message(
      '设备固件升级',
      name: 'deviceFirmwareUpgrade',
      desc: '',
      args: [],
    );
  }

  /// `是否要重启设备？`
  String get deviceRestartTip {
    return Intl.message(
      '是否要重启设备？',
      name: 'deviceRestartTip',
      desc: '',
      args: [],
    );
  }

  /// `取消`
  String get cancelBtn {
    return Intl.message('取消', name: 'cancelBtn', desc: '', args: []);
  }

  /// `确定`
  String get confirmBtn {
    return Intl.message('确定', name: 'confirmBtn', desc: '', args: []);
  }

  /// `设备重启中...`
  String get rebootSuccess {
    return Intl.message('设备重启中...', name: 'rebootSuccess', desc: '', args: []);
  }

  /// `重启失败`
  String get rebootFailed {
    return Intl.message('重启失败', name: 'rebootFailed', desc: '', args: []);
  }

  /// `保存成功`
  String get saveSuccess {
    return Intl.message('保存成功', name: 'saveSuccess', desc: '', args: []);
  }

  /// `保存失败`
  String get saveFailed {
    return Intl.message('保存失败', name: 'saveFailed', desc: '', args: []);
  }

  /// `保存中...`
  String get saving {
    return Intl.message('保存中...', name: 'saving', desc: '', args: []);
  }

  /// `确定要恢复出厂设置吗？`
  String get deviceResetTip {
    return Intl.message(
      '确定要恢复出厂设置吗？',
      name: 'deviceResetTip',
      desc: '',
      args: [],
    );
  }

  /// `恢复出厂设置并删除设备`
  String get factoryResetAndDeleteDev {
    return Intl.message(
      '恢复出厂设置并删除设备',
      name: 'factoryResetAndDeleteDev',
      desc: '',
      args: [],
    );
  }

  /// `仅恢复出厂设置`
  String get onlyFactoryReset {
    return Intl.message(
      '仅恢复出厂设置',
      name: 'onlyFactoryReset',
      desc: '',
      args: [],
    );
  }

  /// `恢复出厂设置成功，重启中...`
  String get resetSuccess {
    return Intl.message(
      '恢复出厂设置成功，重启中...',
      name: 'resetSuccess',
      desc: '',
      args: [],
    );
  }

  /// `恢复出厂设置失败`
  String get resetFailed {
    return Intl.message('恢复出厂设置失败', name: 'resetFailed', desc: '', args: []);
  }

  /// `检查更新`
  String get firmwareCheckUpdate {
    return Intl.message(
      '检查更新',
      name: 'firmwareCheckUpdate',
      desc: '',
      args: [],
    );
  }

  /// `当前版本`
  String get firmwareCurrentVersion {
    return Intl.message(
      '当前版本',
      name: 'firmwareCurrentVersion',
      desc: '',
      args: [],
    );
  }

  /// `新版本`
  String get firmwareNewVersion {
    return Intl.message('新版本', name: 'firmwareNewVersion', desc: '', args: []);
  }

  /// `立即升级`
  String get firmwareUpgradeNow {
    return Intl.message('立即升级', name: 'firmwareUpgradeNow', desc: '', args: []);
  }

  /// `正在检查...`
  String get firmwareChecking {
    return Intl.message(
      '正在检查...',
      name: 'firmwareChecking',
      desc: '',
      args: [],
    );
  }

  /// `已是最新版本`
  String get firmwareLatest {
    return Intl.message('已是最新版本', name: 'firmwareLatest', desc: '', args: []);
  }

  /// `发现新版本`
  String get firmwareUpgradeAvailable {
    return Intl.message(
      '发现新版本',
      name: 'firmwareUpgradeAvailable',
      desc: '',
      args: [],
    );
  }

  /// `正在升级`
  String get firmwareUpgrading {
    return Intl.message('正在升级', name: 'firmwareUpgrading', desc: '', args: []);
  }

  /// `升级成功，重启中...`
  String get firmwareUpgradeSuccess {
    return Intl.message(
      '升级成功，重启中...',
      name: 'firmwareUpgradeSuccess',
      desc: '',
      args: [],
    );
  }

  /// `升级失败`
  String get firmwareUpgradeFailed {
    return Intl.message(
      '升级失败',
      name: 'firmwareUpgradeFailed',
      desc: '',
      args: [],
    );
  }

  /// `升级过程中请勿断开设备电源`
  String get firmwareUpgradeTip {
    return Intl.message(
      '升级过程中请勿断开设备电源',
      name: 'firmwareUpgradeTip',
      desc: '',
      args: [],
    );
  }

  /// `正在下载固件`
  String get firmwareDownloadFile {
    return Intl.message(
      '正在下载固件',
      name: 'firmwareDownloadFile',
      desc: '',
      args: [],
    );
  }

  /// `正在发送固件到设备`
  String get firmwareSendFile {
    return Intl.message(
      '正在发送固件到设备',
      name: 'firmwareSendFile',
      desc: '',
      args: [],
    );
  }

  /// `版本检查失败`
  String get firmwareVersionCheckFailed {
    return Intl.message(
      '版本检查失败',
      name: 'firmwareVersionCheckFailed',
      desc: '',
      args: [],
    );
  }

  /// `未获取到pid，无法执行检测更新`
  String get firmwarePidFail {
    return Intl.message(
      '未获取到pid，无法执行检测更新',
      name: 'firmwarePidFail',
      desc: '',
      args: [],
    );
  }

  /// `本地升级`
  String get firmwareLocalUpgrade {
    return Intl.message(
      '本地升级',
      name: 'firmwareLocalUpgrade',
      desc: '',
      args: [],
    );
  }

  /// `在线升级`
  String get firmwareOnlineUpgrade {
    return Intl.message(
      '在线升级',
      name: 'firmwareOnlineUpgrade',
      desc: '',
      args: [],
    );
  }

  /// `确认要升级设备固件吗？`
  String get firmwareUpgradeConfirm {
    return Intl.message(
      '确认要升级设备固件吗？',
      name: 'firmwareUpgradeConfirm',
      desc: '',
      args: [],
    );
  }

  /// `选择本地固件文件`
  String get firmwareSelectLocalFile {
    return Intl.message(
      '选择本地固件文件',
      name: 'firmwareSelectLocalFile',
      desc: '',
      args: [],
    );
  }

  /// `未找到本地固件文件`
  String get firmwareNoLocalFile {
    return Intl.message(
      '未找到本地固件文件',
      name: 'firmwareNoLocalFile',
      desc: '',
      args: [],
    );
  }

  /// `正在下载固件文件到本地`
  String get firmwareDownloadingToFirmware {
    return Intl.message(
      '正在下载固件文件到本地',
      name: 'firmwareDownloadingToFirmware',
      desc: '',
      args: [],
    );
  }

  /// `固件下载完成`
  String get firmwareDownloadSuccess {
    return Intl.message(
      '固件下载完成',
      name: 'firmwareDownloadSuccess',
      desc: '',
      args: [],
    );
  }

  /// `固件下载失败`
  String get firmwareDownloadFailed {
    return Intl.message(
      '固件下载失败',
      name: 'firmwareDownloadFailed',
      desc: '',
      args: [],
    );
  }

  /// `通用配置`
  String get commonConfig {
    return Intl.message('通用配置', name: 'commonConfig', desc: '', args: []);
  }

  /// `图像配置`
  String get imageConfig {
    return Intl.message('图像配置', name: 'imageConfig', desc: '', args: []);
  }

  /// `设置设备名称`
  String get setDeviceName {
    return Intl.message('设置设备名称', name: 'setDeviceName', desc: '', args: []);
  }

  /// `请输入设备名称`
  String get inputDeviceNameHint {
    return Intl.message(
      '请输入设备名称',
      name: 'inputDeviceNameHint',
      desc: '',
      args: [],
    );
  }

  /// `提示音`
  String get voiceTipSwitch {
    return Intl.message('提示音', name: 'voiceTipSwitch', desc: '', args: []);
  }

  /// `指示灯`
  String get statusLightSwitch {
    return Intl.message('指示灯', name: 'statusLightSwitch', desc: '', args: []);
  }

  /// `设备语言`
  String get deviceLanguage {
    return Intl.message('设备语言', name: 'deviceLanguage', desc: '', args: []);
  }

  /// `日夜切换`
  String get dayNightMode {
    return Intl.message('日夜切换', name: 'dayNightMode', desc: '', args: []);
  }

  /// `自动切换`
  String get dayNightAuto {
    return Intl.message('自动切换', name: 'dayNightAuto', desc: '', args: []);
  }

  /// `根据环境光线自动切换日夜模式`
  String get dayNightAutoTip {
    return Intl.message(
      '根据环境光线自动切换日夜模式',
      name: 'dayNightAutoTip',
      desc: '',
      args: [],
    );
  }

  /// `强制白天`
  String get dayNightDay {
    return Intl.message('强制白天', name: 'dayNightDay', desc: '', args: []);
  }

  /// `强制切换为白天模式`
  String get dayNightDayTip {
    return Intl.message(
      '强制切换为白天模式',
      name: 'dayNightDayTip',
      desc: '',
      args: [],
    );
  }

  /// `强制黑夜`
  String get dayNightNight {
    return Intl.message('强制黑夜', name: 'dayNightNight', desc: '', args: []);
  }

  /// `强制切换为黑夜模式`
  String get dayNightNightTip {
    return Intl.message(
      '强制切换为黑夜模式',
      name: 'dayNightNightTip',
      desc: '',
      args: [],
    );
  }

  /// `定时切换`
  String get dayNightTiming {
    return Intl.message('定时切换', name: 'dayNightTiming', desc: '', args: []);
  }

  /// `按设定时间段定时切换`
  String get dayNightTimingTip {
    return Intl.message(
      '按设定时间段定时切换',
      name: 'dayNightTimingTip',
      desc: '',
      args: [],
    );
  }

  /// `日夜切换灵敏度`
  String get dayNightSensitivity {
    return Intl.message(
      '日夜切换灵敏度',
      name: 'dayNightSensitivity',
      desc: '',
      args: [],
    );
  }

  /// `开始时间`
  String get startTime {
    return Intl.message('开始时间', name: 'startTime', desc: '', args: []);
  }

  /// `结束时间`
  String get endTime {
    return Intl.message('结束时间', name: 'endTime', desc: '', args: []);
  }

  /// `全双工对讲`
  String get fullDuplexIntercom {
    return Intl.message(
      '全双工对讲',
      name: 'fullDuplexIntercom',
      desc: '',
      args: [],
    );
  }

  /// `喇叭音量`
  String get speakerVolume {
    return Intl.message('喇叭音量', name: 'speakerVolume', desc: '', args: []);
  }

  /// `麦克风音量`
  String get micVolume {
    return Intl.message('麦克风音量', name: 'micVolume', desc: '', args: []);
  }

  /// `错误码`
  String get errorCode {
    return Intl.message('错误码', name: 'errorCode', desc: '', args: []);
  }

  /// `请输入错误码`
  String get enterErrorCode {
    return Intl.message('请输入错误码', name: 'enterErrorCode', desc: '', args: []);
  }

  /// `请输入正确的错误码`
  String get inputRightErrorCode {
    return Intl.message(
      '请输入正确的错误码',
      name: 'inputRightErrorCode',
      desc: '',
      args: [],
    );
  }

  /// `请在下方查询错误码或前往开放平台文档中心`
  String get pleaseCheckErrorCode {
    return Intl.message(
      '请在下方查询错误码或前往开放平台文档中心',
      name: 'pleaseCheckErrorCode',
      desc: '',
      args: [],
    );
  }

  /// `前往开放平台文档中心`
  String get visitOpenPlatformDocumentationCenter {
    return Intl.message(
      '前往开放平台文档中心',
      name: 'visitOpenPlatformDocumentationCenter',
      desc: '',
      args: [],
    );
  }

  /// `打开链接失败`
  String get openLinkFailed {
    return Intl.message('打开链接失败', name: 'openLinkFailed', desc: '', args: []);
  }

  /// `网络错误`
  String get tr_error_code_1000 {
    return Intl.message('网络错误', name: 'tr_error_code_1000', desc: '', args: []);
  }

  /// `发送缓冲区已满`
  String get tr_error_code_1001 {
    return Intl.message(
      '发送缓冲区已满',
      name: 'tr_error_code_1001',
      desc: '',
      args: [],
    );
  }

  /// `网络发送失败`
  String get tr_error_code_1002 {
    return Intl.message(
      '网络发送失败',
      name: 'tr_error_code_1002',
      desc: '',
      args: [],
    );
  }

  /// `网络接收失败`
  String get tr_error_code_1003 {
    return Intl.message(
      '网络接收失败',
      name: 'tr_error_code_1003',
      desc: '',
      args: [],
    );
  }

  /// `网络超时`
  String get tr_error_code_1004 {
    return Intl.message('网络超时', name: 'tr_error_code_1004', desc: '', args: []);
  }

  /// `没有对象`
  String get tr_error_code_1005 {
    return Intl.message('没有对象', name: 'tr_error_code_1005', desc: '', args: []);
  }

  /// `创建失败`
  String get tr_error_code_1006 {
    return Intl.message('创建失败', name: 'tr_error_code_1006', desc: '', args: []);
  }

  /// `连接失败`
  String get tr_error_code_1007 {
    return Intl.message('连接失败', name: 'tr_error_code_1007', desc: '', args: []);
  }

  /// `超时`
  String get tr_error_code_1008 {
    return Intl.message('超时', name: 'tr_error_code_1008', desc: '', args: []);
  }

  /// `无连接`
  String get tr_error_code_1009 {
    return Intl.message('无连接', name: 'tr_error_code_1009', desc: '', args: []);
  }

  /// `socket异常`
  String get tr_error_code_1010 {
    return Intl.message(
      'socket异常',
      name: 'tr_error_code_1010',
      desc: '',
      args: [],
    );
  }

  /// `socket关闭异常`
  String get tr_error_code_1011 {
    return Intl.message(
      'socket关闭异常',
      name: 'tr_error_code_1011',
      desc: '',
      args: [],
    );
  }

  /// `创建缓存失败`
  String get tr_error_code_1012 {
    return Intl.message(
      '创建缓存失败',
      name: 'tr_error_code_1012',
      desc: '',
      args: [],
    );
  }

  /// `网络忙`
  String get tr_error_code_1013 {
    return Intl.message('网络忙', name: 'tr_error_code_1013', desc: '', args: []);
  }

  /// `监听异常`
  String get tr_error_code_1014 {
    return Intl.message('监听异常', name: 'tr_error_code_1014', desc: '', args: []);
  }

  /// `接收异常`
  String get tr_error_code_1015 {
    return Intl.message('接收异常', name: 'tr_error_code_1015', desc: '', args: []);
  }

  /// `无缓冲区`
  String get tr_error_code_1016 {
    return Intl.message('无缓冲区', name: 'tr_error_code_1016', desc: '', args: []);
  }

  /// `网络错误或DNS配置错误`
  String get tr_error_code_1017 {
    return Intl.message(
      '网络错误或DNS配置错误',
      name: 'tr_error_code_1017',
      desc: '',
      args: [],
    );
  }

  /// `开发者账号未鉴权`
  String get tr_error_code_1018 {
    return Intl.message(
      '开发者账号未鉴权',
      name: 'tr_error_code_1018',
      desc: '',
      args: [],
    );
  }

  /// `未初始化`
  String get tr_error_code_1019 {
    return Intl.message('未初始化', name: 'tr_error_code_1019', desc: '', args: []);
  }

  /// `设备深度休眠中`
  String get tr_error_code_1020 {
    return Intl.message(
      '设备深度休眠中',
      name: 'tr_error_code_1020',
      desc: '',
      args: [],
    );
  }

  /// `服务器发生错误`
  String get tr_error_code_1021 {
    return Intl.message(
      '服务器发生错误',
      name: 'tr_error_code_1021',
      desc: '',
      args: [],
    );
  }

  /// `HTTPS通讯错误`
  String get tr_error_code_1022 {
    return Intl.message(
      'HTTPS通讯错误',
      name: 'tr_error_code_1022',
      desc: '',
      args: [],
    );
  }

  /// `本机系统忙，请稍后再试`
  String get tr_error_code_1023 {
    return Intl.message(
      '本机系统忙，请稍后再试',
      name: 'tr_error_code_1023',
      desc: '',
      args: [],
    );
  }

  /// `本机网络忙，请稍后再试`
  String get tr_error_code_1024 {
    return Intl.message(
      '本机网络忙，请稍后再试',
      name: 'tr_error_code_1024',
      desc: '',
      args: [],
    );
  }

  /// `CPU忙，请稍后再试`
  String get tr_error_code_1025 {
    return Intl.message(
      'CPU忙，请稍后再试',
      name: 'tr_error_code_1025',
      desc: '',
      args: [],
    );
  }

  /// `内存使用过高，请稍后再试`
  String get tr_error_code_1026 {
    return Intl.message(
      '内存使用过高，请稍后再试',
      name: 'tr_error_code_1026',
      desc: '',
      args: [],
    );
  }

  /// `并发任务过多，请稍后再试`
  String get tr_error_code_1027 {
    return Intl.message(
      '并发任务过多，请稍后再试',
      name: 'tr_error_code_1027',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---内存不足`
  String get tr_error_code_70001 {
    return Intl.message(
      '设备升级---内存不足',
      name: 'tr_error_code_70001',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---文件格式不对`
  String get tr_error_code_70002 {
    return Intl.message(
      '设备升级---文件格式不对',
      name: 'tr_error_code_70002',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---某个分区升级失败`
  String get tr_error_code_70003 {
    return Intl.message(
      '设备升级---某个分区升级失败',
      name: 'tr_error_code_70003',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---硬件型号不匹配`
  String get tr_error_code_70004 {
    return Intl.message(
      '设备升级---硬件型号不匹配',
      name: 'tr_error_code_70004',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---客户信息不匹配`
  String get tr_error_code_70005 {
    return Intl.message(
      '设备升级---客户信息不匹配',
      name: 'tr_error_code_70005',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---要升级的版本低于设备目前版本，不允许升级`
  String get tr_error_code_70006 {
    return Intl.message(
      '设备升级---要升级的版本低于设备目前版本，不允许升级',
      name: 'tr_error_code_70006',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---非法的版本`
  String get tr_error_code_70007 {
    return Intl.message(
      '设备升级---非法的版本',
      name: 'tr_error_code_70007',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---升级程序里wifi驱动和设备当前在使用的wifi网卡不匹配`
  String get tr_error_code_70008 {
    return Intl.message(
      '设备升级---升级程序里wifi驱动和设备当前在使用的wifi网卡不匹配',
      name: 'tr_error_code_70008',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---网络错误`
  String get tr_error_code_70009 {
    return Intl.message(
      '设备升级---网络错误',
      name: 'tr_error_code_70009',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---升级程序不支持设备使用的Flash`
  String get tr_error_code_70010 {
    return Intl.message(
      '设备升级---升级程序不支持设备使用的Flash',
      name: 'tr_error_code_70010',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---升级文件被修改，不能通过外网升级`
  String get tr_error_code_70011 {
    return Intl.message(
      '设备升级---升级文件被修改，不能通过外网升级',
      name: 'tr_error_code_70011',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---升级此固件需要特殊能力支持`
  String get tr_error_code_70012 {
    return Intl.message(
      '设备升级---升级此固件需要特殊能力支持',
      name: 'tr_error_code_70012',
      desc: '',
      args: [],
    );
  }

  /// `未知错误`
  String get tr_error_code_70101 {
    return Intl.message(
      '未知错误',
      name: 'tr_error_code_70101',
      desc: '',
      args: [],
    );
  }

  /// `版本不支持`
  String get tr_error_code_70102 {
    return Intl.message(
      '版本不支持',
      name: 'tr_error_code_70102',
      desc: '',
      args: [],
    );
  }

  /// `非法请求`
  String get tr_error_code_70103 {
    return Intl.message(
      '非法请求',
      name: 'tr_error_code_70103',
      desc: '',
      args: [],
    );
  }

  /// `用户已登录`
  String get tr_error_code_70104 {
    return Intl.message(
      '用户已登录',
      name: 'tr_error_code_70104',
      desc: '',
      args: [],
    );
  }

  /// `用户未登录`
  String get tr_error_code_70105 {
    return Intl.message(
      '用户未登录',
      name: 'tr_error_code_70105',
      desc: '',
      args: [],
    );
  }

  /// `用户名或密码不正确`
  String get tr_error_code_70106 {
    return Intl.message(
      '用户名或密码不正确',
      name: 'tr_error_code_70106',
      desc: '',
      args: [],
    );
  }

  /// `无设备功能权限`
  String get tr_error_code_70107 {
    return Intl.message(
      '无设备功能权限',
      name: 'tr_error_code_70107',
      desc: '',
      args: [],
    );
  }

  /// `超时`
  String get tr_error_code_70108 {
    return Intl.message('超时', name: 'tr_error_code_70108', desc: '', args: []);
  }

  /// `搜索失败，未找到相应的文件`
  String get tr_error_code_70109 {
    return Intl.message(
      '搜索失败，未找到相应的文件',
      name: 'tr_error_code_70109',
      desc: '',
      args: [],
    );
  }

  /// `搜索成功，返回所有文件`
  String get tr_error_code_70110 {
    return Intl.message(
      '搜索成功，返回所有文件',
      name: 'tr_error_code_70110',
      desc: '',
      args: [],
    );
  }

  /// `搜索成功，返回部分文件`
  String get tr_error_code_70111 {
    return Intl.message(
      '搜索成功，返回部分文件',
      name: 'tr_error_code_70111',
      desc: '',
      args: [],
    );
  }

  /// `用户已存在`
  String get tr_error_code_70112 {
    return Intl.message(
      '用户已存在',
      name: 'tr_error_code_70112',
      desc: '',
      args: [],
    );
  }

  /// `用户不存在`
  String get tr_error_code_70113 {
    return Intl.message(
      '用户不存在',
      name: 'tr_error_code_70113',
      desc: '',
      args: [],
    );
  }

  /// `用户组已存在`
  String get tr_error_code_70114 {
    return Intl.message(
      '用户组已存在',
      name: 'tr_error_code_70114',
      desc: '',
      args: [],
    );
  }

  /// `用户组不存在`
  String get tr_error_code_70115 {
    return Intl.message(
      '用户组不存在',
      name: 'tr_error_code_70115',
      desc: '',
      args: [],
    );
  }

  /// `盗版软件`
  String get tr_error_code_70116 {
    return Intl.message(
      '盗版软件',
      name: 'tr_error_code_70116',
      desc: '',
      args: [],
    );
  }

  /// `消息格式不正确`
  String get tr_error_code_70117 {
    return Intl.message(
      '消息格式不正确',
      name: 'tr_error_code_70117',
      desc: '',
      args: [],
    );
  }

  /// `未设置云台协议`
  String get tr_error_code_70118 {
    return Intl.message(
      '未设置云台协议',
      name: 'tr_error_code_70118',
      desc: '',
      args: [],
    );
  }

  /// `未找到录像文件`
  String get tr_error_code_70119 {
    return Intl.message(
      '未找到录像文件',
      name: 'tr_error_code_70119',
      desc: '',
      args: [],
    );
  }

  /// `配置未启用`
  String get tr_error_code_70120 {
    return Intl.message(
      '配置未启用',
      name: 'tr_error_code_70120',
      desc: '',
      args: [],
    );
  }

  /// `数字通道未连接`
  String get tr_error_code_70121 {
    return Intl.message(
      '数字通道未连接',
      name: 'tr_error_code_70121',
      desc: '',
      args: [],
    );
  }

  /// `NAT视频连接数达到最大值，不允许新的NAT连接`
  String get tr_error_code_70122 {
    return Intl.message(
      'NAT视频连接数达到最大值，不允许新的NAT连接',
      name: 'tr_error_code_70122',
      desc: '',
      args: [],
    );
  }

  /// `TCP视频连接数达到最大值，不允许新的TCP视频连接`
  String get tr_error_code_70123 {
    return Intl.message(
      'TCP视频连接数达到最大值，不允许新的TCP视频连接',
      name: 'tr_error_code_70123',
      desc: '',
      args: [],
    );
  }

  /// `不支持此种登录功能（用户名和密码的加密算法不正确）`
  String get tr_error_code_70124 {
    return Intl.message(
      '不支持此种登录功能（用户名和密码的加密算法不正确）',
      name: 'tr_error_code_70124',
      desc: '',
      args: [],
    );
  }

  /// `已创建其他用户，无法再使用管理员登录`
  String get tr_error_code_70125 {
    return Intl.message(
      '已创建其他用户，无法再使用管理员登录',
      name: 'tr_error_code_70125',
      desc: '',
      args: [],
    );
  }

  /// `AES加密数据格式错误`
  String get tr_error_code_70126 {
    return Intl.message(
      'AES加密数据格式错误',
      name: 'tr_error_code_70126',
      desc: '',
      args: [],
    );
  }

  /// `用户通过一键遮蔽等功能关闭了视频录像和预览功能`
  String get tr_error_code_70127 {
    return Intl.message(
      '用户通过一键遮蔽等功能关闭了视频录像和预览功能',
      name: 'tr_error_code_70127',
      desc: '',
      args: [],
    );
  }

  /// `禁止4G远程看视频`
  String get tr_error_code_70128 {
    return Intl.message(
      '禁止4G远程看视频',
      name: 'tr_error_code_70128',
      desc: '',
      args: [],
    );
  }

  /// `禁止使用admin用户名远程登录`
  String get tr_error_code_70129 {
    return Intl.message(
      '禁止使用admin用户名远程登录',
      name: 'tr_error_code_70129',
      desc: '',
      args: [],
    );
  }

  /// `NAS地址已存在`
  String get tr_error_code_70130 {
    return Intl.message(
      'NAS地址已存在',
      name: 'tr_error_code_70130',
      desc: '',
      args: [],
    );
  }

  /// `路径正在使用，无法操作`
  String get tr_error_code_70131 {
    return Intl.message(
      '路径正在使用，无法操作',
      name: 'tr_error_code_70131',
      desc: '',
      args: [],
    );
  }

  /// `NAS已达到支持的最大值，不允许进一步添加`
  String get tr_error_code_70132 {
    return Intl.message(
      'NAS已达到支持的最大值，不允许进一步添加',
      name: 'tr_error_code_70132',
      desc: '',
      args: [],
    );
  }

  /// `CGI格式错误`
  String get tr_error_code_70136 {
    return Intl.message(
      'CGI格式错误',
      name: 'tr_error_code_70136',
      desc: '',
      args: [],
    );
  }

  /// `设备登录Token错误`
  String get tr_error_code_70137 {
    return Intl.message(
      '设备登录Token错误',
      name: 'tr_error_code_70137',
      desc: '',
      args: [],
    );
  }

  /// `消费类产品绑定了错误的密钥`
  String get tr_error_code_70140 {
    return Intl.message(
      '消费类产品绑定了错误的密钥',
      name: 'tr_error_code_70140',
      desc: '',
      args: [],
    );
  }

  /// `成功，设备需要重启`
  String get tr_error_code_70150 {
    return Intl.message(
      '成功，设备需要重启',
      name: 'tr_error_code_70150',
      desc: '',
      args: [],
    );
  }

  /// `文件没有删除成功`
  String get tr_error_code_70151 {
    return Intl.message(
      '文件没有删除成功',
      name: 'tr_error_code_70151',
      desc: '',
      args: [],
    );
  }

  /// `容量不足`
  String get tr_error_code_70152 {
    return Intl.message(
      '容量不足',
      name: 'tr_error_code_70152',
      desc: '',
      args: [],
    );
  }

  /// `没有SD卡或硬盘`
  String get tr_error_code_70153 {
    return Intl.message(
      '没有SD卡或硬盘',
      name: 'tr_error_code_70153',
      desc: '',
      args: [],
    );
  }

  /// `视频备份失败`
  String get tr_error_code_70160 {
    return Intl.message(
      '视频备份失败',
      name: 'tr_error_code_70160',
      desc: '',
      args: [],
    );
  }

  /// `没有录像设备或设备没有进行录像`
  String get tr_error_code_70161 {
    return Intl.message(
      '没有录像设备或设备没有进行录像',
      name: 'tr_error_code_70161',
      desc: '',
      args: [],
    );
  }

  /// `正在添加设备`
  String get tr_error_code_70162 {
    return Intl.message(
      '正在添加设备',
      name: 'tr_error_code_70162',
      desc: '',
      args: [],
    );
  }

  /// `设备返回了错误的密码`
  String get tr_error_code_70163 {
    return Intl.message(
      '设备返回了错误的密码',
      name: 'tr_error_code_70163',
      desc: '',
      args: [],
    );
  }

  /// `设备空间不足`
  String get tr_error_code_70164 {
    return Intl.message(
      '设备空间不足',
      name: 'tr_error_code_70164',
      desc: '',
      args: [],
    );
  }

  /// `设备忙，当前不提供服务/(IOT设备)对端连接数已达上限`
  String get tr_error_code_70165 {
    return Intl.message(
      '设备忙，当前不提供服务/(IOT设备)对端连接数已达上限',
      name: 'tr_error_code_70165',
      desc: '',
      args: [],
    );
  }

  /// `功能未启用`
  String get tr_error_code_70170 {
    return Intl.message(
      '功能未启用',
      name: 'tr_error_code_70170',
      desc: '',
      args: [],
    );
  }

  /// `连接服务器失败`
  String get tr_error_code_70173 {
    return Intl.message(
      '连接服务器失败',
      name: 'tr_error_code_70173',
      desc: '',
      args: [],
    );
  }

  /// `检测不到内存`
  String get tr_error_code_70174 {
    return Intl.message(
      '检测不到内存',
      name: 'tr_error_code_70174',
      desc: '',
      args: [],
    );
  }

  /// `功能已经启动`
  String get tr_error_code_70180 {
    return Intl.message(
      '功能已经启动',
      name: 'tr_error_code_70180',
      desc: '',
      args: [],
    );
  }

  /// `网络初始化失败`
  String get tr_error_code_70181 {
    return Intl.message(
      '网络初始化失败',
      name: 'tr_error_code_70181',
      desc: '',
      args: [],
    );
  }

  /// `系统错误`
  String get tr_error_code_70182 {
    return Intl.message(
      '系统错误',
      name: 'tr_error_code_70182',
      desc: '',
      args: [],
    );
  }

  /// `操作失败`
  String get tr_error_code_70183 {
    return Intl.message(
      '操作失败',
      name: 'tr_error_code_70183',
      desc: '',
      args: [],
    );
  }

  /// `低功耗模式切换到常电模式失败`
  String get tr_error_code_70184 {
    return Intl.message(
      '低功耗模式切换到常电模式失败',
      name: 'tr_error_code_70184',
      desc: '',
      args: [],
    );
  }

  /// `未登录`
  String get tr_error_code_70202 {
    return Intl.message('未登录', name: 'tr_error_code_70202', desc: '', args: []);
  }

  /// `登录设备密码错误`
  String get tr_error_code_70203 {
    return Intl.message(
      '登录设备密码错误',
      name: 'tr_error_code_70203',
      desc: '',
      args: [],
    );
  }

  /// `非法用户`
  String get tr_error_code_70205 {
    return Intl.message(
      '非法用户',
      name: 'tr_error_code_70205',
      desc: '',
      args: [],
    );
  }

  /// `帐户被锁定，登录错误`
  String get tr_error_code_70206 {
    return Intl.message(
      '帐户被锁定，登录错误',
      name: 'tr_error_code_70206',
      desc: '',
      args: [],
    );
  }

  /// `帐户已列入黑名单`
  String get tr_error_code_70207 {
    return Intl.message(
      '帐户已列入黑名单',
      name: 'tr_error_code_70207',
      desc: '',
      args: [],
    );
  }

  /// `用户已使用`
  String get tr_error_code_70208 {
    return Intl.message(
      '用户已使用',
      name: 'tr_error_code_70208',
      desc: '',
      args: [],
    );
  }

  /// `输入无效`
  String get tr_error_code_70209 {
    return Intl.message(
      '输入无效',
      name: 'tr_error_code_70209',
      desc: '',
      args: [],
    );
  }

  /// `如果要添加的用户已经存在，则索引重复`
  String get tr_error_code_70210 {
    return Intl.message(
      '如果要添加的用户已经存在，则索引重复',
      name: 'tr_error_code_70210',
      desc: '',
      args: [],
    );
  }

  /// `用于查询时对象不存在`
  String get tr_error_code_70211 {
    return Intl.message(
      '用于查询时对象不存在',
      name: 'tr_error_code_70211',
      desc: '',
      args: [],
    );
  }

  /// `对象不存在`
  String get tr_error_code_70212 {
    return Intl.message(
      '对象不存在',
      name: 'tr_error_code_70212',
      desc: '',
      args: [],
    );
  }

  /// `目标正在使用中`
  String get tr_error_code_70213 {
    return Intl.message(
      '目标正在使用中',
      name: 'tr_error_code_70213',
      desc: '',
      args: [],
    );
  }

  /// `子集超出范围`
  String get tr_error_code_70214 {
    return Intl.message(
      '子集超出范围',
      name: 'tr_error_code_70214',
      desc: '',
      args: [],
    );
  }

  /// `密码不正确`
  String get tr_error_code_70215 {
    return Intl.message(
      '密码不正确',
      name: 'tr_error_code_70215',
      desc: '',
      args: [],
    );
  }

  /// `密码不匹配`
  String get tr_error_code_70216 {
    return Intl.message(
      '密码不匹配',
      name: 'tr_error_code_70216',
      desc: '',
      args: [],
    );
  }

  /// `保留帐户`
  String get tr_error_code_70217 {
    return Intl.message(
      '保留帐户',
      name: 'tr_error_code_70217',
      desc: '',
      args: [],
    );
  }

  /// `系统维护期间无法登录`
  String get tr_error_code_70218 {
    return Intl.message(
      '系统维护期间无法登录',
      name: 'tr_error_code_70218',
      desc: '',
      args: [],
    );
  }

  /// `试用期已结束，解锁密码不正确`
  String get tr_error_code_70219 {
    return Intl.message(
      '试用期已结束，解锁密码不正确',
      name: 'tr_error_code_70219',
      desc: '',
      args: [],
    );
  }

  /// `安全问题答案错误`
  String get tr_error_code_70220 {
    return Intl.message(
      '安全问题答案错误',
      name: 'tr_error_code_70220',
      desc: '',
      args: [],
    );
  }

  /// `重置密码功能，恢复默认验证码尝试次数太多`
  String get tr_error_code_70221 {
    return Intl.message(
      '重置密码功能，恢复默认验证码尝试次数太多',
      name: 'tr_error_code_70221',
      desc: '',
      args: [],
    );
  }

  /// `恢复默认验证码错误`
  String get tr_error_code_70222 {
    return Intl.message(
      '恢复默认验证码错误',
      name: 'tr_error_code_70222',
      desc: '',
      args: [],
    );
  }

  /// `用户名不可用`
  String get tr_error_code_70223 {
    return Intl.message(
      '用户名不可用',
      name: 'tr_error_code_70223',
      desc: '',
      args: [],
    );
  }

  /// `存储达到上限，不能再增加新用户了`
  String get tr_error_code_70224 {
    return Intl.message(
      '存储达到上限，不能再增加新用户了',
      name: 'tr_error_code_70224',
      desc: '',
      args: [],
    );
  }

  /// `命令不合法`
  String get tr_error_code_70502 {
    return Intl.message(
      '命令不合法',
      name: 'tr_error_code_70502',
      desc: '',
      args: [],
    );
  }

  /// `设备对讲已经开启`
  String get tr_error_code_70503 {
    return Intl.message(
      '设备对讲已经开启',
      name: 'tr_error_code_70503',
      desc: '',
      args: [],
    );
  }

  /// `对讲未开启`
  String get tr_error_code_70504 {
    return Intl.message(
      '对讲未开启',
      name: 'tr_error_code_70504',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---已经开始升级`
  String get tr_error_code_70511 {
    return Intl.message(
      '设备升级---已经开始升级',
      name: 'tr_error_code_70511',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---未开始升级`
  String get tr_error_code_70512 {
    return Intl.message(
      '设备升级---未开始升级',
      name: 'tr_error_code_70512',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---升级数据错误`
  String get tr_error_code_70513 {
    return Intl.message(
      '设备升级---升级数据错误',
      name: 'tr_error_code_70513',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---升级失败`
  String get tr_error_code_70514 {
    return Intl.message(
      '设备升级---升级失败',
      name: 'tr_error_code_70514',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---设备忙或云升级服务器忙`
  String get tr_error_code_70516 {
    return Intl.message(
      '设备升级---设备忙或云升级服务器忙',
      name: 'tr_error_code_70516',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---该升级由其他连接开启，无法停止`
  String get tr_error_code_70517 {
    return Intl.message(
      '设备升级---该升级由其他连接开启，无法停止',
      name: 'tr_error_code_70517',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---当前已是最新版本`
  String get tr_error_code_70518 {
    return Intl.message(
      '设备升级---当前已是最新版本',
      name: 'tr_error_code_70518',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---升级文件不匹配`
  String get tr_error_code_70519 {
    return Intl.message(
      '设备升级---升级文件不匹配',
      name: 'tr_error_code_70519',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---前端设备不在线`
  String get tr_error_code_70520 {
    return Intl.message(
      '设备升级---前端设备不在线',
      name: 'tr_error_code_70520',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---还原默认失败`
  String get tr_error_code_70521 {
    return Intl.message(
      '设备升级---还原默认失败',
      name: 'tr_error_code_70521',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---需要重启设备`
  String get tr_error_code_70522 {
    return Intl.message(
      '设备升级---需要重启设备',
      name: 'tr_error_code_70522',
      desc: '',
      args: [],
    );
  }

  /// `设备升级---默认配置非法`
  String get tr_error_code_70523 {
    return Intl.message(
      '设备升级---默认配置非法',
      name: 'tr_error_code_70523',
      desc: '',
      args: [],
    );
  }

  /// `蓝牙配对已经开始`
  String get tr_error_code_70524 {
    return Intl.message(
      '蓝牙配对已经开始',
      name: 'tr_error_code_70524',
      desc: '',
      args: [],
    );
  }

  /// `蓝牙配对添加到达上限`
  String get tr_error_code_70525 {
    return Intl.message(
      '蓝牙配对添加到达上限',
      name: 'tr_error_code_70525',
      desc: '',
      args: [],
    );
  }

  /// `低电量不支持操控云台`
  String get tr_error_code_70526 {
    return Intl.message(
      '低电量不支持操控云台',
      name: 'tr_error_code_70526',
      desc: '',
      args: [],
    );
  }

  /// `消息发给主控失败了`
  String get tr_error_code_70527 {
    return Intl.message(
      '消息发给主控失败了',
      name: 'tr_error_code_70527',
      desc: '',
      args: [],
    );
  }

  /// `获取升级文件信息失败`
  String get tr_error_code_70528 {
    return Intl.message(
      '获取升级文件信息失败',
      name: 'tr_error_code_70528',
      desc: '',
      args: [],
    );
  }

  /// `未启动在线升级`
  String get tr_error_code_70529 {
    return Intl.message(
      '未启动在线升级',
      name: 'tr_error_code_70529',
      desc: '',
      args: [],
    );
  }

  /// `忽略版本信息提示`
  String get tr_error_code_70530 {
    return Intl.message(
      '忽略版本信息提示',
      name: 'tr_error_code_70530',
      desc: '',
      args: [],
    );
  }

  /// `远程人脸录入功能未启用`
  String get tr_error_code_70531 {
    return Intl.message(
      '远程人脸录入功能未启用',
      name: 'tr_error_code_70531',
      desc: '',
      args: [],
    );
  }

  /// `需要重新启动应用程序`
  String get tr_error_code_70602 {
    return Intl.message(
      '需要重新启动应用程序',
      name: 'tr_error_code_70602',
      desc: '',
      args: [],
    );
  }

  /// `需要重新启动设备`
  String get tr_error_code_70603 {
    return Intl.message(
      '需要重新启动设备',
      name: 'tr_error_code_70603',
      desc: '',
      args: [],
    );
  }

  /// `写入文件失败`
  String get tr_error_code_70604 {
    return Intl.message(
      '写入文件失败',
      name: 'tr_error_code_70604',
      desc: '',
      args: [],
    );
  }

  /// `功能不支持`
  String get tr_error_code_70605 {
    return Intl.message(
      '功能不支持',
      name: 'tr_error_code_70605',
      desc: '',
      args: [],
    );
  }

  /// `验证失败`
  String get tr_error_code_70606 {
    return Intl.message(
      '验证失败',
      name: 'tr_error_code_70606',
      desc: '',
      args: [],
    );
  }

  /// `配置解析错误`
  String get tr_error_code_70607 {
    return Intl.message(
      '配置解析错误',
      name: 'tr_error_code_70607',
      desc: '',
      args: [],
    );
  }

  /// `配置不存在`
  String get tr_error_code_70609 {
    return Intl.message(
      '配置不存在',
      name: 'tr_error_code_70609',
      desc: '',
      args: [],
    );
  }

  /// `Json解析异常`
  String get tr_error_code_69999 {
    return Intl.message(
      'Json解析异常',
      name: 'tr_error_code_69999',
      desc: '',
      args: [],
    );
  }

  /// `打开音频失败`
  String get tr_error_code_79998 {
    return Intl.message(
      '打开音频失败',
      name: 'tr_error_code_79998',
      desc: '',
      args: [],
    );
  }

  /// `YUV数据异常`
  String get tr_error_code_79999 {
    return Intl.message(
      'YUV数据异常',
      name: 'tr_error_code_79999',
      desc: '',
      args: [],
    );
  }

  /// `用户取消`
  String get tr_error_code_90000 {
    return Intl.message(
      '用户取消',
      name: 'tr_error_code_90000',
      desc: '',
      args: [],
    );
  }

  /// `非法文件`
  String get tr_error_code_90001 {
    return Intl.message(
      '非法文件',
      name: 'tr_error_code_90001',
      desc: '',
      args: [],
    );
  }

  /// `账号未启用`
  String get tr_error_code_90002 {
    return Intl.message(
      '账号未启用',
      name: 'tr_error_code_90002',
      desc: '',
      args: [],
    );
  }

  /// `功能超期`
  String get tr_error_code_90003 {
    return Intl.message(
      '功能超期',
      name: 'tr_error_code_90003',
      desc: '',
      args: [],
    );
  }

  /// `达到最大连接数`
  String get tr_error_code_90004 {
    return Intl.message(
      '达到最大连接数',
      name: 'tr_error_code_90004',
      desc: '',
      args: [],
    );
  }

  /// `功能未初始化`
  String get tr_error_code_90005 {
    return Intl.message(
      '功能未初始化',
      name: 'tr_error_code_90005',
      desc: '',
      args: [],
    );
  }

  /// `唤醒设备失败`
  String get tr_error_code_99967 {
    return Intl.message(
      '唤醒设备失败',
      name: 'tr_error_code_99967',
      desc: '',
      args: [],
    );
  }

  /// `设备深度休眠`
  String get tr_error_code_99968 {
    return Intl.message(
      '设备深度休眠',
      name: 'tr_error_code_99968',
      desc: '',
      args: [],
    );
  }

  /// `设备准备休眠中`
  String get tr_error_code_99969 {
    return Intl.message(
      '设备准备休眠中',
      name: 'tr_error_code_99969',
      desc: '',
      args: [],
    );
  }

  /// `文件读取失败`
  String get tr_error_code_99970 {
    return Intl.message(
      '文件读取失败',
      name: 'tr_error_code_99970',
      desc: '',
      args: [],
    );
  }

  /// `文件下载失败`
  String get tr_error_code_99971 {
    return Intl.message(
      '文件下载失败',
      name: 'tr_error_code_99971',
      desc: '',
      args: [],
    );
  }

  /// `文件不存在`
  String get tr_error_code_99972 {
    return Intl.message(
      '文件不存在',
      name: 'tr_error_code_99972',
      desc: '',
      args: [],
    );
  }

  /// `目录不存在`
  String get tr_error_code_99973 {
    return Intl.message(
      '目录不存在',
      name: 'tr_error_code_99973',
      desc: '',
      args: [],
    );
  }

  /// `初始化时未设置临时文件目录`
  String get tr_error_code_99974 {
    return Intl.message(
      '初始化时未设置临时文件目录',
      name: 'tr_error_code_99974',
      desc: '',
      args: [],
    );
  }

  /// `离线状态`
  String get tr_error_code_99975 {
    return Intl.message(
      '离线状态',
      name: 'tr_error_code_99975',
      desc: '',
      args: [],
    );
  }

  /// `用户在黑名单中`
  String get tr_error_code_99976 {
    return Intl.message(
      '用户在黑名单中',
      name: 'tr_error_code_99976',
      desc: '',
      args: [],
    );
  }

  /// `用户被锁定`
  String get tr_error_code_99977 {
    return Intl.message(
      '用户被锁定',
      name: 'tr_error_code_99977',
      desc: '',
      args: [],
    );
  }

  /// `用户已在其他地方登录`
  String get tr_error_code_99978 {
    return Intl.message(
      '用户已在其他地方登录',
      name: 'tr_error_code_99978',
      desc: '',
      args: [],
    );
  }

  /// `用户名或密码错误`
  String get tr_error_code_99979 {
    return Intl.message(
      '用户名或密码错误',
      name: 'tr_error_code_99979',
      desc: '',
      args: [],
    );
  }

  /// `协议解析错误`
  String get tr_error_code_99980 {
    return Intl.message(
      '协议解析错误',
      name: 'tr_error_code_99980',
      desc: '',
      args: [],
    );
  }

  /// `缓冲区大小不够或缓冲区满`
  String get tr_error_code_99981 {
    return Intl.message(
      '缓冲区大小不够或缓冲区满',
      name: 'tr_error_code_99981',
      desc: '',
      args: [],
    );
  }

  /// `发送缓冲区已满`
  String get tr_error_code_99982 {
    return Intl.message(
      '发送缓冲区已满',
      name: 'tr_error_code_99982',
      desc: '',
      args: [],
    );
  }

  /// `监听服务器启动失败`
  String get tr_error_code_99983 {
    return Intl.message(
      '监听服务器启动失败',
      name: 'tr_error_code_99983',
      desc: '',
      args: [],
    );
  }

  /// `监听端口绑定失败（端口被占用）`
  String get tr_error_code_99984 {
    return Intl.message(
      '监听端口绑定失败（端口被占用）',
      name: 'tr_error_code_99984',
      desc: '',
      args: [],
    );
  }

  /// `服务器内部错误`
  String get tr_error_code_99985 {
    return Intl.message(
      '服务器内部错误',
      name: 'tr_error_code_99985',
      desc: '',
      args: [],
    );
  }

  /// `对象正忙`
  String get tr_error_code_99986 {
    return Intl.message(
      '对象正忙',
      name: 'tr_error_code_99986',
      desc: '',
      args: [],
    );
  }

  /// `网络发送错误`
  String get tr_error_code_99987 {
    return Intl.message(
      '网络发送错误',
      name: 'tr_error_code_99987',
      desc: '',
      args: [],
    );
  }

  /// `网络接受错误`
  String get tr_error_code_99988 {
    return Intl.message(
      '网络接受错误',
      name: 'tr_error_code_99988',
      desc: '',
      args: [],
    );
  }

  /// `创建缓冲区失败`
  String get tr_error_code_99989 {
    return Intl.message(
      '创建缓冲区失败',
      name: 'tr_error_code_99989',
      desc: '',
      args: [],
    );
  }

  /// `未找到`
  String get tr_error_code_99990 {
    return Intl.message('未找到', name: 'tr_error_code_99990', desc: '', args: []);
  }

  /// `超时`
  String get tr_error_code_99991 {
    return Intl.message('超时', name: 'tr_error_code_99991', desc: '', args: []);
  }

  /// `对象已存在`
  String get tr_error_code_99992 {
    return Intl.message(
      '对象已存在',
      name: 'tr_error_code_99992',
      desc: '',
      args: [],
    );
  }

  /// `网络错误`
  String get tr_error_code_99993 {
    return Intl.message(
      '网络错误',
      name: 'tr_error_code_99993',
      desc: '',
      args: [],
    );
  }

  /// `不支持`
  String get tr_error_code_99994 {
    return Intl.message('不支持', name: 'tr_error_code_99994', desc: '', args: []);
  }

  /// `读取文件失败`
  String get tr_error_code_99995 {
    return Intl.message(
      '读取文件失败',
      name: 'tr_error_code_99995',
      desc: '',
      args: [],
    );
  }

  /// `写入文件失败`
  String get tr_error_code_99996 {
    return Intl.message(
      '写入文件失败',
      name: 'tr_error_code_99996',
      desc: '',
      args: [],
    );
  }

  /// `打开文件失败`
  String get tr_error_code_99997 {
    return Intl.message(
      '打开文件失败',
      name: 'tr_error_code_99997',
      desc: '',
      args: [],
    );
  }

  /// `创建文件失败`
  String get tr_error_code_99998 {
    return Intl.message(
      '创建文件失败',
      name: 'tr_error_code_99998',
      desc: '',
      args: [],
    );
  }

  /// `参数异常`
  String get tr_error_code_99999 {
    return Intl.message(
      '参数异常',
      name: 'tr_error_code_99999',
      desc: '',
      args: [],
    );
  }

  /// `错误`
  String get tr_error_code_100000 {
    return Intl.message('错误', name: 'tr_error_code_100000', desc: '', args: []);
  }

  /// `对象不存在`
  String get tr_error_code_1239510 {
    return Intl.message(
      '对象不存在',
      name: 'tr_error_code_1239510',
      desc: '',
      args: [],
    );
  }

  /// `值不存在`
  String get tr_error_code_1239511 {
    return Intl.message(
      '值不存在',
      name: 'tr_error_code_1239511',
      desc: '',
      args: [],
    );
  }

  /// `报警相关功能授权失败`
  String get tr_error_code_221201 {
    return Intl.message(
      '报警相关功能授权失败',
      name: 'tr_error_code_221201',
      desc: '',
      args: [],
    );
  }

  /// `未填写鉴权信息`
  String get tr_error_code_225400 {
    return Intl.message(
      '未填写鉴权信息',
      name: 'tr_error_code_225400',
      desc: '',
      args: [],
    );
  }

  /// `鉴权码校验失败`
  String get tr_error_code_225401 {
    return Intl.message(
      '鉴权码校验失败',
      name: 'tr_error_code_225401',
      desc: '',
      args: [],
    );
  }

  /// `消息类型不合法`
  String get tr_error_code_225402 {
    return Intl.message(
      '消息类型不合法',
      name: 'tr_error_code_225402',
      desc: '',
      args: [],
    );
  }

  /// `服务器解析失败`
  String get tr_error_code_225000 {
    return Intl.message(
      '服务器解析失败',
      name: 'tr_error_code_225000',
      desc: '',
      args: [],
    );
  }

  /// `用户名或密码错误`
  String get tr_error_code_225501 {
    return Intl.message(
      '用户名或密码错误',
      name: 'tr_error_code_225501',
      desc: '',
      args: [],
    );
  }

  /// `获取redis的ip、port失败`
  String get tr_error_code_225502 {
    return Intl.message(
      '获取redis的ip、port失败',
      name: 'tr_error_code_225502',
      desc: '',
      args: [],
    );
  }

  /// `Redis建立连接失败`
  String get tr_error_code_225503 {
    return Intl.message(
      'Redis建立连接失败',
      name: 'tr_error_code_225503',
      desc: '',
      args: [],
    );
  }

  /// `Redis操作失败`
  String get tr_error_code_225504 {
    return Intl.message(
      'Redis操作失败',
      name: 'tr_error_code_225504',
      desc: '',
      args: [],
    );
  }

  /// `获取MySQL地址失败`
  String get tr_error_code_225505 {
    return Intl.message(
      '获取MySQL地址失败',
      name: 'tr_error_code_225505',
      desc: '',
      args: [],
    );
  }

  /// `参数错误`
  String get tr_error_code_225506 {
    return Intl.message(
      '参数错误',
      name: 'tr_error_code_225506',
      desc: '',
      args: [],
    );
  }

  /// `SQL操作失败`
  String get tr_error_code_225507 {
    return Intl.message(
      'SQL操作失败',
      name: 'tr_error_code_225507',
      desc: '',
      args: [],
    );
  }

  /// `缩略图URL检索失败`
  String get tr_error_code_225508 {
    return Intl.message(
      '缩略图URL检索失败',
      name: 'tr_error_code_225508',
      desc: '',
      args: [],
    );
  }

  /// `时间格式验证失败`
  String get tr_error_code_225509 {
    return Intl.message(
      '时间格式验证失败',
      name: 'tr_error_code_225509',
      desc: '',
      args: [],
    );
  }

  /// `云存储包信息异常`
  String get tr_error_code_225510 {
    return Intl.message(
      '云存储包信息异常',
      name: 'tr_error_code_225510',
      desc: '',
      args: [],
    );
  }

  /// `查询类型无效`
  String get tr_error_code_225511 {
    return Intl.message(
      '查询类型无效',
      name: 'tr_error_code_225511',
      desc: '',
      args: [],
    );
  }

  /// `查询的开始时间和结束时间不在同一天`
  String get tr_error_code_225512 {
    return Intl.message(
      '查询的开始时间和结束时间不在同一天',
      name: 'tr_error_code_225512',
      desc: '',
      args: [],
    );
  }

  /// `SN格式不合法`
  String get tr_error_code_225513 {
    return Intl.message(
      'SN格式不合法',
      name: 'tr_error_code_225513',
      desc: '',
      args: [],
    );
  }

  /// `清除类型非法`
  String get tr_error_code_225514 {
    return Intl.message(
      '清除类型非法',
      name: 'tr_error_code_225514',
      desc: '',
      args: [],
    );
  }

  /// `未知的订阅查询协议格式`
  String get tr_error_code_225515 {
    return Intl.message(
      '未知的订阅查询协议格式',
      name: 'tr_error_code_225515',
      desc: '',
      args: [],
    );
  }

  /// `非白名单IP请求`
  String get tr_error_code_225516 {
    return Intl.message(
      '非白名单IP请求',
      name: 'tr_error_code_225516',
      desc: '',
      args: [],
    );
  }

  /// `此用户没有查询权限`
  String get tr_error_code_225517 {
    return Intl.message(
      '此用户没有查询权限',
      name: 'tr_error_code_225517',
      desc: '',
      args: [],
    );
  }

  /// `未知取消订阅方法`
  String get tr_error_code_225518 {
    return Intl.message(
      '未知取消订阅方法',
      name: 'tr_error_code_225518',
      desc: '',
      args: [],
    );
  }

  /// `参数格式解析错误`
  String get tr_error_code_225519 {
    return Intl.message(
      '参数格式解析错误',
      name: 'tr_error_code_225519',
      desc: '',
      args: [],
    );
  }

  /// `MongoDB操作错误`
  String get tr_error_code_225520 {
    return Intl.message(
      'MongoDB操作错误',
      name: 'tr_error_code_225520',
      desc: '',
      args: [],
    );
  }

  /// `MongoDB和MySQL同时运行失败`
  String get tr_error_code_225521 {
    return Intl.message(
      'MongoDB和MySQL同时运行失败',
      name: 'tr_error_code_225521',
      desc: '',
      args: [],
    );
  }

  /// `查询的设置结果无效，无法解析`
  String get tr_error_code_225522 {
    return Intl.message(
      '查询的设置结果无效，无法解析',
      name: 'tr_error_code_225522',
      desc: '',
      args: [],
    );
  }

  /// `未知消息，无法解析`
  String get tr_error_code_225523 {
    return Intl.message(
      '未知消息，无法解析',
      name: 'tr_error_code_225523',
      desc: '',
      args: [],
    );
  }

  /// `无法获取重要级别的事件`
  String get tr_error_code_225524 {
    return Intl.message(
      '无法获取重要级别的事件',
      name: 'tr_error_code_225524',
      desc: '',
      args: [],
    );
  }

  /// `未知状态`
  String get tr_error_code_225525 {
    return Intl.message(
      '未知状态',
      name: 'tr_error_code_225525',
      desc: '',
      args: [],
    );
  }

  /// `该设备已被此帐户解除绑定，不允许订阅`
  String get tr_error_code_225526 {
    return Intl.message(
      '该设备已被此帐户解除绑定，不允许订阅',
      name: 'tr_error_code_225526',
      desc: '',
      args: [],
    );
  }

  /// `video id不合法`
  String get tr_error_code_225527 {
    return Intl.message(
      'video id不合法',
      name: 'tr_error_code_225527',
      desc: '',
      args: [],
    );
  }

  /// `设备密码不正确`
  String get tr_error_code_101 {
    return Intl.message(
      '设备密码不正确',
      name: 'tr_error_code_101',
      desc: '',
      args: [],
    );
  }

  /// `设备账号不存在`
  String get tr_error_code_102 {
    return Intl.message(
      '设备账号不存在',
      name: 'tr_error_code_102',
      desc: '',
      args: [],
    );
  }

  /// `设备登录超时(网络连接失败)`
  String get tr_error_code_103 {
    return Intl.message(
      '设备登录超时(网络连接失败)',
      name: 'tr_error_code_103',
      desc: '',
      args: [],
    );
  }

  /// `设备账号在其他地方登录`
  String get tr_error_code_104 {
    return Intl.message(
      '设备账号在其他地方登录',
      name: 'tr_error_code_104',
      desc: '',
      args: [],
    );
  }

  /// `设备账号被锁定`
  String get tr_error_code_105 {
    return Intl.message(
      '设备账号被锁定',
      name: 'tr_error_code_105',
      desc: '',
      args: [],
    );
  }

  /// `设备账号被列入黑名单`
  String get tr_error_code_106 {
    return Intl.message(
      '设备账号被列入黑名单',
      name: 'tr_error_code_106',
      desc: '',
      args: [],
    );
  }

  /// `设备资源不足`
  String get tr_error_code_107 {
    return Intl.message(
      '设备资源不足',
      name: 'tr_error_code_107',
      desc: '',
      args: [],
    );
  }

  /// `设备找不到网络主机`
  String get tr_error_code_109 {
    return Intl.message(
      '设备找不到网络主机',
      name: 'tr_error_code_109',
      desc: '',
      args: [],
    );
  }

  /// `设备不存在(设备被删除)`
  String get tr_error_code_120 {
    return Intl.message(
      '设备不存在(设备被删除)',
      name: 'tr_error_code_120',
      desc: '',
      args: [],
    );
  }

  /// `设备Token不合法`
  String get tr_error_code_137 {
    return Intl.message(
      '设备Token不合法',
      name: 'tr_error_code_137',
      desc: '',
      args: [],
    );
  }

  /// `参数编码格式不是UTF8`
  String get tr_error_code_500000 {
    return Intl.message(
      '参数编码格式不是UTF8',
      name: 'tr_error_code_500000',
      desc: '',
      args: [],
    );
  }

  /// `参数不是JSON格式`
  String get tr_error_code_500001 {
    return Intl.message(
      '参数不是JSON格式',
      name: 'tr_error_code_500001',
      desc: '',
      args: [],
    );
  }

  /// `对讲通道被占用`
  String get tr_error_code_514100 {
    return Intl.message(
      '对讲通道被占用',
      name: 'tr_error_code_514100',
      desc: '',
      args: [],
    );
  }

  /// `回放通道已被占用`
  String get tr_error_code_514053 {
    return Intl.message(
      '回放通道已被占用',
      name: 'tr_error_code_514053',
      desc: '',
      args: [],
    );
  }

  /// `设备离线`
  String get tr_error_code_515000 {
    return Intl.message(
      '设备离线',
      name: 'tr_error_code_515000',
      desc: '',
      args: [],
    );
  }

  /// `设备未注册`
  String get tr_error_code_515001 {
    return Intl.message(
      '设备未注册',
      name: 'tr_error_code_515001',
      desc: '',
      args: [],
    );
  }

  /// `通道不存在`
  String get tr_error_code_515002 {
    return Intl.message(
      '通道不存在',
      name: 'tr_error_code_515002',
      desc: '',
      args: [],
    );
  }

  /// `通道不在线`
  String get tr_error_code_515003 {
    return Intl.message(
      '通道不在线',
      name: 'tr_error_code_515003',
      desc: '',
      args: [],
    );
  }

  /// `账号错误`
  String get tr_error_code_515004 {
    return Intl.message(
      '账号错误',
      name: 'tr_error_code_515004',
      desc: '',
      args: [],
    );
  }

  /// `密码错误`
  String get tr_error_code_515005 {
    return Intl.message(
      '密码错误',
      name: 'tr_error_code_515005',
      desc: '',
      args: [],
    );
  }

  /// `国标或onvif登入异常`
  String get tr_error_code_515006 {
    return Intl.message(
      '国标或onvif登入异常',
      name: 'tr_error_code_515006',
      desc: '',
      args: [],
    );
  }

  /// `获取设备信息失败`
  String get tr_error_code_515104 {
    return Intl.message(
      '获取设备信息失败',
      name: 'tr_error_code_515104',
      desc: '',
      args: [],
    );
  }

  /// `国标设备超负载或正在维护`
  String get tr_error_code_515200 {
    return Intl.message(
      '国标设备超负载或正在维护',
      name: 'tr_error_code_515200',
      desc: '',
      args: [],
    );
  }

  /// `设备无录像`
  String get tr_error_code_515201 {
    return Intl.message(
      '设备无录像',
      name: 'tr_error_code_515201',
      desc: '',
      args: [],
    );
  }

  /// `播放失败，请重试`
  String get tr_error_code_515202 {
    return Intl.message(
      '播放失败，请重试',
      name: 'tr_error_code_515202',
      desc: '',
      args: [],
    );
  }

  /// `设备未响应`
  String get tr_error_code_515203 {
    return Intl.message(
      '设备未响应',
      name: 'tr_error_code_515203',
      desc: '',
      args: [],
    );
  }

  /// `设备协议不兼容`
  String get tr_error_code_515204 {
    return Intl.message(
      '设备协议不兼容',
      name: 'tr_error_code_515204',
      desc: '',
      args: [],
    );
  }

  /// `设备未授权`
  String get tr_error_code_515205 {
    return Intl.message(
      '设备未授权',
      name: 'tr_error_code_515205',
      desc: '',
      args: [],
    );
  }

  /// `URL格式错误`
  String get tr_error_code_516101 {
    return Intl.message(
      'URL格式错误',
      name: 'tr_error_code_516101',
      desc: '',
      args: [],
    );
  }

  /// `没有录像`
  String get tr_error_code_516102 {
    return Intl.message(
      '没有录像',
      name: 'tr_error_code_516102',
      desc: '',
      args: [],
    );
  }

  /// `URL过期`
  String get tr_error_code_516103 {
    return Intl.message(
      'URL过期',
      name: 'tr_error_code_516103',
      desc: '',
      args: [],
    );
  }

  /// `URL鉴权失败`
  String get tr_error_code_516104 {
    return Intl.message(
      'URL鉴权失败',
      name: 'tr_error_code_516104',
      desc: '',
      args: [],
    );
  }

  /// `账号无流量（请联系服务商）`
  String get tr_error_code_516105 {
    return Intl.message(
      '账号无流量（请联系服务商）',
      name: 'tr_error_code_516105',
      desc: '',
      args: [],
    );
  }

  /// `校验URL超时，请重试`
  String get tr_error_code_516106 {
    return Intl.message(
      '校验URL超时，请重试',
      name: 'tr_error_code_516106',
      desc: '',
      args: [],
    );
  }

  /// `打开播放失败，请重试`
  String get tr_error_code_516107 {
    return Intl.message(
      '打开播放失败，请重试',
      name: 'tr_error_code_516107',
      desc: '',
      args: [],
    );
  }

  /// `查询录像失败`
  String get tr_error_code_516108 {
    return Intl.message(
      '查询录像失败',
      name: 'tr_error_code_516108',
      desc: '',
      args: [],
    );
  }

  /// `时间参数超范围`
  String get tr_error_code_516109 {
    return Intl.message(
      '时间参数超范围',
      name: 'tr_error_code_516109',
      desc: '',
      args: [],
    );
  }

  /// `非法URL`
  String get tr_error_code_516110 {
    return Intl.message(
      '非法URL',
      name: 'tr_error_code_516110',
      desc: '',
      args: [],
    );
  }

  /// `请求太频繁`
  String get tr_error_code_516116 {
    return Intl.message(
      '请求太频繁',
      name: 'tr_error_code_516116',
      desc: '',
      args: [],
    );
  }

  /// `未找到i帧`
  String get tr_error_code_2046401 {
    return Intl.message(
      '未找到i帧',
      name: 'tr_error_code_2046401',
      desc: '',
      args: [],
    );
  }

  /// `设备无流超2s`
  String get tr_error_code_2046402 {
    return Intl.message(
      '设备无流超2s',
      name: 'tr_error_code_2046402',
      desc: '',
      args: [],
    );
  }

  /// `设备无流超20s`
  String get tr_error_code_2046403 {
    return Intl.message(
      '设备无流超20s',
      name: 'tr_error_code_2046403',
      desc: '',
      args: [],
    );
  }

  /// `获取数据源失败`
  String get tr_error_code_2046404 {
    return Intl.message(
      '获取数据源失败',
      name: 'tr_error_code_2046404',
      desc: '',
      args: [],
    );
  }

  /// `URL并发受限`
  String get tr_error_code_2046405 {
    return Intl.message(
      'URL并发受限',
      name: 'tr_error_code_2046405',
      desc: '',
      args: [],
    );
  }

  /// `等待gwm的校验结果超时`
  String get tr_error_code_2046406 {
    return Intl.message(
      '等待gwm的校验结果超时',
      name: 'tr_error_code_2046406',
      desc: '',
      args: [],
    );
  }

  /// `Http解析错误`
  String get tr_error_code_2046407 {
    return Intl.message(
      'Http解析错误',
      name: 'tr_error_code_2046407',
      desc: '',
      args: [],
    );
  }

  /// `客户端不支持，请使用chrome`
  String get tr_error_code_2046408 {
    return Intl.message(
      '客户端不支持，请使用chrome',
      name: 'tr_error_code_2046408',
      desc: '',
      args: [],
    );
  }

  /// `I帧无SPS`
  String get tr_error_code_2046409 {
    return Intl.message(
      'I帧无SPS',
      name: 'tr_error_code_2046409',
      desc: '',
      args: [],
    );
  }

  /// `协议报文解析错误`
  String get tr_error_code_2046410 {
    return Intl.message(
      '协议报文解析错误',
      name: 'tr_error_code_2046410',
      desc: '',
      args: [],
    );
  }

  /// `连接期间没有收到帧数据`
  String get tr_error_code_2046411 {
    return Intl.message(
      '连接期间没有收到帧数据',
      name: 'tr_error_code_2046411',
      desc: '',
      args: [],
    );
  }

  /// `断开前2秒内没有收到帧数据`
  String get tr_error_code_2046412 {
    return Intl.message(
      '断开前2秒内没有收到帧数据',
      name: 'tr_error_code_2046412',
      desc: '',
      args: [],
    );
  }

  /// `断开前2秒内没有收到视频帧数据`
  String get tr_error_code_2046413 {
    return Intl.message(
      '断开前2秒内没有收到视频帧数据',
      name: 'tr_error_code_2046413',
      desc: '',
      args: [],
    );
  }

  /// `实际视频帧帧率太小`
  String get tr_error_code_2046414 {
    return Intl.message(
      '实际视频帧帧率太小',
      name: 'tr_error_code_2046414',
      desc: '',
      args: [],
    );
  }

  /// `跳转错误的时间`
  String get tr_error_code_2046415 {
    return Intl.message(
      '跳转错误的时间',
      name: 'tr_error_code_2046415',
      desc: '',
      args: [],
    );
  }

  /// `账户欠费，访问流量服务失败`
  String get tr_error_code_2051000 {
    return Intl.message(
      '账户欠费，访问流量服务失败',
      name: 'tr_error_code_2051000',
      desc: '',
      args: [],
    );
  }

  /// `服务校验时服务异常`
  String get tr_error_code_2051001 {
    return Intl.message(
      '服务校验时服务异常',
      name: 'tr_error_code_2051001',
      desc: '',
      args: [],
    );
  }

  /// `服务器校验时服务出现超时`
  String get tr_error_code_2051002 {
    return Intl.message(
      '服务器校验时服务出现超时',
      name: 'tr_error_code_2051002',
      desc: '',
      args: [],
    );
  }

  /// `服务校验时本机网络出现异常`
  String get tr_error_code_2051003 {
    return Intl.message(
      '服务校验时本机网络出现异常',
      name: 'tr_error_code_2051003',
      desc: '',
      args: [],
    );
  }

  /// `用户名或密码错误`
  String get tr_error_code_604000 {
    return Intl.message(
      '用户名或密码错误',
      name: 'tr_error_code_604000',
      desc: '',
      args: [],
    );
  }

  /// `验证码错误`
  String get tr_error_code_604010 {
    return Intl.message(
      '验证码错误',
      name: 'tr_error_code_604010',
      desc: '',
      args: [],
    );
  }

  /// `密码不一致`
  String get tr_error_code_604011 {
    return Intl.message(
      '密码不一致',
      name: 'tr_error_code_604011',
      desc: '',
      args: [],
    );
  }

  /// `用户名已被注册`
  String get tr_error_code_604012 {
    return Intl.message(
      '用户名已被注册',
      name: 'tr_error_code_604012',
      desc: '',
      args: [],
    );
  }

  /// `用户名为空`
  String get tr_error_code_604013 {
    return Intl.message(
      '用户名为空',
      name: 'tr_error_code_604013',
      desc: '',
      args: [],
    );
  }

  /// `密码为空`
  String get tr_error_code_604014 {
    return Intl.message(
      '密码为空',
      name: 'tr_error_code_604014',
      desc: '',
      args: [],
    );
  }

  /// `确认密码为空`
  String get tr_error_code_604015 {
    return Intl.message(
      '确认密码为空',
      name: 'tr_error_code_604015',
      desc: '',
      args: [],
    );
  }

  /// `手机号为空`
  String get tr_error_code_604016 {
    return Intl.message(
      '手机号为空',
      name: 'tr_error_code_604016',
      desc: '',
      args: [],
    );
  }

  /// `用户名格式不正确`
  String get tr_error_code_604017 {
    return Intl.message(
      '用户名格式不正确',
      name: 'tr_error_code_604017',
      desc: '',
      args: [],
    );
  }

  /// `密码格式不正确`
  String get tr_error_code_604018 {
    return Intl.message(
      '密码格式不正确',
      name: 'tr_error_code_604018',
      desc: '',
      args: [],
    );
  }

  /// `确认密码格式不正确`
  String get tr_error_code_604019 {
    return Intl.message(
      '确认密码格式不正确',
      name: 'tr_error_code_604019',
      desc: '',
      args: [],
    );
  }

  /// `手机号格式不正确`
  String get tr_error_code_604020 {
    return Intl.message(
      '手机号格式不正确',
      name: 'tr_error_code_604020',
      desc: '',
      args: [],
    );
  }

  /// `手机号已存在`
  String get tr_error_code_604021 {
    return Intl.message(
      '手机号已存在',
      name: 'tr_error_code_604021',
      desc: '',
      args: [],
    );
  }

  /// `手机号不存在`
  String get tr_error_code_604022 {
    return Intl.message(
      '手机号不存在',
      name: 'tr_error_code_604022',
      desc: '',
      args: [],
    );
  }

  /// `邮箱已存在`
  String get tr_error_code_604023 {
    return Intl.message(
      '邮箱已存在',
      name: 'tr_error_code_604023',
      desc: '',
      args: [],
    );
  }

  /// `邮箱不存在`
  String get tr_error_code_604024 {
    return Intl.message(
      '邮箱不存在',
      name: 'tr_error_code_604024',
      desc: '',
      args: [],
    );
  }

  /// `原始密码错误`
  String get tr_error_code_604026 {
    return Intl.message(
      '原始密码错误',
      name: 'tr_error_code_604026',
      desc: '',
      args: [],
    );
  }

  /// `修改密码失败`
  String get tr_error_code_604027 {
    return Intl.message(
      '修改密码失败',
      name: 'tr_error_code_604027',
      desc: '',
      args: [],
    );
  }

  /// `用户找回密码链接过期`
  String get tr_error_code_604028 {
    return Intl.message(
      '用户找回密码链接过期',
      name: 'tr_error_code_604028',
      desc: '',
      args: [],
    );
  }

  /// `用户ID为空`
  String get tr_error_code_604029 {
    return Intl.message(
      '用户ID为空',
      name: 'tr_error_code_604029',
      desc: '',
      args: [],
    );
  }

  /// `验证码为空`
  String get tr_error_code_604030 {
    return Intl.message(
      '验证码为空',
      name: 'tr_error_code_604030',
      desc: '',
      args: [],
    );
  }

  /// `邮箱为空`
  String get tr_error_code_604031 {
    return Intl.message(
      '邮箱为空',
      name: 'tr_error_code_604031',
      desc: '',
      args: [],
    );
  }

  /// `邮箱格式不正确`
  String get tr_error_code_604032 {
    return Intl.message(
      '邮箱格式不正确',
      name: 'tr_error_code_604032',
      desc: '',
      args: [],
    );
  }

  /// `无权限不允许用户`
  String get tr_error_code_604033 {
    return Intl.message(
      '无权限不允许用户',
      name: 'tr_error_code_604033',
      desc: '',
      args: [],
    );
  }

  /// `用户未绑定`
  String get tr_error_code_604034 {
    return Intl.message(
      '用户未绑定',
      name: 'tr_error_code_604034',
      desc: '',
      args: [],
    );
  }

  /// `用户绑定失败`
  String get tr_error_code_604035 {
    return Intl.message(
      '用户绑定失败',
      name: 'tr_error_code_604035',
      desc: '',
      args: [],
    );
  }

  /// `手机绑定失败`
  String get tr_error_code_604036 {
    return Intl.message(
      '手机绑定失败',
      name: 'tr_error_code_604036',
      desc: '',
      args: [],
    );
  }

  /// `邮箱绑定失败`
  String get tr_error_code_604037 {
    return Intl.message(
      '邮箱绑定失败',
      name: 'tr_error_code_604037',
      desc: '',
      args: [],
    );
  }

  /// `发送验证码超过最大次数`
  String get tr_error_code_604038 {
    return Intl.message(
      '发送验证码超过最大次数',
      name: 'tr_error_code_604038',
      desc: '',
      args: [],
    );
  }

  /// `注册失败`
  String get tr_error_code_604039 {
    return Intl.message(
      '注册失败',
      name: 'tr_error_code_604039',
      desc: '',
      args: [],
    );
  }

  /// `微信已绑定用户`
  String get tr_error_code_604040 {
    return Intl.message(
      '微信已绑定用户',
      name: 'tr_error_code_604040',
      desc: '',
      args: [],
    );
  }

  /// `没有修改用户名的权限`
  String get tr_error_code_604041 {
    return Intl.message(
      '没有修改用户名的权限',
      name: 'tr_error_code_604041',
      desc: '',
      args: [],
    );
  }

  /// `用户没有绑定facebook`
  String get tr_error_code_604042 {
    return Intl.message(
      '用户没有绑定facebook',
      name: 'tr_error_code_604042',
      desc: '',
      args: [],
    );
  }

  /// `用户绑定facebook失败`
  String get tr_error_code_604043 {
    return Intl.message(
      '用户绑定facebook失败',
      name: 'tr_error_code_604043',
      desc: '',
      args: [],
    );
  }

  /// `用户没有google绑定`
  String get tr_error_code_604044 {
    return Intl.message(
      '用户没有google绑定',
      name: 'tr_error_code_604044',
      desc: '',
      args: [],
    );
  }

  /// `用户绑定google失败`
  String get tr_error_code_604045 {
    return Intl.message(
      '用户绑定google失败',
      name: 'tr_error_code_604045',
      desc: '',
      args: [],
    );
  }

  /// `Line账户未绑定`
  String get tr_error_code_604046 {
    return Intl.message(
      'Line账户未绑定',
      name: 'tr_error_code_604046',
      desc: '',
      args: [],
    );
  }

  /// `Line账户绑定失败`
  String get tr_error_code_604047 {
    return Intl.message(
      'Line账户绑定失败',
      name: 'tr_error_code_604047',
      desc: '',
      args: [],
    );
  }

  /// `用户验证码错误次数太多，验证码失效`
  String get tr_error_code_604048 {
    return Intl.message(
      '用户验证码错误次数太多，验证码失效',
      name: 'tr_error_code_604048',
      desc: '',
      args: [],
    );
  }

  /// `用户错误登陆次数太多，锁定账户十分钟`
  String get tr_error_code_604049 {
    return Intl.message(
      '用户错误登陆次数太多，锁定账户十分钟',
      name: 'tr_error_code_604049',
      desc: '',
      args: [],
    );
  }

  /// `请求太频繁，请稍后尝试`
  String get tr_error_code_604050 {
    return Intl.message(
      '请求太频繁，请稍后尝试',
      name: 'tr_error_code_604050',
      desc: '',
      args: [],
    );
  }

  /// `用户未激活`
  String get tr_error_code_604056 {
    return Intl.message(
      '用户未激活',
      name: 'tr_error_code_604056',
      desc: '',
      args: [],
    );
  }

  /// `用户未找回密码，app端应继续监听`
  String get tr_error_code_604065 {
    return Intl.message(
      '用户未找回密码，app端应继续监听',
      name: 'tr_error_code_604065',
      desc: '',
      args: [],
    );
  }

  /// `设备非法不允许添加`
  String get tr_error_code_604100 {
    return Intl.message(
      '设备非法不允许添加',
      name: 'tr_error_code_604100',
      desc: '',
      args: [],
    );
  }

  /// `设备已经存在`
  String get tr_error_code_604101 {
    return Intl.message(
      '设备已经存在',
      name: 'tr_error_code_604101',
      desc: '',
      args: [],
    );
  }

  /// `删除设备失败`
  String get tr_error_code_604102 {
    return Intl.message(
      '删除设备失败',
      name: 'tr_error_code_604102',
      desc: '',
      args: [],
    );
  }

  /// `设备信息修改失败`
  String get tr_error_code_604103 {
    return Intl.message(
      '设备信息修改失败',
      name: 'tr_error_code_604103',
      desc: '',
      args: [],
    );
  }

  /// `设备uuid参数异常`
  String get tr_error_code_604104 {
    return Intl.message(
      '设备uuid参数异常',
      name: 'tr_error_code_604104',
      desc: '',
      args: [],
    );
  }

  /// `设备用户名参数异常`
  String get tr_error_code_604105 {
    return Intl.message(
      '设备用户名参数异常',
      name: 'tr_error_code_604105',
      desc: '',
      args: [],
    );
  }

  /// `设备密码参数异常`
  String get tr_error_code_604106 {
    return Intl.message(
      '设备密码参数异常',
      name: 'tr_error_code_604106',
      desc: '',
      args: [],
    );
  }

  /// `设备端口参数异常`
  String get tr_error_code_604107 {
    return Intl.message(
      '设备端口参数异常',
      name: 'tr_error_code_604107',
      desc: '',
      args: [],
    );
  }

  /// `设备扩展字段参数异常`
  String get tr_error_code_604108 {
    return Intl.message(
      '设备扩展字段参数异常',
      name: 'tr_error_code_604108',
      desc: '',
      args: [],
    );
  }

  /// `新密码校验失败`
  String get tr_error_code_604110 {
    return Intl.message(
      '新密码校验失败',
      name: 'tr_error_code_604110',
      desc: '',
      args: [],
    );
  }

  /// `确认密码校验失败`
  String get tr_error_code_604111 {
    return Intl.message(
      '确认密码校验失败',
      name: 'tr_error_code_604111',
      desc: '',
      args: [],
    );
  }

  /// `设备别名校验失败`
  String get tr_error_code_604112 {
    return Intl.message(
      '设备别名校验失败',
      name: 'tr_error_code_604112',
      desc: '',
      args: [],
    );
  }

  /// `云存储支持`
  String get tr_error_code_604114 {
    return Intl.message(
      '云存储支持',
      name: 'tr_error_code_604114',
      desc: '',
      args: [],
    );
  }

  /// `云存储不支持`
  String get tr_error_code_604115 {
    return Intl.message(
      '云存储不支持',
      name: 'tr_error_code_604115',
      desc: '',
      args: [],
    );
  }

  /// `将设备主账户移交给其他用户失败，检查用户是否拥有设备并且拥有设备主账户权限`
  String get tr_error_code_604116 {
    return Intl.message(
      '将设备主账户移交给其他用户失败，检查用户是否拥有设备并且拥有设备主账户权限',
      name: 'tr_error_code_604116',
      desc: '',
      args: [],
    );
  }

  /// `当前账户不是当前设备的主账户`
  String get tr_error_code_604117 {
    return Intl.message(
      '当前账户不是当前设备的主账户',
      name: 'tr_error_code_604117',
      desc: '',
      args: [],
    );
  }

  /// `设备不存在了 已经被移除了`
  String get tr_error_code_604118 {
    return Intl.message(
      '设备不存在了 已经被移除了',
      name: 'tr_error_code_604118',
      desc: '',
      args: [],
    );
  }

  /// `添加设备不唯一，其他账户已添加`
  String get tr_error_code_604119 {
    return Intl.message(
      '添加设备不唯一，其他账户已添加',
      name: 'tr_error_code_604119',
      desc: '',
      args: [],
    );
  }

  /// `添加设备达到最大数量限制`
  String get tr_error_code_604120 {
    return Intl.message(
      '添加设备达到最大数量限制',
      name: 'tr_error_code_604120',
      desc: '',
      args: [],
    );
  }

  /// `设备支持令牌、只能由一个账户添加`
  String get tr_error_code_604126 {
    return Intl.message(
      '设备支持令牌、只能由一个账户添加',
      name: 'tr_error_code_604126',
      desc: '',
      args: [],
    );
  }

  /// `缺少设备令牌`
  String get tr_error_code_604127 {
    return Intl.message(
      '缺少设备令牌',
      name: 'tr_error_code_604127',
      desc: '',
      args: [],
    );
  }

  /// `添加授权失败`
  String get tr_error_code_604200 {
    return Intl.message(
      '添加授权失败',
      name: 'tr_error_code_604200',
      desc: '',
      args: [],
    );
  }

  /// `修改授权失败`
  String get tr_error_code_604201 {
    return Intl.message(
      '修改授权失败',
      name: 'tr_error_code_604201',
      desc: '',
      args: [],
    );
  }

  /// `删除授权失败`
  String get tr_error_code_604202 {
    return Intl.message(
      '删除授权失败',
      name: 'tr_error_code_604202',
      desc: '',
      args: [],
    );
  }

  /// `单个授权同步失败`
  String get tr_error_code_604203 {
    return Intl.message(
      '单个授权同步失败',
      name: 'tr_error_code_604203',
      desc: '',
      args: [],
    );
  }

  /// `发送失败`
  String get tr_error_code_604300 {
    return Intl.message(
      '发送失败',
      name: 'tr_error_code_604300',
      desc: '',
      args: [],
    );
  }

  /// `邮箱签名失败`
  String get tr_error_code_604301 {
    return Intl.message(
      '邮箱签名失败',
      name: 'tr_error_code_604301',
      desc: '',
      args: [],
    );
  }

  /// `注销账号需要验证码`
  String get tr_error_code_604302 {
    return Intl.message(
      '注销账号需要验证码',
      name: 'tr_error_code_604302',
      desc: '',
      args: [],
    );
  }

  /// `注册邮件发送超过次数，每个邮箱一天只能发送五次`
  String get tr_error_code_604303 {
    return Intl.message(
      '注册邮件发送超过次数，每个邮箱一天只能发送五次',
      name: 'tr_error_code_604303',
      desc: '',
      args: [],
    );
  }

  /// `找回密码邮件发送超过次数，每个邮箱一天只能发送五次`
  String get tr_error_code_604304 {
    return Intl.message(
      '找回密码邮件发送超过次数，每个邮箱一天只能发送五次',
      name: 'tr_error_code_604304',
      desc: '',
      args: [],
    );
  }

  /// `短信接口验证失败，请联系我们`
  String get tr_error_code_604400 {
    return Intl.message(
      '短信接口验证失败，请联系我们',
      name: 'tr_error_code_604400',
      desc: '',
      args: [],
    );
  }

  /// `短信接口参数错误，请联系我们`
  String get tr_error_code_604401 {
    return Intl.message(
      '短信接口参数错误，请联系我们',
      name: 'tr_error_code_604401',
      desc: '',
      args: [],
    );
  }

  /// `短信发送超过次数，每个手机号一天只能发送三次`
  String get tr_error_code_604402 {
    return Intl.message(
      '短信发送超过次数，每个手机号一天只能发送三次',
      name: 'tr_error_code_604402',
      desc: '',
      args: [],
    );
  }

  /// `发送失败，请稍后再试`
  String get tr_error_code_604403 {
    return Intl.message(
      '发送失败，请稍后再试',
      name: 'tr_error_code_604403',
      desc: '',
      args: [],
    );
  }

  /// `发送太频繁了，请间隔120秒`
  String get tr_error_code_604404 {
    return Intl.message(
      '发送太频繁了，请间隔120秒',
      name: 'tr_error_code_604404',
      desc: '',
      args: [],
    );
  }

  /// `发送失败`
  String get tr_error_code_604405 {
    return Intl.message(
      '发送失败',
      name: 'tr_error_code_604405',
      desc: '',
      args: [],
    );
  }

  /// `未查到用户列表或用户列表为空`
  String get tr_error_code_604500 {
    return Intl.message(
      '未查到用户列表或用户列表为空',
      name: 'tr_error_code_604500',
      desc: '',
      args: [],
    );
  }

  /// `未查到设备列表或设备列表为空`
  String get tr_error_code_604502 {
    return Intl.message(
      '未查到设备列表或设备列表为空',
      name: 'tr_error_code_604502',
      desc: '',
      args: [],
    );
  }

  /// `重置 app secret 失败`
  String get tr_error_code_604503 {
    return Intl.message(
      '重置 app secret 失败',
      name: 'tr_error_code_604503',
      desc: '',
      args: [],
    );
  }

  /// `微信报警打开失败`
  String get tr_error_code_604600 {
    return Intl.message(
      '微信报警打开失败',
      name: 'tr_error_code_604600',
      desc: '',
      args: [],
    );
  }

  /// `微信报警关闭失败`
  String get tr_error_code_604601 {
    return Intl.message(
      '微信报警关闭失败',
      name: 'tr_error_code_604601',
      desc: '',
      args: [],
    );
  }

  /// `服务器故障`
  String get tr_error_code_605000 {
    return Intl.message(
      '服务器故障',
      name: 'tr_error_code_605000',
      desc: '',
      args: [],
    );
  }

  /// `证书不存在`
  String get tr_error_code_605001 {
    return Intl.message(
      '证书不存在',
      name: 'tr_error_code_605001',
      desc: '',
      args: [],
    );
  }

  /// `请求头信息错误`
  String get tr_error_code_605002 {
    return Intl.message(
      '请求头信息错误',
      name: 'tr_error_code_605002',
      desc: '',
      args: [],
    );
  }

  /// `证书失效`
  String get tr_error_code_605003 {
    return Intl.message(
      '证书失效',
      name: 'tr_error_code_605003',
      desc: '',
      args: [],
    );
  }

  /// `生成密钥校验错误`
  String get tr_error_code_605004 {
    return Intl.message(
      '生成密钥校验错误',
      name: 'tr_error_code_605004',
      desc: '',
      args: [],
    );
  }

  /// `参数异常`
  String get tr_error_code_605005 {
    return Intl.message(
      '参数异常',
      name: 'tr_error_code_605005',
      desc: '',
      args: [],
    );
  }

  /// `连接失败`
  String get tr_error_code_605006 {
    return Intl.message(
      '连接失败',
      name: 'tr_error_code_605006',
      desc: '',
      args: [],
    );
  }

  /// `未知错误`
  String get tr_error_code_605007 {
    return Intl.message(
      '未知错误',
      name: 'tr_error_code_605007',
      desc: '',
      args: [],
    );
  }

  /// `ip地址不允许接入`
  String get tr_error_code_605008 {
    return Intl.message(
      'ip地址不允许接入',
      name: 'tr_error_code_605008',
      desc: '',
      args: [],
    );
  }

  /// `解密错误，说明用户名密码非法 微信code错误、AES加解密错误`
  String get tr_error_code_605009 {
    return Intl.message(
      '解密错误，说明用户名密码非法 微信code错误、AES加解密错误',
      name: 'tr_error_code_605009',
      desc: '',
      args: [],
    );
  }

  /// `token已过期`
  String get tr_error_code_605010 {
    return Intl.message(
      'token已过期',
      name: 'tr_error_code_605010',
      desc: '',
      args: [],
    );
  }

  /// `token错误`
  String get tr_error_code_605011 {
    return Intl.message(
      'token错误',
      name: 'tr_error_code_605011',
      desc: '',
      args: [],
    );
  }

  /// `token无权限`
  String get tr_error_code_605012 {
    return Intl.message(
      'token无权限',
      name: 'tr_error_code_605012',
      desc: '',
      args: [],
    );
  }

  /// `不支持`
  String get tr_error_code_605013 {
    return Intl.message(
      '不支持',
      name: 'tr_error_code_605013',
      desc: '',
      args: [],
    );
  }

  /// `操作太频繁`
  String get tr_error_code_605014 {
    return Intl.message(
      '操作太频繁',
      name: 'tr_error_code_605014',
      desc: '',
      args: [],
    );
  }

  /// `无效登录方式`
  String get tr_error_code_606000 {
    return Intl.message(
      '无效登录方式',
      name: 'tr_error_code_606000',
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
