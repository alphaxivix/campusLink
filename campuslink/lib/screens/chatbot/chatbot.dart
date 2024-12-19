import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../profile.dart';
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
  
  // Animated Welcome Message
  String _welcomeText = '';
  final String _fullWelcomeText = 'Welcome to Campus Master';
  late AnimationController _animationController;
  
  // Chat history variables
  List<Map<String, dynamic>> _chatHistory = [];
  int _currentChatIndex = -1;

  // Emoji List
  final List<String> _emojis = [
    '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂', '🙂', '🙃', 
    '😉', '😊', '😇', '🥰', '😍', '🤩', '😘', '😗', '😚', '😙', 
    '😋', '😛', '😜', '🤪', '😝', '🤑', '🤗', '🤭', '🤫', '🤔', 
    '🤐', '🤨', '😐', '😑', '😶', '😏', '😒', '🙄', '😬', '🤥', 
    '😌', '😔', '😪', '🤤', '😴', '😷', '🤒', '🤕', '🤢', '🤮'
  ];

  // Predefined Responses
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
    
    // Animation Controller for Welcome Text
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..addListener(() {
        setState(() {
          _welcomeText = _fullWelcomeText.substring(0, (_fullWelcomeText.length * _animationController.value).round());
        });
      });
    
    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
        // Check for predefined responses first
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
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 39, 46, 58)),
              child: Center(
                child: Text(
                  "Guest Menu",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            // Chat History as an Expansion Tile within the main drawer
            ExpansionTile(
              leading: Icon(Icons.history),
              title: Text('Chat History'),
              children: [
                _chatHistory.isEmpty
                    ? Center(
                        child: Text(
                          'No previous chats',
                          style: TextStyle(color: Colors.grey),
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
                              style: TextStyle(
                                color: _currentChatIndex == index
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                            ),
                            onTap: () => _loadChat(index),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteChat(index),
                            ),
                          );
                        },
                      ),
                ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Start New Chat'),
                  onTap: _startNewChat,
                ),
              ],
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 46, 58),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('Chatbot', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
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
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: _welcomeText.isEmpty
                  ? SizedBox.shrink()
                  : Center(
                      child: Text(
                        _welcomeText,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
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
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(Icons.smart_toy, color: Colors.blue.shade700),
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
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  color: isUserMessage
                                      ? Colors.blue.shade100
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _messages[index].substring(4),
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                  ),
                                  softWrap: true,
                                  maxLines: null,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isUserMessage)
                          SizedBox(width: 8),
                        if (isUserMessage)
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(Icons.person, color: Color.fromARGB(255, 52, 93, 138)),
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
                color: Colors.white,
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
                  // Input Field
                  TextField(
                    controller: _controller,
                    cursorColor: Colors.blue.shade700,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(color: Colors.grey[800]),
                    decoration: InputDecoration(
                      hintText: 'Chat with Campus Master...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 50.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                  ),
                  // Emoji Picker Icon
                  Positioned(
                    left: 10.0,
                    child: IconButton(
                      icon: Icon(Icons.emoji_emotions, color: const Color.fromARGB(255, 52, 93, 138)),
                      onPressed: () {
                        setState(() {
                          _isEmojiPickerVisible = !_isEmojiPickerVisible;
                        });
                      },
                    ),
                  ),
                  // Send Button
                  Positioned(
                    right: 10.0,
                    child: IconButton(
                      icon: Icon(Icons.send, color: const Color.fromARGB(255, 52, 93, 138)),
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