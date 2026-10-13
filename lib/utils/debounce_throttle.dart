import 'dart:async';

class DebounceThrottle {
  static final instance = DebounceThrottle();
  final Map<String, Timer> timerMap = {};

  /// 防抖
  static debounce(Function func, Duration delay, {required String key}) {
    final timerMap = DebounceThrottle.instance.timerMap;
    Timer? timer = timerMap[key];

    if (timer != null) {
      timer.cancel();
    }

    timer = Timer(delay, () {
      func();
      timerMap.remove(key);
    });

    timerMap[key] = timer;
  }

  /// 限流
  static throttle(Function func, Duration delay, {required String key}) {
    final timerMap = DebounceThrottle.instance.timerMap;
    Timer? timer = timerMap[key];

    if (timer != null) {
      return;
    }

    /// 先响应
    func();
    timer = Timer(delay, () {
      timerMap.remove(key);
    });

    timerMap[key] = timer;
  }

  static cancel({required String key}) {
    final timerMap = DebounceThrottle.instance.timerMap;
    Timer? timer = timerMap[key];

    if (timer != null) {
      timer.cancel();
    }
  }
}

class Once {
  static final instance = Once();
  final Map<String, Function> map = {};

  static Future<T?> runOnce<T>(String key,
      {required T? Function() func}) async {
    final map = Once.instance.map;
    if (map.containsKey(key)) {
      return Future.value();
    }
    map[key] = func;
    return func.call();
  }

  static hadRun(String key) {
    final map = Once.instance.map;
    return map.containsKey(key);
  }

  static clear(String key) {
    final map = Once.instance.map;
    map.remove(key);
  }

  static clearAll() {
    final map = Once.instance.map;
    map.clear();
  }
}
