import 'package:flutter/material.dart';

class InfinityDataScrollWidget extends StatelessWidget {
  const InfinityDataScrollWidget({
    super.key,
    required this.scrollController,
		this.scrollDirection = Axis.vertical,
    required this.onScrollEnd,
    required this.child,
  });

  final ScrollController scrollController;
	/// This property need for correct calling of [onDataEnd] on specific scroll position depending on device height or device width
	final Axis scrollDirection;
  final VoidCallback onScrollEnd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
		final deviceSize = MediaQuery.of(context).size;
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
				// if scroll position is <= to devise (height, width) so call [onDataEnd] function
				final lessThan = scrollDirection == Axis.vertical ? deviceSize.height : deviceSize.width;
        if (notification is ScrollEndNotification && scrollController.position.extentAfter <= lessThan)
          onScrollEnd();
        return false;
      },
      child: child
    );
  }
}
