
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/all_item_controller.dart';
class SearchWidget extends ConsumerStatefulWidget{
  const SearchWidget(this.onPressed,this.onChanged, this.label, {required this.searchController,super.key});
  final TextEditingController searchController;
  final  VoidCallback onPressed;
  final  ValueChanged<String?> onChanged;
  final String? label;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _SearchWidget();
  }



}

class _SearchWidget extends ConsumerState<SearchWidget> {
   _SearchWidget();

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      controller: widget.searchController,
      style: const TextStyle(color: Colors.black, fontSize: 18),
      cursorColor: Colors.blueAccent,
      decoration: InputDecoration(
        hintText: widget.label,
        hintStyle: const TextStyle(color: Colors.grey),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Text alignment

        suffixIcon: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: widget.onPressed,
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}