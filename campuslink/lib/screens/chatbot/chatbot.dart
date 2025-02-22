import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/profile.dart';
import 'google_service.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({Key? key}) : super(key: key);
  
  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  
  String institution = '';  // Add institution variable
  List<String> _messages = [];
  bool _isEmojiPickerVisible = false;
  bool _isLoading = false;
  
  String _welcomeText = '';
  final String _fullWelcomeText = 'Welcome to Campus Master';
  late AnimationController _animationController;
  
  List<Map<String, dynamic>> _chatHistory = [];
  int _currentChatIndex = -1;

  final List<String> _emojis = [
    '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂', '🙂', '🙃',
    // ... rest of emojis
  ];

  @override
  void initState() {
    super.initState();
    loadUserData();  // Load institution data
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..addListener(() {
        setState(() {
          _welcomeText = _fullWelcomeText.substring(0, (_fullWelcomeText.length * _animationController.value).round());
        });
      });
    _animationController.forward();
  }

  // Add loadUserData method
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      institution = prefs.getString('institution') ?? '';
    });
    print('Institution loaded: $institution');
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

   void _sendMessage() async {
    String message = _controller.text.trim();
    if (message.isNotEmpty) {
      if (institution.isEmpty) {
        // Check if institution is loaded
        _addBotMessage("Sorry, institution information is not available. Please try again later.");
        return;
      }

      setState(() {
        _messages.add("You: $message");
        _isLoading = true;
        if (_currentChatIndex == -1) {
          _chatHistory.add({
            'title': 'New Chat ${_chatHistory.length + 1}',
            'messages': List.from(_messages)
          });
          _currentChatIndex = _chatHistory.length - 1;
        } else {
          _chatHistory[_currentChatIndex]['messages'] = List.from(_messages);
        }
      });
      _controller.clear();
      _scrollToBottom();

      try {
        String response = await _geminiService.sendMessage(message, institution);
        _addBotMessage(response);
      } catch (e) {
        _addBotMessage("Sorry, I couldn't process your request. Please try again later.");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add("Bot: $message");
      _chatHistory[_currentChatIndex]['messages'] = List.from(_messages);
    });
    _scrollToBottom();
  }

    void _startNewChat() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Chatbot()),
    );
  }

  void _loadChat(int index) {
    setState(() {
      _messages = List.from(_chatHistory[index]['messages']);
      _currentChatIndex = index;
      Navigator.pop(context);
    });
  }

  void _deleteChat(int index) {
    setState(() {
      _chatHistory.removeAt(index);
      if (index == _currentChatIndex) {
        _currentChatIndex = -1;
        _messages.clear();
      }
      Navigator.pop(context);
    });
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
              child: Center(
                child: Text(
                  "Chat History",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add, color: theme.colorScheme.primary),
              title: Text('New Chat', style: theme.textTheme.titleMedium),
              onTap: _startNewChat,
            ),
            const Divider(),
            ..._chatHistory.map((chat) => ListTile(
              title: Text(
                chat['title'],
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: _chatHistory.indexOf(chat) == _currentChatIndex
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              onTap: () => _loadChat(_chatHistory.indexOf(chat)),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: theme.colorScheme.error),
                onPressed: () => _deleteChat(_chatHistory.indexOf(chat)),
              ),
            )).toList(),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Campus Master'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: theme.colorScheme.background,
        child: Column(
          children: [
            if (_welcomeText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _welcomeText,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final isUserMessage = _messages[index].startsWith("You:");
                  final message = _messages[index].substring(5);
                  
                  return MessageBubble(
                    message: message,
                    isUser: isUserMessage,
                    theme: theme,
                  );
                },
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
            if (_isEmojiPickerVisible)
              Container(
                height: 250,
                color: theme.colorScheme.surface,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _emojis.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _controller.text += _emojis[index];
                        setState(() {
                          _isEmojiPickerVisible = false;
                        });
                      },
                      child: Center(
                        child: Text(
                          _emojis[index],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ChatInput(
              controller: _controller,
              onSend: _sendMessage,
              onEmojiTap: () {
                setState(() {
                  _isEmojiPickerVisible = !_isEmojiPickerVisible;
                });
              },
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

// Separate widget for message bubbles
class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final ThemeData theme;

  const MessageBubble({
    required this.message,
    required this.isUser,
    required this.theme,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              child: Icon(Icons.smart_toy, color: theme.colorScheme.primary),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary.withOpacity(0.2)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              child: Icon(Icons.person, color: theme.colorScheme.primary),
            ),
        ],
      ),
    );
  }
}

// Separate widget for chat input
class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onEmojiTap;
  final ThemeData theme;

  const ChatInput({
    required this.controller,
    required this.onSend,
    required this.onEmojiTap,
    required this.theme,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.emoji_emotions, color: theme.colorScheme.primary),
            onPressed: onEmojiTap,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: theme.colorScheme.primary),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}