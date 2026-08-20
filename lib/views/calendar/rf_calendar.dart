import 'package:flutter/material.dart';
import 'package:fcloudsdk_example/views/calendar/rf_calendar_month_view.dart';

showRFCalendar(
    {required BuildContext context,
    required DateTime beginDatetime,
    required DateTime endDatetime,
    required Map<DateTime, int> hasDataDateMap, //有数据的日期map
    required DateTime selectedDate, //选中的日期
    required Function(DateTime selectedDateTime) onSelected,
    Function(DateTime currentMonth,
            Function(Map<DateTime, int> pHasDataDateMap) onCallBack)?
        onChangeMonth}) {
  assert(
      !beginDatetime.isAfter(endDatetime), 'beginDatetime 不能在 endDatetime 后面');

  Widget dialog = RFCalendar(
    beginDatetime: beginDatetime,
    endDatetime: endDatetime,
    hasDataDateMap: hasDataDateMap,
    selectedDate: selectedDate,
    onSelected: (DateTime selectedDateTime) {
      onSelected(selectedDateTime);
    },
    onChangeMonth: onChangeMonth,
  );

  showDialog(
      useSafeArea: false,
      context: context,
      builder: (BuildContext context) {
        return dialog;
      });
}

// ignore: must_be_immutable
class RFCalendar extends StatefulWidget {
  final DateTime beginDatetime;
  final DateTime endDatetime;
  final Map<DateTime, int> hasDataDateMap; //有数据的日期map
  final DateTime selectedDate; //选中的日期
  final Function(DateTime selectedDateTime) onSelected;
  Function(DateTime currentMonth,
      Function(Map<DateTime, int> pHasDataDateMap) onCallBack)? onChangeMonth;
  RFCalendar(
      {super.key,
      required this.beginDatetime,
      required this.endDatetime,
      required this.hasDataDateMap,
      required this.selectedDate,
      required this.onSelected,
      this.onChangeMonth})
      : assert(!beginDatetime.isAfter(endDatetime),
            'beginDatetime 不能在 endDatetime 后面');

  @override
  State<RFCalendar> createState() => _RFCalendarState();
}

class _RFCalendarState extends State<RFCalendar> {
  PageController _pageController = PageController();
  Map<DateTime, int> _hasDataDateMap = {};
  List<DateTime> _monthList = [];
  int _currentIndex = 0;

  @override
  void initState() {
    _hasDataDateMap = widget.hasDataDateMap;
    _monthList = _monthsBetween(widget.beginDatetime, widget.endDatetime);
    //找到当前需要展示的页面
    int initialPage = 0;
    for (int i = 0; i < _monthList.length; i++) {
      DateTime date = _monthList[i];
      if (date.year == widget.selectedDate.year &&
          date.month == widget.selectedDate.month) {
        initialPage = i;
        break;
      }
    }
    _currentIndex = initialPage;
    _pageController = PageController(initialPage: initialPage);
    Future.delayed(Duration.zero, () {
      _onChangeMonth();
    });
    super.initState();
  }

  _onChangeMonth() async {
    DateTime currentDateMonth = _monthList[_currentIndex];
    if (widget.onChangeMonth != null) {
      widget.onChangeMonth!(currentDateMonth,
          (Map<DateTime, int> pHasDataDateMap) {
        if (!mounted) {
          return;
        }
        setState(() {
          _hasDataDateMap = pHasDataDateMap;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentDateMonth = _monthList[_currentIndex];
    String dateStr = currentDateMonth.toString(); //2022-01-06 14:15:16.789
    dateStr = dateStr.split(' ')[0].substring(0, 7); //2022-01-06

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  onPressed: () {
                    if (_currentIndex == 0) {
                      return;
                    }
                    _currentIndex--;
                    _pageController.jumpToPage(_currentIndex);
                    _onChangeMonth();
                    setState(() {});
                  },
                  icon: _currentIndex == 0
                      ? const SizedBox()
                      : const Icon(Icons.chevron_left)),
              Text(
                dateStr,
                style: const TextStyle(fontSize: 25),
              ),
              IconButton(
                  onPressed: () {
                    if (_currentIndex == _monthList.length - 1) {
                      return;
                    }
                    _currentIndex++;
                    _pageController.jumpToPage(_currentIndex);
                    _onChangeMonth();
                    setState(() {});
                  },
                  icon: _currentIndex == _monthList.length - 1
                      ? const SizedBox()
                      : const Icon(Icons.chevron_right)),
            ],
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemBuilder: _builderMonthItems,
              onPageChanged: (int page) {
                _currentIndex = page;
                _onChangeMonth();
                setState(() {});
              },
              itemCount: _monthList.length,
              allowImplicitScrolling: true,
            ),
          ),
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              const Text('有数据: '),
              Container(
                height: 8,
                width: 8,
                decoration: const BoxDecoration(
                  color: calendarColorHasDataDay,
                  shape: BoxShape.circle, // 将Container形状设置为圆形
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              const Text('当天: '),
              Container(
                height: 30,
                width: 30,
                decoration: const BoxDecoration(
                  color: calendarCColorIsToday,
                  shape: BoxShape.circle, // 将Container形状设置为圆形
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              const Text('选中: '),
              Container(
                height: 30,
                width: 30,
                decoration: const BoxDecoration(
                  color: calendarColorSelectedDay,
                  shape: BoxShape.circle, // 将Container形状设置为圆形
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
              child: const Center(
                child: Text(
                  '取消',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom,
          ),
        ],
      ),
    );
  }

  Widget _builderMonthItems(BuildContext context, int index) {
    final DateTime monthDate = _monthList[index];
    return RFCalendarMonthView(
      beginDatetime: widget.beginDatetime,
      endDatetime: widget.endDatetime,
      monthDate: monthDate,
      hasDataDateMap: _hasDataDateMap,
      selectedDate: widget.selectedDate,
      onSelected: (DateTime selectedDateTime) {
        Navigator.of(context).pop();
        widget.onSelected(selectedDateTime);
      },
    );
  }

  //计算开始日期和结束日期间的月份数组
  List<DateTime> _monthsBetween(DateTime startDate, DateTime endDate) {
    final startYear = startDate.year;
    final startMonth = startDate.month;
    final endYear = endDate.year;
    final endMonth = endDate.month;
    final totalMonths =
        (endYear - startYear) * 12 + (endMonth - startMonth) + 1;
    final result = <DateTime>[]; // 初始化结果为一个空列表

    for (var i = 0; i < totalMonths; i++) {
      final year = startYear + ((startMonth + i - 1) ~/ 12);
      final month = ((startMonth + i - 1) % 12) + 1;
      result.add(DateTime(year, month, 1));
    }
    return result;
  }
}
