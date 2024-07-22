import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for date formatting

class AdminDashboardPage extends StatefulWidget {
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _clockInOutData = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final snapshot = await _firestore.collection('employee_clock_in_out').get();
    setState(() {
      _clockInOutData = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Employee Clock In/Out Data',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _clockInOutData.length,
                itemBuilder: (context, index) {
                  final data = _clockInOutData[index];
                  final employeeId = data['employee_id'];
                  final clockInTime = DateTime.parse(data['clock_in_time']);
                  final clockOutTime = data.containsKey('clock_out_time')
                      ? DateTime.parse(data['clock_out_time'])
                      : null;
                  final duration = clockOutTime != null ? clockOutTime.difference(clockInTime) : null;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Employee ID:'),
                              SizedBox(width: 10),
                              Text(employeeId),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Text('Clock In:'),
                              SizedBox(width: 10),
                              Text(DateFormat('h:mm a').format(clockInTime)),
                            ],
                          ),
                          if (clockOutTime != null)
                            Row(
                              children: [
                                Text('Clock Out:'),
                                SizedBox(width: 10),
                                Text(DateFormat('h:mm a').format(clockOutTime)),
                              ],
                            ),
                          if (clockOutTime != null)
                            Row(
                              children: [
                                Text('Duration:'),
                                SizedBox(width: 10),
                                Text(duration!.inHours.toString() + 'h ' + duration!.inMinutes.remainder(60).toString() + 'm'),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
