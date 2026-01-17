import 'package:flutter/material.dart';
import 'package:todo_notes/Core/Helpers/sharedPref.dart';
import 'package:todo_notes/Presentation/Screens/noteScreen/mainNoteScreen.dart';

import 'settings.dart';
import 'todoScreens/MainScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedScreen = 0;

  @override
  void initState() {
    super.initState();
    gettingScreenIndex();
  }

  Future<void> gettingScreenIndex() async {
    int? index = await getStoredScreen();
    if (index != null) {
      setState(() {
        selectedScreen = index;
      });
    }
  }

  static List<Widget> screens = [
    MainTodoScreen(),
    MainNoteScreen(),
    Settings(),
  ];

  void onScreenTapped(int index) {
    setState(() {
      selectedScreen = index;
      print(selectedScreen);
      if (selectedScreen == 2) {
        storeSelectedScreen(0);
      } else {
        storeSelectedScreen(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens.elementAt(selectedScreen),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Task'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Note'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: selectedScreen,

        onTap: onScreenTapped,
      ),
    );
  }
}
