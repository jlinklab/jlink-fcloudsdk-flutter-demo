import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:xcloudsdk_flutter_example/common/common_path.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/album/album_page.dart';
import 'package:xcloudsdk_flutter_example/pages/alarm_message/model/model.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';
import '../../common/base_const.dart';

class AlarmMessageDetailPage extends StatefulWidget {
  final AlarmMessage message;
  final String deviceId;
  const AlarmMessageDetailPage({
    Key? key,
    required this.message,
    required this.deviceId,
  }) : super(key: key);

  @override
  State<AlarmMessageDetailPage> createState() => _AlarmMessageListPageState();
}

class _AlarmMessageListPageState extends State<AlarmMessageDetailPage> {
  late AlarmMessage _message;
  late File _localImageFile;
  bool _isHasFile = false;

  @override
  void initState() {
    _message = widget.message;

    Future.delayed(Duration.zero, () async {
      _checkIsHasLocalData();
    });
    super.initState();
  }

  void _checkIsHasLocalData() async {
    String picImage = _message.picinfo!.name!;
    String directoryPath = await _getDirectoryPath();
    String imagePath = '$directoryPath/$picImage';
    File imageFile = File(imagePath);
    if (await imageFile.exists()) {
      ///本地对应的图片，直接加载显示
      KToast.show(status: '正在加载本地图片');
      setState(() {
        _isHasFile = true;
        _localImageFile = imageFile;
      });
    } else {
      /// 没有，先下载，存到本地再显示
      KToast.show();
      String imageURL = _message.picinfo!.originalImage!;
      http
          .get(
        Uri.parse(imageURL),
      )
          .then((value) {
        KToast.dismiss();
        final data = value.bodyBytes;
        imageFile.writeAsBytesSync(data);
        setState(() {
          _isHasFile = true;
          _localImageFile = imageFile;
        });
      }).catchError((error) {
        KToast.show(status: '图片下载错误');
      });
    }
  }

  /// 本地存报警图片的文件夹,没有的话就会创建
  Future<String> _getDirectoryPath() async {
    Directory? directory;
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      //isAndroid
      directory = await getExternalStorageDirectory();
    }
    const folderName = "alarm_images";
    final dPathStr = '/${directory!.path}/$folderName';
    final dPath = Directory(dPathStr);
    if (await dPath.exists()) {
      return Future.value(dPathStr);
    } else {
      dPath.create();
      return Future.value(dPathStr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(TR.current.messageDetail),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isHasFile)
                Image.file(
                  _localImageFile,
                  width: kScreenWidth,
                  height: kScreenWidth * 9 / 16,
                ),
              if (_isHasFile)
                Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: TextButton(
                      onPressed: _isSaving ? null : _saveImageToGallery,
                      child: Text(
                        _isSaving
                            ? TR.current.saving
                            : TR.current.save,
                      ),
                    ))
            ],
          ),
        ));
  }

  

  bool _isSaving = false;

  /// 将报警图片保存到系统相册 + app相册
  Future<void> _saveImageToGallery() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final Uint8List bytes = await _localImageFile.readAsBytes();
      // 保存到系统相册
      final result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 80,
        name: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      // 同步保存到app相册
      await _saveToAppAlbum(bytes);
      if (result != null && result['isSuccess'] == true) {
        KToast.show(status: TR.current.saveSuccess);
      } else {
        KToast.show(status: TR.current.saveFailed);
      }
    } catch (e) {
      KToast.show(status: TR.current.saveFailed);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// 保存到app相册（jf_images目录）
  Future<void> _saveToAppAlbum(Uint8List bytes) async {
    try {
      final directoryPath = await kDirectoryPathImages();
      final timeStr = DateFormat('yyyy-MM-dd HH_mm_ss SSS').format(DateTime.now());
      final channel = 'channel${_message.ch ?? '0'}';
      final savePath =
          '/$directoryPath/$kPrefixImage${widget.deviceId} $timeStr $channel.jpg';
      final appFile = File(savePath);
      if (!await appFile.parent.exists()) {
        await appFile.parent.create(recursive: true);
      }
      await appFile.writeAsBytes(bytes);
      // 刷新相册页
      AlbumPage.update();
    } catch (e) {
      debugPrint('保存到app相册失败: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
