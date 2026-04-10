import 'dart:io';

import 'package:flutter/material.dart';

import 'package:open_file/open_file.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

class CloudDownloadManagerPage extends StatefulWidget {
  const CloudDownloadManagerPage({Key? key}) : super(key: key);

  @override
  State<CloudDownloadManagerPage> createState() => _DownloadManagerPageState();
}

class _DownloadManagerPageState extends State<CloudDownloadManagerPage> {
  // List<CloudVideoDownloadItemModel> _list = [];

  // @override
  // void initState() {
  //   ///先更新数据最新状态
  //   JFApi.xcCloudVideoDownloadController.xcCheckDownloadList();
  //
  //   ///拿到数据源
  //   _list = JFApi.xcCloudVideoDownloadController.downloadList;
  //
  //   ///监听数据变化
  //   JFApi.xcCloudVideoDownloadController.xcAddUpdateNotify(() {
  //     if (!mounted) {
  //       return;
  //     }
  //
  //     ///刷新
  //     setState(() {});
  //   });
  //   super.initState();
  // }
  //
  // _onTapModel(CloudVideoDownloadItemModel model) {
  //   if (model.state == CloudVideoDownloadState.done) {
  //     ///播放
  //     if (Platform.isAndroid) {
  //       OpenFile.open(model.fileName);
  //     } else {
  //       JFApi.xcVideoPlay.xcPlayNormalVideo(model.fileName);
  //     }
  //   } else {
  //     JFApi.xcCloudVideoDownloadController.xcChangeModelState(model);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(TR.current.cloudDownload),
    //     automaticallyImplyLeading: false, // 禁用自动返回按钮
    //     actions: [
    //       IconButton(
    //           onPressed: () {
    //             Navigator.pop(context);
    //           },
    //           icon: const Icon(Icons.close))
    //     ],
    //   ),
    //   body: _list.isEmpty
    //       ? Center(
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               const Icon(
    //                 Icons.hourglass_empty,
    //                 size: 50,
    //               ),
    //               const SizedBox(
    //                 height: 10,
    //               ),
    //               Text(
    //                 TR.current.nothing,
    //                 style: const TextStyle(fontSize: 30),
    //               )
    //             ],
    //           ),
    //         )
    //       : ListView.separated(
    //           itemBuilder: (context, index) {
    //             CloudVideoDownloadItemModel model = _list[index];
    //             String stateText = '';
    //             String subTitle = '';
    //             Color textColor = Colors.black;
    //             if (model.state == CloudVideoDownloadState.wait) {
    //               stateText = '待下载';
    //               textColor = Colors.blue;
    //             } else if (model.state == CloudVideoDownloadState.downloading) {
    //               stateText = '正在下载';
    //               subTitle = '下载进度 ${model.progress}%';
    //               textColor = Colors.black;
    //             } else if (model.state == CloudVideoDownloadState.done) {
    //               stateText = '播放';
    //               subTitle = '下载完成';
    //               textColor = Colors.green;
    //             } else if (model.state == CloudVideoDownloadState.fail) {
    //               stateText = '下载失败，请重试';
    //               textColor = Colors.red;
    //             } else if (model.state == CloudVideoDownloadState.change) {
    //               stateText = '转码中';
    //               textColor = Colors.lightGreen;
    //             }
    //             return InkWell(
    //               onTap: () {
    //                 _onTapModel(model);
    //               },
    //               child: ListTile(
    //                 title: Text(model.fileName),
    //                 subtitle: Text(subTitle),
    //                 trailing: Text(
    //                   stateText,
    //                   style: TextStyle(color: textColor),
    //                 ),
    //               ),
    //             );
    //           },
    //           separatorBuilder: (context, index) {
    //             return const Divider(
    //               thickness: 1,
    //               color: Colors.grey,
    //             );
    //           },
    //           itemCount: _list.length),
    // );
  }

  @override
  void dispose() {
    KToast.dismissInDispose();
    super.dispose();
  }
}
