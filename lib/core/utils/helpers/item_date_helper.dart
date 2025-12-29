
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemUtils{

  static Color getColor(String itemDateString){

    final currentDate = DateUtils.dateOnly(DateTime.now());

    final itemDate = DateFormat('yyyy-MM-dd').tryParse(itemDateString);
    if(itemDate==null) return Colors.grey;
    final int days = itemDate.difference(currentDate).inDays;

    if (days < 0) {
      return Colors.red.shade900; // Expired
    }
    else if (days == 0) {
      return Colors.red.shade800; // Expiring Today (Critical)
    }
    else if (days <= 2) {
      return Colors.red.shade600; // 1-2 Days (Urgent)
    }
    else if (days <= 5) {
      return Colors.deepOrange.shade600; // 3-5 Days (Warning)
    }
    else if (days <= 10) {
      return Colors.orange.shade800; // 6-10 Days (Attention)
    }
    else if (days <= 15) {
      return Colors.amber.shade800; // 11-15 Days (Caution - Readable Yellow)
    }
    else if (days <= 30) {
      return Colors.lime.shade800; // 15-30 Days (Good - Dark Lime)
    }
    else if (days <= 60) {
      return Colors.lightGreen.shade700; // 1-2 Months (Safe)
    }
    else {
      return Colors.green.shade800; // 2+ Months (Excellent)
    }

  }

  static String getExpiryTime(String itemDateString){
    if(itemDateString.length<2) return "no date found";

    final currentDate = DateUtils.dateOnly(DateTime.now());

    final itemDate = DateFormat('yyyy-MM-dd').tryParse(itemDateString);
    if(itemDate==null) return 'no expiry found';
    final int days = currentDate.difference(itemDate).inDays;

   if(days == 1){
      return "Expired yesterday";

    }else if(days<=45 && days >0){
      return "Expired ${days.abs()} days ago";

    }else if(days<=60 && days >0){
      int weeks = (days/7).round();
      return "Expired ${weeks.abs()} weeks ago";

    }else if(days>60){
      int months = (days/30).round();
      return "Expired ${months.abs()} months ago";
    }


     if(days == 0){
      return "Expires today";

    }else if(days == 1){
      return "Expiring tomorrow";

    }else if(days<=45){
      return "Expiring in ${days.abs()} days";

    }else if(days<=60){
       int weeks = (days/7).round();
      return "Expiring in ${weeks.abs()} weeks";

    }else{
       int months = (days/30).round();
       return "Expiring in ${months.abs()} months";
    }

  }


  static String getAddedTime(String itemDateString){
    print('added => $itemDateString');
    if(itemDateString.length<2) return "no date found";
    final currentDate = DateUtils.dateOnly(DateTime.now());

    final itemDate = DateFormat('yyyy-MM-dd').tryParse(itemDateString);
    if(itemDate==null) return '';
    final int days = currentDate.difference(itemDate).inDays;

    if(days == 0) {
      return "Added today";
    }else if(days == 1){
      return "Added yesterday";

    }else if(days<=45 && days >0){
      return "Added $days days ago";

    }else if(days<=60 && days >0){
      int weeks = (days/7).round();
      return "Added $weeks weeks ago";

    }else if(days>60){
      int months = (days/30).round();
      return "Added $months months ago";
    }
    return "no date found";

  }
  
  static double widthFactor(String date){
    final now = DateTime.now();
    final exp = DateTime.parse(date);
    if(exp.isBefore(now.subtract(Duration(days: 1)))) return 0;
    if(exp.isAfter(now.add(Duration(days: 28)))) return 0.05;
    final diff = exp.difference(now.subtract(Duration(days: 1)));
    return 1 - diff.inDays / 30;
  }

  static Icon getExpiryIcon(String expiryDateString) {
    // 1. Basic Check
    if (expiryDateString.length < 2) {
      return const Icon(Icons.help_outline_rounded, color: Colors.grey);
    }

    // 2. Dates Setup
    final currentDate = DateUtils.dateOnly(DateTime.now());
    final expiryDate = DateFormat('yyyy-MM-dd').tryParse(expiryDateString);

    if (expiryDate == null) {
      return const Icon(Icons.help_outline_rounded, color: Colors.grey);
    }

    // 3. Calculate Difference
    final int daysLeft = expiryDate.difference(currentDate).inDays;

    // 4. Icon Logic
    if (daysLeft < 0) {

      return const Icon(Icons.error_outline_rounded, color: Colors.red);

    } else if (daysLeft <= 4) {

      return const Icon(Icons.warning_amber_rounded, color: Colors.orange);

    } else {

      return const Icon(Icons.check_circle_outline_rounded, color: Colors.green);
    }
  }

  static Color getBackgroundColor(String itemDateString){

    final currentDate = DateUtils.dateOnly(DateTime.now());

    final itemDate = DateFormat('yyyy-MM-dd').tryParse(itemDateString);
    // Agar date invalid hai to light grey background
    if(itemDate==null) return Colors.grey.shade200;

    final int days = itemDate.difference(currentDate).inDays;

    if (days < 0) {
      return Colors.red.shade100; // Expired (Light Red background)
    }
    else if (days == 0) {
      return Colors.red.shade100; // Expiring Today (Critical)
    }
    else if (days <= 2) {
      return Colors.red.shade50; // 1-2 Days (Very Light Red)
    }
    else if (days <= 5) {
      return Colors.deepOrange.shade50; // 3-5 Days (Light Deep Orange)
    }
    else if (days <= 10) {
      return Colors.orange.shade50; // 6-10 Days (Light Orange)
    }
    else if (days <= 15) {
      return Colors.amber.shade100; // 11-15 Days (Light Amber)
    }
    else if (days <= 30) {
      return Colors.lime.shade100; // 15-30 Days (Light Lime)
    }
    else if (days <= 60) {
      return Colors.lightGreen.shade100; // 1-2 Months (Light Green)
    }
    else {
      return Colors.green.shade50; // 2+ Months (Very Light Green)
    }

  }
}