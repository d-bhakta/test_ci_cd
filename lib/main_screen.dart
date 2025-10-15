// This is the stateful widget that will hold our main page content and the navigation bar.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_ci_cd/user/calculator/calculator.dart';
import 'package:test_ci_cd/user/user.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // This integer variable will keep track of the currently selected tab.
  int _selectedIndex = 0;

  // This is a list of the pages (widgets) we want to display for each tab.
  static const List<Widget> _widgetOptions = <Widget>[
    UsersPage(),
    CalculatorPage(),
    ProfilePage(),
  ];

  // This function is called when a user taps on a navigation bar item.
  // It updates the state with the new index.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      // systemNavigationBarColor: Colors.amber, // Set the status bar icon brightness
    ));
    // Scaffold provides the basic structure of the visual interface.
    return Scaffold(
      // extendBody: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Bottom Navigation Bar')),
      // The body will display the widget from our _widgetOptions list based on the selected index.
      body: Stack(
        children: [
          SafeArea(child: Padding(
            padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
            child: Center(child: _widgetOptions.elementAt(_selectedIndex)),
          )),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.hardEdge,
              child: BottomNavigationBar(
                backgroundColor: Colors.lightBlue.shade100,
                iconSize: 30,
                // The list of items (tabs) to display.
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calculate),
                    label: 'Calculator',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
                currentIndex: _selectedIndex,
                // Highlights the current tab.
                selectedItemColor: Colors.amber[800],
                // Color of the selected tab's icon and label.
                onTap:
                    _onItemTapped, // The function to call when a tab is tapped.
              ),
            ),
          ),
        ],
      ),
      // This is where we define the bottom navigation bar.
      // bottomNavigationBar:
    );
  }
}

// --- Placeholder Pages for each Tab ---

// A simple stateless widget for the Home page.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.cyanAccent,
      child: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 120.0),
          child: SingleChildScrollView(
            child: Text(
              'Home Page  dad akd kad okapds okpaokds paksdokasd pokasd ck asdkpoasdc ldjc sdjc sjdck jsd kcjkls dcklj sdlcjioisdjc oisjdco ijsdco ijoijeomdcoiecmk dco sjdco jdco ijd ckmdnc oijsdc osdckm sodc sdmcoijefmrikvnjid sijdc oijejs dcoiedmnsdcm ijnedc END',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// A simple stateless widget for the Search page.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: const Center(
        child: Text(
          'Search Page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// A simple stateless widget for the Profile page.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.blueAccent,
        child: Center(
          child: Row(
            children: [
              const Text(
                'Profile Page',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () {
                  print("Profile icon tapped");
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => Container(
                      height: 150,
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      color: Colors.cyanAccent,
                      child: SafeArea(
                        child: const Center(
                          child: Text(
                            "This is a modal bottom sheet, s jmc ijcx djcn dnc ijdci jmodic iodjsc iojdsc oijsdco ijsod cijoisjdcoijsdcoijsodc oijdc iodjc oijdc oijdc ij sdj ijdsc ishdc khsdkc ksdch ksdchiu hf hdic idsuh l vkfvpojofvjodifjv odifjv",
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.add_a_photo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
