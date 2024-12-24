// chatbot_management_screen.dart
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
  // Safely handle the case where 'institution' might not be stored in SharedPreferences
  institution = prefs.getString('institution') ?? '';
  
  // Optionally print to debug
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
        Uri.parse('http://192.168.1.78/get_predefined_questions.php')
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
      Uri.parse('http://192.168.1.78/get_admin_answers.php?institution=$institution')
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
      Uri.parse('http://192.168.1.78/save_admin_answer.php'),
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
      builder: (context) => AlertDialog(
        title: Text('Answer for: ${question.questionText}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: answerController,
                decoration: InputDecoration(
                  labelText: 'Your Answer',
                  hintText: 'Enter your specific answer'
                ),
                maxLines: 3,
                validator: (value) => 
                  value?.isEmpty == true ? 'Please enter an answer' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
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
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red)
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchPredefinedQuestions();
              fetchAdminAnswers();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
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
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      question.questionText,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: ${question.category}'),
                        if (answer.answer.isNotEmpty)
                          Text(
                            'Your Answer: ${answer.answer}',
                            style: TextStyle(color: Colors.blue),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        IconButton(
                          icon: Icon(
                            answer.answer.isEmpty 
                              ? Icons.add_circle 
                              : Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () => _showAnswerDialog(question),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
      keywords: List<String>.from(json['keywords']),
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