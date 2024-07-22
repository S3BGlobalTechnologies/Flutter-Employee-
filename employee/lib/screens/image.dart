import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class ImageGenerationPage extends StatefulWidget {
  @override
  _ImageGenerationPageState createState() => _ImageGenerationPageState();
}

class _ImageGenerationPageState extends State<ImageGenerationPage> {
  final TextEditingController _promptController = TextEditingController();
  Uint8List? _generatedImage;
  bool _isLoading = false;
  String lmStudioApiUrl = 'http://localhost:1234/v1/completions'; // Replace with your LM Studio port
  String modelName = 'LM Studio Community/Meta-Llama-3-8B-Instruct-GGUF'; // Replace with your model's name

  Future<void> generateImage(String prompt) async {
    setState(() {
      _isLoading = true;
      _generatedImage = null; // Clear previous image
    });

    try {
      final response = await http.post(
        Uri.parse(lmStudioApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': modelName,
          'prompt': prompt,
          // Add any additional parameters your model might need (e.g., width, height, number of images)
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final imageData = responseData['images'][0]; // Assuming the response has a list of images

        // Decode the base64 encoded image data
        setState(() {
          _generatedImage = base64Decode(imageData);
        });
      } else {
        throw Exception('Failed to generate image: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle the error (e.g., show a snackbar to the user)
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Generation')),
      body: SingleChildScrollView( // Make the content scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _promptController,
                decoration: InputDecoration(hintText: 'Enter your prompt'),
                maxLines: null, // Allow multiple lines for longer prompts
              ),
              ElevatedButton(
                onPressed: () => generateImage(_promptController.text),
                child: Text('Generate Image'),
              ),
              SizedBox(height: 20),
              if (_isLoading) CircularProgressIndicator(),
              if (_generatedImage != null)
                Image.memory(_generatedImage!), 
            ],
          ),
        ),
      ),
    );
  }
}
