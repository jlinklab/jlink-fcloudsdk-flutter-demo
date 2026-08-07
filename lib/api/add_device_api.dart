import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:xcloudsdk_flutter_example/api/core/api_url.dart';
import 'package:xcloudsdk_flutter_example/api/core/dio_config.dart';

part 'add_device_api.g.dart';

///脚本  flutter packages pub run build_runner build

@RestApi(baseUrl: "https://jvss.xmcsrv.net", parser: Parser.JsonSerializable)
abstract class AddDeviceAPI {
  factory AddDeviceAPI(Dio dio, {String baseUrl}) = _AddDeviceAPI;

  ///获取单个设备类型详情。eg:设备图片
  ///pid：有pid传pid，没有pid传deviceType
  @POST('/v3/deviceType/getDeviceType$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<DeviceDetailTypeModel> queryDeviceTypeDetailInfo({
    @Field('pid') required String pid,
    @Field('styleKey') String styleKey = "iCSee",
  });

  ///根据pid查询设备支持的能力
  @POST(
      '/v3/deviceTypeProp/getDeviceTypePropListByPageForApp$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> getDevicePropList({
    @Field('pid') required String pid,
    @Field('isCondition') String isCondition = '',
    @Field('styleKey') String styleKey = "iCSee",
    @Field('page') int page = 1,
    @Field('limit') int limit = 999,
  });
}

AddDeviceAPI addDeviceAPI = AddDeviceAPI(DioConfig.getDio());

///设备具体类型model
class DeviceDetailTypeModel {
  String? id;
  String? parentPid;
  String? pid;
  String? deviceTypeName;
  bool? isEnable;
  String? description; //设备类型说明
  String? devicePic; //设备类型图片
  String?
      connectType; //支持的配网方式：0:wifi配网，1:蓝牙配网，2:二维码配网,3:ap配网,4:4G配网,5:扫一扫配网,6:有线配网。支持多种用逗号隔开,例如支持蓝牙和4G配网：1,4, eg:0,2   以,分开
  bool? isSharable; //是否可以分享
  int? maxChannelNumber; //最大通道数
  String? binId;
  String? objectId;
  bool? oppfEnable;
  List<String>? props;

  bool isSupportConnectType(String type) {
    if (connectType == null) {
      return false;
    }
    if (connectType!.isEmpty) {
      return false;
    }
    List<String> types = connectType!.split(',');
    return types.contains(type);
  }

  DeviceDetailTypeModel({
    this.id,
    this.parentPid,
    this.pid,
    this.deviceTypeName,
    this.isEnable,
    this.description,
    this.devicePic,
    this.connectType,
    this.isSharable,
    this.maxChannelNumber,
    this.binId,
    this.objectId,
    this.oppfEnable,
    this.props,
  });

  DeviceDetailTypeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentPid = json['parentPid'];
    pid = json['pid'];
    deviceTypeName = json['deviceTypeName'];
    isEnable = json['isEnable'];
    description = json['description'];
    devicePic = json['devicePic'];
    connectType = json['connectType'];
    isSharable = json['isSharable'];
    maxChannelNumber = json['maxChannelNumber'];
    binId = json['binId'];
    objectId = json['objectId'];
    oppfEnable = json['oppfEnable'];
    if (json['props'] != null) {
      props = [];
      json['props']!.forEach((v) {
        props!.add(v);
      });
    }
  }
}
