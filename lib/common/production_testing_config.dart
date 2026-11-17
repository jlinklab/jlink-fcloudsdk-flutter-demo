import 'package:fcloudsdk/utils/sp_utils.dart';

///产测模式状态
class ProductionTestingConfig {
  static const String _productionTestingModeKey = 'KProductionTestingMode';

  ProductionTestingConfig._();

  static bool get isOn =>
      SPUtils.preferences.getBool(_productionTestingModeKey) ?? false;

  static set setOn(bool on) {
    SPUtils.preferences.setBool(_productionTestingModeKey, on);
  }
}
