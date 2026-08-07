import 'package:shared_preferences/shared_preferences.dart';


///[SPUtils]中缓存数据的key统一放在这里，防止定义重复
class SPDefine {
  SPDefine._();

  ///当前APP系统语言,当语言切换时,需要向服务器同步一些数据
  static const String currentLanguage = 'current_language';

  ///缓存的当前国家信息
  static const String currentCountryKey = 'current_country';

  ///缓存手机号规则 域名请求到的json数据,防止从网络获取不到
  static const String phoneRuleAndUrlKey = 'phone_rule_and_url';

  ///APP是否首次安装
  static const String firstInstall = 'firstInstall';

  ///APP 是否已经同意 隐私政策
  static const String hasAgreePolicy = 'hasAgreePolicy';

  ///历史登录账户信息
  static const String localAccounts = 'localAccounts';

  ///私有推送APP生成的推送Token
  static const String jfPushToken = 'jfPushToken';

  ///设备订阅的缓存信息
  static const String deviceSubscribeKey = 'DeviceSubsribe';

  /// 报警翻译图标版本
  static const String pmsTlIconVersion = "pms_tl_icon_version";

  ///翻译版本
  static const String pmsTlVersion = "pms_tl_version";

  ///  pms 翻译
  static const String pmsTranslate = "pms_translate";

  ///ICON 缓存下载成功标志, 如果存在失败的, 则下次请求时需全量更新.
  static const String pmsTranslateDownloadSuccess =
      "pms_translate_down_load_success";

  ///设备能力缓存
  static const String systemFunctionCacheKey = 'system_function_cache';

  ///设备云服务能力缓存
  static const String cloudServerCacheKey = 'cloud_server_cache';

  ///设备capsList缓存前缀, 实际key为 device_caps_cache_$sn
  static const String deviceCapsCacheKeyPrefix = 'device_caps_cache_';

  ///设备AI服务能力缓存
  static const String aiServerCacheKey = 'ai_server_cache';

  ///是否开启加密传输 [bool]
  static const String encryptedTransferState = 'encryptedTransferState';

  ///设置DSS和 RPS [bool]
  static const String dssAndRPSEnableState = 'DSSAndRPSEnableState';

  ///是否开启Logcat打印
  static const String logcatMode = 'logcatMode';

  ///强制开启广告
  static const String forceAD = 'forceAD';

  ///是否打开调试选项
  static const String appDebugMode = 'appDebugMode';

  ///是否打开工程调试选项
  static const String factoryDebugMode = 'factoryDebugMode';

  ///是否启用开发者模式,开启后 登陆页面会显示杰峰开发助手字样，并且要通过开放平台账号登录
  static const String enableDeveloperMode = 'enable_developer_mode';

  /// 判断ai 服务的那些cap 字段
  static const String support_ais_caps = "support_ais_caps";

  ///设备列表排序方式
  static const String deviceListSortType = 'device_list_sort_type';

  ///首页卡片展示
  static const String deviceListCardType = 'home_small_item';

  ///设备列表自定义排序的设备ID列表,和用户相关,使用时需要增加用户id后缀
  static const String deviceSortIdList = 'device_sort_id_list';

  ///缓存算法超市版本信息
  static const String aiMarketVersion = "ai_market_version";

  ///缓存算法超市信息
  static const String aiMarketFromServer = "ai_market_from_server";

  ///缓存ai Banner广告 版本信息
  static const String aiBannerVersion = "ai_banner_version";

  ///缓存ai Banner广告信息
  static const String aiBannerFromServer = "ai_banner_from_server";

  static const String aiBannerLastLanguage = "ai_banner_last_language";

  ///报警消息中出现过的报警类型
  static const String alarmEventRecord = "alarm_event_record";

  static const String adeParams = "ade_params";

  /// 是否需要绑定手机号[bool]
  static const String bmnParams = "bmn_params";

  static const String vipState = "vip_state";

  /// 广告开关状态
  static const String isThirdAdShow = "is_third_ad_show";

  /// 服务器返回的pushAd
  static const String pushAdParams = "push_ad";

  /// 通过oemid判断是否要显示广告
  static const String showAdParams = "show_ad_params";

  /// 服务端返回的不显示广告的oemId List
  static const String freeAdOemIdList = "free_ad_oem_id_list";

  static const String devOemId = "dev_oem_id";

  /// 上一次的APPVersion 如果跟当前APPVersion 不一致，则重置广告开关
  static const String lastAppVersion = "last_app_version";

  ///是否已经同步过原生的数据
  static const String hasSyncNativeInfo = 'has_sync_native_info';

  ///App云服务能力开关
  static const String appCapsXMC = 'app_caps_xmc';

  ///App云盘能力开关
  static const String appCapsDISK = 'app_caps_disk';

