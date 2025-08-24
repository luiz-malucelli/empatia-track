import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '0_calendarView.dart';
import '0_chartsView.dart';
import '0_settingsView.dart';
import '0_utilityFunctions.dart';
import '0_viewModelGlobal.dart';

class TabMenu extends StatefulWidget {
  const TabMenu({super.key});

  @override
  State<TabMenu> createState() => _TabMenuState();
}

class _TabMenuState extends State<TabMenu> {

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final viewModel = Provider.of<ViewModelGlobal>(context, listen: false);
    // viewModel.loadDiasSalvos();
    viewModel.loadFontSize();
    viewModel.loadHasSeenExplanation();
  }

  void _onItemTapped(int index) {
    logEvent('navigating to tab index: $index');
    final viewModel = Provider.of<ViewModelGlobal>(context, listen: false);
    setState(() {
      viewModel.setSelectedIndex(index);
    });
  }


  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    final viewModel = Provider.of<ViewModelGlobal>(context);
    final selectedIndex = viewModel.selectedIndex;

    List<Widget> widgetOptions = <Widget>[

      CalendarView(key: ValueKey('$selectedIndex')),
      ChartsView(key: ValueKey('$selectedIndex')),
      const SettingsView()
    ];


    return PopScope(
      canPop: false,
      child: Scaffold(resizeToAvoidBottomInset: true,
        body: Center(
          child: IndexedStack(
            index: selectedIndex,
            children: widgetOptions,
          ),
        ),
        bottomNavigationBar:

        Container(decoration: BoxDecoration(
          color: brightness == Brightness.dark ? const Color.fromRGBO(
              40, 40, 43, 1.0)  : const Color.fromRGBO(5, 65, 149, 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2), // Shadow color and opacity
              spreadRadius: 0, // Spread radius
              blurRadius: 30, // Blur radius
              offset: const Offset(0, 10), // Shadow position
            ),
          ],
        ),
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child:
          BottomNavigationBar(
            backgroundColor: brightness == Brightness.dark ? const Color.fromRGBO(
                40, 40, 43, 1.0)  : const Color.fromRGBO(5, 65, 149, 1.0),
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                activeIcon: Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Icon(Icons.calendar_month),
                ),
                icon: Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Icon(Icons.calendar_month),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                activeIcon: Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Icon(CupertinoIcons.chart_bar_alt_fill),
                ),
                icon: Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Icon(CupertinoIcons.chart_bar_alt_fill),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                activeIcon: Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Icon(CupertinoIcons.gear_alt_fill),
                ),
                icon: Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Icon(CupertinoIcons.gear_alt),
                ),
                label: '',
              ),
            ],
            currentIndex: selectedIndex,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            unselectedFontSize: 0,
            selectedFontSize: 0,
            selectedItemColor: brightness == Brightness.dark ? const Color.fromRGBO(100, 210, 255, 1) : Colors.white,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped, // Update the state upon item tap
            iconSize: 26,

          ),
        ),
      ),
    );
  }

}