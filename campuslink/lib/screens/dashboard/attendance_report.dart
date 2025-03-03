import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/profile.dart';

class AttendanceReport extends StatefulWidget {
  final bool isStudent;
  final String studentId;

  const AttendanceReport({
    super.key,
    required this.isStudent,
    required this.studentId,
  });

  @override
  _AttendanceReportState createState() => _AttendanceReportState();
}

class _AttendanceReportState extends State<AttendanceReport> {
  DateTime _selectedDate = DateTime.now();
  final ScrollController _calendarScrollController = ScrollController();

  // Sample student data - Replace with your actual data model
  final Map<String, Map<String, dynamic>> _studentsAttendance = {
    'STD001': {
      'name': 'John Doe',
      'totalDays': 50,
      'presentDays': 42,
      'lateDays': 5,
      'absentDays': 3,
      'status': 'present',
      'timeIn': '08:00 AM',
    },
    // Add more students here
  };

  @override
  void dispose() {
    _calendarScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.isStudent ? 'My Attendance' : 'Student Attendance',
          style: theme.appBarTheme.titleTextStyle?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            ),
          ),
        ],
      ),
      body: widget.isStudent 
          ? _buildStudentView(theme)
          : _buildTeacherView(theme),
    );
  }

  Widget _buildStudentView(ThemeData theme) {
    final studentData = _studentsAttendance[widget.studentId] ?? {
      'totalDays': 50,
      'presentDays': 42,
      'lateDays': 5,
      'absentDays': 3,
    };

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDateScroller(theme),
          _buildStudentAttendanceSummary(theme, studentData),
          _buildAttendanceChart(theme, studentData),
        ],
      ),
    );
  }

  Widget _buildTeacherView(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateScroller(theme),
          _buildClassAttendanceSummary(theme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildTimelineSection(theme),
          ),
          _buildStudentsList(theme),
        ],
      ),
    );
  }

  Widget _buildDateScroller(ThemeData theme) {
  // Calculate dates centered around current date
  final now = DateTime.now();
  final dates = List.generate(
    180,
    (i) => now.subtract(Duration(days: 90)).add(Duration(days: i)),
  );

  // Initialize scroll controller to middle position on first build
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_calendarScrollController.hasClients && 
        _calendarScrollController.position.pixels == 0) {
      _calendarScrollController.jumpTo(
        _calendarScrollController.position.maxScrollExtent / 2,
      );
    }
  });

  return Container(
    height: 120,
    margin: const EdgeInsets.symmetric(vertical: 16),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            DateFormat('MMMM yyyy').format(_selectedDate),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            controller: _calendarScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
                  DateFormat('yyyy-MM-dd').format(_selectedDate);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(date),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d').format(date),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

  Widget _buildStudentAttendanceSummary(ThemeData theme, Map<String, dynamic> studentData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAttendanceStatistic(
            'Present',
            studentData['presentDays'].toString(),
            '${((studentData['presentDays'] / studentData['totalDays']) * 100).round()}%',
            Colors.green,
            Icons.check_circle_outline,
          ),
          _buildAttendanceStatistic(
            'Late',
            studentData['lateDays'].toString(),
            '${((studentData['lateDays'] / studentData['totalDays']) * 100).round()}%',
            Colors.orange,
            Icons.access_time,
          ),
          _buildAttendanceStatistic(
            'Absent',
            studentData['absentDays'].toString(),
            '${((studentData['absentDays'] / studentData['totalDays']) * 100).round()}%',
            Colors.red,
            Icons.cancel_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildClassAttendanceSummary(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAttendanceStatistic('Present', '42', '85%', Colors.green, Icons.check_circle_outline),
          _buildAttendanceStatistic('Late', '5', '10%', Colors.orange, Icons.access_time),
          _buildAttendanceStatistic('Absent', '3', '5%', Colors.red, Icons.cancel_outlined),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatistic(
    String title,
    String count,
    String percentage,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        Text(
          count,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            percentage,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Timeline',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTimelineItem('08:00 AM', 'Morning Session Started', '42 students present', Colors.blue, theme),
        _buildTimelineItem('08:15 AM', 'Late Arrivals', '5 students marked late', Colors.orange, theme),
        _buildTimelineItem('08:30 AM', 'Attendance Closed', '3 students marked absent', Colors.red, theme),
      ],
    );
  }

  Widget _buildTimelineItem(String time, String title, String subtitle, Color color, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(left: 8, bottom: 16),
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: color.withOpacity(0.5),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Students Attendance',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _studentsAttendance.length,
            itemBuilder: (context, index) {
              final student = _studentsAttendance.entries.elementAt(index);
              return _buildStudentListItem(student.value, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStudentListItem(Map<String, dynamic> student, ThemeData theme) {
    final Color statusColor = student['status'] == 'present'
        ? Colors.green
        : student['status'] == 'late'
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => _showStudentDetails(student),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Text(
            student['name'].substring(0, 1),
            style: TextStyle(color: statusColor),
          ),
        ),
        title: Text(student['name']),
        subtitle: Text('Time in: ${student['timeIn']}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            student['status'].toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showStudentDetails(Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildStudentDetailedReport(Theme.of(context), student),
    );
  }

  Widget _buildStudentDetailedReport(ThemeData theme, Map<String, dynamic> student) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${student['name']}\'s Attendance Report',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildMonthlyReport(theme, student),
        ],
      ),
    );
  }

  Widget _buildMonthlyReport(ThemeData theme, Map<String, dynamic> student) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildReportItem('Total Days', student['totalDays'].toString(), theme.colorScheme.primary, theme),
        _buildReportItem('Present', student['presentDays'].toString(), Colors.green, theme),
        _buildReportItem('Late', student['lateDays'].toString(), Colors.orange, theme),
        _buildReportItem('Absent', student['absentDays'].toString(), Colors.red, theme),
      ],
    );
  }

  Widget _buildReportItem(String title, String value, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceChart(ThemeData theme, Map<String, dynamic> studentData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Overview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _getMonthlyData().map((data) {
                      return _buildChartBar(
                        data['month'],
                        data['percentage'].toDouble(),
                        theme,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _getMonthlyData().map((data) {
                    return SizedBox(
                      width: 40,
                      child: Text(
                        data['month'],
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildMonthlyTable(theme),
        ],
      ),
    );
  }

  Widget _buildChartBar(String month, double percentage, ThemeData theme) {
    return Tooltip(
      message: '$month: ${percentage.round()}%',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 20,
            height: percentage * 1.5,
            decoration: BoxDecoration(
              color: _getAttendanceColor(percentage.round()),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMonthlyData() {
    final now = DateTime.now();
    final months = List.generate(6, (index) {
      final month = DateTime(now.year, now.month - index);
      return DateFormat('MMM').format(month);
    }).reversed.toList();

    // Sample data - Replace with actual data
    return List.generate(6, (index) {
      return {
        'month': months[index],
        'percentage': 70 + (index * 5),
      };
    });
  }

  Widget _buildMonthlyTable(ThemeData theme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Monthly Report',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return DataTable(
              headingRowColor: WidgetStateProperty.all(
                theme.colorScheme.primary.withOpacity(0.1),
              ),
              columnSpacing: constraints.maxWidth * 0.05, // 5% of screen width
              dataRowHeight: 56,
              horizontalMargin: 12,
              columns: const [
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'Month',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'P',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'L',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'A',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      '%',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
              rows: _getMonthlyTableData().map((data) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        data['month'].toString().substring(0, 3),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text(
                          data['present'].toString(),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text(
                          data['late'].toString(),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text(
                          data['absent'].toString(),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getAttendanceColor(data['percentage'])
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${data['percentage']}%',
                            style: TextStyle(
                              color: _getAttendanceColor(data['percentage']),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
    ],
  );
}

  List<Map<String, dynamic>> _getMonthlyTableData() {
    final now = DateTime.now();
    final months = List.generate(6, (index) {
      final month = DateTime(now.year, now.month - index);
      return DateFormat('MMMM').format(month);
    }).reversed.toList();

    // Sample data - Replace with actual data
    return List.generate(6, (index) {
      return {
        'month': months[index],
        'present': 18 + index,
        'late': 2,
        'absent': 2 - (index ~/ 2),
        'percentage': 70 + (index * 5),
      };
    });
  }

  Color _getAttendanceColor(int percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 75) return Colors.blue;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}