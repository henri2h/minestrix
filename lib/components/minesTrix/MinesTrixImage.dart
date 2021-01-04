import 'package:cached_network_image/cached_network_image.dart';
import 'package:famedlysdk/famedlysdk.dart';
import 'package:flutter/material.dart';
import 'package:minestrix/global/smatrixWidget.dart';
import 'package:minestrix/global/smatrix.dart';

class MinesTrixImage extends StatelessWidget {
  MinesTrixImage(
      {Key key,
      @required this.url,
      this.width,
      this.height,
      this.isCircle = true})
      : super(key: key);
  final Uri url;
  final double width;
  final double height;
  final bool isCircle;
  @override
  Widget build(BuildContext context) {
    SClient sclient = Matrix.of(context).sclient;
    if (url == null)
      return Container(
          height: height != null ? height : 30,
          width: width != null ? width : 30,
          decoration: isCircle
              ? BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                )
              : null,
          child: Icon(Icons.image));
    return CachedNetworkImage(
      imageUrl: url.getDownloadLink(
        sclient,
      ),
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          CircularProgressIndicator(value: downloadProgress.progress),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}