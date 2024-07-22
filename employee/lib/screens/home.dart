import 'package:employee/screens/leavereq.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:employee/screens/post_screen.dart';
import 'package:employee/screens/profile_screen.dart';
import 'leavereq.dart';
import 'favorite_screen.dart';
import 'feed.dart';
import 'locator.dart';
import 'search.dart';
import 'image.dart';
import 'timer.dart';
import 'adminscreen.dart';
import 'location.dart';
import 'setting.dart';
import 'adminpass.dart';
import 'signup.dart';
import 'delete.dart';
import 'clockio.dart';
import 'adminclockio.dart';
import 'empstatus.dart';
import 'trackReq.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;

  List<Widget> pages = [];
  PanelController panelController = PanelController();

  @override
  void initState() {
    pages = [
      // const FeedScreen(),
      ClockInOutPage(),
      EmployeeLeaveRequestsPage(),
      // const TodayScreen(),
      //SignupScreen(),  //ye admin makeup page hai
      // const AdminMaker(),
      // AdminDashboardPage(),    //admin page for data for clockin/o

      // AdminPanel(),
      HolidayRequestPage(),
      HolidayRequestPage(),

      // HolidayRequestPage(),
      // const SearchScreen(),
      PostScreen(panelController: panelController),
      // const FavoriteScreen(),
      const ProfileScreen(),
      // SettingsScreen(),
      // ImageGenerationPage(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        controller: panelController,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        panelBuilder: (ScrollController sc) {
          return PostScreen(panelController: panelController);
        },
        body: pages[selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          if (index == 2) {
            panelController.isPanelOpen
                ? panelController.close()
                : panelController.open();
          } else {
            panelController.close();
            setState(() {
              selectedIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),

          BottomNavigationBarItem(
              icon: Icon(Icons.sports_martial_arts_rounded), label: 'Feed'),

          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_sharp), label: 'post'),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.favorite), label: 'favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'),
        ],
      ),
    );
  }
}
