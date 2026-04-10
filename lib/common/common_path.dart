import 'dart:io';
import 'package:path_provider/path_provider.dart';

const String kPrefixImage = 'jf_image';
const String kPrefixVideo = 'jf_video';
const String _kSplitStr = '___*#[0]#*___';

///固定分割符
const String _kDeviceName = '[kDeviceName]';
const String _kDeviceId = '[kDeviceId]';
const String _kChannel = '[kChannel]';
const String _kTime = '[kTime]';
const String _kEndTime = '[kEndTime]';
const String _kExInfo = '[kExInfo]';
const String kPresetImage = 'preset_image';

///文件类型，目前就两种，后面慢慢扩展
enum FileType {
  ///图片类型
  jpg,

  ///视频类型
  mp4,
}

extension FileTypeExtension on FileType {
  String toName() {
    switch (this) {
      case FileType.jpg:
        return 'jpg';
      case FileType.mp4:
        return 'mp4';
      default:
        return 'unknown';
    }
  }
}

///生成统一格式的图片/视频文件名称，便于后面解析
///[time] 时间格式yyyy-MM-dd_HH-mm-ss_SSS eg:2012-09-01_12-01-03_111
///[endTime] 如果有开始时间和结束时间，那就上面的time就是开始时间 endTime就是结束时间，时间格式都是yyyy-MM-dd_HH-mm-ss_SSS eg:2012-09-01_12-01-03_111
///return eg
/// image ==>  //var/mobile/Containers/Data/Application/03645884-74CE-4B83-9D46-2D1F12E45380/Documents/jf_videos/jf_video___*#[0]#*___[kDeviceName]设备9527___*#[0]#*___[kDeviceId]122jhk433bnjb23h3jh___*#[0]#*___[kChannel]0___*#[0]#*___[kTime]2012-09-01_12-01-03_111___*#[0]#*___[kEndTime]2012-09-01_12-04-03_000___*#[0]#*___[kExInfo]___*#[0]#*___.mp4
/// video ==>  //var/mobile/Containers/Data/Application/03645884-74CE-4B83-9D46-2D1F12E45380/Documents/jf_images/jf_image___*#[0]#*___[kDeviceName]设备9527___*#[0]#*___[kDeviceId]122jhk433bnjb23h3jh___*#[0]#*___[kChannel]0___*#[0]#*___[kTime]2012-09-01_12-01-03_111___*#[0]#*___[kEndTime]2012-09-01_12-01-03_111___*#[0]#*___[kExInfo]___*#[0]#*___.jpg
Future<String> kGenLocalMediaFilePath({
  required String deviceName,
  required String deviceId,
  required int channel,
  required String time,
  String endTime = '',
  required FileType fileType,
  String exInfo = '',
}) async {
  ///先获取文件夹路径
  String dirPath = '';
  String fineName = '';
  if (fileType == FileType.jpg) {
    //图片
    dirPath = await kDirectoryPathImages();
    fineName += kPrefixImage; //加上前缀
  } else {
    //视频
    dirPath = await kDirectoryPathVideos();
    fineName += kPrefixVideo; //加上前缀
  }
  fineName += _kSplitStr;
  if (deviceName.isNotEmpty) {
    fineName += '$_kDeviceName$deviceName';
  } else {
    //没有用deviceId 替代DeviceName
    fineName += '$_kDeviceName$deviceId';
  }
  fineName += _kSplitStr;
  fineName += '$_kDeviceId$deviceId';
  fineName += _kSplitStr;
  fineName += '$_kChannel$channel';
  fineName += _kSplitStr;
  fineName += '$_kTime$time';
  fineName += _kSplitStr;
  if (endTime.isNotEmpty) {
    fineName += '$_kEndTime$endTime';
  } else {
    ///没有配置结束时间那就用time
    fineName += '$_kEndTime$time';
  }
  fineName += _kSplitStr;
  fineName += '$_kExInfo$exInfo';
  fineName += _kSplitStr;
  fineName += '.${fileType.toName()}';
  final filePath = '$dirPath/$fineName';
  return filePath;
}

///生成本地文件夹
///如果是iOS就在ApplicationDocument文件夹中
///如果是Android就在ExternalStorage文件夹中
///[dirName] 如果有对应的dirName文件夹，那就返回对应的dirName文件夹，没有就会创建dirName文件夹
///return 返回对应文件夹的路径
Future<String> kGenLocalDirectoryPath({required String dirName}) async {
  Directory? directory;
  if (Platform.isIOS) {
    directory = await getApplicationDocumentsDirectory();
  } else {
    //isAndroid
    directory = await getExternalStorageDirectory();
  }
  final dPathStr = '/${directory!.path}/$dirName';
  final dPath = Directory(dPathStr);
  if (await dPath.exists()) {
    return Future.value(dPathStr);
  } else {
    dPath.create();
    return Future.value(dPathStr);
  }
}

/// 本地存图片的文件夹,没有的话就会创建
Future<String> kDirectoryPathImages() async {
  return kGenLocalDirectoryPath(dirName: 'jf_images');
}

/// 本地存视频的文件夹,没有的话就会创建
Future<String> kDirectoryPathVideos() async {
  return kGenLocalDirectoryPath(dirName: 'jf_videos');
}

///存储SD卡本地图片
Future<String> kDirectoryPathSDCardPictures() async {
  return kGenLocalDirectoryPath(dirName: 'jf_sdcardImage');
}

///存储SD卡本地录像段缩略图
Future<String> kDirectoryPathSDCardRecordThumbnail() async {
  return kGenLocalDirectoryPath(dirName: 'SDCardRecordThumbnails');
}

///存储SD卡本地原图
Future<String> kDirectoryPathSDCardRecordOriginalPic() async {
  return kGenLocalDirectoryPath(dirName: 'SDCardRecordOriginalPic');
}

Future<List<File>> kGetLocalImages() async {
  final directoryPath = await kDirectoryPathImages();
  final directory = Directory(directoryPath);
  if (directory.existsSync() == false) {
    return [];
  }
  final files = directory.listSync(recursive: true).where((file) {
    return file.path.endsWith('.jpg');
    // return file.path.endsWith('.jpg')
    //     || file.path.endsWith('.jpeg')
    //     || file.path.endsWith('.png');
  }).toList();

  // 将文件对象转换成 `File` 类型并返回结果
  return files.map((file) => File(file.path)).toList();
}

Future<List<File>> kGetLocalVideos() async {
  final directoryPath = await kDirectoryPathVideos();
  final directory = Directory(directoryPath);
  if (directory.existsSync() == false) {
    return [];
  }
  final files = directory.listSync(recursive: true).where((file) {
    return file.path.endsWith('.mp4');
  }).toList();

  // 将文件对象转换成 `File` 类型并返回结果
  return files.map((file) => File(file.path)).toList();
}

/// 本地存预置点图片的文件夹,没有的话就会创建
Future<String> kDirectoryPresetImagePath() async {
  return kGenLocalDirectoryPath(dirName: 'preset_image');
}

/// 回放视频的文件夹,没有的话就会创建
Future<String> kDirectoryVideoRecordPath() async {
  return kGenLocalDirectoryPath(dirName: 'jf_videorecord');
}