  /// App 小飞入口服务端能力开关
  static const String appCapsJfclaw = 'app_caps_jfclaw';

  /// 服务端下发的视频观看时长提醒阈值，单位秒
  static const String appCapsVideoWatchReminderTime =
      'app_caps_video_watch_reminder_time';

  /// 服务端下发的低功耗/4G 设备专用视频观看时长提醒阈值，单位秒。
  static const String appCapsVideoWatchReminderTimeFor4G =
      'app_caps_video_watch_reminder_time_for_4g';

  /// 视频观看时长提醒调试开关。
  ///
  /// 打开后，无论设备类型或服务端配置如何，都统一使用 120 秒，
  /// 便于在预览页和 SD 卡回放页快速验证提醒流程。
  static const String debugVideoWatchReminderTwoMinutes =
      'debug_video_watch_reminder_two_minutes';

  /// 三方登录能力集
  static const String kAppThirdLoginCapacity = 'app_third_login_capacity';

  ///不开启推送用户手动关闭不再提示
  static const String notificationTip = 'notificationTip';

  ///首页banner位置-推送权限提示-每周只弹一次
  static const String notificationBannerTipsTimesTamp =
      'notificationBannerTipsTimesTamp';

  static const String lastCheckNewMessageTime = 'last_check_new_message_time';

  static const String newPushMsgPrefix = 'new_push_msg_prefix';

  ///临时用户ID
  static const String tempUserID = 'tempUserID';

  ///不再提醒重要固件版本
  static const String notRemindImportVersion = 'not_remind_import_version';

  ///ios 报警消息翻译和图标是否做过全量更新,针对之前iOS 覆盖安装 下载icon不对问题。
  static const String iphoneHasUpDateAlarmMsgTransLationAndIcon =
      'iphone_has_update_alarmmsg_translation_and_icon';

  static const String playAdjustFluency = 'play_adjust_fluency';

  // 存储wifi信息
  static const String keyWifiScanResultSsid = 'wifi_scan_result_ssid';
  static const String keyWifiScanResultBssid = 'wifi_scan_result_bssid';
  static const String keyWifiScanResultCapabilities =
      'wifi_scan_result_capabilities';
  static const String keyWifiFrequency = 'wifi_frequency';

  /// 支持自动唤醒的序列号列表
  static const String autoWakeUpIds = "auto_wake_up_ids";

  /// 自动续费失败相关本地存储键
  static const String CLOUD_SERVICE_EXPRITE_SHOW_TIPS_TIME =
      "cs_exprite_show_tips_time"; //云服务到期提醒的时间记录
  static const String HAS_SHOW_SERVICE_EXPRITE_SHOW_TIPS =
      "has_show_cs_expire_show_tips"; //记录是否显示过云服务到期提醒(即将到期，4~5天)
  static const String SERVICE_AUTO_RENEW_SHOW_TIPS_TIME =
      "auto_renew_show_tips_time"; //服务自动续费提醒的时间记录
  static const String HAS_SHOW_SERVICE_AUTO_RENEW_TIPS =
      "has_show_auto_renew_tips"; //记录是否显示过服务自动续费提醒（下个月扣款前1~4天）
  static const String SERVICE_EXPIRE_3_SHOW_TIPS_TIME =
      "service_expire_3_show_tips_time"; //服务到期提醒的时间记录
  static const String HAS_SHOW_SERVICE_EXPIRE_3_TIPS =
      "has_show_service_expire_3_tips"; //记录是否显示服务即将到期提醒(3天内即将到期)
  static const String SERVICE_EXPIRED_7_SHOW_TIPS_TIME =
      "service_expired_7_show_tips_time"; //服务已过期提醒的时间记录（过期20天和过期7天，使用同一个记录）
  static const String HAS_SHOW_SERVICE_EXPIRED_7_TIPS =
      "has_show_service_expired_7_tips"; //记录是否显示服务已过期提醒(已过期7天)

  /// 访客登录本地数据读取标识
  static const String deviceDataVisitor = 'isReadDeviceDataByVisitor';

  ///选择通道之后更新
  ///下次初始化时使用,直接定位到该通道
  static const String channelNumCacheKey = 'channel_num_cache';

  /// 联动准心偏移
  static const String draggableSightCenterOffset = 'draggableSightCenterOffset';

  ///iOS 广告权限
  static const String appTrackingTransparency = 'appTrackingTransparency';

  ///通知权限
  static const String notification = 'notification';

  /// 设备是否登录成功过
  static const String deviceHasLogin = 'deviceHasLogin';
}

class SPUtils {
  SPUtils._();

  static late SharedPreferences preferences;

  ///初始化，此时所有的数据缓存都已经加载进入内存
  ///在SDK初始化之前即可初始化
  ///保证APP使用同一个工具类
  static Future init() async {
    preferences = await SharedPreferences.getInstance();
  }
}
