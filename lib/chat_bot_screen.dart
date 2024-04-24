import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatBot extends StatefulWidget {
  final String? userId;
  final String? userName;

  const ChatBot({ this.userId,  this.userName});

  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final TextEditingController _textEditingController = TextEditingController();
  List <dynamic> _messages = [];
  bool _isBotTyping = false;
   
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    _initMessages();
  }


   void _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    List<dynamic>? storedMessages = _prefs.getStringList('chat_history');
    if (storedMessages != null) {
      setState(() {
        _messages = storedMessages.map((msg) => json.decode(msg)).toList();
      });
    }
  }

   Future<void> _saveMessagesToPrefs() async {
    List<String> encodedMessages = _messages.map((msg) => json.encode(msg)).toList();
    await _prefs.setStringList('chat_history', encodedMessages);
  }

  Future<void> _initMessages() async {
    setState(() {
      _messages = [
        {
          'message': 'Hi there! My name is Ozey and I am here to support you on your journey to emotional well-being.',
          'isUserMessage': false,
        },
        {
          'message': "How are you feeling today? Feel free to share anything that's on your mind - I'm here to listen and help.",
          'isUserMessage': false,
        },
      ];
    });
  }

  Future<String> _callAIModelAPI(String message, String userId) async {
    final url = Uri.parse('https://nationally-precise-stork.ngrok-free.app/chat');
    try {
      final response = await http.post(
        url,
        body: {
          'user_input': message,
          'user_id': userId,
        },
      );
      
      return response.body;
      // print('Response from API: ${response}'); 

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['response'];
      } else {
        throw Exception('Failed to get response from AI model');
      }
    } catch (e) {
      print('Error calling AI model API: $e');
      rethrow;
    }
  }

  Future<void> _sendMessage(String message) async {
  String userId = widget.userId ?? "Ahmedr";

  setState(() {
    _messages.add({
      'message': message,
      'isUserMessage': true,
    });
    _isBotTyping = true; // Set it to true before calling API
  });

  print('Sending message to API: $message'); // Print user's message before sending to API

  try {
    print("I am in try");
    final String response2 = await _callAIModelAPI(message, userId);
    print(response2 + "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
    if (response2.isNotEmpty) {
      setState(() {
        _messages.add({
          'message': response2,
          'isUserMessage': false,
        });
        _isBotTyping = false; // Set it to false after receiving the response
      });
      print('Received response from API: $response2'); // Print API response
    } else {
      print('Empty response received from API'); // Print message if response is empty
    }
  } catch (e) {
    // Handle errors from AI model API call
    print('Error sending message: $e');
    setState(() {
      _messages.add({
        'message': 'Oops! Something went wrong. Please try again later.',
        'isUserMessage': false,
      });
      _isBotTyping = false; // Set it to false even if there's an error
    });
  }

  await _saveMessagesToPrefs();
  _textEditingController.clear();
}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soothe Bot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUserMessage = message['isUserMessage'] as bool;
                return Align(
                  alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUserMessage ? Colors.blueAccent : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isUserMessage ? 16 : 0),
                        topRight: Radius.circular(isUserMessage ? 0 : 16),
                        bottomLeft: const Radius.circular(16),
                        bottomRight: const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      message['message'] as String,
                      style: TextStyle(
                        color: isUserMessage ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _isBotTyping
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Typing...',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 2,
                          spreadRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _textEditingController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    String message = _textEditingController.text;
                    _sendMessage(message);
                  },
                  icon: const Icon(Icons.send),
                  color: const Color.fromARGB(255, 172, 209, 209),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}