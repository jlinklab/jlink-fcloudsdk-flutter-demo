import 'package:flutter/material.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/controllers/recordfile_pic/model.dart';
import 'package:fcloudsdk/controllers/recordfile_pic/record_file_pic_controller.dart';
import 'package:fcloudsdk/utils/date_util.dart';
import 'package:fcloudsdk/widgets/images_jf.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/common/common_path.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/record/record_file_pic_original_page.dart';
import 'package:fcloudsdk_example/views/calendar/rf_calendar.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

class RecordFilePicturePage extends StatefulWidget {
  const RecordFilePicturePage({Key? key, required this.deviceId})
      : super(key: key);

  final String deviceId;

  @override
  State<RecordFilePicturePage> createState() => _RecordFilePicturePageState();
}

class _RecordFilePicturePageState extends State<RecordFilePicturePage> {
  DateTime _currentDateTime = DateTime.now(); //可以自定义，外界传进来 DateTime(2023,05,07)
  late RecordFilePictureController controller;
  List<SDCardAlarmMsgLocal> dataSource = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.sdList),
        actions: [
          IconButton(
              onPressed: () {
                ///处理点击事件
                showRFCalendar(
                    context: context,
                    beginDatetime: DateTime(2000, 1, 1),
                    endDatetime: DateTime.now(),
                    hasDataDateMap: {},
                    selectedDate: _currentDateTime,
                    onSelected: (DateTime onSelectedTime) {
                      _currentDateTime = onSelectedTime;
                      dataSource.clear();

                      setState(() {});
                      getDataSource();
                    });
              },
              icon: const Icon(Icons.date_range))
        ],
      ),
      body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemBuilder: (BuildContext context, int index) {
            SDCardAlarmMsgLocal alarmMsg = dataSource[index];
            AddDownloadComPicToTaskList param = AddDownloadComPicToTaskList(
                height: 135, width: 240, picName: alarmMsg.msg!.fileName!);
            return GridTile(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return SDCardOriginalImage(
                        szDevId: widget.deviceId, channel: 0, model: alarmMsg);
                  }));
                },
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(alarmMsg.msg!.beginTime!),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: JFImage.croppingDiagramSDCard(
                          szDevId: widget.deviceId,
                          assetName: 'images/monitor_bg.png',
                          localPath: alarmMsg.localPath!,
                          croppingDiagramParam: param),
                    )
                  ],
                ),
              ),
            );
          },
          itemCount: dataSource.length),
    );
  }

  @override
  void initState() {
    super.initState();
    controller = RecordFilePictureController(deviceID: widget.deviceId);
    getDataSource();
  }

  @override
  void dispose() {
    JFApi.xcMediaDownload.xcDevCancelDownloadComPic(widget.deviceId);
    super.dispose();
  }

  void getDataSource() async {
    ///获取本地用于存储图片的文件夹(由序列号和开始时间组成)
    String path = await kDirectoryPathSDCardPictures();

    try {
      dataSource = await controller.findRecordFile(
          DateUtil.startOfDay(_currentDateTime),
          DateUtil.endOfDay(_currentDateTime),
          path);
    } catch (error) {
      KToast.show(
          status: kErrorMsg(error), duration: const Duration(seconds: 2));
      dataSource.clear();
    }
    setState(() {});
  }
}
