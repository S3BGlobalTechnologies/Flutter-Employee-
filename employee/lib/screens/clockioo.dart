import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
// ... (other imports for your existing pages)

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clock In/Out App',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: EmployeeClockPage(),
    );
  }
}

class EmployeeClockPage extends StatefulWidget {
  @override
  _EmployeeClockPageState createState() => _EmployeeClockPageState();
}

class _EmployeeClockPageState extends State<EmployeeClockPage> {
  String? _username;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          _username = userDoc.data()?['username'] ?? 'Unknown User';
        });
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Employee Clock')),
      body: _username != null
          ? ClockInOutPage(username: _username!)
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class ClockInOutPage extends StatefulWidget {
  final String username;
  ClockInOutPage({required this.username});

  @override
  _ClockInOutPageState createState() => _ClockInOutPageState();
}

class _ClockInOutPageState extends State<ClockInOutPage> with SingleTickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false; 
  bool _clockedIn = false;
  DateTime? _clockInTime;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  StreamSubscription<QuerySnapshot>? _clockStatusSubscription;

  @override
  void initState() {
    super.initState();
    _fetchClockStatus(); 
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
  }

  Future<void> _fetchClockStatus() async {
    setState(() {
      _isLoading = true;
    }); 

    try {
      final querySnapshot = await _firestore
          .collection('employee_clock_in_out')
          .where('username', isEqualTo: widget.username)
          .orderBy('clock_in_time', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        setState(() {
          _clockedIn = data['clock_out_time'] == null;
          _clockInTime = data['clock_in_time'] != null
              ? (data['clock_in_time'] as Timestamp).toDate()
              : null;
        });
      }
    } catch (e) {
      print('Error fetching clock status: $e');
    } finally {
      setState(() {
        _isLoading = false;
      }); 
    }
  }

  Future<String?> _getClockInDocumentId() async {
    final querySnapshot = await _firestore
        .collection('employee_clock_in_out')
        .where('username', isEqualTo: widget.username)
        .where('clock_out_time', isNull: true) 
        .limit(1) 
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      return null;
    }
  }
  
  Future<void> _clockIn() async {
    if (_clockedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You are already clocked in!')));
      return;
    }

    await _firestore.collection('employee_clock_in_out').add({
      'username': widget.username,
      'clock_in_time': DateTime.now(),
    });
    _fetchClockStatus(); // Refresh status after clocking in
  }

  Future<void> _clockOut() async {
    if (!_clockedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You are not currently clocked in!')));
      return;
    }

    final clockInDocId = await _getClockInDocumentId();

    if (clockInDocId != null) {
      await _firestore
          .collection('employee_clock_in_out')
          .doc(clockInDocId)
          .update({
        'clock_out_time': DateTime.now(),
      });
      _fetchClockStatus(); // Refresh status after clocking out
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You are not clocked in yet.')));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _clockedIn ? Colors.green[300] : Colors.blueGrey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _clockedIn ? Icons.check_circle : Icons.timer,
                  size: 80,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Text(
                  _clockedIn ? 'Clocked In' : 'Clocked Out',
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                if (_clockedIn && _clockInTime != null)
                  Text(
                    DateFormat('h:mm a').format(_clockInTime!),
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : (_clockedIn ? _clockOut : _clockIn), 
                  child: _isLoading
                      ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                      : Text(_clockedIn ? 'Clock Out' : 'Clock In'),
                  style: ElevatedButton.styleFrom(
                    // primary: _clockedIn ? Colors.red : Colors.green,
                    // onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _clockStatusSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }
}
