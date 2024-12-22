// models.dart

class Teacher {
  final String id;
  final String name;
  final String username;
  final String password;
  final String subject;
  final String qualification;
  final String experience;
  final String contact;
  final String email;

  Teacher({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.subject,
    required this.qualification,
    required this.experience,
    required this.contact,
    required this.email,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      password: json['password'] ?? '',
      subject: json['subject'],
      qualification: json['qualification'],
      experience: json['experience'],
      contact: json['contact'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'subject': subject,
      'qualification': qualification,
      'experience': experience,
      'contact': contact,
      'email': email,
    };
  }

  Teacher copyWith({
    String? name,
    String? username,
    String? password,
    String? subject,
    String? qualification,
    String? experience,
    String? contact,
    String? email,
  }) {
    return Teacher(
      id: this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      subject: subject ?? this.subject,
      qualification: qualification ?? this.qualification,
      experience: experience ?? this.experience,
      contact: contact ?? this.contact,
      email: email ?? this.email,
    );
  }
}

class Student {
  final String id;
  final String name;
  final String username;
  final String password;
  final String grade;
  final String section;
  final String contact;
  final String email;

  Student({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.grade,
    required this.section,
    required this.contact,
    required this.email,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      password: json['password'] ?? '',
      grade: json['grade'],
      section: json['section'],
      contact: json['contact'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'grade': grade,
      'section': section,
      'contact': contact,
      'email': email,
    };
  }

  Student copyWith({
    String? name,
    String? username,
    String? password,
    String? grade,
    String? section,
    String? contact,
    String? email,
  }) {
    return Student(
      id: this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      contact: contact ?? this.contact,
      email: email ?? this.email,
    );
  }
}