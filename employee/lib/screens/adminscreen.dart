import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import for SVG icons (optional)

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _holidayRequestsStream =
      FirebaseFirestore.instance.collection('holiday_requests').snapshots();
  final _userManagementStream = FirebaseFirestore.instance.collection('users').snapshots();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Set tab length to 2
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Set tab length to 2
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Panel'),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: SvgPicture.asset('assets/calendar.svg')), // Replace with your icon asset path
              Tab(icon: SvgPicture.asset('assets/user.svg')), // Replace with your icon asset path
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            HolidayRequestList(_holidayRequestsStream),
            UserList(_userManagementStream),
          ],
        ),
      ),
    );
  }
}

class HolidayRequestList extends StatefulWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;

  const HolidayRequestList(this.stream);

  @override
  _HolidayRequestListState createState() => _HolidayRequestListState();
}

class _HolidayRequestListState extends State<HolidayRequestList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: widget.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final holidayRequests = snapshot.data!.docs;

        return ListView.builder(
          itemCount: holidayRequests.length,
          itemBuilder: (context, index) {
            final requestData = holidayRequests[index].data();
            final docId = holidayRequests[index].id; // Get document ID for update
            final startDate = DateTime.parse(requestData['start_date']);
            final endDate = DateTime.parse(requestData['end_date']);
            final totalDays = requestData['total_days'];
            final reason = requestData['reason'];
            final status = requestData['status'] ?? 'pending'; // Handle potential missing 'status' field

            return ListTile(
              title: Text(
                  '${startDate.toIso8601String()} - ${endDate.toIso8601String()} ($totalDays days)'),
              subtitle: Text(reason),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      status == 'approved' ? Icons.check_circle : Icons.check,
                      color: status == 'approved' ? Colors.green : Colors.grey,
                    ),
                    onPressed: () => _updateLeaveStatus(docId, 'approved'),
                  ),
                  IconButton(
                    icon: Icon(
                      status == 'rejected' ? Icons.cancel : Icons.cancel_outlined,
                      color: status == 'rejected' ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => _updateLeaveStatus(docId, 'rejected'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _updateLeaveStatus(String docId, String newStatus) async {
    try {
      await _firestore.collection('holiday_requests').doc(docId).update({
        'status': newStatus,
      });
      // Show success message (optional)
    } catch (error) {
      // Handle errors (optional)
      print('Error updating leave request: $error');
    }
  }
}

class UserList extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;

  const UserList(this.stream);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        // Implement user list logic based on your user data structure
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        // Replace with your user data extraction and display logic
        final users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            // Extract user data and display it here
            return ListTile(
              title: Text('User Name'), // Replace with actual user data
              subtitle: Text('User Email'), // Replace with actual user data
            );
          },
        );
      },
    );
  }
}