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
        brightness: json["Brightness"] ?? 0,
        moveTrigLight: json["MoveTrigLight"] != null
            ? MoveTrigLight.fromJson(json["MoveTrigLight"])
            : MoveTrigLight(duration: 0, level: 0),
        workMode: json["WorkMode"] ?? "Close",
        workPeriod: json["WorkPeriod"] != null
            ? WorkPeriod.fromJson(json["WorkPeriod"])
            : WorkPeriod(eHour: 0, eMinute: 0, enable: 0, sHour: 0, sMinute: 0),
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
        duration: json["Duration"] ?? 0,
        level: json["Level"] ?? 0,
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
        eHour: json["EHour"] ?? 0,
        eMinute: json["EMinute"] ?? 0,
        enable: json["Enable"] ?? 0,
        sHour: json["SHour"] ?? 0,
        sMinute: json["SMinute"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "EHour": eHour,
        "EMinute": eMinute,
        "Enable": enable,
        "SHour": sHour,
        "SMinute": sMinute,
      };
}
