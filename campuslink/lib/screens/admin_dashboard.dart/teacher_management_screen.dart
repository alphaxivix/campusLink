import 'package:flutter/material.dart';

class ManageTeachersScreen extends StatelessWidget {
  final List<Map<String, dynamic>> teachers = [
    {
      'id': 'TCH001',
      'name': 'Dr. Sarah Johnson',
      'subject': 'Mathematics',
      'contact': '+1234567890',
      'email': 'sarah.j@email.com',
      'qualification': 'Ph.D. Mathematics',
      'experience': '8 years',
      'classes': ['10A', '11B', '12A'],
    },
    // Add more teacher data as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 46, 58),
        title: const Text('Manage Teachers', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search teachers...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    // Handle filter selection
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'subject',
                      child: Text('Filter by Subject'),
                    ),
                    const PopupMenuItem(
                      value: 'qualification',
                      child: Text('Filter by Qualification'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Teachers List
          Expanded(
            child: ListView.builder(
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                final teacher = teachers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  elevation: 2,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(
                        teacher['name'].toString().substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      teacher['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('${teacher['subject']} | ID: ${teacher['id']}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Qualification', teacher['qualification']),
                            _buildInfoRow('Experience', teacher['experience']),
                            _buildInfoRow('Contact', teacher['contact']),
                            _buildInfoRow('Email', teacher['email']),
                            const SizedBox(height: 10),
                            const Text(
                              'Assigned Classes:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Wrap(
                              spacing: 8,
                              children: (teacher['classes'] as List<String>).map((className) {
                                return Chip(
                                  label: Text(className),
                                  backgroundColor: Colors.green[100],
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  icon: Icons.edit,
                                  label: 'Edit',
                                  color: Colors.blue,
                                  onPressed: () => _showEditTeacherDialog(context, teacher),
                                ),
                                _buildActionButton(
                                  icon: Icons.class_,
                                  label: 'Assign Classes',
                                  color: Colors.green,
                                  onPressed: () => _showAssignClassesDialog(context, teacher),
                                ),
                                _buildActionButton(
                                  icon: Icons.delete,
                                  label: 'Delete',
                                  color: Colors.red,
                                  onPressed: () => _showDeleteConfirmation(context, teacher),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTeacherDialog(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _showAddTeacherDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Teacher'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Full Name'),
              const SizedBox(height: 10),
              _buildTextField('Subject'),
              const SizedBox(height: 10),
              _buildTextField('Qualification'),
              const SizedBox(height: 10),
              _buildTextField('Contact Number'),
              const SizedBox(height: 10),
              _buildTextField('Email'),
              const SizedBox(height: 10),
              _buildTextField('Experience (years)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle save
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showEditTeacherDialog(BuildContext context, Map<String, dynamic> teacher) {
    // Similar to add dialog but pre-filled with teacher data
  }

  void _showAssignClassesDialog(BuildContext context, Map<String, dynamic> teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Classes - ${teacher['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add checkboxes or multi-select for classes
            CheckboxListTile(
              title: const Text('Class 10A'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Class 11B'),
              value: false,
              onChanged: (value) {},
            ),
            // Add more classes
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle save
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: Text('Are you sure you want to delete ${teacher['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle delete
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}