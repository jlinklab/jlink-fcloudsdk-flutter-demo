import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fcloudsdk_example/common/common_path.dart';
import 'package:fcloudsdk_example/pages/album/views/album_Item_list_view.dart';
import 'package:fcloudsdk_example/pages/album/views/album_bottom_tool_view.dart';
import 'package:fcloudsdk_example/pages/album/models/album_model.dart';
import 'package:fcloudsdk_example/pages/album/views/album_date_picker.dart';
import 'package:fcloudsdk_example/pages/album/views/album_device_picker.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

class AlbumPage extends StatefulWidget {
  // ignore: library_private_types_in_public_api
  static _AlbumPageState? state;
  static update() {
    if (AlbumPage.state != null) {
      _AlbumPageState pState = AlbumPage.state!;
      pState.load();
    }
  }

  final Function(bool isEditting) onChangeEditStatus;

  const AlbumPage({Key? key, required this.onChangeEditStatus}) : super(key: key);

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {

  late PageController _pageController;
  int _modeType = 0; //0:图片 1:录像
  bool _isEditing = false;
  bool _isShowDatePicker = false;
  bool _isShowDevicePicker = false;
  bool _isSelectedAll = false;

  late List<File> _fileImages;
  late List<File> _fileVideos;

  List<Album> _oImages = []; //从本地读到的原始数据
  List<Album> _oVideos = []; //从本地读到的原始数据

  //空就是全部日期，不空代表具体某一天例如 _videoDay = '2020-12-23';
  final _kAllDay = '不限日期';
  String _imageDay = '不限日期';
  List<String> _imageDayList = [];
  String _videoDay = '不限日期';
  List<String> _videoDayList = [];

  final _kAllDevice = '所有设备';
  String _imageDevice = '所有设备';
  List<String> _imageDeviceList = [];
  String _videoDevice = '所有设备';
  List<String> _videoDeviceList = [];

  ///用于展示的图片和
  List<List<Album>> _imageList = [];
  List<List<Album>> _videoList = [];

  @override
  void initState() {
    _pageController = PageController();
    Future.delayed(Duration.zero, () {
      load();
    });



    super.initState();
    AlbumPage.state = this;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: albumPageStateGlobalKey,
      appBar: AppBar(
        title: const Text('相册'),
        actions: [
          TextButton(
              onPressed: () {
                _onCancelEdit();
              },
              child: _isEditing
                  ? const Text(
                '取消',
                style: TextStyle(color: Colors.white, fontSize: 20),
              )
                  : const Text(
                '编辑',
                style: TextStyle(color: Colors.white, fontSize: 20),
              )),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () {
                      if (_modeType != 0) {
                        setState(() {
                          _modeType = 0;
                          _isEditing = false;
                          widget.onChangeEditStatus(_isEditing);
                          _isShowDatePicker = false;
                          _isShowDevicePicker = false;
                        });
                        _pageController.jumpToPage(0);
                      }
                    },
                    child: Text(
                      '图片',
                      style: TextStyle(
                          fontSize: 25,
                          color: _modeType == 0 ? Colors.blue : Colors.grey),
                    )),
                TextButton(
                    onPressed: () {
                      if (_modeType != 1) {
                        setState(() {
                          _modeType = 1;
                          _isEditing = false;
                          widget.onChangeEditStatus(_isEditing);
                          _isShowDatePicker = false;
                          _isShowDevicePicker = false;
                        });
                        _pageController.jumpToPage(1);
                      }
                    },
                    child: Text(
                      '录像',
                      style: TextStyle(
                          fontSize: 25,
                          color: _modeType == 1 ? Colors.blue : Colors.grey),
                    )),
              ],
            ),
          ),
          Container(
            color: Colors.grey,
            height: 1,
          ),
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: TextButton(
                      onPressed: () {
                        //编辑状态不可按
                        if (_isEditing) {
                          return;
                        }
                        setState(() {
                          _isShowDatePicker = !_isShowDatePicker;
                          _isShowDevicePicker = false;
                        });
                      },
                      child: Text(
                        _modeType == 0 ? _imageDay : _videoDay,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1, // 最多只显示一行
                        style: TextStyle(
                            fontSize: 25,
                            color:
                            _isShowDatePicker ? Colors.blue : Colors.grey),
                      )),
                ),
                Expanded(
                  flex: 1,
                  child: TextButton(
                      onPressed: () {
                        //编辑状态不可按
                        if (_isEditing) {
                          return;
                        }
                        setState(() {
                          _isShowDevicePicker = !_isShowDevicePicker;
                          _isShowDatePicker = false;
                        });
                      },
                      child: Text(
                        _modeType == 0 ? _imageDevice : _videoDevice,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1, // 最多只显示一行
                        style: TextStyle(
                            fontSize: 25,
                            color: _isShowDevicePicker
                                ? Colors.blue
                                : Colors.grey),
                      )),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey,
            height: 1,
          ),
          Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            scrollDirection: Axis.horizontal, // 设置为水平方向
                            physics: const NeverScrollableScrollPhysics(), // 禁用滚动
                            children: [
                              AlbumItemListView(
                                // key: ObjectKey(_imageList),
                                dataList: _imageList,
                                isEditting: _isEditing,
                              ),
                              AlbumItemListView(
                                // key: ObjectKey(_videoList),
                                dataList: _videoList,
                                isEditting: _isEditing,
                              ),
                            ],
                          ),
                        ),
                        Offstage(
                            offstage: !_isEditing,
                            child: AlbumBottomToolView(
                              onDelete: () {
                                _showDeleteDialog(context);
                              },
                              onShare: () {
                                KToast.show(status: '暂未实现');
                              },
                              onSelectAll: () {
                                _onSelectAll();
                              },
                              onCancel: () {
                                _onCancelEdit();
                              },
                              isSelectedAll: _isSelectedAll,
                            ))
                      ],
                    ),
                  ),
                  if (_isShowDatePicker)
                    Positioned.fill(
                        child: AlbumDatePicker(
                          onSelectDeviceCallback: (String device) {
                            //先关了
                            setState(() {
                              _isShowDatePicker = !_isShowDatePicker;
                            });
                            //再处理数据
                            if (_modeType == 0) {
                              if (_imageDay != device) {
                                _imageDay = device;
                              }
                            } else {
                              if (_videoDay != device) {
                                _videoDay = device;
                              }
                            }
                            //全局处理数据
                            _handelData();
                          },
                          dataList: _modeType == 0 ? _imageDayList : _videoDayList,
                          selectedDevice: _modeType == 0 ? _imageDay : _videoDay,
                        )),
                  if (_isShowDevicePicker)
                    Positioned.fill(
                        child: AlbumDevicePicker(
                          onSelectDeviceCallback: (String device) {
                            //先关了
                            setState(() {
                              _isShowDevicePicker = !_isShowDevicePicker;
                            });
                            //再处理数据
                            if (_modeType == 0) {
                              if (_imageDevice != device) {
                                _imageDevice = device;
                              }
                            } else {
                              if (_videoDevice != device) {
                                _videoDevice = device;
                              }
                            }
                            //全局处理数据
                            _handelData();
                          },
                          dataList:
                          _modeType == 0 ? _imageDeviceList : _videoDeviceList,
                          selectedDevice: _modeType == 0 ? _imageDevice : _videoDevice,
                        ))
                ],
              ))
        ],
      ),
    );
  }

  load() async {
    _fileImages = await kGetLocalImages();
    _oImages.clear();
    for (File file in _fileImages) {
      String path = file.path;
      //path==> //var/mobile/Containers/Data/Application/9AE07893-DF4E-44C8-982F-83352518E370/Documents/jf_images/jf_image34234234234234ds23d 2023-05-25 21_16_34 175.jpg
      String fullName = path.split('/').last;
      if (fullName.startsWith(kPrefixImage)) {
        List<String> list = fullName.split(' ');
        String date = list[1];
        String time = list[2].split('_').join(':');
        String name = list[0].replaceFirst('jf_image', ''); //设备名称需要去掉前缀jf_image
        // jf_image34234234234234ds23d 2023-05-25 21_16_34 175.jpg
        _oImages.add(Album(
            type: '0',
            date: date,
            time: time,
            name: name,
            fullName: fullName,
            path: path,
            isSelected: false));
      }
    }

    _fileVideos = await kGetLocalVideos();
    _oVideos.clear();
    for (File file in _fileVideos) {
      String path = file.path;
      // //var/mobile/Containers/Data/Application/9AE07893-DF4E-44C8-982F-83352518E370/Documents/jf_images/jf_image34234234234234ds23d 2023-05-25 21_16_34 175.mp4
      String fullName = path.split('/').last;
      if (fullName.startsWith(kPrefixVideo)) {
        List<String> list = fullName.split(' ');
        String date = list[1];
        String time = list[2].split('_').join(':');
        String name = list[0].replaceFirst('jf_video', ''); //设备名称需要去掉前缀jf_image
        // jf_image34234234234234ds23d 2023-05-25 21_16_34 175.jpg
        _oVideos.add(Album(
            type: '1',
            date: date,
            time: time,
            name: name,
            fullName: fullName,
            path: path,
            isSelected: false));
      }
    }

    _handelData();
  }

  ///全局处理数据
  _handelData() {
    ///先处理图片
    List<Album> tempListImage = [];
    //1.筛选日期
    if (_imageDay != _kAllDay) {
      tempListImage = _oImages.where((Album e) => e.date == _imageDay).toList();
    } else {
      tempListImage = List.from(_oImages);
    }
    //2.筛选设备
    if (_imageDevice != _kAllDevice) {
      tempListImage =
          tempListImage.where((Album e) => e.name == _imageDevice).toList();
    } else {
      //不做筛选
    }
    //3.根据日期分成二维数组，并赋值
    _imageList = _sortDataList(tempListImage);
    //4.处理当前日期list和设备list
    final imageHandleResult = _handleCanSelectDatesAndDevices(_oImages);
    _imageDayList = imageHandleResult[0];
    _imageDeviceList = imageHandleResult[1];

    ///再处理视频
    List<Album> tempListVideo = [];
    //1.筛选日期
    if (_videoDay != _kAllDay) {
      tempListVideo = _oVideos.where((Album e) => e.date == _videoDay).toList();
    } else {
      tempListVideo = List.from(_oVideos);
    }
    //2.筛选设备
    if (_videoDevice != _kAllDevice) {
      tempListVideo =
          tempListVideo.where((Album e) => e.name == _videoDevice).toList();
    } else {
      //不做筛选
    }
    //3.根据日期分成二维数组，并赋值
    _videoList = _sortDataList(tempListVideo);
    //4.处理当前日期list和设备list
    final videoHandleResult = _handleCanSelectDatesAndDevices(_oVideos);
    _videoDayList = videoHandleResult[0];
    _videoDeviceList = videoHandleResult[1];

    if (!mounted) {
      return;
    }
    ///刷新页面
    setState(() {});
  }

  ///列出当前可供选择的日期和设备
  List<List<String>> _handleCanSelectDatesAndDevices(List<Album> list) {
    Map<String, int> mapDay = {};
    Map<String, int> mapDevice = {};
    for (var album in list) {
      mapDay[album.date] = 1;
      mapDevice[album.name] = 1;
    }

    List<String> dayList = List.from(mapDay.keys);
    dayList.insert(0, '不限日期');
    List<String> deviceList = List.from(mapDevice.keys);
    deviceList.insert(0, '所有设备');
    return [dayList, deviceList];
  }

  ///根据日期转成二维数组并排序
  List<List<Album>> _sortDataList(
      List<Album> list,
      ) {
    //转成二维数组
    Map<String, List<Album>> dateToAlbumsMap = {};
    for (Album album in list) {
      if (!dateToAlbumsMap.containsKey(album.date)) {
        dateToAlbumsMap[album.date] = [];
      }
      dateToAlbumsMap[album.date]!.add(album);
    }
    List<List<Album>> doubleList = List.from(dateToAlbumsMap.values);

    //排序
    //日期排序
    doubleList
        .sort((List<Album> a, List<Album> b) => a[0].date.compareTo(b[0].date));
    //时间排序
    for (var element in doubleList) {
      element.sort((Album a, Album b) => a.time.compareTo(b.time));
    }
    return doubleList;
  }

  _onDelete() {
    final selectedAlbumMap = _getSelectedAlbumMap();

    if (selectedAlbumMap.isEmpty) {
      final type = _modeType == 0 ? '图片' : '视频';
      KToast.show(status: '请选择想要删除的$type');
      return;
    }

    if (_modeType == 0) {
      ///过滤删掉的元素
      _oImages = _oImages
          .where((element) => selectedAlbumMap.containsKey(element) == false)
          .toList();
    } else {
      ///过滤删掉的元素
      _oVideos = _oVideos
          .where((element) => selectedAlbumMap.containsKey(element) == false)
          .toList();
    }

    KToast.show();
    for (Album album in selectedAlbumMap.keys) {
      //一个个删除
      final file = File(album.path);
      file.deleteSync();
    }
    KToast.show(status: '已删除');

    ///重新处理数据
    _handelData();
  }

  _onSelectAll() {
    setState(() {
      _isSelectedAll = !_isSelectedAll;
      if (_modeType == 0) {
        for (var albums in _imageList) {
          for (Album album in albums) {
            album.isSelected = _isSelectedAll;
          }
        }
      } else {
        for (var albums in _videoList) {
          for (Album album in albums) {
            album.isSelected = _isSelectedAll;
          }
        }
      }
    });
  }

  _onCancelEdit() {
    setState(() {
      _isEditing = !_isEditing;
      widget.onChangeEditStatus(_isEditing);
      _isShowDatePicker = false;
      _isShowDevicePicker = false;

      ///重置选中数据
      if (_modeType == 0) {
        for (var albums in _imageList) {
          for (Album album in albums) {
            album.isSelected = false;
          }
        }
      } else {
        for (var albums in _videoList) {
          for (Album album in albums) {
            album.isSelected = false;
          }
        }
      }
    });
  }

  ///获取选择的项目map
  Map<Album, int> _getSelectedAlbumMap() {
    //遍历当前图片列表，找到选择的
    final selectedAlbumMap = <Album, int>{};
    if (_modeType == 0) {
      for (var albums in _imageList) {
        for (Album album in albums) {
          if (album.isSelected) {
            selectedAlbumMap[album] = 1;
          }
        }
      }
    } else {
      for (var albums in _videoList) {
        for (Album album in albums) {
          if (album.isSelected) {
            selectedAlbumMap[album] = 1;
          }
        }
      }
    }
    return selectedAlbumMap;
  }

  _showDeleteDialog(BuildContext context) {
    final selectedAlbumMap = _getSelectedAlbumMap();

    if (selectedAlbumMap.isEmpty) {
      final type = _modeType == 0 ? '图片' : '视频';
      KToast.show(status: '请选择想要删除的$type');
      return;
    }

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('删除确认'),
          content: const Text('您确定要删除此选中项吗?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('删除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // 在这里处理删除操作
                Navigator.of(context).pop();
                _onDelete();
              },
            ),
          ],
        );
      },
    );
  }
}
