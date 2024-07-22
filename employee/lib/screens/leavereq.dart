import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class HolidayRequestPage extends StatefulWidget {
  @override
  _HolidayRequestPageState createState() => _HolidayRequestPageState();
}

class _HolidayRequestPageState extends State<HolidayRequestPage> {
  String? _selectedLeaveType;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;
  int _totalDaysSelected = 0;
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _reasonController = TextEditingController();
  String? _username;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserInfo();
  }

  Future<void> _getCurrentUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData =
            await _firestore.collection('users').doc(user.uid).get();
        setState(() {
          _username = userData['username'] as String?;
          _userId = user.uid;
        });
      }
    } catch (e) {}
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      if (_startDate == null) {
        _startDate = selectedDay;
      } else if (_endDate == null) {
        _endDate = selectedDay;
        if (_startDate!.isAfter(_endDate!)) {
          final tempDate = _startDate;
          _startDate = _endDate;
          _endDate = tempDate;
        }
        _calculateTotalDays();
      } else {
        _startDate = selectedDay;
        _endDate = null;
        _totalDaysSelected = 0;
      }
    });
  }

  void _calculateTotalDays() {
    if (_startDate != null && _endDate != null) {
      _totalDaysSelected = _endDate!.difference(_startDate!).inDays + 1;
    }
  }

  Future<void> _submitHolidayRequest() async {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null &&
        _username != null &&
        _userId != null) {
      try {
        await _firestore.collection('holiday_requests').add({
          'start_date': _startDate!.toIso8601String(),
          'end_date': _endDate!.toIso8601String(),
          'total_days': _totalDaysSelected,
          'reason': _reasonController.text,
          'leave_type': _selectedLeaveType,
          'username': _username,
          'user_id': _userId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
              content: Text('Holiday request submitted successfully!'),
              backgroundColor: Colors.green),
        );
        setState(() {
          _startDate = null;
          _endDate = null;
          _totalDaysSelected = 0;
          _reasonController.clear();
          _selectedLeaveType = null;
        });
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error submitting request: ${e.message}'),
              backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please select both dates and fill the form'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> leaveTypes = ['Casual', 'Sick', 'Personal', 'Other'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Holiday Request', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration:
                  BoxDecoration(color: Color.fromARGB(255, 228, 125, 204)),
              child: Text(
                'Your Name',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Holiday Requests'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request Time Off',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins'),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TableCalendar(
                        focusedDay: _selectedDay,
                        firstDay: DateTime(DateTime.now().year - 1),
                        lastDay: DateTime(DateTime.now().year + 1),
                        selectedDayPredicate: (day) =>
                            isSameDay(day, _selectedDay),
                        calendarFormat: _calendarFormat,
                        onDaySelected: _onDaySelected,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        calendarStyle: CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: Colors.deepPurple[100],
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Colors.deepPurple[50],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Selected Dates: ${_startDate != null ? DateFormat('dd MMM yyyy').format(_startDate!) : '-'} - ${_endDate != null ? DateFormat('dd MMM yyyy').format(_endDate!) : '-'}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _reasonController,
                        decoration: InputDecoration(
                          labelText: 'Reason for Leave',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a reason'
                            : null,
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedLeaveType,
                        items: leaveTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedLeaveType = value!),
                        validator: (value) =>
                            value == null ? 'Please select a leave type' : null,
                        decoration: InputDecoration(
                          labelText: 'Leave Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: _submitHolidayRequest,
                        child: Text(
                          'Submit Request',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
