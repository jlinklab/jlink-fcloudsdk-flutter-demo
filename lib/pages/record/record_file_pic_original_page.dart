import 'package:flutter/material.dart';
import 'package:fcloudsdk/controllers/recordfile_pic/model.dart';
import 'package:fcloudsdk/utils/date_util.dart';
import 'package:fcloudsdk/widgets/images_jf.dart';

import '../../common/common_path.dart';

// ignore: must_be_immutable
class SDCardOriginalImage extends StatefulWidget {
  SDCardOriginalImage(
      {Key? key,
      required this.szDevId,
      required this.channel,
      required this.model})
      : super(key: key);

  String szDevId;
  int channel;
  SDCardAlarmMsgLocal model;

  @override
  State<SDCardOriginalImage> createState() => _SDCardOriginalImageState();
}

class _SDCardOriginalImageState extends State<SDCardOriginalImage> {
  ///原图存储路径
  late String dataString;

  @override
  void initState() {
    super.initState();
    getLocalPath();
    setState(() {});
  }

  Future<String> getLocalPath() async {
    List<String> fileNameList = widget.model.msg!.fileName!.split('/');

    dataString = widget.model.msg!.beginTime!;

    String dataStringLine =
        DateUtil.formatDateTimeline(DateUtil.fromDateString(dataString), true);
    String localAlarmPicsPath = await kDirectoryPathSDCardRecordOriginalPic();

    ///获取本地用于存储图片的文件夹(由序列号和开始时间组成)
    return '/$localAlarmPicsPath/${widget.szDevId}_${fileNameList[3]}_$dataStringLine.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(dataString)),
      body: FutureBuilder<String>(
        future: getLocalPath(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text((snapshot.error as FlutterError).message),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Center(
            child: JFImage.originalPicSDCard(
              szDevId: widget.szDevId,
              channel: widget.channel,
              assetName: 'images/monitor_bg.png',
              fileName: widget.model.msg!.fileName!,
              localPath: snapshot.requireData,
              beginTime: DateUtil.fromDateString(widget.model.msg!.beginTime!),
              endTime: DateUtil.fromDateString(widget.model.msg!.endTime!),
              downloadStatus: (status) {
                if (status == DownloadStatus.start) {
                  // KToast.show();
                } else if (status == DownloadStatus.completion) {
                  // KToast.dismiss();
                } else if (status == DownloadStatus.failed) {
                  // KToast.show(status: 'failed', duration: const Duration(seconds: 2));
                }
              },
            ),
          );
        }
      ),
    );
  }
}
