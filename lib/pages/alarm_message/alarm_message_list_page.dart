import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/models/user_instance.dart';
import 'package:xcloudsdk_flutter_example/pages/alarm_message/alarm_message_detail_page.dart';
import 'package:xcloudsdk_flutter_example/pages/alarm_message/alarm_message_video_page.dart';
import 'package:xcloudsdk_flutter_example/pages/alarm_message/model/model.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

class AlarmMessageListPage extends StatefulWidget {
  final String deviceId;

  const AlarmMessageListPage({Key? key, required this.deviceId})
      : super(key: key);

  @override
  State<AlarmMessageListPage> createState() => _AlarmMessageListPageState();
}

class _AlarmMessageListPageState extends State<AlarmMessageListPage> {
  bool _hasMore = true;
  bool _isLoading = true;

  // 滚动控制器
  final ScrollController _scrollController = ScrollController();
  List<AlarmMessage> _dataList = [];
  late AlarmMessageModel _model;

  @override
  void initState() {
    // 监听滚动事件
    _scrollController.addListener(() {
      if (!_hasMore || _isLoading) {
        return;
      }
      // 获取滚动条下拉的距离
      // print(_scrollController.position.pixels);
      // 获取整个页面的高度
      // print(_scrollController.position.maxScrollExtent);
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        int pageNum = _model.pgnum ?? 1;
        _model = AlarmMessageModel(
            sn: widget.deviceId,
            userId: UserInfo.instance.userId,
            pgnum: pageNum + 1);
        _loadData(_model);
      }
    });

    Future.delayed(Duration.zero, () {
      if (widget.deviceId.contains('.')) {
        KToast.show(status: 'IP地址形式的设备序列号不支持报警消息查询！！！');
      } else {
        _model = AlarmMessageModel(
            sn: widget.deviceId, userId: UserInfo.instance.userId, pgnum: 1);
        _loadData(_model);
      }
    });
    super.initState();
  }

  ///type:1 加载更多 0：刷新
  _loadData(AlarmMessageModel model) async {
    _isLoading = true;
    if (model.pgnum == 1) {
      KToast.show();
    }

    JFApi.xcAlarmMessage.xcQueryAlarmMsgList(model).then((value) {
      if (model.pgnum == 1) {
        KToast.dismiss();
      }

      _isLoading = false;
      AlarmMessageResult result = AlarmMessageResult.fromJson(value);
      if (result.msglist != null && result.msglist!.length == 20) {
        _hasMore = true;
      } else {
        _hasMore = false;
      }
      if (model.pgnum == 1) {
        _dataList = result.msglist ?? [];
      } else {
        _dataList.addAll(result.msglist ?? []);
      }
      if (mounted) {
        setState(() {});
      }
    }).catchError((error) {
      _isLoading = false;
      KToast.show(status: kErrorMsg(error));
    });
  }

  _onDelete(int index, BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('确认这条报警消息删除'),
          actions: [
            CupertinoDialogAction(
              child: const Text('确认'),
              onPressed: () {
                Navigator.of(context).pop();
                AlarmMessage m = _dataList[index];
                AlarmMessageDeleteId id = AlarmMessageDeleteId(id: m.id!);
                AlarmMessageDeleteModel model = AlarmMessageDeleteModel(
                    sn: widget.deviceId, delty: 'MSG', ids: [id]);
                KToast.show();
                // AlarmMessageApiPlatform.instance.
                JFApi.xcAlarmMessage.xcDeleteAlarmMessages(model).then((value) {
                  KToast.dismiss();
                  setState(() {
                    _dataList.removeAt(index);
                  });
                }).catchError((error) {
                  _isLoading = false;
                  KToast.show(status: kErrorMsg(error));
                });
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  Widget _hasMoreTipView() {
    // 如果还有数据
    if (_hasMore) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                '加载中',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(
                width: 5,
              ),
              // 加载图标
              CircularProgressIndicator()
            ],
          ),
        ),
      );
    } else {
      return const Center(
        child: Text("没有更多了..."),
      );
    }
  }

  Widget _itemView(int index, BuildContext context) {
    AlarmMessage m = _dataList[index];
    String imageUrl = '';
    if (m.picinfo != null && m.picinfo!.thumbnail != null) {
      imageUrl = m.picinfo!.thumbnail!;
    }
    final title = m.event ?? '\n';
    final subTitle = m.tm ?? '\n';
    bool visiable = false;
    if ((m.vidinfo?.vidlen != null && m.vidinfo?.vidlen != 0) ||
        (m.picinfo?.originalImage != null &&
            m.picinfo!.originalImage!.isNotEmpty)) {
      visiable = true;
    }

    return ListTile(
      title: Text(title),
      subtitle: Text(subTitle),
      leading: CachedNetworkImage(
        width: 90,
        height: 60,
        imageUrl: imageUrl,
        placeholder: (context, url) => const SizedBox(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
      onLongPress: () {
        _onDelete(index, context);
      },
      trailing: Visibility(
        visible: visiable,
        child: ElevatedButton(
            onPressed: () {
              _onSearchMedia(index, context);
            },
            child: (m.vidinfo == null || m.vidinfo?.vidlen == 0)
                ? const Text("图片")
                : const Text("视频")),
      ),
    );
  }

  void _onSearchMedia(int index, BuildContext context) async {
    AlarmMessage msg = _dataList[index];
    if (msg.vidinfo == null || msg.vidinfo?.vidlen == 0) {
      ///显示图片
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return AlarmMessageDetailPage(message: msg);
      }));
    } else {
      ///播放视频
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return AlarmMsgVideo(msg: msg, deviceId: widget.deviceId);
      }));
    }
  }

  Widget _emptyStatusView() {
    if (_isLoading) {
      return const SizedBox();
    } else {
      return const Center(
        child: Text('暂无报警消息'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(TR.current.messageList),
        ),
        body: RefreshIndicator(
          onRefresh: () {
            _model = AlarmMessageModel(
                sn: widget.deviceId,
                userId: UserInfo.instance.userId,
                pgnum: 1);
            _loadData(_model);
            return Future.value();
          },
          child: _dataList.isEmpty
              ? _emptyStatusView()
              : ListView.separated(
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        _itemView(index, context),
                        if (index == _dataList.length - 1)
                          _hasMoreTipView(), // 当渲染到最后一条数据时，加载动画提示
                      ],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: Colors.grey,
                    );
                  },
                  itemCount: _dataList.length,
                ),
        ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
