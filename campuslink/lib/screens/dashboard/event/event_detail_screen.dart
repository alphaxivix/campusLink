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
    final theme = Theme.of(context);
    
    return Scaffold(
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
        : CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    eventDetails['title'] ?? 'Event Details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                          theme.colorScheme.primary.withOpacity(0.6),
                        ],
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
                        context,
                        icon: Icons.calendar_today,
                        title: 'Date & Time',
                        content: DateFormat('MMMM dd, yyyy - HH:mm')
                            .format(DateTime.parse(eventDetails['event_date'])),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        icon: Icons.location_on,
                        title: 'Location',
                        content: eventDetails['location'] ?? 'TBA',
                        subtitle: eventDetails['location_detail'],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        icon: Icons.description,
                        title: 'Description',
                        content: eventDetails['description'] ?? 'No description available',
                      ),
                      const SizedBox(height: 24),
                      _buildScheduleSection(context),
                      const SizedBox(height: 24),
                      _buildCoordinatorsSection(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: theme.cardTheme.elevation,
      shape: theme.cardTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium,
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

  Widget _buildScheduleSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        if (schedules.isEmpty)
          Card(
            elevation: theme.cardTheme.elevation,
            shape: theme.cardTheme.shape,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No schedule available',
                style: theme.textTheme.bodyMedium,
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
                elevation: theme.cardTheme.elevation,
                shape: theme.cardTheme.shape,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(Icons.access_time, color: theme.colorScheme.primary),
                  title: Text(schedule['activity'], style: theme.textTheme.titleLarge),
                  subtitle: Text(schedule['time'], style: theme.textTheme.bodyMedium),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCoordinatorsSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Coordinators',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        if (coordinators.isEmpty)
          Card(
            elevation: theme.cardTheme.elevation,
            shape: theme.cardTheme.shape,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No coordinators assigned',
                style: theme.textTheme.bodyMedium,
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
                elevation: theme.cardTheme.elevation,
                shape: theme.cardTheme.shape,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      coordinator['name'][0].toUpperCase(),
                      style: TextStyle(color: theme.colorScheme.onPrimary),
                    ),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  title: Text(
                    coordinator['name'],
                    style: theme.textTheme.titleLarge,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coordinator['role'],
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        coordinator['email'],
                        style: theme.textTheme.bodyMedium,
                      ),
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