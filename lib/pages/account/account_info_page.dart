import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/models/user_instance.dart';
import 'package:xcloudsdk_flutter_example/pages/account/model/model.dart';
import 'package:xcloudsdk_flutter_example/pages/setting/setting_page.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({Key? key}) : super(key: key);

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  @override
  void initState() {
    context.read<UserInfo>().updateUserInfoDetail();
    super.initState();
  }

  List<List<String>> getDataList(User user) {
    Map dataMap = user.toJson();
    var dataList = <List<String>>[];

    dataMap.forEach((key, value) {
      if (key == 'authorizes') {
        Map subMap = value;
        subMap.forEach((pKey, pValue) {
          final item = <String>[];
          item.add(pKey.toString());
          item.add(pValue.toString());
          dataList.add(item);
        });
      } else {
        final item = <String>[];
        item.add(key.toString());
        item.add(value.toString());
        dataList.add(item);
      }
    });

    ///除去空的项目
    dataList = dataList.where((element) => element[1] != '').toList();
    return dataList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.info),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return const SettingPage();
                }));
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          Expanded(
            //使用Selector值监听 UserInfo 中的 userDetail 变量发生改变
            child: Selector<UserInfo, User>(
              selector: (_, userInfo) => userInfo.userDetail,
              builder: (_, user, __) {
                List<List<String>> dataList = getDataList(user);
                if (dataList.isEmpty) {
                  return const SizedBox();
                }
                return ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    final item = dataList[index];
                    return Container(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        height: 60,
                        child: InkWell(
                          onTap: () async {
                            if (item[0] == 'nickname') {
                              await JFApi.xcAccount
                                  .xcModifyAccountNickName(nickname: 'aaaaa');
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item[0],
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                ),
                              ),
                              Text(item[1]),
                              const Divider(
                                thickness: 1,
                                color: Colors.blueAccent,
                              ),
                            ],
                          ),
                        ));
                  },
                  itemCount: dataList.length,
                  // shrinkWrap: true,
                );
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              KToast.show();
              Future.delayed(const Duration(seconds: 1), () async {
                ///延迟2秒,模拟接口请求 后期可以删掉
                UserInfo.instance.quit(false).then((value) {
                  KToast.show(status: '已登出');
                });
              });
            },
            child: Container(
              height: 42.0,
              margin: const EdgeInsets.only(left: 15, right: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                TR.current.logout,
                style: const TextStyle(color: Colors.white, fontSize: 22.0),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom + 20,
          )
        ],
      ),
    );
  }
}
