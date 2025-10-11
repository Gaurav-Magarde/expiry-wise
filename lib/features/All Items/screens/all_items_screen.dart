import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AllItemsScreen extends StatelessWidget {
  const AllItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.send),
        titleSpacing: 0,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.black),
        backgroundColor: Colors.transparent,

        title: Text("All Items"),
      ),
      body: Center(child: Text("All Items"),),
    );
  }
}
