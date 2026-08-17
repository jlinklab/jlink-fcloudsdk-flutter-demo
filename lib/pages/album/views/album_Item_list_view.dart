// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/album/models/album_model.dart';
import 'package:fcloudsdk_example/pages/album/views/album_item_view.dart';

class AlbumItemListView extends StatefulWidget {
  final bool isEditting;
  final List<List<Album>> dataList;
  const AlbumItemListView({
    Key? key,
    required this.dataList,
    required this.isEditting,
  }) : super(key: key);

  @override
  State<AlbumItemListView> createState() => _AlbumItemListViewState();
}

class _AlbumItemListViewState extends State<AlbumItemListView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.dataList.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.hourglass_empty,
                  size: 40,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  TR.current.nothing,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                )
              ],
            ),
          )
        : ListView.builder(
            itemBuilder: (context, index) {
              List subList = widget.dataList[index];
              String time = '';
              if (subList.isNotEmpty) {
                Album album = subList[0];
                time = album.date;
              }
              return Column(
                children: [
                  Container(
                    color: Colors.white,
                    height: 40,
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(time),
                  ),
                  GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 10 / 6,
                    mainAxisSpacing: 5.0, //item上下之间的间距
                    crossAxisSpacing: 5.0, //item左右之间的间距
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(subList.length, (i) {
                      return AlbumItemView(
                        album: subList[i],
                        isEditting: widget.isEditting,
                      );
                    }),
                  )
                ],
              );
            },
            itemCount: widget.dataList.length,
          );
  }
}
