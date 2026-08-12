extension MapValueGet on Map<String, dynamic> {
  bool getBoolValue({required Object key, bool defaultValue = false}) {
    if (!containsKey(key) || this[key] is! bool) {
      return defaultValue;
    }
    return this[key] as bool;
  }

  int getIntValue({required Object key, int defaultValue = 0}) {
    if (!containsKey(key)) {
      return defaultValue;
    }
    if (this[key] is String) {
      return int.tryParse(this[key]) ?? defaultValue;
    }
    if (this[key] is! int) {
      return defaultValue;
    }
    return this[key] as int;
  }

  double getDoubleValue({required Object key, double defaultValue = 0.0}) {
    if (!containsKey(key)) {
      return defaultValue;
    }
    if (this[key] is String) {
      return double.tryParse(this[key]) ?? defaultValue;
    }
    if (this[key] is! double) {
      return defaultValue;
    }
    return this[key] as double;
  }
}

/// Map数据解析
extension MapParser on Map {
  /// 获取Map中，String类型的值
  static String queryString(Map? map, String key, String value) {
    return readString(map, key) ?? value;
  }

  static String? readString(Map? map, String key) {
    return map?.getString(key);
  }

  String? getString(String? key) {
    try {
      if (key != null) {
        dynamic value = this[key];
        if (value != null) {
          if (value is String) {
            return value;
          } else {
            return value.toString();
          }
        }
      }
    } catch (e, s) {
      //
    }
    return null;
  }

  /// 获取Map中，bool类型的值
  static bool queryBool(Map? map, String key, bool value) {
    return readBool(map, key) ?? value;
  }

  static bool? readBool(Map? map, String key) {
    return map?.getBool(key);
  }

  bool? getBool(String? key) {
    try {
      if (key != null) {
        dynamic value = this[key];
        if (value != null) {
          if (value is bool) {
            return value;
          } else if (value is int) {
            return value == 1 ? true : false;
          } else if (value is String) {
            String str = value.trim().toLowerCase();
            if (str == 'true' || str == 'yes' || str == '1') {
              return true;
            } else if (str == 'false' || str == 'no' || str == '0') {
              return false;
            }
          }
        }
      }
    } catch (e, s) {
      //
    }
    return null;
  }

  /// 获取Map中，int类型的值
  static int queryInt(Map? map, String key, int value) {
    return readInt(map, key) ?? value;
  }

  static int? readInt(Map? map, String key) {
    return map?.getInt(key);
  }

  int? getInt(String? key) {
    try {
      if (key != null) {
        dynamic value = this[key];
        if (value != null) {
          if (value is int) {
            return value;
          } else if (value is double) {
            return value.toInt();
          } else if (value is String) {
            return int.parse(value);
          }
        }
      }
    } catch (e, s) {
      //
    }
    return null;
  }

  /// 获取Map中，double类型的值
  static double queryDouble(Map? map, String key, double value) {
    return readDouble(map, key) ?? value;
  }

  static double? readDouble(Map? map, String key) {
    return map?.getDouble(key);
  }

  double? getDouble(String? key) {
    try {
      if (key != null) {
        dynamic value = this[key];
        if (value != null) {
          if (value is double) {
            return value;
          } else if (value is int) {
            return value.toDouble();
          } else if (value is String) {
            return double.parse(value);
          }
        }
      }
    } catch (e, s) {
      //
    }
    return null;
  }

  static Map queryMap(Map? map, String key, Map value) {
    return readMap(map, key) ?? value;
  }

  static Map? readMap(Map? map, String key) {
    return map?.getMap(key);
  }

  static List queryList(Map? map, String key, List value) {
    return readList(map, key) ?? value;
  }

  static List? readList(Map? map, String key) {
    return map?.getList(key);
  }

  /// Map
  Map? getMap(String? key) {
    try {
      if (key != null) {
        dynamic value = this[key];
        if (value != null && value is Map) {
          return value;
        }
      }
    } catch (e, s) {
      //
    }
    return null;
  }

  /// List
  List? getList(String? key) {
    dynamic value = this[key];
    if (value != null && value is List) {
      return value;
    }
    return null;
  }
}
