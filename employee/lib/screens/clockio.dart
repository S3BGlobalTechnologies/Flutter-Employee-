import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ClockInOutPage extends StatefulWidget {
  @override
  _ClockInOutPageState createState() => _ClockInOutPageState();
}

class _ClockInOutPageState extends State<ClockInOutPage> {
  final _firestore = FirebaseFirestore.instance;
  bool _clockedIn = false;
  DateTime? _clockInTime;
  String? _username;
  bool _isLoading = false;
  late VideoPlayerController _controller;
  Position? userLocation;
  String? latestClockInDocId;

  final String lmStudioApiUrl = 'http://192.168.29.18:1234/v1/completions';
  final String modelName = 'LM Studio Community/Meta-Llama-3-8B-Instruct-GGUF';

  Future<String> analyzeSentiment(String prompt) async {
    final response = await http.post(
      Uri.parse(lmStudioApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': modelName,
        'prompt': "Analyze the sentiment of this text: '$prompt'",
        'max_tokens': 10,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['text'].trim();
    } else {
      throw Exception('Failed to analyze sentiment');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkClockStatus();
    _getCurrentUserName();
    _getUserLocation();
    _controller = VideoPlayerController.asset('assets/your_video.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _checkClockStatus() async {
    final querySnapshot = await _firestore
        .collection('employee_clock_in_out')
        .where('employee_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .orderBy('clock_in_time', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      if (doc['clock_out_time'] == null) {
        setState(() {
          _clockedIn = true;
          _clockInTime = DateTime.parse(doc['clock_in_time']);
          latestClockInDocId = doc.id;
        });
      }
    }
  }

  Future<void> _getCurrentUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData =
            await _firestore.collection('users').doc(user.uid).get();
        setState(() {
          _username = userData['username'] as String?;
        });
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Location permissions are denied. Please enable them in app settings.'),
      ));
      return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        userLocation = position;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clock In/Out'),
        backgroundColor: Colors.deepPurple,
      ),
       drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
       const     DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF7868E6),
                    Color(0xFF9B89B3),
                  ],
                ),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {


              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          if (_controller.value.isInitialized)
            SizedBox.expand(child: VideoPlayer(_controller)),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 243, 131, 5),
                  Color.fromARGB(137, 206, 58, 58)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_username != null)
                      Text(
                        'Hello, $_username!',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    SizedBox(height: 30),
                    Icon(
                      _clockedIn ? Icons.access_time : Icons.timer_off,
                      size: 80,
                      color: _clockedIn ? Colors.green : Colors.red,
                    ),
                    SizedBox(height: 10),
                    Text(
                      _clockedIn ? 'Clocked In' : 'Clocked Out',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                    ),
                    if (_clockedIn)
                      Text(
                        DateFormat('h:mm a, EEEE, MMMM d')
                            .format(_clockInTime!),
                        style: TextStyle(fontSize: 16),
                      ),
                    if (userLocation != null)
                      Text(
                        'Location: ${userLocation!.latitude}, ${userLocation!.longitude}',
                        style: TextStyle(fontSize: 16),
                      ),
                    SizedBox(height: 40),
                    SlideAction(
                      onSubmit: _clockedIn ? _clockOut : _clockIn,
                      text: _clockedIn
                          ? 'Slide to Clock Out'
                          : 'Slide to Clock In',
                      innerColor: _clockedIn ? Colors.red : Colors.green,
                      outerColor:
                          _clockedIn ? Colors.red[100]! : Colors.green[100]!,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clockIn() async {
    setState(() {
      _isLoading = true;
      _clockedIn = true;
      _clockInTime = DateTime.now();
    });

    try {
      final docRef = await _firestore.collection('employee_clock_in_out').add({
        'employee_id': FirebaseAuth.instance.currentUser!.uid,
        'clock_in_time': _clockInTime!.toIso8601String(),
        'location': GeoPoint(userLocation!.latitude, userLocation!.longitude),
        'username': _username,
      });

      setState(() {
        latestClockInDocId = docRef.id;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Successfully clocked in!')));
    } catch (e) {
      print('Error clocking in: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error clocking in. Please try again.')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clockOut() async {
    if (userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('Location is not available. Please enable location services.'),
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? feedback;

    feedback = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('How was your day?'),
        content: TextField(
          onChanged: (text) {
            feedback = text; 
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, feedback),
              child: Text('Submit')),
        ],
      ),
    );

    if (feedback != null) {
      try {
      final sentiment = await analyzeSentiment(feedback ?? ''); 
        await _firestore
            .collection('employee_clock_in_out')
            .doc(latestClockInDocId)
            .update({'sentiment': sentiment});
      } catch (e) {
        print('Error analyzing sentiment: $e');
      }
    }

    try {
      if (latestClockInDocId != null) {
        await _firestore
            .collection('employee_clock_in_out')
            .doc(latestClockInDocId)
            .update({
          'clock_out_time': DateTime.now().toIso8601String(),
          'clock_out_latitude': userLocation!.latitude,
          'clock_out_longitude': userLocation!.longitude,
        });
        setState(() {
          _clockedIn = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully clocked out!')));
      } else {
        print("No active clock-in found.");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No active clock-in found.')));
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error clocking out: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error clocking out. Please try again.')));
      setState(() {
        _isLoading = false;
      });
    }
  }
}