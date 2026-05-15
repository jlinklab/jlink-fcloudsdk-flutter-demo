import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/pages/account/model/model.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

class UpdateUserInfoDetail {
  final bool isSuccess;
  final String errorMsg;

  const UpdateUserInfoDetail({required this.isSuccess, required this.errorMsg});
}

enum LoginType {
  ///账号密码登录
  normal,

  ///手机验证码登录
  phone,

  ///token登录
  token,
}

class UserInfo extends ChangeNotifier {
  static UserInfo instance = UserInfo();

  static const String userInfo = 'USER_INFO';
  static const String deviceInfo = 'DEVICE_INFO';

  /// userId, 在登录 获取设备列表时返回, 保存本地
  String _userId = '';
  LoginType _loginType = LoginType.normal;
  String _userName = '';
  String _userPwd = '';
  String _phoneNum = '';
  final String _nickname = '';
  User _userDetail = User();

  String get userId => _userId;

  bool get isLogin => _userId.isNotEmpty;

  LoginType get loginType => _loginType;

  String get userName => _userName;

  String get userPwd => _userPwd;

  User get userDetail => _userDetail;

  String get nickname => _nickname;

  ///设备信息. 主要缓存 设备 账号和密码
  /// {'device_id':{'name':'xx','pwd':'xxx'}}
  Map<String, dynamic> _devices = {};

  void init() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // String userInfoJsonString = preferences.getString(userInfo) ?? '{}';
    // Map<String, dynamic> userInfoJson = json.decode(userInfoJsonString);
    //
    // _userId = userInfoJson['userId'] ?? '';
    // _userName = userInfoJson['userName'] ?? '';
    // _userPwd = userInfoJson['userPwd'] ?? '';
    // String deviceJsonString = preferences.getString(deviceInfo) ?? '{}';
    // _devices = json.decode(deviceJsonString);
    // notifyListeners();
  }

  ///登录 注意loginType，
  ///loginType == normal 要传userName 和 pwd
  ///loginType == phone 要传phoneNum
  ///loginType == token 不需要传
  void login({
    required String userId,
    required LoginType loginType,
    String? userName,
    String? pwd,
    String? phoneNum,
  }) async {
    _userId = userId;
    _loginType = loginType;

    if (_loginType == LoginType.token) {
      ///token登录保存userId即可
      notifyListeners();
      return;
    } else if (_loginType == LoginType.normal) {
      _userName = userName!;
      _userPwd = pwd!;
    } else if (_loginType == LoginType.phone) {
      _phoneNum = phoneNum!;
    }

    ///获取token
    final String token = await JFApi.xcAccount.xcGetAccessToken();
    final preference = await SharedPreferences.getInstance();

    ///保存登录信息
    if (_loginType == LoginType.normal) {
      preference.setString(
          userInfo,
          json.encode({
            'userId': _userId,
            'loginType': 'normal',
            'userName': _userName,
            'userPwd': _userPwd,
            'token': token
          }));
      //保存下当前登录的用户名，用于登录页面快速选择某个账户
      List<String> nameList =
          preference.getStringList("loggedAccount") ?? <String>[];
      if (!nameList.contains(_userName)) {
        nameList.add(_userName);
        preference.setStringList("loggedAccount", nameList);
      }
    } else if (_loginType == LoginType.phone) {
      preference.setString(
          userInfo,
          json.encode({
            'userId': _userId,
            'loginType': 'phone',
            'phoneNum': _phoneNum,
            'token': token
          }));
    }
    notifyListeners();
  }

  ///自动登录
  autoLogin() async {
    final sp = await SharedPreferences.getInstance();
    String? userInfoStr = sp.getString(userInfo);
    if (userInfoStr != null) {
      final Map<String, dynamic> userInfoMap = jsonDecode(userInfoStr);
      String? token = userInfoMap['token'];
      if (token == null || token.isEmpty) {
        return;
      }

      ///拿着token去自动登录
      KToast.show();
      JFApi.xcAccount
          .xcLoginAndGetDeviceList(userName: token, pwd: '')
          .then((value) {
        final json = value;
        login(userId: json['userId'], loginType: LoginType.token);
      }).catchError((error) {
        KToast.show(status: KErrorMsg(error));
      });
    }
  }

  Future<List<String>> loadHistoryAccountList() async {
    List<String> result = [];
    await SharedPreferences.getInstance().then((preference) {
      result = preference.getStringList("loggedAccount") ?? [];
    });
    return Future.value(result);
  }

  //本地退出
  Future<void> quit(bool isCancel) async {
    if (UserInfo.instance.isLogin == false) {
      return;
    }

    if (isCancel) {
      await SharedPreferences.getInstance().then((preference) {
        List<String> nameList =
            preference.getStringList("loggedAccount") ?? <String>[];
        nameList.remove(userName);
        preference.setStringList("loggedAccount", nameList);
      });
    }

    //清空用户数据
    _userId = '';
    _userName = '';
    _userPwd = '';

    await SharedPreferences.getInstance().then((preference) {
      preference.remove(userInfo);
    });

    //清空设备数据
    _devices = {};
    await SharedPreferences.getInstance().then((preference) {
      preference.setString(deviceInfo, json.encode(_devices));
    });

    ///调SDK内部的登出方法
    await JFApi.xcAccount.xcLoginOut();
    notifyListeners();
    return Future.value();
  }

  ///更新用户信息
  void updateUserInfoDetail() async {
    try {
      final Map<String, dynamic> result = await JFApi.xcAccount.xcGetUserInfo();
      _userDetail = User.fromJson(result);
      notifyListeners();
    } catch (error) {
      // String errorMsg = '获取用户信息错误';
      // if (error.runtimeType == int) {
      //   errorMsg = KErrorMsg(error as int)!;
      // }
    }
  }

  void saveDeviceInfo(String deviceId, String name, String pwd) {
    _devices[deviceId] = {'name': name, 'pwd': pwd};
    SharedPreferences.getInstance().then((preference) {
      preference.setString(deviceInfo, json.encode(_devices));
    });
  }

  bool isDeviceLogin(String deviceId) {
    return _devices.containsKey(deviceId);
  }

  Map<String, dynamic> getDeviceNameAndPwd(String deviceId) {
    return _devices[deviceId];
  }
}
