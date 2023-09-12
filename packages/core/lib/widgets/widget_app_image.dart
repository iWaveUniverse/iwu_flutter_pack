import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart'; 

import '../setup/index.dart';
import 'widget_app_image_placeholder.dart';

class WidgetAppImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final double radius;
  final Widget? errorWidget;
  final Widget? placeholderWidget;
  final bool assetImage;
  final bool autoPrefix;
  final BoxFit boxFit;
  final Color? color;

  const WidgetAppImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.placeholderWidget,
    this.errorWidget,
    this.radius = 0,
    this.assetImage = false,
    this.autoPrefix = true,
    this.boxFit = BoxFit.cover,
    this.color,
  }) : super(key: key);

  bool get isUrlEmpty => (imageUrl ?? '').trim().isEmpty;

  Widget get error => errorWidget ?? const SizedBox();

  Widget get placeholder =>
      placeholderWidget ??
      WidgetAppImagePlaceHolder(
        width: width,
        height: height,
        borderRadius: radius == 0
            ? BorderRadius.zero
            : BorderRadius.all(
                Radius.circular(radius),
              ),
      );

  @override
  Widget build(BuildContext context) {
    if (isUrlEmpty) return SizedBox(width: width, height: height, child: error);
    String correctImage = imageUrl!;
    if (autoPrefix && !isUrlEmpty) {
      correctImage = appImageCorrectUrl(correctImage);
    }
    if (radius == 0) {
      return _buildImage(correctImage);
    } else {
      return ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          child: _buildImage(correctImage));
    }
  }

  Widget _buildImage(String correctImage) {
    ImageProvider provider = (assetImage
        ? AssetImage(imageUrl!)
        : CachedNetworkImageProvider(correctImage)) as ImageProvider;
    return OctoImage(
      color: color,
      image: provider,
      fit: boxFit,
      width: width,
      height: height,
      placeholderBuilder: (_) => placeholder,
      errorBuilder: (_, object, trace) => error,
    );
  }
}
