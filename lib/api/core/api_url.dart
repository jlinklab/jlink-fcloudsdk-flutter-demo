///API 域名地址
///在设置国家之后,进行对应的修改.
class ApiUrl {
  static String capsUrl = 'https://caps.jftechws.com';
  static String amsUrl = 'https://cn-ams.jftechws.com'; //rs
  static String bossUrl = 'https://boss-api.jftechsoft.com';
  static String jvssUrl = 'https://jvss.jftechws.com';
  static String openApiUrl = 'https://api.jftechws.com';

  /// googleHome
  static String googleHomeUrl = 'https://aisvr-google.bcloud365.net';

  static String getHost(String host) {
    switch (host) {
      case ams:
        return amsUrl;
      case caps:
        return capsUrl;
      case jvss:
        return jvssUrl;
      case boss:
        return bossUrl;
      case openApi:
        return openApiUrl;
      case googleHome:
        return googleHomeUrl;
      default:
        return amsUrl;
    }
  }
}

///域名类型, API接口的定义需要在Header中指定所属域名类型
///在拦截器中根据 header中的定义 使用对应的域名作为该次请求dio的baseUrl.
///以达到在切换国家之后,修改域名地址的目的.
const String ams = 'ams'; //rs
const String caps = 'caps';
const String jvss = 'jvss';
const String boss = 'boss';
const String openApi = 'openApi';
const String googleHome = 'googleHome';
