import 'package:flutter/material.dart';

class LazyLoadingGrid extends StatefulWidget {
  final List<Widget> children;
  final int itemsPerPage;
  final double spacing;
  final double runSpacing;

  const LazyLoadingGrid({
    required this.children,
    this.itemsPerPage = 12,
    this.spacing = 16,
    this.runSpacing = 16,
    super.key,
  });

  @override
  State<LazyLoadingGrid> createState() => _LazyLoadingGridState();
}

class _LazyLoadingGridState extends State<LazyLoadingGrid> {
  final ScrollController _scrollController = ScrollController();
  int _currentItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialItems();
    _scrollController.addListener(_onScroll);
  }

  void _loadInitialItems() {
    setState(() {
      _currentItemCount = widget.itemsPerPage.clamp(0, widget.children.length);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    if (_currentItemCount >= widget.children.length) return;

    setState(() {
      _currentItemCount += widget.itemsPerPage;
      if (_currentItemCount > widget.children.length) {
        _currentItemCount = widget.children.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Wrap(
        spacing: widget.spacing,
        runSpacing: widget.runSpacing,
        children: widget.children.take(_currentItemCount).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
