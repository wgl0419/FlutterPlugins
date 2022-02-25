import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base_kit/utils/image_utils.dart';
import 'package:get/get.dart';

/// 图片加载（支持本地与网络图片）
///
/// [image] 图片本地路径/网络图片
/// [darkImage] 暗色模式图片
/// [width] 宽度
/// [height] 高度
class LoadImage extends StatelessWidget {
  const LoadImage(
    this.image, {
    this.darkImage,
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.format = ImageFormat.png,
    this.holderImg = 'common/placeholder',
    this.cacheWidth,
    this.cacheHeight,
  }) : super(key: key);

  final String image;
  final String? darkImage;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ImageFormat format;
  final String holderImg;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty || image.startsWith('http')) {
      final Widget _image =
          LoadAssetImage(holderImg, height: height, width: width, fit: fit);
      return CachedNetworkImage(
        imageUrl: Get.isDarkMode ? darkImage ?? image : image,
        placeholder: (_, __) => _image,
        errorWidget: (_, __, dynamic error) => _image,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
      );
    } else {
      return LoadAssetImage(
        image,
        darkImage: darkImage,
        height: height,
        width: width,
        fit: fit,
        format: format,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
      );
    }
  }
}

/// 加载本地资源图片
class LoadAssetImage extends StatelessWidget {
  const LoadAssetImage(this.image,
      {Key? key,
      this.width,
      this.height,
      this.cacheWidth,
      this.cacheHeight,
      this.fit,
      this.format = ImageFormat.png,
      this.color,
      this.darkImage})
      : super(key: key);

  final String image;
  final String? darkImage;
  final double? width;
  final double? height;
  final int? cacheWidth;
  final int? cacheHeight;
  final BoxFit? fit;
  final ImageFormat format;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      ImageUtils.getImgPath(Get.isDarkMode ? darkImage ?? image : image,
          format: format),
      height: height,
      width: width,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      fit: fit,
      color: color,

      /// 忽略图片语义
      excludeFromSemantics: true,
    );
  }
}
