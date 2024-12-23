import 'package:campuslink/screens/dashboard/attendance_report.dart';
import 'package:campuslink/screens/dashboard/event/event_detail_screen.dart';
import 'package:campuslink/screens/dashboard/event/event_list_screen.dart';
import 'package:campuslink/screens/dashboard/chatbot_manage.dart';
import 'package:campuslink/screens/dashboard/student_management_screen.dart';
import 'package:campuslink/screens/dashboard/teacher_management_screen.dart';
import 'package:flutter/material.dart';
import '../../widgets/profile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UserDashboard extends StatefulWidget {
  final String userId;
  final String userRole;
  
  const UserDashboard({
    Key? key,
    required this.userId,
    required this.userRole,
  }) : super(key: key);

  static final StreamController<void> eventUpdateController = StreamController<void>.broadcast();
  
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String eventTitle = 'Loading...';
  String? eventDate;
  late StreamSubscription eventUpdateSubscription;
  Map<String, dynamic> upcomingEvent = {};

  @override
  void initState() {
    super.initState();
    fetchUpcomingEvent();
    eventUpdateSubscription = UserDashboard.eventUpdateController.stream.listen((_) {
      fetchUpcomingEvent();
    });
  }

  @override
  void dispose() {
    eventUpdateSubscription.cancel();
    super.dispose();
  }

  Future<void> fetchUpcomingEvent() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.78/upcoming_event.php'));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          setState(() {
            eventTitle = 'No upcoming events';
            eventDate = null;
            upcomingEvent = {};
          });
          return;
        }

        final data = jsonDecode(response.body);
        setState(() {
          upcomingEvent = data;
          eventTitle = data['title'] ?? 'No title';
          eventDate = data['event_date'];
        });
      } else {
        setState(() {
          eventTitle = 'Error loading event';
          eventDate = null;
          upcomingEvent = {};
        });
      }
    } catch (e) {
      setState(() {
        eventTitle = 'Error loading event';
        eventDate = null;
        upcomingEvent = {};
      });
      print('Error: $e');
    }
  }


 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      drawer: _buildModernDrawer(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ).animate().fadeIn().scale(),
        ),
        title: Text(
          '${widget.userRole} Dashboard',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ).animate().fadeIn().slideX(),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => ProfilePage())
            ),
          ).animate().fadeIn().scale(),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6C63FF), Color(0xFF2C3E50)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section with animated gradient
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6C63FF).withOpacity(0.1),
                    const Color(0xFF2C3E50).withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back,',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ).animate().fadeIn().slideX(),
                  const SizedBox(height: 8),
                  Text(
                    widget.userId,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ).animate().fadeIn().slideX(delay: 200.ms),
                ],
              ),
            ),

            // Stats Section with animated cards
            if (widget.userRole.toLowerCase() == 'admin' || 
                widget.userRole.toLowerCase() == 'teacher')
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildAnimatedStatCard(
                        'Total Students',
                        '1,234',
                        Icons.school,
                        const Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (widget.userRole.toLowerCase() == 'admin')
                      Expanded(
                        child: _buildAnimatedStatCard(
                          'Total Teachers',
                          '89',
                          Icons.person,
                          const Color(0xFF00B4D8),
                        ),
                      ),
                  ],
                ),
              ),

            // Upcoming Events Section with glass effect
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildGlassEventCard(context),
            ),

            // Quick Actions Section with animated grid
            if (widget.userRole.toLowerCase() != 'guest')
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[300],
                      ),
                    ).animate().fadeIn().slideX(),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: _getQuickActionsByRole(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF1A1A1A),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6C63FF), Color(0xFF2C3E50)],
                ),
              ),
              child: Center(
                child: Text(
                  "${widget.userRole} Menu",
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', () => Navigator.pop(context)),
            _buildDrawerItem(Icons.info, 'About', () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    ).animate().fadeIn().slideX();
  }

  Widget _buildAnimatedStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
        
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 30),
              ).animate().fadeIn().scale(),
              const SizedBox(height: 15),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().slideX().fadeIn(),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ).animate().slideX(delay: 200.ms).fadeIn(),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildGlassEventCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event,
                color: Colors.white.withOpacity(0.9),
                size: 30,
              ),
              const SizedBox(width: 12),
              Text(
                'Upcoming Event',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn().slideX(),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            eventTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn().slideX(delay: 200.ms),
          const SizedBox(height: 12),
          if (eventDate != null)
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(eventDate!)),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ).animate().fadeIn().slideX(delay: 400.ms),
          if (widget.userRole.toLowerCase() != 'guest')
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailScreen(
                      eventId: upcomingEvent['id']?.toString() ?? '1',
                      onEventUpdated: fetchUpcomingEvent,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('View Details'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ).animate().fadeIn().scale(delay: 600.ms),
            ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  List<Widget> _getQuickActionsByRole() {
    final actions = <Widget>[];
    final roleActions = {
      'admin': [
        ('Manage Students', Icons.people_outline, const Color(0xFF6C63FF), ManageStudentsScreen(userType: widget.userRole, userId: widget.userId,)),
        ('Manage Teachers', Icons.person, const Color(0xFF00B4D8), ManageTeachersScreen(userType: widget.userRole, userId: widget.userId,)),
        ('Attendance', Icons.check_circle_outline, const Color(0xFFFF6B6B), AdminAttendanceReport()),
        ('Manage Chatbot', Icons.smart_toy, const Color(0xFFFFA62B), ChatbotManagementScreen(adminId: widget.userId)),
        ('Manage Events', Icons.event_note, const Color(0xFF4CAF50), EventListScreen()),
      ],
      'teacher': [
        ('Manage Students', Icons.people_outline, const Color(0xFF6C63FF), ManageStudentsScreen(userType: widget.userRole, userId: widget.userId,)),
        ('Attendance', Icons.check_circle_outline, const Color(0xFFFF6B6B), AdminAttendanceReport()),
        ('Manage Events', Icons.event_note, const Color(0xFF4CAF50), EventListScreen()),
      ],
      'student': [
        ('Attendance', Icons.check_circle_outline, const Color(0xFFFF6B6B), AdminAttendanceReport()),
      ],
    };

    final currentRoleActions = roleActions[widget.userRole.toLowerCase()] ?? [];
    
    for (var i = 0; i < currentRoleActions.length; i++) {
      final (title, icon, color, screen) = currentRoleActions[i];
      actions.add(
        _buildAnimatedActionCard(title, icon, color, screen),
      );
    }

    return actions;
  }

  Widget _buildAnimatedActionCard(String title, IconData icon, Color color, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ).animate().fadeIn().scale(),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn().slideX(delay: 200.ms),
          ],
        ),
      ),
    ).animate().fadeIn().scale(delay: 400.ms);
  }
}