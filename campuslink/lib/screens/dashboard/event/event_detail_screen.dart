import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  final VoidCallback? onEventUpdated;

  const EventDetailScreen({
    Key? key,
    required this.eventId,
    this.onEventUpdated,
  }) : super(key: key);

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}
class _EventDetailScreenState extends State<EventDetailScreen> {
  Map<String, dynamic> eventDetails = {};
  List<dynamic> schedules = [];
  List<dynamic> coordinators = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.78/get_event_details.php?id=${widget.eventId}')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          eventDetails = data['event'];
          schedules = data['schedules'];
          coordinators = data['coordinators'];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(eventDetails['title'] ?? 'Event Details'),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade400, Colors.purple.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(
                        icon: Icons.calendar_today,
                        title: 'Date & Time',
                        content: DateFormat('MMMM dd, yyyy - HH:mm')
                            .format(DateTime.parse(eventDetails['event_date'])),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        icon: Icons.location_on,
                        title: 'Location',
                        content: eventDetails['location'] ?? 'TBA',
                        subtitle: eventDetails['location_detail'],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        icon: Icons.description,
                        title: 'Description',
                        content: eventDetails['description'] ?? 'No description available',
                      ),
                      const SizedBox(height: 24),
                      _buildScheduleSection(),
                      const SizedBox(height: 24),
                      _buildCoordinatorsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.purple.shade400),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 15),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (schedules.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No schedule available',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(schedule['activity']),
                  subtitle: Text(schedule['time']),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCoordinatorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Coordinators',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (coordinators.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No coordinators assigned',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: coordinators.length,
            itemBuilder: (context, index) {
              final coordinator = coordinators[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      coordinator['name'][0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.purple.shade400,
                  ),
                  title: Text(coordinator['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(coordinator['role']),
                      Text(coordinator['email']),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
      ],
    );
  }
}