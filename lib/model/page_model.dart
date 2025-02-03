import 'package:flutter/material.dart';

class PageModel extends ChangeNotifier {
  PageModel({required this.pages});

  final controller = PageController(initialPage: 1);
  final List<Widget> pages;
  int selectedIndex = 1;

  void setPage(int index) {
    if (index >= pages.length) {
      index = pages.length - 1;
    } else if (index < 0) {
      index = 0;
    }
    selectedIndex = index;
    controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutQuint,
    );
  }
}