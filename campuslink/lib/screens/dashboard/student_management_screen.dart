import 'package:campuslink/data/data_provider.dart';
import 'package:campuslink/models/teacher_and_student_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageStudentsScreen extends StatefulWidget {
  final String userType;
  final String userId;

  const ManageStudentsScreen({Key? key, required this.userType, required this.userId}) : super(key: key);

  @override
  _ManageStudentsScreenState createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch students when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().fetchStudents();
    });
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 46, 58),
        title: const Text('Manage Students', style: TextStyle(color: Colors.white)),
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
                    onPressed: () => dataProvider.fetchStudents(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (dataProvider.students.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: dataProvider.students.length,
                  itemBuilder: (context, index) {
                    final student = dataProvider.students[index];
                    return StudentCard(
                      student: student,
                      userType: widget.userType,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: widget.userType == 'Admin'
          ? FloatingActionButton(
              onPressed: () => _showAddStudentDialog(context),
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }


  void _showAddStudentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final gradeController = TextEditingController();
    final sectionController = TextEditingController();
    final contactController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Student'),
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
                controller: gradeController,
                decoration: InputDecoration(labelText: 'Grade/Year'),
              ),
              TextField(
                controller: sectionController,
                decoration: InputDecoration(labelText: 'Section'),
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
              final student = Student(
                id: 'STD${DateTime.now().millisecondsSinceEpoch}',
                name: nameController.text,
                username: usernameController.text,
                password: passwordController.text,
                grade: gradeController.text,
                section: sectionController.text,
                contact: contactController.text,
                email: emailController.text,
              );
              context.read<DataProvider>().addStudent(student);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final Student student;
  final String userType;

  const StudentCard({Key? key, required this.student, required this.userType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ExpansionTile(
        title: Text(student.name),
        subtitle: Text('Grade: ${student.grade} | Username: ${student.username}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Username', student.username),
                _buildInfoRow('Grade/Year', student.grade),
                _buildInfoRow("Password", student.password),
                _buildInfoRow('Section', student.section),
                _buildInfoRow('Contact', student.contact),
                _buildInfoRow('Email', student.email),
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
    final nameController = TextEditingController(text: student.name);
    final usernameController = TextEditingController(text: student.username);
    final passwordController = TextEditingController(text: student.password);
    final gradeController = TextEditingController(text: student.grade);
    final sectionController = TextEditingController(text: student.section);
    final contactController = TextEditingController(text: student.contact);
    final emailController = TextEditingController(text: student.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Student'),
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
                controller: gradeController,
                decoration: InputDecoration(labelText: 'Grade/Year'),
              ),
              TextField(
                controller: sectionController,
                decoration: InputDecoration(labelText: 'Section'),
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
              final updatedStudent = student.copyWith(
                name: nameController.text,
                username: usernameController.text,
                password: passwordController.text,
                grade: gradeController.text,
                section: sectionController.text,
                contact: contactController.text,
                email: emailController.text,
              );
              context.read<DataProvider>().updateStudent(updatedStudent);
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
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DataProvider>().deleteStudent(student.id);
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