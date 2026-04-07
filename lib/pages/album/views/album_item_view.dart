import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/pages/album/models/album_model.dart';
import 'package:xcloudsdk_flutter_example/pages/album/views/album_image_detail_view.dart';

class AlbumItemView extends StatefulWidget {
  final Album album;
  final bool isEditting;

  const AlbumItemView({
    Key? key,
    required this.album,
    required this.isEditting,
  }) : super(key: key);

  @override
  State<AlbumItemView> createState() => _AlbumItemViewState();
}

class _AlbumItemViewState extends State<AlbumItemView> {
  String? _thumbnailPath;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _load();
    });
  }

  _load() async {
    if (widget.album.type == '1') {
      try {
        _thumbnailPath = await VideoThumbnail.thumbnailFile(
            video: widget.album.path,
            imageFormat: ImageFormat.PNG,
            maxWidth: 128,
            quality: 25);

        //这里的生成的Path是这样的 //var/mobile/Containers/Data/Application/20E0CE6C-2DB2-4222-AC29-725131A1FDCF/Documents/jf_videos/jf_video%202023-05-25%2022_29_31%20631.png
        //后面会出现%20，其实是空格，可能VideoThumbnail内部替换掉了所以要处理下
        //将%20替换回空格
        if (_thumbnailPath != null && _thumbnailPath!.isNotEmpty) {
          setState(() {
            _thumbnailPath = _thumbnailPath!.split('%20').join(' ');
          });
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  _showImageDetail(BuildContext context) {
    if (widget.isEditting) {
      return;
    }
    showAlbumImageDetail(context, widget.album);
  }

  _playVideo(BuildContext context) {
    if (widget.isEditting) {
      return;
    }
    if (Platform.isAndroid) {
      OpenFile.open(widget.album.path);
      return;
    } else if (Platform.isIOS) {
      JFApi.xcVideoPlay.xcPlayNormalVideo(widget.album.path);
      return;
    } else {
      JFApi.xcVideoPlay.xcPlayLocalVideoOnOhos(widget.album.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ///展示图片
          if (widget.album.type == '0')
            Positioned.fill(
                child: Container(
                    color: Colors.grey,
                    child: GestureDetector(
                      onTap: () {
                        _showImageDetail(context);
                      },
                      child: Image(
                        image: FileImage(
                          File(widget.album.path),
                        ),
                        fit: BoxFit.fill,
                      ),
                    ))),

          ///展示视频缩略图
          if (widget.album.type == '1' &&
              _thumbnailPath != null &&
              _thumbnailPath!.isNotEmpty)
            Positioned.fill(
                child: Container(
                    color: Colors.grey,
                    child: GestureDetector(
                      onTap: () {
                        _playVideo(context);
                      },
                      child: Image(
                        image: FileImage(
                          File(_thumbnailPath!),
                        ),
                        fit: BoxFit.fill,
                      ),
                    ))),
          Positioned(
            left: 5,
            bottom: 5,
            child: Text(
              widget.album.time,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          if (widget.album.type == '1')
            GestureDetector(
              onTap: () {
                _playVideo(context);
              },
              child: const SizedBox(
                width: 45,
                height: 45,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(
                    Icons.play_circle_outline_sharp,
                    size: 100.0,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          if (widget.isEditting)
            Positioned(
              right: 5,
              top: 5,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    // _isSelect = !_isSelect;
                    widget.album.isSelected = !widget.album.isSelected;
                  });
                },
                child: SizedBox(
                  width: 25,
                  height: 25,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: widget.album.isSelected
                        ? const Icon(
                            Icons.check_circle,
                            size: 100.0,
                            color: Colors.blue,
                          )
                        : const Icon(
                            Icons.circle_outlined,
                            size: 100.0,
                            color: Colors.blue,
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
