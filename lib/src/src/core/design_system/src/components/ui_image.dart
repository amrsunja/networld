// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app_ui.dart';

enum UIDataSourceFrom {network, local, asset, memory}

class UIImage extends StatelessWidget {
	/// [imageUrl] Network or local path to the image
	final String? image;
	final Uint8List? memoryImage;
	final BoxFit boxFit;
	final Widget? defaultImage;
	final UIDataSourceFrom source;

	const UIImage.network({
		super.key,
		this.image,
		this.memoryImage,
		this.defaultImage,
		this.boxFit = BoxFit.cover,
	}) : source = UIDataSourceFrom.network;

	const UIImage.local({
		super.key,
		this.image,
		this.memoryImage,
		this.defaultImage,
		this.boxFit = BoxFit.cover,
	}) : source = UIDataSourceFrom.local;

	const UIImage.asset({
		super.key,
		this.image,
		this.memoryImage,
		this.defaultImage,
		this.boxFit = BoxFit.cover,
	}) : source = UIDataSourceFrom.asset;

	const UIImage.memory({
		super.key,
		this.image,
		this.memoryImage,
		this.defaultImage,
		this.boxFit = BoxFit.cover,
	}) : source = UIDataSourceFrom.memory;

	@override
	Widget build(BuildContext context) {
		if ((image == null || image == '') && memoryImage == null)
			return _errorBuilder();

		return _imageBuilder();
	}

	Widget _errorBuilder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[400]!,
      highlightColor: Colors.grey[300]!,
      child: Container(
        decoration: BoxDecoration(
          color: UIColorsToken.neu50.withValues(alpha: 0.4),
        ),
      ),
    );
	}

	Widget _imageBuilder() {
		switch (source) {
			case UIDataSourceFrom.network:
				return CachedNetworkImage(
					fadeInDuration: const Duration(milliseconds: 500),
					imageUrl: image!,
					fit: boxFit,
					placeholder: (context, string) {
						return Shimmer.fromColors(
							baseColor: Colors.grey[400]!,
							highlightColor: Colors.grey[300]!,
							child: const DecoratedBox(
								decoration: BoxDecoration(
									color: UIColorsToken.pri100,
								),
							),
						);
					},
					errorWidget: (context, obj, stackTrace) => _errorBuilder(),
				);
			case UIDataSourceFrom.local:
				return Image.file(
					File(image!),
					fit: boxFit,
					errorBuilder: (context, obj, stackTrace) => _errorBuilder(),
				);
			case UIDataSourceFrom.asset:
				return Image.asset(
					image!,
					fit: boxFit,
					errorBuilder: (context, obj, stackTrace) => _errorBuilder(),
				);
			case UIDataSourceFrom.memory:
				return Image.memory(
					memoryImage!,
					fit: boxFit,
					errorBuilder: (context, obj, stackTrace) => _errorBuilder(),
				);
		}
	}
}
