import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _widgetOptions,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedItemColor: Theme.of(context).primaryColor,
                unselectedItemColor: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                elevation: 0,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: const [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(top: 6.0),
                      child: Icon(Icons.home_outlined),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(top: 6.0),
                      child: Icon(Icons.home),
                    ),
                    label: 'Accueil',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(top: 6.0),
                      child: Icon(Icons.search_outlined),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(top: 6.0),
                      child: Icon(Icons.search),
                    ),
                    label: 'Recherche',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(top: 6.0),
                      child: Icon(Icons.settings_outlined),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(top: 6.0),
                      child: Icon(Icons.settings),
                    ),
                    label: 'Paramètres',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
