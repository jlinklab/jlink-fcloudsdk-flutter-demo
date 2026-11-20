

/// 门锁类型
enum JFDoorLockType {
  /// 未知类型
  none,

  /// 全自动锁
  fullAuto,

  /// 半自动锁
  halfAuto,

  /// 呆锁
  normal,

  /// 把手锁
  handle,
}

/// 本机安全验证结果
enum LocalAuthResult {
  ///手机未设置锁屏凭据（无密码/指纹/人脸），未弹验证
  noCredential,

  ///验证通过
  passed,

  ///验证失败/取消/异常
  failed,
}
