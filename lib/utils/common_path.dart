import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:fcloudsdk/api/mobile_systeminfo/MobileSystemInfo_api.dart';

Future<String> kDirectoryPath() async {
  Directory? directory;
  if (Platform.isIOS) {
    directory = await getApplicationDocumentsDirectory();
  } else if (Platform.isAndroid) {
    //isAndroid
    directory = await getExternalStorageDirectory();
  } else {
    String path = await MobileSystemAPI.instance.xcGetOhosFilesDir();
    directory = Directory(path);
    // directory = await getTemporaryDirectory();
  }

  return directory!.path;
}
