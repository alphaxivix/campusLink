import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'event_form.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({Key? key}) : super(key: key);

  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<dynamic> events = [];
  bool isLoading = true;
  final String baseUrl = 'http://192.168.1.78/save_events.php'; // For Android Emulator

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

Future<void> _loadEvents() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          setState(() {
            events = [];
            isLoading = false;
          });
          return;
        }
        
        final List<dynamic> decodedData = json.decode(response.body);
        setState(() {
          events = decodedData;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        events = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading events: $e')),
      );
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
              ? const Center(child: Text('No events found'))
              : ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(event['title'] ?? 'No Title'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['event_date'] != null
                                  ? DateFormat('MMM dd, yyyy HH:mm')
                                      .format(DateTime.parse(event['event_date']))
                                  : 'No date',
                            ),
                            Text(event['location'] ?? 'No location'),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventForm(
                                    eventId: event['id'].toString(),
                                  ),
                                ),
                              );
                              if (result == true) {
                                _loadEvents();
                              }
                            } else if (value == 'delete') {
                              // Handle delete
                              _deleteEvent(event['id'].toString());
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventForm()),
          );
          if (result == true) {
            _loadEvents();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteEvent(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl?id=$id'),
      );
      if (response.statusCode == 200) {
        _loadEvents();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting event: $e')),
      );
    }
  }
}