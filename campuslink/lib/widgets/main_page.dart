import 'package:campuslink/screens/dashboard/dashboard.dart';
import 'package:campuslink/screens/chatbot/chatbot.dart';
import 'package:campuslink/screens/chatroom/chatroom.dart';
import 'package:campuslink/screens/community_post/community_post.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavItem {
  final IconData icon;
  final String label;
  final Color activeColor;

  const NavItem({
    required this.icon,
    required this.label,
    this.activeColor = const Color(0xFFBB86FC),
  });
}

class MainPage extends StatefulWidget {
  final String userType;
  final String userId;

  const MainPage({Key? key, required this.userType, required this.userId}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  late List<NavItem> _navItems;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('userId');
      _initializeNavigation();
    });
  }

  void _initializeNavigation() {
    if (_username == null) return;

    final baseNavItems = <NavItem>[
      const NavItem(
        icon: Icons.dashboard_rounded,
        label: 'Dashboard',
        activeColor: Color(0xFFBB86FC),
      ),
      const NavItem(
        icon: Icons.group_rounded,
        label: 'Community',
        activeColor: Color(0xFF03DAC6),
      ),
    ];

    switch (widget.userType) {
      case 'Guest':
        _pages = [
          UserDashboard(userRole: widget.userType, userId: widget.userId),
          CommunityPost(username: _username!),
          Chatbot(),
        ];
        _navItems = [
          ...baseNavItems,
          const NavItem(
            icon: Icons.smart_toy,
            label: 'Chatbot',
            activeColor: Color(0xFFCF6679),
          ),
        ];
        break;
      case 'Admin':
      case 'Student':
      case 'Teacher':
        _pages = [
          UserDashboard(userRole: widget.userType, userId: widget.userId),
          CommunityPost(username: _username!),
          Chatroom(),
          Chatbot(),
        ];
        _navItems = [
          ...baseNavItems,
          const NavItem(
            icon: Icons.chat_rounded,
            label: 'Chatroom',
            activeColor: Color(0xFF03DAC6),
          ),
          const NavItem(
            icon: Icons.smart_toy,
            label: 'Chatbot',
            activeColor: Color(0xFFCF6679),
          ),
        ];
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_username == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          _pages[_currentIndex],
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 0, 3, 95), Color.fromARGB(255, 35, 0, 74)], // Updated gradient colors
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  _navItems.length,
                  (index) => _buildNavItem(_navItems[index], index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(NavItem item, int index) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16.0 : 12.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? item.activeColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected ? const Color.fromARGB(255, 255, 255, 255) : Colors.grey[400], // Updated icon color
              size: isSelected ? 28 : 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                item.label,
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255), // Updated text color
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}