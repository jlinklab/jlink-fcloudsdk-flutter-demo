/// 白光灯配置数据模型
class WhiteLightBean {
  int brightness;
  MoveTrigLight moveTrigLight;
  String workMode;
  WorkPeriod workPeriod;

  WhiteLightBean({
    required this.brightness,
    required this.moveTrigLight,
    required this.workMode,
    required this.workPeriod,
  });

  factory WhiteLightBean.fromJson(Map<String, dynamic> json) => WhiteLightBean(
        brightness: json["Brightness"],
        moveTrigLight: MoveTrigLight.fromJson(json["MoveTrigLight"]),
        workMode: json["WorkMode"],
        workPeriod: WorkPeriod.fromJson(json["WorkPeriod"]),
      );

  Map<String, dynamic> toJson() => {
        "Brightness": brightness,
        "MoveTrigLight": moveTrigLight.toJson(),
        "WorkMode": workMode,
        "WorkPeriod": workPeriod.toJson(),
      };
}

class MoveTrigLight {
  int duration;
  int level;

  MoveTrigLight({
    required this.duration,
    required this.level,
  });

  factory MoveTrigLight.fromJson(Map<String, dynamic> json) => MoveTrigLight(
        duration: json["Duration"],
        level: json["Level"],
      );

  Map<String, dynamic> toJson() => {
        "Duration": duration,
        "Level": level,
      };
}

class WorkPeriod {
  int eHour;
  int eMinute;
  int enable;
  int sHour;
  int sMinute;

  WorkPeriod({
    required this.eHour,
    required this.eMinute,
    required this.enable,
    required this.sHour,
    required this.sMinute,
  });

  factory WorkPeriod.fromJson(Map<String, dynamic> json) => WorkPeriod(
        eHour: json["EHour"],
        eMinute: json["EMinute"],
        enable: json["Enable"],
        sHour: json["SHour"],
        sMinute: json["SMinute"],
      );

  Map<String, dynamic> toJson() => {
        "EHour": eHour,
        "EMinute": eMinute,
        "Enable": enable,
        "SHour": sHour,
        "SMinute": sMinute,
      };
}
