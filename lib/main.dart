import 'package:api_demo/chat_bot_screen.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Bot Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatBot(
        userId: 'Abdo', 
        userName: 'John', 
      ),
    );
  }
}























// import 'dart:convert';
// import 'package:http/http.dart' as http;

// void main() {
//   final String apiUrl = 'https://nationally-precise-stork.ngrok-free.app/chat'; 
//   final String userId = 'Abdo'; 
//   final String userInput = 'What did i just say?'; 

//   sendMessage(apiUrl, userId, userInput);
// }

// Future<void> sendMessage(String apiUrl, String userId, String userInput) async {
//   try {
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       body: {
//         'user_id': userId,
//         'user_input': userInput,
//       },
//     );

//     if (response.statusCode == 200) {
//       print('Response: ${response.body}');
//     } else {
//       print('Error: ${response.reasonPhrase}');
//     }
//   } catch (e) {
//     print('Exception caught: $e');
//   }
// }
