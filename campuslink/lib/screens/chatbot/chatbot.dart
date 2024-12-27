import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../widgets/profile.dart';
import '../chatbot/rasa_service.dart';

class Chatbot extends StatefulWidget {
  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> with SingleTickerProviderStateMixin {
  final RasaService _rasaService = RasaService();
  final TextEditingController _controller = TextEditingController();
  List<String> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isEmojiPickerVisible = false;
  
  String _welcomeText = '';
  final String _fullWelcomeText = 'Welcome to Campus Master';
  late AnimationController _animationController;
  
  List<Map<String, dynamic>> _chatHistory = [];
  int _currentChatIndex = -1;

  final List<String> _emojis = [
    '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂', '🙂', '🙃', 
    '😉', '😊', '😇', '🥰', '😍', '🤩', '😘', '😗', '😚', '😙', 
    '😋', '😛', '😜', '🤪', '😝', '🤑', '🤗', '🤭', '🤫', '🤔', 
    '🤐', '🤨', '😐', '😑', '😶', '😏', '😒', '🙄', '😬', '🤥', 
    '😌', '😔', '😪', '🤤', '😴', '😷', '🤒', '🤕', '🤢', '🤮'
  ];

  final Map<String, String> _predefinedResponses = {
    'hi': 'Hello! How can I assist you today?',
    'hello': 'Hi there! Welcome to Campus Master. How can I help you?',
    'hey': 'Hey! What can I do for you?',
    'who are you': 'I am Campus Master, an AI assistant designed to help you with campus-related queries.',
    'what is your name': 'I\'m Campus Master, your friendly AI assistant.',
    'help': 'I\'m here to help! What information are you looking for?',
  };

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Rest of the methods remain the same...
  void _sendMessage() async {
    String message = _controller.text.trim().toLowerCase();
    if (message.isNotEmpty) {
      setState(() {
        _messages.add("You: $message");
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
        if (_predefinedResponses.containsKey(message)) {
          _addBotMessage(_predefinedResponses[message]!);
          return;
        }

        var response = await _rasaService.sendMessage(message);
        if (response.isNotEmpty) {
          _addBotMessage(response[0]['text']);
        } else {
          _addBotMessage("I'm not sure how to respond to that. Could you rephrase or ask something else?");
        }
      } catch (e) {
        _addBotMessage("Sorry, I couldn't connect to the server. Please try again later.");
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Chatbot()),
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
          duration: Duration(milliseconds: 300),
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
                  "Guest Menu",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            ExpansionTile(
              leading: Icon(Icons.history, color: theme.colorScheme.onBackground),
              title: Text('Chat History', style: theme.textTheme.titleMedium),
              children: [
                _chatHistory.isEmpty
                    ? Center(
                        child: Text(
                          'No previous chats',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _chatHistory.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              _chatHistory[index]['title'],
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: _currentChatIndex == index
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            onTap: () => _loadChat(index),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: theme.colorScheme.error),
                              onPressed: () => _deleteChat(index),
                            ),
                          );
                        },
                      ),
                ListTile(
                  leading: Icon(Icons.add, color: theme.colorScheme.onBackground),
                  title: Text('Start New Chat', style: theme.textTheme.bodyLarge),
                  onTap: _startNewChat,
                ),
              ],
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('Chatbot'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: theme.colorScheme.background,
        child: Column(
          children: [
            Expanded(
              child: _welcomeText.isEmpty
                  ? SizedBox.shrink()
                  : Center(
                      child: Text(
                        _welcomeText,
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
            ),
            Expanded(
              flex: 2,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  bool isUserMessage = _messages[index].startsWith("You:");
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: isUserMessage
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isUserMessage)
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                            child: Icon(Icons.smart_toy, color: theme.colorScheme.primary),
                          ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: isUserMessage
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                isUserMessage ? 'You' : 'Campus_Master',
                                style: theme.textTheme.bodySmall,
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  color: isUserMessage
                                      ? theme.colorScheme.primary.withOpacity(0.2)
                                      : theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _messages[index].substring(4),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isUserMessage)
                          SizedBox(width: 8),
                        if (isUserMessage)
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                            child: Icon(Icons.person, color: theme.colorScheme.primary),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_isEmojiPickerVisible)
              Container(
                height: 250,
                color: theme.colorScheme.surface,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
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
                          style: TextStyle(fontSize: 24)
                        ),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TextField(
                    controller: _controller,
                    cursorColor: theme.colorScheme.primary,
                    textAlignVertical: TextAlignVertical.center,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Chat with Campus Master...',
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 50.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10.0,
                    child: IconButton(
                      icon: Icon(Icons.emoji_emotions, color: theme.colorScheme.primary),
                      onPressed: () {
                        setState(() {
                          _isEmojiPickerVisible = !_isEmojiPickerVisible;
                        });
                      },
                    ),
                  ),
                  Positioned(
                    right: 10.0,
                    child: IconButton(
                      icon: Icon(Icons.send, color: theme.colorScheme.primary),
                      onPressed: _sendMessage,
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
}