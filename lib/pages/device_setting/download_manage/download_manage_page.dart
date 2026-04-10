import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/media/download/meida_download_controller.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/download_manage/manager/download_manage.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

import '../../download_manage/model/record_file.dart';

class DownloadManagerPage extends StatefulWidget {
  const DownloadManagerPage({Key? key, required this.deviceId, this.records})
      : super(key: key);

  final String deviceId;

  ///需要下载的文件
  final List<RecordFile>? records;

  @override
  State<DownloadManagerPage> createState() => _DownloadManagerPageState();
}

class _DownloadManagerPageState extends State<DownloadManagerPage> {
  List<RecordFile> _list = [];

  @override
  void initState() {
    super.initState();
    DownloadManage.instance.addListener(refresh);
    _list = DownloadManage.instance
        .addToHistory(widget.deviceId, widget.records ?? []);
  }

  _onTapModel(RecordFile model) {
    if (model.download) {
      ///播放
      if (Platform.isAndroid) {
        OpenFile.open(model.saveFilePath);
      } else if (Platform.isIOS) {
        JFApi.xcVideoPlay.xcPlayNormalVideo(model.saveFilePath);
      } else {
        JFApi.xcVideoPlay.xcPlayLocalVideoOnOhos(model.saveFilePath);
      }
    } else if (!model.download) {
      //这里应该去检查是否可以直接下载
      //直接下载[当前没有正在下载的任务,否则需要取消正在下载的任务],核心原因是不支持并行下载
      DownloadManage.instance.checkStartDownload(widget.deviceId, _list[0]);
    }
  }

  refresh() {
    if (context.mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.download),
        automaticallyImplyLeading: false, // 禁用自动返回按钮
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ],
      ),
      body: _list.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.hourglass_empty,
                    size: 50,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    TR.current.nothing,
                    style: const TextStyle(fontSize: 30),
                  )
                ],
              ),
            )
          : ListView.separated(
              itemBuilder: (context, index) {
                RecordFile model = _list[index];
                String stateText = '';
                String subtitle = '';
                Color textColor = Colors.black;
                if (model.downloadProgress.state == DownloadState.downloading) {
                  stateText = '正在下载';
                  subtitle = '下载进度 ${model.downloadProgress.progress}%';
                  textColor = Colors.black;
                } else if (model.downloadProgress.state == DownloadState.done) {
                  stateText = '播放';
                  subtitle = '下载完成';
                  textColor = Colors.green;
                } else if (model.downloadProgress.state ==
                    DownloadState.error) {
                  stateText = '下载失败，请重试';
                  textColor = Colors.red;
                }
                return InkWell(
                  onTap: () {
                    _onTapModel(model);
                  },
                  child: ListTile(
                    title: Text((model as CardRecord).fileName ?? ''),
                    subtitle: Text(subtitle),
                    trailing: Text(
                      stateText,
                      style: TextStyle(color: textColor),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  thickness: 1,
                  color: Colors.grey,
                );
              },
              itemCount: _list.length),
    );
  }

  @override
  void dispose() {
    KToast.dismissInDispose();
    DownloadManage.instance.removeListener(refresh);
    DownloadManage.instance.disposeDownload();
    super.dispose();
  }
}
