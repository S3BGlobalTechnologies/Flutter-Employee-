// import 'package:flutter/material.dart';
// import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';

// class JitsiMeetPage extends StatefulWidget {
//   final String roomName;
//   final String userName; // Optional: User's display name

//   const JitsiMeetPage({Key? key, required this.roomName, this.userName = ''})
//       : super(key: key);

//   @override
//   State<JitsiMeetPage> createState() => _JitsiMeetPageState();
// }

// class _JitsiMeetPageState extends State<JitsiMeetPage> {
//   @override
//   void initState() {
//     super.initState();
//     _joinMeeting();
//   }

//   Future<void> _joinMeeting() async {
//     try {
//       // Create JitsiMeetingOptions for customization
//       var options = JitsiMeetingOptions(roomNameOrUrl: widget.roomName)
//         ..subject = 'Meeting in Room: ${widget.roomName}'
//         ..userDisplayName =
//             widget.userName.isNotEmpty ? widget.userName : null
//         ..audioMuted = true
//         ..videoMuted = true
//         ..featureFlags.addAll({
//           // Add your feature flags here
//           FeatureFlag.WELCOME_PAGE_ENABLED: false,
//         });

//       // Join the meeting!
//       await JitsiMeetWrapper.joinMeeting(options);
//     } catch (error) {
//       debugPrint("Error joining meeting: $error");
//       // Handle error (e.g., show a dialog to user)
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Jitsi Meet'),
//       ),
//       body: const Center(
//         child: Text("Joining Meeting..."),
//       ),
//     );
//   }
// }
//itf ]]]]] i\ f(x)=[ksjs ,d ds f esfef,fe few]