import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  const SettingTile({super.key, required this.icon, required this.title,required this.subTitle,  this.suffixWidget, this.onTap, this.iconColor, this.backgroundColor});

  final IconData icon;
  final Widget? suffixWidget;
  final Color? iconColor;
  final Color? backgroundColor;

  final String title;
  final String subTitle;
  final GestureTapCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
    padding:const  EdgeInsets.symmetric(horizontal: 0,vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: Row(
            children: [
              // Row(
              CircleAvatar(
                backgroundColor: backgroundColor,
                child: Icon(
                  icon,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12,)
              ,
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(title,style: Theme.of(context).textTheme.titleSmall!.apply(fontSizeDelta: 2),),
                          const SizedBox(),
                          Text(subTitle,style: Theme.of(context).textTheme.bodyMedium!.apply(),overflow: TextOverflow.ellipsis,),

                        ],
                      ),
                    ),
                ?suffixWidget,
                  ],
                ),
              ),

            ]
            ),
      ),
    );
  }
}
