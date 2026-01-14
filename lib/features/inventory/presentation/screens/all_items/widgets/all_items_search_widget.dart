
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/item_controller/all_item_controller.dart';
class SearchWidget extends ConsumerStatefulWidget{
  SearchWidget(this.controller, this.label, {super.key});
  final TextEditingController _searchController = TextEditingController();
  final controller;
  final label;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _SearchWidget();
  }



}

class _SearchWidget extends ConsumerState<SearchWidget> {
   _SearchWidget();
@override
  void dispose() {
    super.dispose();
    widget._searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      controller: widget._searchController,
      style: const TextStyle(color: Colors.black, fontSize: 18),
      cursorColor: Colors.blueAccent,
      decoration: InputDecoration(
        hintText: widget.label,
        hintStyle: const TextStyle(color: Colors.grey),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Text alignment

        suffixIcon: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () {
            widget._searchController.clear();
            widget.controller.state = "";
          },
        ),
      ),
      onChanged: (val) {
        widget.controller.state = val;
      },
    );
  }
}