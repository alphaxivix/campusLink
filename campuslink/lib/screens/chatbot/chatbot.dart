import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/profile.dart';
import 'google_service.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({Key? key}) : super(key: key);
  
  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  
  String _institution = '';
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> _chatHistory = [];
  int _currentChatIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadInstitution();
  }

  Future<void> _loadInstitution() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _institution = prefs.getString('institution') ?? '';
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    if (_institution.isEmpty) {
      _addMessage('system', 'Institution information not available. Please set up your profile first.');
      return;
    }

    setState(() {
      _isLoading = true;
      _addMessage('user', message);
      _messageController.clear();
    });

    try {
      final response = await _geminiService.sendMessage(message, _institution);
      _addMessage('bot', response);
    } catch (e) {
      _addMessage('system', 'Failed to process your request. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addMessage(String sender, String content) {
    setState(() {
      _messages.add({'sender': sender, 'content': content});
      
      if (_currentChatIndex == -1) {
        _chatHistory.add({
          'title': 'Chat ${_chatHistory.length + 1}',
          'messages': List.from(_messages)
        });
        _currentChatIndex = _chatHistory.length - 1;
      } else {
        _chatHistory[_currentChatIndex]['messages'] = List.from(_messages);
      }
    });
    
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _currentChatIndex = -1;
    });
    Navigator.pop(context);
  }

  void _loadChat(int index) {
    setState(() {
      _messages = List<Map<String, String>>.from(
        _chatHistory[index]['messages']
      );
      _currentChatIndex = index;
    });
    Navigator.pop(context);
  }

  void _deleteChat(int index) {
    setState(() {
      _chatHistory.removeAt(index);
      if (index == _currentChatIndex) {
        _currentChatIndex = -1;
        _messages.clear();
      }
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      drawer: _buildDrawer(theme),
      appBar: AppBar(
        title: const Text('Campus Assistant'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(theme),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              ),
            ),
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Center(
              child: Text(
                "Conversations",
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('New Conversation'),
            onTap: _startNewChat,
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) => ListTile(
                selected: index == _currentChatIndex,
                leading: const Icon(Icons.chat_bubble_outline),
                title: Text(_chatHistory[index]['title']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteChat(index),
                ),
                onTap: () => _loadChat(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return MessageBubble(
          message: message['content'] ?? '',
          sender: message['sender'] ?? '',
          theme: theme,
        );
      },
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.dividerColor,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final String sender;
  final ThemeData theme;

  const MessageBubble({
    required this.message,
    required this.sender,
    required this.theme,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSystem = sender == 'system';
    final bool alignRight = sender == 'user';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,  // Align to top
        children: [
          if (!alignRight)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: isSystem 
                    ? theme.colorScheme.error.withOpacity(0.1)
                    : theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  isSystem ? Icons.info : Icons.smart_toy,
                  color: isSystem 
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: alignRight
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : isSystem
                        ? theme.colorScheme.error.withOpacity(0.1)
                        : theme.cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(alignRight ? 12 : 4),
                  topRight: Radius.circular(alignRight ? 4 : 12),
                  bottomLeft: const Radius.circular(12),
                  bottomRight: const Radius.circular(12),
                ),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.5),
                  width: 0.5,
                ),
              ),
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSystem
                      ? theme.colorScheme.error
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
          if (alignRight)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}