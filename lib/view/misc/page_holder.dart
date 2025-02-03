import 'package:flutter/material.dart';
import 'package:portal/model/inbox_model.dart';
import 'package:portal/model/page_model.dart';

import 'package:portal/view/chat/inbox_page.dart';
import 'package:portal/view/chat/message_page.dart';
import 'package:portal/view/portal/portal_page.dart';
import 'package:provider/provider.dart';

import 'package:portal/model/user_model.dart';

class PageHolder extends StatefulWidget {
  const PageHolder({
    super.key,
  });

  @override
  State<PageHolder> createState() => _PageHolderState();
}

class _PageHolderState extends State<PageHolder> {

  static final List<Widget> _pages = [
    MessagePage(), // hidden page
    InboxPage(),
    PortalPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PageModel(pages: _pages)),
        ChangeNotifierProvider(create: (context) => InboxModel(context.read<UserModel>().currentUser)),
      ],
      builder: (BuildContext context, Widget? child) {
        return Consumer<PageModel>(
          builder: (context, pageModel, child) {
            return Scaffold(
              body: PageView(
                controller: pageModel.controller,
                onPageChanged: (index) => setState(() => pageModel.selectedIndex = index),
                hitTestBehavior: HitTestBehavior.translucent,
                children: _pages,
              ),
              bottomNavigationBar: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat),
                    label: 'Chat',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people),
                    label: 'Portal',
                  ),
                ],
                currentIndex: pageModel.selectedIndex > 1 ? 1 : 0,
                onTap: (index) {
                  setState(() {
                    pageModel.setPage(index + 1);
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}
