// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/search_device/model/model.dart';

class SearchDevicePage extends StatefulWidget {
  const SearchDevicePage({Key? key}) : super(key: key);

  @override
  State<SearchDevicePage> createState() => _SearchDevicePageState();
}

class _SearchDevicePageState extends State<SearchDevicePage> {
  var _future;

  Future<List<SearchedDevice>> onFuture() async {
    final json = await JFApi.xcDevice.xcSearchDevices();
    List<SearchedDevice> searchedDevices =
        json.map((e) => SearchedDevice.fromJson(e)).toList();
    return searchedDevices;
  }

  @override
  void initState() {
    _future = onFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.lanSearch),
        centerTitle: true,
      ),
      body: FutureBuilder<List<SearchedDevice>>(
        future: _future,
        builder: (context, data) {
          if (data.hasError) {
            return Center(
              child: Text(data.error?.toString() ?? ''),
            );
          }
          if (!data.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (data.requireData.isEmpty) {
            return Center(
              child: Text(TR.current.noFound),
            );
          }

          List<SearchedDevice> devices = data.requireData;
          return ListView.separated(
            itemBuilder: (context, index) {
              SearchedDevice device = devices[index];
              return Container(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 5, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(device.deviceName ?? ''),
                        Text(device.sn ?? ''),
                        Text(
                            '${device.hostIP ?? ''}${device.httpPort != null ? ':${device.httpPort.toString()}' : ''}')
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(device);
                      },
                      child: const Icon(
                        Icons.add_rounded,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Container(
                height: 1,
                color: Colors.black12,
              );
            },
            itemCount: devices.length,
          );
        },
      ),
    );
  }
}
