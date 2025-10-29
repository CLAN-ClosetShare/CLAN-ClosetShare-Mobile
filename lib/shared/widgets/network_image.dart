import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Shared network image widget that protects against empty/invalid URLs.
///
/// Usage: SharedNetworkImage(imageUrl: someUrl, width: ..., height: ..., fit: BoxFit.cover)
class SharedNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SharedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();

    final placeholderWidget =
        placeholder ??
        Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image),
        );

    final errorWidgetFinal =
        errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image),
        );

    if (url == null || url.isEmpty) {
      return placeholderWidget;
    }

    // Local file path (may be stored as file://... or absolute path)
    if (url.startsWith('file://')) {
      try {
        return Image.file(
          File(url.substring(7)),
          width: width,
          height: height,
          fit: fit,
        );
      } catch (_) {
        return errorWidgetFinal;
      }
    }

    // If it's an absolute local path without file://
    if (!url.startsWith('http')) {
      try {
        return Image.file(File(url), width: width, height: height, fit: fit);
      } catch (_) {
        // fallthrough to network
      }
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (c, u) => placeholderWidget,
      errorWidget: (c, u, e) => errorWidgetFinal,
    );
  }
}
