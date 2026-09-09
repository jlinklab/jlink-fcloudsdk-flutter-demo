///正则匹配

class JFMatch {
  ///邮箱格式
  static bool kIsValidAccountEmail(String str) {
    if (str.length < 4) {
      return false;
    }
    return str.contains('@');
  }

  /// 用户密码格式
  /// 要8~64个字符
  /// 必须包含大写字母
  /// 必须包含小写字母
  /// 必须包含数字
  /// 必须包含特殊字符。 特殊字符为    !@#%^&*()_[]{}?/.<>,';:-
  /// 字符类型只能是上面的四种，其他字符不允许，不能包含空格
  static bool kIsValidAccountPwd(String str) {
    if (str.isEmpty) {
      return false;
    }

    final RegExp regex = RegExp(
        r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?\d)(?=.*?[!@#%^&*()_{}\[\]?/.,<>\';:-])[A-Za-z\d!@#%^&*()_{}\[\]?/.,<>\';:-]{8,64}$");
    return regex.hasMatch(str);
  }

  ///用户名格式
  /// 不能纯数字
  /// 汉字
  /// 中文
  /// 英文
  /// 4-32位
  /// 用户名必须要4-32个字符，中文、英文字母、可以数字，但是不能纯数字
  static bool kIsValidAccountUserName(String str) {
    if (str.isEmpty) {
      return false;
    }

    ///不能纯数字
    final RegExp regexNum = RegExp(r"^[0-9]*$");
    if (regexNum.hasMatch(str)) {
      return false;
    }
    ///其他规则
    final RegExp regex = RegExp(r"^([\u4e00-\u9fa5]|[a-zA-Z0-9_]){4,32}$");
    return regex.hasMatch(str);
  }

  /// 设备名称格式
  /// 4-15位长度 包含数字和字母
  /// 不支持特殊格式的字符 @"admin",@"root",@"system",@"user",@"guest",@"select",@"delete",@"insert"
  static bool kIsValidDeviceLoginName(String str) {
    if (str.isEmpty) {
      return false;
    }

    final RegExp regex = RegExp(r"^([\[\]{}*'#%+=_|~<>•.,?!/:;()$&@\s\-]|\w){4,15}$");
    if (regex.hasMatch(str) == false) {
      return false;
    }

    Map pMap = {
      'admin': 1,
      'root': 1,
      'system': 1,
      'user': 1,
      'guest': 1,
      'select': 1,
      'delete': 1,
      'insert': 1,
    };

    if (pMap.containsKey(str)) {
      return false;
    }
    return true;
  }

  /// 设备密码格式
  /// 要8~64个字符
  /// 只能包含字母和数字
  /// 至少有一个字母
  /// 至少有一个数字
  static bool kIsValidDevicePwd(String str) {
    if (str.isEmpty) {
      return false;
    }

    final RegExp regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,64}$');
    return regex.hasMatch(str);
  }

  ///预置点名称格式
  static bool kIsValidPresetPointName(String str) {
    if (str.isEmpty) {
      return false;
    }

    final RegExp regex = RegExp(r"^[\u4e00-\u9fa5a-zA-Z0-9!@#%^&*()_\[\]{}?/.<>,';:-]{1,16}$");
    return regex.hasMatch(str);
  }

  ///设备名称格式
  static bool kIsValidDeviceName(String str) {
    if (str.isEmpty) {
      return false;
    }

    final RegExp regex = RegExp(r"^[\u4e00-\u9fa5a-zA-Z0-9]{4,16}$");
    return regex.hasMatch(str);
  }
}
