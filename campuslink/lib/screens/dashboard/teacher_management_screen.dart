import 'package:campuslink/data/data_provider.dart';
import 'package:campuslink/models/teacher_and_student_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageTeachersScreen extends StatefulWidget {
  final String userType;
  final String userId;

  const ManageTeachersScreen({Key? key, required this.userType, required this.userId}) : super(key: key);

  @override
  _ManageTeachersScreenState createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch teachers when the screen loads
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().fetchTeachers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 46, 58),
        title: const Text('Manage Teachers', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          if (dataProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${dataProvider.error}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => dataProvider.fetchTeachers(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // if (dataProvider.teachers.isEmpty) {
          //   return Center(child: CircularProgressIndicator());
          // }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: dataProvider.teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = dataProvider.teachers[index];
                    return TeacherCard(
                      teacher: teacher,
                      userType: widget.userType,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTeacherDialog(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTeacherDialog(BuildContext context) {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final subjectController = TextEditingController();
    final qualificationController = TextEditingController();
    final experienceController = TextEditingController();
    final contactController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Teacher'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: subjectController,
                decoration: InputDecoration(labelText: 'Subject'),
              ),
              TextField(
                controller: qualificationController,
                decoration: InputDecoration(labelText: 'Qualification'),
              ),
              TextField(
                controller: experienceController,
                decoration: InputDecoration(labelText: 'Experience (Years)'),
              ),
              TextField(
                controller: contactController,
                decoration: InputDecoration(labelText: 'Contact'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
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
              final teacher = Teacher(
                id: 'TCH${DateTime.now().millisecondsSinceEpoch}',
                name: nameController.text,
                username: usernameController.text,
                password: passwordController.text,
                subject: subjectController.text,
                qualification: qualificationController.text,
                experience: experienceController.text,
                contact: contactController.text,
                email: emailController.text,
              );
              context.read<DataProvider>().addTeacher(teacher);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class TeacherCard extends StatelessWidget {
  final Teacher teacher;
  final String userType;

  const TeacherCard({Key? key, required this.teacher, required this.userType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ExpansionTile(
        title: Text(teacher.name),
        subtitle: Text('Subject: ${teacher.subject} | Username: ${teacher.username}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Username', teacher.username),
                _buildInfoRow('Subject', teacher.subject),
                _buildInfoRow('Qualification', teacher.qualification),
                _buildInfoRow('Experience', teacher.experience),
                _buildInfoRow('Contact', teacher.contact),
                _buildInfoRow('Email', teacher.email),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showEditDialog(context),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showDeleteDialog(context),
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: teacher.name);
    final usernameController = TextEditingController(text: teacher.username);
    final passwordController = TextEditingController(text: teacher.password);
    final subjectController = TextEditingController(text: teacher.subject);
    final qualificationController = TextEditingController(text: teacher.qualification);
    final experienceController = TextEditingController(text: teacher.experience);
    final contactController = TextEditingController(text: teacher.contact);
    final emailController = TextEditingController(text: teacher.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Teacher'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: subjectController,
                decoration: InputDecoration(labelText: 'Subject'),
              ),
              TextField(
                controller: qualificationController,
                decoration: InputDecoration(labelText: 'Qualification'),
              ),
              TextField(
                controller: experienceController,
                decoration: InputDecoration(labelText: 'Experience (Years)'),
              ),
              TextField(
                controller: contactController,
                decoration: InputDecoration(labelText: 'Contact'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
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
              final updatedTeacher = teacher.copyWith(
                name: nameController.text,
                username: usernameController.text,
                password: passwordController.text,
                subject: subjectController.text,
                qualification: qualificationController.text,
                experience: experienceController.text,
                contact: contactController.text,
                email: emailController.text,
              );
              context.read<DataProvider>().updateTeacher(updatedTeacher);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: Text('Are you sure you want to delete ${teacher.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DataProvider>().deleteTeacher(teacher.id);
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