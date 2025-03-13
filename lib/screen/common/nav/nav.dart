import 'package:harvest_pro/core/constants/constants.dart';
import 'package:harvest_pro/screen/function_1/predictFertilizer/fertilizer.dart';
import 'package:harvest_pro/screen/function_2/growthQualit/growthQuality.dart';
import 'package:harvest_pro/screen/function_2_Part2/harvest/harvest.dart';
import 'package:harvest_pro/screen/function_3/diseaseIdentification/diseaseIdentification.dart';
import 'package:harvest_pro/screen/common/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:harvest_pro/screen/screen.dart';

// A StatefulWidget for managing navigation between different screens in the app.
class Nav extends StatefulWidget {
  static String routeName = '/nav';
  const Nav({
    Key? key,
  }) : super(key: key);

  @override
  State<Nav> createState() => _NavState();
}

// The state class for Nav, handling bottom navigation and page switching.
class _NavState extends State<Nav> {
  // Member variables and methods...
  final user = FirebaseAuth.instance.currentUser!;
  final List<Widget> _pages = [];
  int _currentIndex = 0;

  // Initializes the pages for navigation and sets the initial state.
  @override
  void initState() {
    _pages.add(Home());
    _pages.add(Fertilizer());
    _pages.add(GrowthQuality());
    _pages.add(DiseaseIdentification());
    _pages.add(Harvest());
    _pages.add(ProfileScreen());
    super.initState();
  }

  // Builds the main UI of the Nav screen with a BottomNavigationBar.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors
            .white, // Set to white as it will be overwritten by the ShaderMask for selected items
        unselectedItemColor: const Color(nav),
        selectedLabelStyle:
            TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: _currentIndex == 0
                ? gradientIcon(Icons.home)
                : Icon(Icons.home, size: 32),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 1
                ? gradientIcon(Icons.local_florist)
                : Icon(Icons.local_florist, size: 32),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 2
                ? gradientIcon(Icons.trending_up)
                : Icon(Icons.trending_up, size: 32),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 3
                ? gradientIcon(Icons.bug_report)
                : Icon(Icons.bug_report, size: 32),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 4
                ? gradientIcon(Icons.grass)
                : Icon(Icons.grass, size: 32),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 5
                ? gradientIcon(Icons.person)
                : Icon(Icons.person, size: 32),
            label: '',
          ),
        ],
      ),
    );
  }

  // Creates a gradient icon for the navigation bar.
  Widget gradientIcon(IconData iconData) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black, Colors.grey.shade600],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Icon(
        iconData,
        size: 38,
        color: Colors.white, // Temporary color, will be covered by gradient
      ),
    );
  }

  // Handles tab selection in the BottomNavigationBar.
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
