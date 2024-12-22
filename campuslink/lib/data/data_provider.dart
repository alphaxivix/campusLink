import 'dart:convert';
import 'package:campuslink/models/teacher_and_student_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DataProvider with ChangeNotifier {
  // Update the base URL to point directly to user.php
  final String baseUrl = 'http://192.168.1.78/manage_teacher_and_student/user.php';
  List<Student> _students = [];
  List<Teacher> _teachers = [];
  String? _error;

  List<Student> get students => _students;
  List<Teacher> get teachers => _teachers;
  String? get error => _error;


  // Teacher Methods
  // Teacher Methods
Future<void> fetchTeachers() async {
  try {
    print('Fetching teachers from: $baseUrl?endpoint=teachers');
    
    final response = await http.get(Uri.parse('$baseUrl?endpoint=teachers'));
    
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _teachers = data.map((json) => Teacher.fromJson(json)).toList();
      _error = null;
      notifyListeners();
    } else {
      _error = 'Failed to fetch teachers. Status code: ${response.statusCode}';
      _teachers = [];
      notifyListeners();
    }
  } catch (e) {
    print('Error fetching teachers: $e');
    _error = 'Error fetching teachers: $e';
    _teachers = [];
    notifyListeners();
  }
}

Future<void> addTeacher(Teacher teacher) async {
  try {
    print('Adding teacher: ${json.encode(teacher.toJson())}');
    
    final response = await http.post(
      Uri.parse('$baseUrl?endpoint=teachers'),
      body: json.encode(teacher.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    print('Add teacher response: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      await fetchTeachers();
    } else {
      _error = 'Failed to add teacher. Status code: ${response.statusCode}';
      notifyListeners();
    }
  } catch (e) {
    print('Error adding teacher: $e');
    _error = 'Error adding teacher: $e';
    notifyListeners();
  }
}

Future<void> updateTeacher(Teacher teacher) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl?endpoint=teachers'),
      body: json.encode(teacher.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      await fetchTeachers();
    } else {
      _error = 'Failed to update teacher';
      notifyListeners();
    }
  } catch (e) {
    _error = 'Error updating teacher: $e';
    notifyListeners();
  }
}

Future<void> deleteTeacher(String id) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl?endpoint=teachers'),
      body: json.encode({'id': id}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      await fetchTeachers();
    } else {
      _error = 'Failed to delete teacher';
      notifyListeners();
    }
  } catch (e) {
    _error = 'Error deleting teacher: $e';
    notifyListeners();
  }
}

Future<void> fetchStudents() async {
    try {
      // Add debug print
      print('Fetching students from: $baseUrl?endpoint=students');
      
      final response = await http.get(Uri.parse('$baseUrl?endpoint=students'));
      
      // Debug response
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _students = data.map((json) => Student.fromJson(json)).toList();
        _error = null;
        notifyListeners();
      } else {
        _error = 'Failed to fetch students. Status code: ${response.statusCode}';
        _students = [];
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching students: $e');
      _error = 'Error fetching students: $e';
      _students = [];
      notifyListeners();
    }
  }

  Future<void> addStudent(Student student) async {
    try {
      print('Adding student: ${json.encode(student.toJson())}');
      
      final response = await http.post(
        Uri.parse('$baseUrl?endpoint=students'),
        body: json.encode(student.toJson()),
        headers: {'Content-Type': 'application/json'},
      );

      print('Add student response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        await fetchStudents();
      } else {
        _error = 'Failed to add student. Status code: ${response.statusCode}';
        notifyListeners();
      }
    } catch (e) {
      print('Error adding student: $e');
      _error = 'Error adding student: $e';
      notifyListeners();
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl?endpoint=students'),
        body: json.encode(student.toJson()),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await fetchStudents();
      } else {
        _error = 'Failed to update student';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error updating student: $e';
      notifyListeners();
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl?endpoint=students'),
        body: json.encode({'id': id}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await fetchStudents();
      } else {
        _error = 'Failed to delete student';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error deleting student: $e';
      notifyListeners();
    }
  }
}
