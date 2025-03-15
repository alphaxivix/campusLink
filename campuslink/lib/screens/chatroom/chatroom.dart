import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../widgets/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campuslink/data/config.dart';
import 'package:campuslink/data/config.dart';

class Chatroom extends StatefulWidget {
  const Chatroom({super.key});

  @override
  _ChatroomState createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isEmojiPickerVisible = false;
  String? userData;
  Timer? _timer;

  final List<String> _emojis = [
    '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂', '🙂', '🙃', 
    '😉', '😊', '😇', '🥰', '😍', '🤩', '😘', '😗', '😚', '😙', 
    '😋', '😛', '😜', '🤪', '😝', '🤑', '🤗', '🤭', '🤫', '🤔', 
    '🤐', '🤨', '😐', '😑', '😶', '😏', '😒', '🙄', '😬', '🤥', 
    '😌', '😔', '😪', '🤤', '😴', '😷', '🤒', '🤕', '🤢', '🤮'
  ];

  @override
  void initState() {
    super.initState();
    loadUserData();
    _fetchMessages();
    _startFetchingMessages();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userData = prefs.getString('userId');
    });
  }

  Future<void> _fetchMessages() async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/clink/api/chatroom/chats.php'));
    if (response.statusCode == 200) {
      final List<dynamic> messagesJson = json.decode(response.body);
      setState(() {
        _messages.clear();
        for (var messageJson in messagesJson) {
          _messages.add(ChatMessage(
            text: messageJson['text'],
            sender: messageJson['sender'],
            timestamp: DateTime.parse(messageJson['timestamp']),
          ));
        }
      });
      _scrollToBottom();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<void> _sendMessage() async {
    String message = _controller.text.trim();
    if (message.isNotEmpty) {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/clink/api/chatroom/chats.php'),
        body: {
          'text': message,
          'sender': userData,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _messages.add(ChatMessage(
            text: message,
            sender: 'You',
            timestamp: DateTime.now(),
          ));
        });
        _controller.clear();
        _scrollToBottom();
      } else {
        throw Exception('Failed to send message');
      }
    }
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startFetchingMessages() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchMessages();
    });
  }

// ...existing code...

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  
  return Scaffold(
    backgroundColor: const Color(0xFF1A1D21), // Dark background
    appBar: AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF252A34),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.chat_bubble, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Campus Chat',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_messages.length} messages',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_circle, color: theme.colorScheme.primary),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          ),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF252A34),
            const Color(0xFF1A1D21),
          ],
        ),
      ),
      child: Column(
        children: [
          // Update the ListView.builder section in the build method
Expanded(
  child: ListView.builder(
    reverse: false, // Change to false to show messages in correct order
    controller: _scrollController,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    itemCount: _messages.length,
    itemBuilder: (context, index) {
      final message = _messages[index];
      final isMe = message.sender == userData;
      final showDate = index == 0 || 
          !_isSameDay(
            message.timestamp,
            _messages[index - 1].timestamp
          );
      
      return Column(
        children: [
          if (showDate)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatDate(message.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isMe 
                    ? Theme.of(context).colorScheme.primary 
                    : const Color.fromARGB(255, 5, 155, 255).withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 20),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        message.sender,
                        style: TextStyle(
                          color: const Color.fromARGB(179, 255, 222, 5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  ),
),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF252A34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              children: [
                if (_isEmojiPickerVisible)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D21),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: _emojis.length,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          _controller.text += _emojis[index];
                          setState(() => _isEmojiPickerVisible = false);
                        },
                        child: Center(
                          child: Text(_emojis[index], style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.emoji_emotions,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () => setState(() => _isEmojiPickerVisible = !_isEmojiPickerVisible),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
// ...existing code...

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final String sender;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}