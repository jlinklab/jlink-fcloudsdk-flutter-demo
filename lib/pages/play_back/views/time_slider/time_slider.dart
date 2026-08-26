import 'package:flutter/material.dart';
import 'package:fcloudsdk_example/pages/play_back/views/time_slider/time_fragment.dart';

class TimeSlider extends StatefulWidget {
  const TimeSlider({Key? key}) : super(key: key);

  @override
  State<TimeSlider> createState() => _TimeSliderState();
}

class _TimeSliderState extends State<TimeSlider> {
  bool _isHours = true;

  _onChangeTimeType() {
    setState(() {
      _isHours = !_isHours;
    });

  }

  List<Widget> _timesBars(double width,double height) {
    final halfWidth = width/2;
    // const pHeight = 30.0;
    final pHeight = height;
    // final pHeight = 20.0;
    final header = Container(width: halfWidth,height: pHeight, color: Colors.yellow,);
    final footer = Container(width: halfWidth,height: pHeight, color: Colors.yellow,);

    List<String> times;
    if (_isHours) {
      times = _dataFromHourtimes();
    } else {
      times = _dataFromMinitetimes();
    }

    List<Widget> timeFragments = [header];
    for(int i=0;i<times.length;i++){
      final timeFragment = TimeFragment(timeFragmentType:_isHours ? TimeFragmentType.hours : TimeFragmentType.minite, time: times[i]);
      timeFragments.add(timeFragment);
    }
    timeFragments.add(footer);
    return timeFragments;
  }

  _timeFromDuration(Duration duration){
    List<String> parts = duration.toString().split(':');
    String hour = parts[0];
    String minite = parts[1];
    hour = hour.length < 2 ? '0$hour' : hour;
    minite = minite.length < 2 ? '0$minite' : minite;
    return '$hour:$minite';
  }

  _dataFromMinitetimes() {
    List<String> timesString = [];
    int minite = 0;
    int maxMinite = 60 * 24;
    while (minite < maxMinite) {
      var d = Duration(minutes: minite);
      timesString.add(_timeFromDuration(d));
      minite += 10;
    }
    return timesString;
  }

  _dataFromHourtimes() {
    List<String> timesString = [];
    int hour = 0;
    int maxhour = 24;
    while (hour < maxhour) {
      var d = Duration(hours: hour);
      timesString.add(_timeFromDuration(d));
      hour++;
    }
    return timesString;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 120,
        color: Colors.grey,
        child: Column(
          children: [
            SizedBox(
              height: 30,
              // color: Colors.red,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100,
                  ),
                  const Text(
                    '00:07:34',
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue,width: 2),
                        color: Colors.amber,
                        borderRadius: const BorderRadius.all(Radius.circular(5))
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          color: _isHours ? Colors.blue : Colors.grey,
                          child: GestureDetector(
                            onTap: () {
                              if (_isHours == false) {
                                _onChangeTimeType();
                              }
                            },
                            child: const Center(
                              child: Text(
                                '小时',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 48,
                          color: _isHours ? Colors.grey : Colors.blue,
                          child: GestureDetector(
                            onTap: () {
                              if (_isHours) {
                                _onChangeTimeType();
                              }
                            },
                            child: const Center(
                              child: Text(
                                '分钟',
                                style: TextStyle(color: Colors.white,fontSize: 15),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 90,
              color: Colors.green,
              child: Stack(
                children: [
                  Container(
                    color: Colors.green,
                    child: LayoutBuilder(builder: (BuildContext context , BoxConstraints boxConstraints) {

                      final width = boxConstraints.maxWidth;
                      final height = boxConstraints.maxHeight;
                      return ListView(
                        physics: const ClampingScrollPhysics(),//取消回弹效果
                        scrollDirection: Axis.horizontal,
                        children: _timesBars(width,height),
                      );
                    },
                    ),
                  ),
                  //中间的那根线
                  Center(
                    child: Container(height: 90,width: 2,color: Colors.red,),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
