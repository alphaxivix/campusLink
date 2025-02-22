import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotManagementScreen extends StatefulWidget {
  final String adminId;

  const ChatbotManagementScreen({
    Key? key,
    required this.adminId,
  }) : super(key: key);

  @override
  _ChatbotManagementScreenState createState() => _ChatbotManagementScreenState();
}

class _ChatbotManagementScreenState extends State<ChatbotManagementScreen> {
  List<PredefinedQuestion> predefinedQuestions = [];
  List<AdminAnswer> adminAnswers = [];
  bool _isLoading = false;
  String institution = '';

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    institution = prefs.getString('institution') ?? '';
    print('Institution loaded: $institution');
  }

  @override
  void initState() {
    super.initState();
    fetchPredefinedQuestions();
    fetchAdminAnswers();
  }

  Future<void> fetchPredefinedQuestions() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.5/clink/api/get_predefined_questions.php')
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          predefinedQuestions = data
              .map((json) => PredefinedQuestion.fromJson(json))
              .toList();
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load predefined questions: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

void fetchAdminAnswers() async {
  await loadUserData(); // Make sure data is loaded before the request

  if (institution.isEmpty) {
    _showErrorSnackBar('Institution ID is required');
    return;
  }

  try {
    final response = await http.get(
      Uri.parse('http://192.168.1.5/clink/api/get_admin_answers.php?institution=$institution')
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        adminAnswers = data.map((json) => AdminAnswer.fromJson(json)).toList();
      });
    } else {
      _showErrorSnackBar('Failed to load admin answers: ${response.statusCode}');
    }
  } catch (e) {
    _showErrorSnackBar('Failed to load admin answers: $e');
  }
}



Future<void> saveAdminAnswer(AdminAnswer answer) async {
  try {
    // If no ID exists, send null to trigger UUID generation
    final payload = {
      'id': answer.id.isEmpty ? null : answer.id,
      'question_id': answer.questionId,
      'answer': answer.answer,
      'active': answer.active,
      'institution': institution,
    };

    final response = await http.post(
      Uri.parse('http://192.168.1.5/clink/api/save_admin_answer.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload)
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['success'] == true) {
        fetchAdminAnswers();
        _showSuccessSnackBar('Answer saved successfully');
      } else {
        _showErrorSnackBar('Failed to save answer: ${responseBody['error']}');
      }
    } else {
      _showErrorSnackBar('Failed to save answer: HTTP ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    _showErrorSnackBar('Error saving answer: $e');
  }
}

  void _showAnswerDialog(PredefinedQuestion question) {
    final existingAnswer = adminAnswers.firstWhere(
      (answer) => answer.questionId == question.id,
      orElse: () => AdminAnswer(
        id: '',
        questionId: question.id,
        answer: '',
        active: true,
      ),
    );

    final answerController = TextEditingController(text: existingAnswer.answer);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Answer Question',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                question.questionText,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Form(
                key: formKey,
                child: TextFormField(
                  controller: answerController,
                  decoration: const InputDecoration(
                    labelText: 'Your Answer',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Please enter an answer' : null,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final updatedAnswer = AdminAnswer(
                          id: existingAnswer.id,
                          questionId: question.id,
                          answer: answerController.text,
                          active: true,
                        );
                        saveAdminAnswer(updatedAnswer);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chatbot Management',
          style: theme.textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            onPressed: () {
              fetchPredefinedQuestions();
              fetchAdminAnswers();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: predefinedQuestions.length,
              itemBuilder: (context, index) {
                final question = predefinedQuestions[index];
                final answer = adminAnswers.firstWhere(
                  (a) => a.questionId == question.id,
                  orElse: () => AdminAnswer(
                    id: '',
                    questionId: question.id,
                    answer: '',
                    active: false,
                  ),
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                question.questionText,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                question.category,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (answer.answer.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              answer.answer,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Active',
                                  style: theme.textTheme.labelLarge,
                                ),
                                const SizedBox(width: 8),
                                Switch(
                                  value: answer.active,
                                  onChanged: (value) {
                                    final updatedAnswer = AdminAnswer(
                                      id: answer.id,
                                      questionId: question.id,
                                      answer: answer.answer,
                                      active: value,
                                    );
                                    saveAdminAnswer(updatedAnswer);
                                  },
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showAnswerDialog(question),
                              label: Text(
                                answer.answer.isEmpty ? 'Add Answer' : 'Edit',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Add this Floating Action Button in the build method's Scaffold
floatingActionButton: FloatingActionButton(
  onPressed: _showAddQuestionDialog,
  child: Icon(Icons.add),
  tooltip: 'Add Predefined Question',
),
    );
  }
  // Add this inside ChatbotManagementScreen class

// Function to show the dialog for adding a predefined question
void _showAddQuestionDialog() {
  final categoryController = TextEditingController();
  final questionController = TextEditingController();
  final keywordsController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add New Predefined Question', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (value) => value!.isEmpty ? 'Enter a category' : null,
                  ),
                  TextFormField(
                    controller: questionController,
                    decoration: const InputDecoration(labelText: 'Question Text'),
                    validator: (value) => value!.isEmpty ? 'Enter a question' : null,
                  ),
                  TextFormField(
                    controller: keywordsController,
                    decoration: const InputDecoration(labelText: 'Keywords (comma-separated)'),
                    validator: (value) => value!.isEmpty ? 'Enter keywords' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      _savePredefinedQuestion(
                        categoryController.text,
                        questionController.text,
                        keywordsController.text,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// Function to call the API and save the question
Future<void> _savePredefinedQuestion(String category, String questionText, String keywords) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.5/clink/api/add_predefined_question.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'category': category,
        'question_text': questionText,
        'keywords': keywords,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['success'] == true) {
        fetchPredefinedQuestions(); // Refresh the list
        _showSuccessSnackBar('Question added successfully');
      } else {
        _showErrorSnackBar('Failed to add question: ${responseBody['error']}');
      }
    } else {
      _showErrorSnackBar('HTTP Error: ${response.statusCode}');
    }
  } catch (e) {
    _showErrorSnackBar('Error: $e');
  }
}


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.onError,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50), 
      ),
    );
  }
}

class PredefinedQuestion {
  final String id;
  final String category;
  final String questionText;
  final List<String> keywords;

  PredefinedQuestion({
    required this.id,
    required this.category,
    required this.questionText,
    required this.keywords,
  });

  factory PredefinedQuestion.fromJson(Map<String, dynamic> json) {
  return PredefinedQuestion(
    id: json['id'],
    category: json['category'],
    questionText: json['question_text'],
    keywords: json['keywords'].toString().split(','),
  );
}

}

class AdminAnswer {
  final String id;
  final String questionId;
  final String answer;
  final bool active;

  AdminAnswer({
    required this.id,
    required this.questionId,
    required this.answer,
    required this.active,
  });

  factory AdminAnswer.fromJson(Map<String, dynamic> json) {
    return AdminAnswer(
      id: json['id'],
      questionId: json['question_id'],
      answer: json['answer'],
      active: json['active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'answer': answer,
      'active': active ? 1 : 0,
    };
  }
}