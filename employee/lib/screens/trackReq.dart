import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class EmployeeLeaveRequestsPage extends StatefulWidget {
  @override
  _EmployeeLeaveRequestsPageState createState() =>
      _EmployeeLeaveRequestsPageState();
}

class _EmployeeLeaveRequestsPageState
    extends State<EmployeeLeaveRequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = FirebaseAuth.instance.currentUser!.uid;
  bool _isDarkMode = false;
  Map<String, String> _analysisResults = {};
  bool _analyzing = false;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'leave_request_channel',
      'Leave Requests',
      importance: Importance.high,
    );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _loadDarkModePreference();
    _requestNotificationPermission();
  }

  Future<void> _loadDarkModePreference() async {}

  Stream<QuerySnapshot<Map<String, dynamic>>> get _leaveRequestsStream {
    return _firestore
        .collection('holiday_requests')
        .where('user_id', isEqualTo: _userId)
        .snapshots();
  }

  Future<void> analyzeLeaveRequests(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> leaveRequests) async {
    setState(() => _analyzing = true);
    final String lmStudioApiUrl = 'http://192.168.29.18:1234/v1/completions';

    for (var request in leaveRequests) {
      final requestData = request.data();
      final response = await http.post(
        Uri.parse(lmStudioApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'your_local_llm_model',
          'prompt':
              'Classify this leave request as genuine or non-genuine:\n\n${jsonEncode(requestData)}',
          'max_tokens': 50,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        setState(() {
          _analysisResults[request.id] =
              result['choices'][0]['text'].trim();
        });
      }
    }
    setState(() => _analyzing = false);
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      // Permission granted
    } else if (status.isDenied) {
      // Permission denied
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.deepPurple,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('My Leave Requests',
              style: GoogleFonts.pacifico(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black)),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
            ),
            IconButton(
              icon: Icon(Icons.analytics),
              onPressed: _analyzing
                  ? null
                  : () async {
                      final snapshot = await _leaveRequestsStream.first;
                      analyzeLeaveRequests(snapshot.docs);
                    },
            ),
          ],
          backgroundColor: Colors.deepPurple,
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _leaveRequestsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: GoogleFonts.lato()));
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());

            final leaveRequests = snapshot.data!.docs;

            _showLeaveStatusNotification(leaveRequests);

            return _buildLeaveRequestList(leaveRequests);
          },
        ),
      ),
    );
  }

  Widget _buildLeaveRequestList(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> leaveRequests) {
    return ListView.builder(
      itemCount: leaveRequests.length,
      itemBuilder: (context, index) {
        final request = leaveRequests[index];
        final requestData = request.data();
        final startDate = DateTime.parse(requestData['start_date']);
        final endDate = DateTime.parse(requestData['end_date']);
        final totalDays = requestData['total_days'];
        final reason = requestData['reason'];
        final status = requestData['status'] ?? 'pending';
        final leaveType = requestData['leave_type'] ?? 'Unknown';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: _isDarkMode ? Colors.grey[800] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Leave Type: $leaveType',
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                    'Dates: ${DateFormat('yMd').format(startDate)} - ${DateFormat('yMd').format(endDate)}',
                    style: GoogleFonts.lato()),
                Text('Total Days: $totalDays', style: GoogleFonts.lato()),
                Text('Reason: $reason', style: GoogleFonts.lato()),
                Text(
                  'Status: $status',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    color: status == 'approved'
                        ? Colors.green
                        : (status == 'rejected'
                            ? Colors.red
                            : Colors.orange),
                  ),
                ),
                Text(
                    'Analysis: ${_analysisResults[request.id] ?? (_analyzing ? "Analyzing..." : "Not analyzed")}',
                    style: GoogleFonts.lato()),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLeaveStatusNotification(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> leaveRequests) async {
    for (var request in leaveRequests) {
      final requestData = request.data();
      final status = requestData['status'] ?? 'pending';

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              'leave_request_channel', 'Leave Requests',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: false);
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          0, 'Leave Request Update', 'Your leave request is now $status.',
          platformChannelSpecifics,
          payload: 'item x');
    }
  }
}