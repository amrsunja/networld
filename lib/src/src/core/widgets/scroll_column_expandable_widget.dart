import 'package:flutter/material.dart';

class ScrollColumnExpandable extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final VerticalDirection verticalDirection;
  final TextDirection? textDirection;
  final TextBaseline? textBaseline;
  final EdgeInsetsGeometry padding;
	final ScrollController? scrollController;

  const ScrollColumnExpandable({
    super.key,
    required this.children,
    CrossAxisAlignment? crossAxisAlignment,
    MainAxisAlignment? mainAxisAlignment,
    VerticalDirection? verticalDirection,
    EdgeInsetsGeometry? padding,
    this.textDirection,
    this.textBaseline,
    this.scrollController,
  })  : crossAxisAlignment = crossAxisAlignment ?? CrossAxisAlignment.center,
        mainAxisAlignment = mainAxisAlignment ?? MainAxisAlignment.start,
        verticalDirection = verticalDirection ?? VerticalDirection.down,
        padding = padding ?? EdgeInsets.zero;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
				return SingleChildScrollView(
					controller: scrollController,
					physics: const BouncingScrollPhysics(parent: ClampingScrollPhysics()),
          child: Padding(
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraint.maxHeight - padding.vertical,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: crossAxisAlignment,
                  mainAxisAlignment: mainAxisAlignment,
                  mainAxisSize: MainAxisSize.min,
                  verticalDirection: verticalDirection,
                  textBaseline: textBaseline,
                  textDirection: textDirection,
                  children: children,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
