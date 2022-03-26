import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/colors.dart';
import '../utils/global_variable.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    addData();
  }

  addData() async {
    UserProvider _userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await _userProvider.refreshUser();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card(
        elevation: 20,
        child: PageView(
          children: homeScreenItems,
          controller: pageController,
          onPageChanged: onPageChanged,
        ),
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.teal.shade400,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_rounded,
              color: (_page == 0) ? primaryColor : secondaryColor,
            ),
            label: '',
            activeIcon: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black)
                  // color: Color.fromARGB(255, 2, 29, 88),
                  ),
              height: 50,
              width: 70,
              child: const Center(
                child: Text(
                  'Home',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
            ),
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                color: (_page == 1) ? primaryColor : secondaryColor,
              ),
              activeIcon: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black)
                    // color: Color.fromARGB(255, 2, 29, 88),
                    ),
                height: 50,
                width: 70,
                child: const Center(
                  child: Text(
                    'Search',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
              ),
              label: '',
              backgroundColor: primaryColor),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.post_add_rounded,
                color: (_page == 2) ? primaryColor : secondaryColor,
              ),
              label: '',
              activeIcon: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black)
                    // color: const Color.fromARGB(255, 2, 29, 88),
                    ),
                height: 50,
                width: 70,
                child: const Center(
                  child: Text(
                    'Post',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
              ),
              backgroundColor: primaryColor),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.people_alt_outlined,
              color: (_page == 3) ? primaryColor : secondaryColor,
            ),
            label: '',
            activeIcon: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black),
                //color: const Color.fromARGB(255, 2, 29, 88),
              ),
              height: 50,
              width: 70,
              child: const Center(
                child: Text(
                  'People',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
            ),
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline_rounded,
              color: (_page == 4) ? primaryColor : secondaryColor,
            ),
            label: '',
            activeIcon: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black)
                  //color: Color.fromARGB(255, 2, 29, 88),
                  ),
              height: 50,
              width: 70,
              child: const Center(
                child: Text(
                  'Person',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
            ),
            backgroundColor: primaryColor,
          ),
        ],
        onTap: navigationTapped,
        currentIndex: _page,
      ),
    );
  }
}
