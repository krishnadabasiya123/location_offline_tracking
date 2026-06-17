import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/location/service/shift_background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await configureShiftService();
  }
  runApp(await initializeApp());
}

// import 'package:flutter/material.dart';

// void main() => runApp(const MaterialApp(home: LeftToRightPagination()));

// class LeftToRightPagination extends StatefulWidget {
//   const LeftToRightPagination({super.key});
//   @override
//   State<LeftToRightPagination> createState() => _LeftToRightPaginationState();
// }

// class _LeftToRightPaginationState extends State<LeftToRightPagination> {
//   final List<String> _items = List.generate(12, (i) => 'Item ${i + 1}');
//   bool _isLoading = false;

//   Future<void> _loadMore() async {
//     if (_isLoading) return;
//     setState(() => _isLoading = true);
//     await Future.delayed(const Duration(seconds: 1)); // Simulate loading
//     setState(() {
//       _items.addAll(List.generate(10, (i) => 'Item ${_items.length + i + 1}'));
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Left to Right Staggered')),
//       body: NotificationListener<ScrollNotification>(
//         onNotification: (scroll) {
//           if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) _loadMore();
//           return true;
//         },
//         child: ListView.builder(
//           itemCount: _items.length + (_isLoading ? 1 : 0),
//           itemBuilder: (context, index) {
//             if (index == _items.length)
//               return const Center(
//                 child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
//               );

//             return StaggeredItem(index: index, title: _items[index]);
//           },
//         ),
//       ),
//     );
//   }
// }

// class StaggeredItem extends StatefulWidget {
//   const StaggeredItem({required this.index, required this.title, super.key});
//   final int index;
//   final String title;

//   @override
//   State<StaggeredItem> createState() => _StaggeredItemState();
// }

// class _StaggeredItemState extends State<StaggeredItem> {
//   bool _startAnim = false;

//   @override
//   void initState() {
//     super.initState();
//     // Delay each item by 100ms based on its position in the current "batch"
//     Future.delayed(Duration(milliseconds: (widget.index % 10) * 100), () {
//       if (mounted) setState(() => _startAnim = true);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedOpacity(
//       duration: const Duration(milliseconds: 500),
//       opacity: _startAnim ? 1.0 : 0.0,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeOutCubic,
//         // If _startAnim is false, move it 100 pixels to the LEFT (-100)
//         transform: Matrix4.translationValues(_startAnim ? 0 : -100, 0, 0),
//         child: Card(
//           margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//           child: ListTile(
//             leading: CircleAvatar(child: Text('${widget.index + 1}')),
//             title: Text(widget.title),
//           ),
//         ),
//       ),
//     );
//   }
// }
