import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../model/user.dart';

class EmployeeLeaveHistoryPage extends StatefulWidget {
  final String employeeId;

  const EmployeeLeaveHistoryPage({Key? key, required this.employeeId})
      : super(key: key);

  @override
  _EmployeeLeaveHistoryPageState createState() =>
      _EmployeeLeaveHistoryPageState();
}

class _EmployeeLeaveHistoryPageState extends State<EmployeeLeaveHistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, int> _leaveRequestCounts = {};
  List<Map<String, dynamic>> _leaveRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchLeaveRequestData();
  }

  Future<void> _fetchLeaveRequestData() async {
    try {
      final snapshot = await _firestore
          .collection('holiday_requests')
          .where('user_id', isEqualTo: widget.employeeId)
          .get();
      final requests = snapshot.docs.map((doc) => doc.data()).toList();
      setState(() {
        _leaveRequestCounts = {
          'Pending': requests.where((r) => r['status'] == 'pending').length,
          'Approved': requests.where((r) => r['status'] == 'approved').length,
          'Rejected': requests.where((r) => r['status'] == 'rejected').length,
        };
        _leaveRequests = requests;
      });
    } catch (e) {
      print('Error fetching leave request data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Leave History',
          style: GoogleFonts.pacifico(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPieChart(),
            _buildLeaveRequestsChart(),
            const SizedBox(height: 20),
            Text(
              'Leave Requests Details:',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildLeaveRequestList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final List<PieChartSectionData> sections =
        _leaveRequestCounts.entries.map((entry) {
      final value = entry.value.toDouble();
      return PieChartSectionData(
        color: entry.key == 'Pending'
            ? Colors.orange
            : entry.key == 'Approved'
                ? Colors.green
                : Colors.red,
        value: value,
        title: '${entry.key}: ${value.toInt()}',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Leave Request Status',
                style:
                    GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              PieChart(
                PieChartData(
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: sections,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveRequestsChart() {
    final groupedData = _leaveRequests.fold<Map<String, int>>(
      {},
      (acc, request) {
        final month =
            DateFormat('MMM').format(DateTime.parse(request['start_date']));
        acc[month] = (acc[month] ?? 0) + 1;
        return acc;
      },
    );

    final chartData = groupedData.entries
        .map((entry) => _SalesData(entry.key, entry.value.toDouble()))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Leave Requests by Month',
                style: GoogleFonts.lato(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                title: ChartTitle(
                  text: 'Leave Requests vs. Monthly Days',
                  textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold),
                ),
                series: <CartesianSeries>[
                  // Use CartesianSeries instead of ColumnSeries
                  ColumnSeries<_SalesData, String>(
                    dataSource: chartData,
                    xValueMapper: (_SalesData sales, _) => sales.year,
                    yValueMapper: (_SalesData sales, _) => sales.sales,
                    name: 'Leave Requests',
                    color: Colors.deepPurpleAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveRequestList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _leaveRequests.length,
      itemBuilder: (context, index) {
        final leaveRequest = _leaveRequests[index];
        final startDate = DateTime.parse(leaveRequest['start_date']);
        final endDate = DateTime.parse(leaveRequest['end_date']);
        final leaveType = leaveRequest['leave_type'];
        final status = leaveRequest['status'];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                  style: GoogleFonts.lato(),
                ),
                Text('Status: $status',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      color: status == 'approved'
                          ? Colors.green
                          : (status == 'rejected' ? Colors.red : Colors.orange),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(child: Text('Error: $error', style: GoogleFonts.lato()));
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
