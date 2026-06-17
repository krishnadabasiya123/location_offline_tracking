import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class PaginatedBlocListView<T> extends StatefulWidget {
  const PaginatedBlocListView({
    required this.items,
    required this.hasMore,
    required this.isLoading,
    required this.isInitialLoad,
    required this.onLoadMore,
    required this.itemBuilder,
    super.key,
    this.separatorBuilder,
    this.initialLoadingWidget = const Center(child: CustomCircularProgressIndicator()),
    this.bottomLoadingWidget = const Center(
      child: Padding(padding: EdgeInsets.all(16), child: CustomCircularProgressIndicator()),
    ),
    this.emptyWidget = const Center(child: Text('No items found.')),
    this.scrollController,
    this.padding,
    this.physics, // Let this be null by default
    this.shrinkWrap = false,
  });

  final List<T> items;
  final bool hasMore;
  final bool isLoading;
  final bool isInitialLoad;
  final VoidCallback onLoadMore;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final Widget initialLoadingWidget;
  final Widget bottomLoadingWidget;
  final Widget emptyWidget;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics; // This should be nullable
  final bool shrinkWrap;

  @override
  State<PaginatedBlocListView<T>> createState() => _PaginatedBlocListViewState<T>();
}

class _PaginatedBlocListViewState<T> extends State<PaginatedBlocListView<T>> {
  late ScrollController _scrollController;

  // A flag to track if the scroll was initiated by the user.
  final ValueNotifier<bool> _isUserScrolling = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  // This didUpdateWidget logic remains the same. It's a nice UX feature.
  @override
  void didUpdateWidget(PaginatedBlocListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isLoading && widget.isLoading && widget.items.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 20,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isInitialLoad) {
      return widget.initialLoadingWidget;
    }

    if (widget.items.isEmpty) {
      return widget.emptyWidget;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo is UserScrollNotification) {
          if (scrollInfo.direction != ScrollDirection.idle) {
            _isUserScrolling.value = true;
          }
        } else if (scrollInfo is ScrollEndNotification) {
          if (_isUserScrolling.value) {
            if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent) {
              if (widget.hasMore && !widget.isLoading) {
                widget.onLoadMore();
              }
            }
          }
          _isUserScrolling.value = false;
        }

        return false;
      },
      child: ListView.separated(
        physics: widget.physics,
        controller: _scrollController,
        padding: widget.padding ?? EdgeInsets.zero,
        shrinkWrap: widget.shrinkWrap,
        itemCount: widget.items.length + (widget.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= widget.items.length) {
            return widget.bottomLoadingWidget;
          }
          final item = widget.items[index];
          return widget.itemBuilder(context, item);
        },
        separatorBuilder: widget.separatorBuilder ?? (context, index) => const SizedBox.shrink(),
      ),
    );
  }
}
