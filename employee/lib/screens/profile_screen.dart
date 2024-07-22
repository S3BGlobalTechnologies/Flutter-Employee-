import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../model/thread_message.dart';
import '../model/user.dart';
import '../screens/edit_profile.dart';
import '../screens/login.dart';
import '../widgets/thread_message.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final currentUser = FirebaseAuth.instance.currentUser;
  late Stream<UserModel> userStream;
  final CollectionReference threadCollection =
      FirebaseFirestore.instance.collection('threads');
  final PanelController panelController = PanelController();
  late TabController _tabController;
  bool isPanelOpen = false;

  Stream<UserModel> fetchUserData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .snapshots()
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>));
  }

  Stream<List<ThreadMessage>> fetchUserThreads(UserModel user) {
    return FirebaseFirestore.instance
        .collection('threads')
        .where('sender', isEqualTo: user.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final messageData = doc.data();
              final timestamp = (messageData['timestamp'] as Timestamp).toDate();
              return ThreadMessage(
                id: doc.id,
                senderName: messageData['sender'],
                senderProfileImageUrl: user.profileImageUrl ??
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRz8cLf8-P2P8GZ0-KiQ-OXpZQ4bebpa3K3Dw&usqp=CAU',
                message: messageData['message'],
                timestamp: timestamp,
                likes: messageData['likes'] ?? [],
                comments: messageData['comments'] ?? [],
              );
            }).toList());
  }

  @override
  void initState() {
    userStream = fetchUserData();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, size: 30),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Text('Profile',
            style: GoogleFonts.pacifico(
                fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                _logout(context);
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<UserModel>(
        stream: userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final UserModel? user = snapshot.data;
            return SlidingUpPanel(
              controller: panelController,
              minHeight: 0,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25)),
              panelBuilder: (sc) => snapshot.hasData
                  ? EditProfile(
                      panelController: panelController, user: snapshot.data!)
                  : const Center(child: CircularProgressIndicator()),
              body: _buildBody(user, context),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildBody(UserModel? user, BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7868E6), Color(0xFF9B89B3)],
          stops: [0.1, 0.9],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView( // Make the entire content scrollable
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                    backgroundImage: NetworkImage(user?.profileImageUrl ?? ''),
                    radius: 60),
                const SizedBox(height: 15),
                Text(user?.name ?? "",
                    style: GoogleFonts.lobster(fontSize: 28)),
                Text('@${user?.username ?? ""}',
                    style: const TextStyle(color: Color.fromARGB(255, 224, 224, 224))),
                const SizedBox(height: 10),
                Text(user?.bio ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildElevatedButton('Edit Profile', onPressed: () {
                      if (isPanelOpen) {
                        panelController.close();
                      } else {
                        panelController.open();
                      }
                    }),
                    // const SizedBox(width: 20),
                    // _buildElevatedButton('Share Profile', onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 25),
                TabBar(
                    controller: _tabController,
                    labelColor: Colors.black,
                    indicatorColor: Colors.black,
                    tabs: const [
                      Tab(text: 'Notes to self'),
                      Tab(text: 'Request Replies'),
                    ]),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      StreamBuilder(
                        stream: fetchUserThreads(user!),
                        builder: (context, snapshot) => snapshot.hasData
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final messageData = snapshot.data![index];
                                  final message = ThreadMessage(
                                    id: messageData.id,
                                    senderName: messageData.senderName,
                                    senderProfileImageUrl:
                                        user.profileImageUrl ??
                                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRz8cLf8-P2P8GZ0-KiQ-OXpZQ4bebpa3K3Dw&usqp=CAU',
                                    message: messageData.message,
                                    timestamp: messageData.timestamp,
                                    likes: messageData.likes,
                                    comments: messageData.comments,
                                  );
                                  return ThreadMessageWidget(
                                    message: message,
                                    onDisLike: () => dislikeThreadMessage(
                                        snapshot.data![index].id),
                                    onLike: () => likeThreadMessage(
                                        snapshot.data![index].id),
                                    onComment: () {},
                                    panelController: panelController,
                                  );
                                },
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                      const Center(child: Text('Your replies here')),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

    Widget _buildElevatedButton(String text, {required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: Colors.white)),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Future<void> likeThreadMessage(String id) async {
    try {
      threadCollection
          .doc(id)
          .update({'likes': FieldValue.arrayUnion([currentUser!.uid])});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> dislikeThreadMessage(String id) async {
    try {
      threadCollection
          .doc(id)
          .update({'likes': FieldValue.arrayRemove([currentUser!.uid])});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false, 
    );
  }
}