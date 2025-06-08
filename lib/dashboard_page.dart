import 'package:flutter/material.dart';
import 'updates_page.dart';
import 'chats_tab.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 1;
  final String profileImage = '';
  final String myName = 'Me';

  static const List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('Chats')),
    // UpdatesPage will be injected with profileImage/myName in build
    SizedBox.shrink(),
    Center(child: Text('Communities')),
    Center(child: Text('Calls')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      ChatsTab(myName: myName),
      UpdatesPage(myProfileImage: profileImage, myName: myName),
      const Center(child: Text('Communities')),
      const Center(child: Text('Calls')),
    ];
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Updates'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Communities'),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Calls'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
