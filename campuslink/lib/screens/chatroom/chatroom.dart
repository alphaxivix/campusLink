import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../profile.dart';


class Chatroom extends StatefulWidget {
  @override
  _ChatroomState createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {

  final TextEditingController _controller = TextEditingController();
  List<String> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isEmojiPickerVisible = false;


  final List<String> _emojis = [
    '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂', '🙂', '🙃', 
    '😉', '😊', '😇', '🥰', '😍', '🤩', '😘', '😗', '😚', '😙', 
    '😋', '😛', '😜', '🤪', '😝', '🤑', '🤗', '🤭', '🤫', '🤔', 
    '🤐', '🤨', '😐', '😑', '😶', '😏', '😒', '🙄', '😬', '🤥', 
    '😌', '😔', '😪', '🤤', '😴', '😷', '🤒', '🤕', '🤢', '🤮'
  ];

  void _sendMessage() {
    String message = _controller.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _messages.add("You: $message");
      });
      _controller.clear();
      _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 39, 46, 58),
        title: Text('Chatroom', style: TextStyle(color: Colors.white)),
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
                            child: Icon(Icons.person, color: Colors.blue.shade700),
                          ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: isUserMessage
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                isUserMessage ? 'You' : 'User',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 12,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
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
                                    color: isUserMessage
                                        ? Colors.black
                                        : Colors.white,
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
            // Emoji Picker
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
            // Message Input Area
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
                      hintText: 'Say something...',
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
