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
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Students',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
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
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => dataProvider.fetchStudents(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dataProvider.students.length,
            itemBuilder: (context, index) {
              final student = dataProvider.students[index];
              return StudentCard(
                student: student,
                userType: widget.userType,
              );
            },
          );
        },
      ),
      floatingActionButton: widget.userType == 'Admin'
          ? FloatingActionButton(
              onPressed: () => _showAddStudentDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

 void _showAddStudentDialog(BuildContext context) {
  final theme = Theme.of(context);
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
      title: Text('Add New Student', style: theme.textTheme.headlineSmall),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: gradeController,
              decoration: const InputDecoration(labelText: 'Grade/Year'),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sectionController,
              decoration: const InputDecoration(labelText: 'Section'),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contactController,
              decoration: const InputDecoration(labelText: 'Contact'),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              style: theme.textTheme.bodyLarge,
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
          onPressed: () async {
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
            await context.read<DataProvider>().addStudent(student);
            Navigator.pop(context);

            // Show success snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Student added successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 3),
              ),
            );

            // Navigate back to the ManageStudentsScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ManageStudentsScreen(
                  userType: widget.userType,
                  userId: widget.userId,
                ),
              ),
            );
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
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          student.name,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          'Grade: ${student.grade} | Username: ${student.username}',
          style: theme.textTheme.bodyMedium,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(context, 'Username', student.username),
                _buildInfoRow(context, 'Grade/Year', student.grade),
                _buildInfoRow(context, 'Password', student.password),
                _buildInfoRow(context, 'Section', student.section),
                _buildInfoRow(context, 'Contact', student.contact),
                _buildInfoRow(context, 'Email', student.email),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showEditDialog(context),
                      icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                      label: Text('Edit', style: TextStyle(color: theme.colorScheme.primary)),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showDeleteDialog(context),
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
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
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Student',
          style: theme.textTheme.headlineSmall,
        ),
        content: Text(
          'Are you sure you want to delete ${student.name}?',
          style: theme.textTheme.bodyLarge,
        ),
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
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}