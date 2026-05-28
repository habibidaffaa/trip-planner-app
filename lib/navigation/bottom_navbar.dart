import 'package:flutter/material.dart';
import 'package:iterasi1/pages/itinerary_list.dart';
import 'package:iterasi1/resource/theme.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({Key? key}) : super(key: key);

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _indexPage = 0;

  final List<BottomNavigationBarItem> _bottomNavBarItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
    BottomNavigationBarItem(
      icon: Icon(Icons.library_books_outlined),
      label: 'Paket Wisata',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.list_alt_outlined),
      label: 'Itinerary',
    ),
  ];

  final List<Widget> _tabViews = const [
    ItineraryList(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _tabViews[_indexPage],
          Positioned(
            bottom: 8,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: CustomColor.whiteColor,
                borderRadius: BorderRadius.circular(100),
                boxShadow: const [
                  BoxShadow(
                    color: CustomColor.actionPanelShadowColor,
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BottomNavigationBar(
                  backgroundColor: CustomColor.whiteColor,
                  selectedItemColor: CustomColor.brandElectric,
                  unselectedItemColor: CustomColor.mediumGray,
                  showSelectedLabels: true,
                  showUnselectedLabels: false,
                  items: _bottomNavBarItems,
                  currentIndex: _indexPage,
                  onTap: (int index) {
                    setState(() {
                      _indexPage = index;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
