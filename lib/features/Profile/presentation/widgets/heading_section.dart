import 'package:flutter/material.dart';

class HeadingSection extends StatelessWidget {

  final String heading;  const HeadingSection({super.key, required this.heading, required this.buttonName,});

  final String buttonName;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:const  EdgeInsets.only(top: 8,left: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(heading,style:  TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700]!,)),
          Text(buttonName,style: Theme.of(context).textTheme.titleMedium,),

        ],
      ),
    );
  }
}
