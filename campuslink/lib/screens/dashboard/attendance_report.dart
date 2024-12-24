import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../widgets/profile.dart';

class AttendanceReport extends StatefulWidget {
  final bool isStudent;
  final String studentId;

  const AttendanceReport({
    Key? key,
    required this.isStudent,
    required this.studentId,
  }) : super(key: key);

  @override
  _AttendanceReportState createState() => _AttendanceReportState();
}

class _AttendanceReportState extends State<AttendanceReport> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  bool isCheckedIn = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          _buildCalendar(theme),
          _buildStats(theme, isDarkMode),
          Expanded(
            child: _buildAttendanceList(theme, isDarkMode),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      elevation: 0,
      title: Text(
        widget.isStudent ? 'My Attendance' : 'Student Attendance',
        style: theme.appBarTheme.titleTextStyle,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: _showDatePicker,
        ),
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2024, 12, 31),
        focusedDay: _focusedDate,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        calendarFormat: CalendarFormat.week,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: theme.textTheme.titleLarge!,
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
        onDaySelected: _onDaySelected,
      ),
    );
  }

  Widget _buildStats(ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          _buildStatCard(theme, 'Present', '85%', Icons.check_circle_outline, theme.colorScheme.primary),
          _buildStatCard(theme, 'Late', '10%', Icons.access_time, theme.colorScheme.tertiary),
          _buildStatCard(theme, 'Absent', '5%', Icons.cancel_outlined, theme.colorScheme.error),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Icon(icon, color: color),
              Text(value, style: theme.textTheme.titleMedium?.copyWith(color: color)),
              Text(title, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceList(ThemeData theme, bool isDarkMode) {
    if (widget.isStudent) {
      return _buildStudentAttendanceList(theme);
    } else {
      return _buildAllStudentsAttendanceList(theme);
    }
  }

  Widget _buildStudentAttendanceList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: 1, // Replace with actual data count
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Icon(
              isCheckedIn ? Icons.login : Icons.logout,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              DateFormat('MMMM d, yyyy').format(_selectedDate),
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(
              isCheckedIn ? 'Checked In: ${DateFormat('hh:mm a').format(DateTime.now())}'
                         : 'Not Checked In',
              style: theme.textTheme.bodyMedium,
            ),
            trailing: _buildStatusChip(theme, isCheckedIn ? 'Present' : 'Absent'),
          ),
        );
      },
    );
  }

  Widget _buildAllStudentsAttendanceList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: 10, // Replace with actual student count
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Text('${index + 1}'),
            ),
            title: Text(
              'Student ${index + 1}',
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(
              'Check-in: 8:00 AM',
              style: theme.textTheme.bodyMedium,
            ),
            trailing: _buildStatusChip(theme, 'Present'),
            onTap: () => _showStudentDetails(context, index, theme),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(ThemeData theme, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'Present' ? theme.colorScheme.primary : theme.colorScheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary),
      ),
    );
  }


  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      _onDaySelected(picked, picked);
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDate = selectedDay;
      _focusedDate = focusedDay;
    });
  }


  void _showStudentDetails(BuildContext context, int index, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Student ${index + 1} Attendance Details',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text('Check-in Time: 8:00 AM'),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Attendance Rate: 95%'),
            ),
          ],
        ),
      ),
    );
  }
}