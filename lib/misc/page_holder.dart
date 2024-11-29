import 'package:flutter/material.dart';

import '/chat/chats_page.dart';
import '/portal/portal_page.dart';

class PageHolder extends StatefulWidget {
  const PageHolder({
    super.key,
  });

  @override
  State<PageHolder> createState() => _PageHolderState();
}

class _PageHolderState extends State<PageHolder> {
  int _selectedIndex = 1;
  final _pageController = PageController(initialPage: 1);

  static const List<Widget> _pages = [
    PortalPage(),
    ChatsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    void setPage(int index) {
      if (index >= _pages.length) {
        index = _pages.length - 1;
      } else if (index < 0) {
        index = 0;
      }
      setState(() {
        _selectedIndex = index;
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutQuint,
        );
      });
    }

    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dx > 0) {
            setPage(_selectedIndex - 1);
          } else if (details.delta.dx < 0) {
            setPage(_selectedIndex + 1);
          }
        },
        child: Center(
          child: PageView(
            controller: _pageController,
            children: _pages,
            onPageChanged: (index) => setState(
              () => _selectedIndex = index,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Portal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: setPage,
      ),
    );
  }
}
