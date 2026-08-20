import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:fcloudsdk_example/pages/album/models/album_model.dart';
void showAlbumImageDetail(BuildContext context, Album album) {
  showDialog(
      useSafeArea: false,
      context: context, builder: (BuildContext context) {
    return PhotoView(
        onTapUp: (BuildContext context,
            TapUpDetails details,
            PhotoViewControllerValue controllerValue,
            ) {
          Navigator.of(context).pop();
        },
        imageProvider: FileImage(File(album.path)));
  });
}

void showAlbumImageDetail1(BuildContext context, Album album) {
  showDialog(
    useSafeArea: false,
      context: context, builder: (BuildContext context) {
    return ImageSacleView(imagePath: album.path,type: 0,);
  });
}


class ImageSacleView extends StatefulWidget {
  final String imagePath;
  final int type;//0 本地图片 1 网络图片
  const ImageSacleView({Key? key, required this.imagePath, required this.type}) : super(key: key);

  @override
  State<ImageSacleView> createState() => _ImageSacleViewState();
}

class _ImageSacleViewState extends State<ImageSacleView> {
  double _scale = 1.0; //初始化缩放比例
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () { Navigator.of(context).pop();},
      child: Container(
        color: Colors.white,
        child: GestureDetector(
          onScaleUpdate: (ScaleUpdateDetails scaleUpdateDetails) {
            setState(() {
              _scale = scaleUpdateDetails.scale;
            });
          },
          child: Center(
            child: Transform.scale(
              scale: _scale,
              child: widget.type == 0 ? Image(image: FileImage(File(widget.imagePath)),fit: BoxFit.fill) : Image.network(widget.imagePath,fit: BoxFit.fill),
            ),
          ),
        ),
      ),
    );
  }
}


