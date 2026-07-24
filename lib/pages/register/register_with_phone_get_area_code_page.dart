import 'package:flutter/material.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/register/model/model.dart';
import 'package:xcloudsdk_flutter_example/pages/register/register_with_phone_page.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

// ignore: must_be_immutable
class RegisterWithPhoneGetAreaCodePage extends StatefulWidget {
  RegisterWithPhoneGetAreaCodePage({Key? key, required this.login})
      : super(key: key);

  bool login = false;

  @override
  State<RegisterWithPhoneGetAreaCodePage> createState() =>
      _RegisterWithPhoneGetAreaCodePageState();
}

class _RegisterWithPhoneGetAreaCodePageState
    extends State<RegisterWithPhoneGetAreaCodePage> {
  List<AreaCodeModel> _dataList = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      _onGetCodeList();
    });
    super.initState();
  }

  _onGetCodeList() {
    KToast.show();
    JFApi.xcAccount.xcGetAreaCode().then((value) {
      KToast.dismiss();
      setState(() {
        _dataList = value.map((e) => AreaCodeModel.fromJson(e)).toList();
      });
    }).catchError((error) {
      KToast.show(status: kErrorMsg(error));
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false); // 阻止右划返回手势
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(TR.current.areaCode),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                final model = _dataList[index];
                return GestureDetector(
                  onTap: () {
                    if (!widget.login) {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return RegisterWithPhonePage(model: model);
                      }));
                    } else {
                      Navigator.of(context).pop(model);
                    }
                  },
                  child: ListTile(
                    title: Text(model.country!),
                    subtitle: Text(model.head!),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  thickness: 1.0,
                );
              },
              itemCount: _dataList.length)),
    );
  }
}
