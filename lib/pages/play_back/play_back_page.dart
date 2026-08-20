import 'package:flutter/material.dart';
import 'package:fcloudsdk_example/pages/play_back/views/time_slider/time_slider.dart';
import 'package:fcloudsdk_example/pages/play_back/views/time_view.dart';
import 'package:fcloudsdk_example/pages/play_back/views/video_type_selector.dart';
import 'package:fcloudsdk_example/views/calendar/rf_calendar.dart';

class PlayBackPage extends StatefulWidget {
  const PlayBackPage({Key? key}) : super(key: key);

  @override
  State<PlayBackPage> createState() => _PlayBackPageState();
}

class _PlayBackPageState extends State<PlayBackPage> {
  bool _isPlaying = true;
  bool _isMute = false;
  int _speed = 1;

  _showDateView(BuildContext context) {
    final currentDateTime =
        DateTime(2023, 05, 07); //可以自定义，外界传进来 DateTime.now()
    showRFCalendar(
        context: context,
        beginDatetime: DateTime(2016, 7, 1),
        endDatetime: DateTime.now(),
        hasDataDateMap: {},
        selectedDate: currentDateTime,
        onSelected: (DateTime selectedDateTime) {
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("视频回放"),
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: () {
                _showDateView(context);
              },
              child: const Text(
                '日期',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ))
        ],
      ),
      body: Column(
        children: [
          LayoutBuilder(
              builder: (BuildContext context, BoxConstraints boxConstraints) {
            return Container(
              width: boxConstraints.maxWidth,
              height: boxConstraints.maxWidth * 9 / 16,
              color: Colors.red,
              child: const SizedBox(),
            );
          }),
          Container(
            height: 50,
            color: Colors.blue,
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      //播放 暂停
                      setState(() {
                        _isPlaying = !_isPlaying;
                      });
                    },
                    icon: Icon(
                      _isPlaying ? Icons.play_arrow : Icons.pause,
                      size: 30,
                    )),
                IconButton(
                    onPressed: () {
                      //静音
                      setState(() {
                        _isMute = !_isMute;
                      });
                    },
                    icon: Icon(
                      _isMute ? Icons.volume_off : Icons.volume_up,
                      size: 30,
                    )),
                TextButton(
                  onPressed: () {
                    //倍数
                    if (_speed == 8) {
                      _speed = 1;
                    } else {
                      _speed++;
                    }
                    setState(() {});
                  },
                  child: Text(
                    'x$_speed',
                    style: const TextStyle(color: Colors.white, fontSize: 30),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      //抓图
                    },
                    icon: const Icon(
                      Icons.local_see,
                      size: 30,
                    )),
                IconButton(
                    onPressed: () {
                      //录像
                    },
                    icon: const Icon(
                      Icons.switch_video,
                      size: 30,
                    )),
              ],
            ),
          ),
          Container(
            height: 100,
            color: Colors.yellow,
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Container(
                  height: 90,
                  width: 160,
                  color: Colors.blue,
                  child: const Center(
                    child: Icon(Icons.play_circle_outline_sharp),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  height: 90,
                  width: 160,
                  color: Colors.blue,
                  child: const Center(
                    child: Icon(Icons.play_circle_outline_sharp),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  height: 90,
                  width: 160,
                  color: Colors.blue,
                  child: const Center(
                    child: Icon(Icons.play_circle_outline_sharp),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  height: 90,
                  width: 160,
                  color: Colors.blue,
                  child: const Center(
                    child: Icon(Icons.play_circle_outline_sharp),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  height: 90,
                  width: 160,
                  color: Colors.blue,
                  child: const Center(
                    child: Icon(Icons.play_circle_outline_sharp),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const TimeSlider(),
          const SizedBox(
            height: 10,
          ),
          const VideoTypeSelector(),
          ElevatedButton(
              onPressed: () {
                ///处理点击事件
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const TimeViewPage();
                }));
              },
              child: const Text('时间线')),
        ],
      ),
    );
  }
}
