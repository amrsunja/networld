import 'package:flutter/material.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';

import 'infinity_data_scroll.dart';

class InfinityListView extends StatefulWidget {
  const InfinityListView({
    super.key,
    this.scrollController,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = true,
    this.canLoadMoreData = false,
    this.doNotRefresh = false,
    this.physics,
    this.padding,
    this.cacheExtent = 250.0, // Default cache extent
    this.preloadDistance = 3, // How many items to preload ahead
    required this.itemCount,
    required this.onRefresh,
    required this.onScrollEnd,
    required this.itemBuilder,
    this.onItemPreload, // Optional callback for preloading
  });

  final ScrollController? scrollController;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final bool canLoadMoreData;
  final bool doNotRefresh;
  final ScrollPhysics? physics;
  final int itemCount;
  final EdgeInsets? padding;
  final double cacheExtent;
  final int preloadDistance;
  final VoidCallback onScrollEnd;
  final Future<void> Function() onRefresh;
  final Widget? Function(BuildContext context, int ind) itemBuilder;
  final Function(int index)? onItemPreload;

  @override
  State<InfinityListView> createState() => _InfinityListViewState();
}

class _InfinityListViewState extends State<InfinityListView> {
  late final ScrollController scrollController;
  final Set<int> _preloadedIndices = <int>{};
  final Map<int, Widget> _widgetCache = <int, Widget>{};
  int _lastVisibleIndex = 0;

  @override
  void initState() {
    super.initState();
    scrollController = widget.scrollController ?? ScrollController();
    _setupScrollListener();
    
    // Preload initial items
    _preloadInitialItems();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      scrollController.dispose();
    }
    super.dispose();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      _handleScroll();
    });
  }

  void _preloadInitialItems() {
    // Preload first few items on initialization
    for (int i = 0; i < widget.preloadDistance && i < widget.itemCount; i++) {
      _preloadItem(i);
    }
  }

  void _handleScroll() {
    if (!scrollController.hasClients) return;
    if(!mounted) return;
    
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final double viewportHeight = renderBox.size.height;
    final double scrollOffset = scrollController.offset;
    final double itemHeight = _estimateItemHeight();

    // Calculate visible range
    final int firstVisibleIndex = (scrollOffset / itemHeight).floor().clamp(0, widget.itemCount - 1);
    final int lastVisibleIndex = ((scrollOffset + viewportHeight) / itemHeight).ceil().clamp(0, widget.itemCount - 1);

    _lastVisibleIndex = lastVisibleIndex;

    // Preload items ahead of visible range
    final int preloadStart = (lastVisibleIndex + 1).clamp(0, widget.itemCount - 1);
    final int preloadEnd = (preloadStart + widget.preloadDistance).clamp(0, widget.itemCount - 1);

    for (int i = preloadStart; i <= preloadEnd; i++) {
      _preloadItem(i);
    }

    // Clean up cache for items that are far behind
    _cleanupDistantCache(firstVisibleIndex);
  }

  double _estimateItemHeight() {
    // Estimate item height based on context
    // You can make this more sophisticated based on your use case
    if (widget.scrollDirection == Axis.vertical) {
      return 100.0; // Adjust this based on your typical item height
    } else {
      return 150.0; // Adjust for horizontal items
    }
  }

  void _preloadItem(int index) {
    if (_preloadedIndices.contains(index) || index >= widget.itemCount) return;

    _preloadedIndices.add(index);
    
    // Call preload callback if provided
    widget.onItemPreload?.call(index);
    
    // Pre-build and cache the widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final widget = this.widget.itemBuilder(context, index);
        if (widget != null) {
          _widgetCache[index] = widget;
        }
      }
    });
  }

  void _cleanupDistantCache(int currentFirstVisible) {
    // Remove cached widgets that are far behind current position
    final int cleanupThreshold = widget.preloadDistance * 2;
    final List<int> indicesToRemove = [];

    for (final int index in _widgetCache.keys) {
      if (index < currentFirstVisible - cleanupThreshold) {
        indicesToRemove.add(index);
      }
    }

    for (final int index in indicesToRemove) {
      _widgetCache.remove(index);
      _preloadedIndices.remove(index);
    }
  }

  Widget _buildCachedItem(BuildContext context, int index) {
    // Return cached widget if available, otherwise build new one
    if (_widgetCache.containsKey(index)) {
      return _widgetCache[index]!;
    }

    final widget = this.widget.itemBuilder(context, index);
    if (widget != null) {
      _widgetCache[index] = widget;
    }
    return widget ?? const SizedBox.shrink();
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: widget.padding,
      controller: scrollController,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      cacheExtent: widget.cacheExtent, // Extended cache extent
      itemCount: widget.canLoadMoreData ? widget.itemCount + 1 : widget.itemCount,
      itemBuilder: (context, index) {
        if (widget.canLoadMoreData && index == widget.itemCount) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: UICircularProgressBar(),
            ),
          );
        }

        // Trigger preload for upcoming items
        if (index > _lastVisibleIndex - widget.preloadDistance) {
          _preloadItem(index + widget.preloadDistance);
        }

        return _buildCachedItem(context, index);
      },
    );
  }

  Widget _build() {
    return InfinityDataScrollWidget(
      scrollController: scrollController,
      scrollDirection: widget.scrollDirection,
      onScrollEnd: widget.onScrollEnd,
      child: _buildListView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.doNotRefresh
        ? _build()
        : RefreshIndicator(
            color: UIColorsToken.pri350,
            backgroundColor: UIColorsToken.black,
            onRefresh: widget.onRefresh,
            child: _build(),
          );
  }
}

// Extension for better cache management
extension InfinityListViewExtension on InfinityListView {
  // Factory constructor for high-performance lists
  static InfinityListView highPerformance({
    Key? key,
    ScrollController? scrollController,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = true,
    bool canLoadMoreData = false,
    bool doNotRefresh = false,
    ScrollPhysics? physics,
    EdgeInsets? padding,
    required int itemCount,
    required Future<void> Function() onRefresh,
    required VoidCallback onScrollEnd,
    required Widget? Function(BuildContext context, int ind) itemBuilder,
    Function(int index)? onItemPreload,
  }) {
    return InfinityListView(
      key: key,
      scrollController: scrollController,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      canLoadMoreData: canLoadMoreData,
      doNotRefresh: doNotRefresh,
      physics: physics,
      padding: padding,
      cacheExtent: 500.0, // Extended cache for better performance
      preloadDistance: 5, // Preload 5 items ahead
      itemCount: itemCount,
      onRefresh: onRefresh,
      onScrollEnd: onScrollEnd,
      itemBuilder: itemBuilder,
      onItemPreload: onItemPreload,
    );
  }
}
