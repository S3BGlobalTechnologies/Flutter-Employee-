import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/src/panel.dart';
import 'package:employee/model/user.dart';
import 'package:http/http.dart'as http;
import 'dart:convert';

class PostScreen extends StatefulWidget {
  const PostScreen({
    super.key,
    required this.panelController,
  });

  final PanelController panelController;
  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final messageController = TextEditingController();

  final currentUser = FirebaseAuth.instance.currentUser;
  late Future<UserModel> fetchUser;
  Future<void> postThreadMessage(String username) async {
    try {
      if (messageController.text.isNotEmpty) {
        await FirebaseFirestore.instance.collection('threads').add({
          'id': currentUser!.uid,
          'sender': username,
          'message': messageController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
        messageController.clear();
        widget.panelController.close();
      }
    } catch (e) {
      rethrow;
    }
  }

    final String lmStudioApiUrl = 'http://192.168.29.18:1234/v1/completions';
  final String modelName = 'LM Studio Community/Meta-Llama-3-8B-Instruct-GGUF';
  String summaryText = ""; // To store the generated summary

  Future<String> generateSummary(String text) async {
    final response = await http.post(
      Uri.parse(lmStudioApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': modelName,
        'prompt': "Summarize this text: $text",
        'max_tokens': 100,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['text'];
    } else {
      throw Exception('Failed to generate summary');
    }
  }

  Future<UserModel> fetchUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      final user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    fetchUser = fetchUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<UserModel>(
          future: fetchUser,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final user = snapshot.data;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          widget.panelController.close();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Text(
                        'Leave a comment',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      TextButton(
                        onPressed: () => postThreadMessage(user?.name ?? ""),
                        child: const Text(
                          'Post',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(thickness: 1),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        foregroundImage:
                            NetworkImage(user?.profileImageUrl ?? ""),
                        radius: 25,
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              user?.username ?? "",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextFormField(
                              controller: messageController,
                              decoration: const InputDecoration(
                                hintText: 'Start a request',
                                hintStyle: TextStyle(fontSize: 14),
                                border: InputBorder.none,
                              ),
                              maxLines: null,
                              style: const TextStyle(fontSize: 14),
                            ),



TextButton(
        onPressed: () async {
          try {
            final summary = await generateSummary(messageController.text);
            setState(() {
              summaryText = summary; // Update the summaryText state
            });
          } catch (e) {
            print('Error: $e');
          }
        },
        child: Text('Generate Summary', style: TextStyle(fontWeight: FontWeight.bold)),
      ),

      // Display the generated summary below the button
      if (summaryText.isNotEmpty) 
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(summaryText),
        ),


                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          }),
    );
  }
}
