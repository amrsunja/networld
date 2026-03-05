import 'package:flutter/material.dart';

class UISpace extends StatelessWidget {
	final double? height;
	final double? width;

	const UISpace.horz(
		this.width, {
		super.key,
	}) : height = null;

	const UISpace.vert(
		this.height, {
		super.key,
	}) : width = null;

	const UISpace.zero({
		super.key,
	}) : height = null, width = null;

	@override
	Widget build(BuildContext context) {
		return SizedBox(height: height, width: width);
	}
}
