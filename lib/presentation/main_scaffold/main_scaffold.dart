import 'package:flutter/material.dart';
import 'package:messenger/presentation/chat_list/chat_list_screen.dart';
import 'package:messenger/presentation/settings/settings_screen.dart';

class MainScaffold extends StatefulWidget {
  final int? currentIndex;
  const MainScaffold({super.key, required this.currentIndex});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex ?? 0; // chatlist if not specified
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // slide to the screen after changing the index
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 550),
      curve: Curves.easeOutQuart,
    );
  }

  final List<Widget> _screens = [
    KeepAlive(keepAlive: true, child: const ChatListScreen()),
    KeepAlive(keepAlive: true, child: const SettingsScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => _onTabTapped(index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
