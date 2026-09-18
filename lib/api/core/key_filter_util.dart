class KeyFilterUtil {
  static String keyFilter(String key) {
    int length = key.length;
    if (length > 16) {
      key = key.substring(0, 16);
    } else {
      for (int i = 0; i < 16 - length; i++) {
        key = key + i.toString();
      }
    }
    return key;
  }

  static String keyFilterWithTimeAndSecret(String timeMillis, String appSecret) {
    StringBuffer key = StringBuffer();
    int timeLength = timeMillis.length;
    if (timeLength ~/ 2 > 0) {
      key.write(timeMillis.substring(timeLength ~/ 2));
    }
    key.write(appSecret);
    return keyFilter(key.toString());
  }
}
