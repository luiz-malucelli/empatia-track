import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../l10n/app_localizations.dart';
import '0_chartsView.dart';
import '0_registrarDiaView.dart';
import '0_utilityFunctions.dart';
import '0_viewModelGlobal.dart';


class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  double registerDayOpacity = 1.0;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay = DateTime.now();
  DateTime _today = DateTime.now();
  DateTime _calendarFocusedDay = DateTime.now();

  void _setFocusedDay(DateTime newFocused) {
    final viewModel = Provider.of<ViewModelGlobal>(context, listen: false);
    viewModel.updateCalendarFocusedDay(newFocused); // update the calendar focused day
    viewModel.updateCalendarCurrentMonth(newFocused); // update the calendar selected day
    viewModel.updateCurrentMonth(newFocused); // update the charts day
  }

  List<String> _getEventsForDay(DateTime day) {
    final viewModel = Provider.of<ViewModelGlobal>(context, listen: false);
    Map<DateTime, List<String>> events = viewModel.events;
    return events[_normalizeDate(day)] ?? [];
  }

  bool _isCurrentMonth(DateTime focusedDay) {
    return focusedDay.year == _today.year && focusedDay.month == _today.month;
  }

  bool _isAfterCurrentMonth(DateTime d) {
    final now = DateTime.now();
    return d.year > now.year || (d.year == now.year && d.month > now.month);
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _onLeftChevronTap() {
    final viewModel = Provider.of<ViewModelGlobal>(context, listen: false);
    final newFocusedDay = DateTime(viewModel.calendarFocusedDay.year, viewModel.calendarFocusedDay.month - 1);
    _setFocusedDay(newFocusedDay);
    // viewModel.updateFocusedDay(newFocusedDay);
    // viewModel.updateCurrentMonth(newFocusedDay);
  }

  void _onRightChevronTap() {
    final viewModel = Provider.of<ViewModelGlobal>(context, listen: false);
    if (!_isCurrentMonth(viewModel.calendarFocusedDay)) {
      DateTime newFocusedDay = DateTime(viewModel.calendarFocusedDay.year, viewModel.calendarFocusedDay.month + 1);
      if (_isCurrentMonth(newFocusedDay)) {
        newFocusedDay = DateTime.now();
      }
      _setFocusedDay(newFocusedDay);
      // viewModel.updateFocusedDay(newFocusedDay);
      // viewModel.updateCurrentMonth(newFocusedDay);

    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ViewModelGlobal>(context);
    Map<DateTime, List<String>> events = viewModel.events;
    var brightness = Theme.of(context).brightness;
    final AppLocalizations? loc = AppLocalizations.of(context);
    final locale = loc?.appLanguage ?? '';
    final formatLocale = locale == 'en' ? 'en_US' : 'pt_BR' ;
    final prevFocused = viewModel.calendarFocusedDay;
    final selectedDay = viewModel.calendarCurrentMonth;

    const tabletBreakpoint = 600.0;
    const smallScreenBreakpoint = 380.0;

    // Device type checks
    bool isTablet = !kIsWeb && MediaQuery.of(context).size.width >= tabletBreakpoint;
    bool isSmallScreen = !kIsWeb && MediaQuery.of(context).size.width <= smallScreenBreakpoint;


    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Empatia Track', style: TextStyle(fontFamily: 'RobotoSlab', fontWeight: FontWeight.bold, fontSize: fontSize(21, viewModel),
                color: Theme.of(context).colorScheme.onPrimary),
            ),
          ],
        ),

      ),
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      body: ListView(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: brightness == Brightness.dark ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
                        onPressed: _onLeftChevronTap,
                      ),
                      GestureDetector(
                        onTap: () async {
                          logEvent('in calendar view month/year text tapped - now showing DateSelectorDialog');
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DateSelectorDialog(viewModel: viewModel, isCalendar: true,);
                            },
                          );
                        },
                        child: Row(mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat.yMMMM(formatLocale).format(viewModel.calendarFocusedDay),
                              style: TextStyle(
                                fontWeight: _isCurrentMonth(viewModel.calendarFocusedDay) ? FontWeight.w500 : FontWeight.w400,
                                fontSize: fontSize(17, viewModel),
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(CupertinoIcons.chevron_down, color: Theme.of(context).colorScheme.onSurface, size: 15,)
                          ],
                        ),
                      ),
                      IconButton(
                        icon: _isCurrentMonth(viewModel.calendarFocusedDay) ? Container() : Icon(Icons.chevron_right, color: brightness == Brightness.dark ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
                        onPressed: _isCurrentMonth(viewModel.calendarFocusedDay) ? null : _onRightChevronTap,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: TableCalendar(
                    availableGestures: AvailableGestures.all,
                    rowHeight: isSmallScreen ? 46 : 52,
                    pageAnimationEnabled: true,
                    pageAnimationCurve: Curves.easeInOut,
                    pageAnimationDuration: const Duration(milliseconds: 600),
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: viewModel.calendarFocusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(viewModel.calendarCurrentMonth, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        Provider.of<ViewModelGlobal>(context, listen: false).updateCalendarCurrentMonth(selectedDay);
                        if (!selectedDay.isAfter(DateTime.now())) {
                          Provider.of<ViewModelGlobal>(context, listen: false).updateFocusedDay(selectedDay);
                          Provider.of<ViewModelGlobal>(context, listen: false).updateCurrentMonth(selectedDay);
                        } else {
                          Provider.of<ViewModelGlobal>(context, listen: false).updateFocusedDay(DateTime.now());
                          Provider.of<ViewModelGlobal>(context, listen: false).updateCurrentMonth(DateTime.now());
                        }
                      });
                    },
                    onPageChanged: (newFocused) {
                      int ym(DateTime d) => d.year * 12 + d.month;
                      final delta = ym(newFocused) - ym(prevFocused);
                      if (delta > 0) {
                        if (_isAfterCurrentMonth(newFocused)) {
                          _setFocusedDay(DateTime.now()); // programmatic jump back (guarded)
                          return;
                        }
                        if (!_isCurrentMonth(viewModel.calendarFocusedDay)) {
                          DateTime newFocusedDay = DateTime(viewModel.calendarFocusedDay.year, viewModel.calendarFocusedDay.month + 1);
                          if (_isCurrentMonth(newFocusedDay)) {
                            newFocusedDay = DateTime.now();
                          }
                          _setFocusedDay(newFocusedDay);
                          // viewModel.updateFocusedDay(newFocusedDay);
                          // viewModel.updateCurrentMonth(newFocusedDay);

                        }
                      } else if (delta < 0) {
                        final newFocusedDay = DateTime(viewModel.calendarFocusedDay.year, viewModel.calendarFocusedDay.month - 1);
                        _setFocusedDay(newFocusedDay);
                      }
                    },
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      leftChevronIcon: const Icon(Icons.chevron_left),
                      rightChevronIcon: _isCurrentMonth(_calendarFocusedDay) ? Container() : const Icon(Icons.chevron_right),
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(color: brightness == Brightness.dark ? Colors.grey : const Color.fromRGBO(
                          1, 71, 73, 1.0), fontSize: fontSize(14, viewModel)),
                      todayTextStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w500),
                      defaultTextStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: fontSize(14, viewModel)),
                      selectedTextStyle: TextStyle(color: brightness == Brightness.dark ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w600, fontSize: fontSize(14, viewModel)),
                      todayDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: const Color.fromRGBO(5, 65, 149, 1.0), // Set the color of the border
                          width: 2.0, // Set the width of the border
                        ),
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize(14, viewModel)),
                      weekendStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize(14, viewModel)),

                    ),
                    daysOfWeekVisible: true,
                    daysOfWeekHeight: 40,
                    headerVisible: false,
                    locale: 'pt_BR',
                    eventLoader: _getEventsForDay,
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        final isToday = date.day == _today.day && date.month == _today.month && date.year == _today.year;
                        final isSelectedDay = _selectedDay != null && isSameDay(_selectedDay, date);
                        final isDarkModeAndToday = isToday && brightness == Brightness.dark || isSelectedDay;
                        if (events.isNotEmpty) {
                          return _buildEventsMarker(events, isDarkModeAndToday);
                        }
                        return const SizedBox.shrink();
                      },
                      todayBuilder: (context, date, focusedDay) {
                        final events = _getEventsForDay(date);
                        return Container(
                          margin: const EdgeInsets.all(6.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: brightness == Brightness.dark ? 0 : 0.4),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: brightness == Brightness.dark ? Colors.white : const Color.fromRGBO(5, 65, 149, 1.0),
                              width: 2.0,
                            ),
                          ),
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                                color: brightness == Brightness.dark ? Colors.white : const Color.fromRGBO(5, 65, 149, 1.0),
                                fontWeight: FontWeight.bold, fontSize: fontSize(14, viewModel)
                            ),
                          ),
                        );
                      },
                      defaultBuilder: (context, day, focusedDay) {
                        final events = _getEventsForDay(day);
                        if (events.isNotEmpty) {
                          return Container(

                            margin: const EdgeInsets.all(5.0),
                            alignment: Alignment.center,
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                                  fontSize: fontSize(14, viewModel)
                              ),
                            ),
                          );
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                ),

                if (selectedDay.month == viewModel.calendarFocusedDay.month)
                _buildEventList(viewModel),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsMarker(List events, bool isDarkModeAndToday) {
    return Center(
      child: Stack(alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkModeAndToday ? Colors.transparent : Theme.of(context).colorScheme.onPrimary, // Set the color of the border
                  width: 2.0, // Set the width of the border
                ),
              ),
              width: 40.0,
              height: 40.0,
            ),
          ),

          const Positioned(bottom: 2, right: 0,
              child: Icon(CupertinoIcons.circle_fill, color: Colors.white, size: 18,)),


          const Positioned(bottom: 2, right: 0,
              child: Icon(CupertinoIcons.check_mark_circled_solid, color: Color.fromRGBO(
                  67, 168, 58, 1.0), size: 18,))

        ],
      ),
    );
  }

  Widget _buildEventList(ViewModelGlobal viewModel) {
    final AppLocalizations? loc = AppLocalizations.of(context);
    final events = viewModel.getDiaSalvoByDate(viewModel.calendarCurrentMonth ?? DateTime.now());
    var brightness = Theme.of(context).brightness;
    double barBorderRadius = 5;
    String formattedDate = DateFormat.yMMMMd('pt_BR').format(viewModel.calendarCurrentMonth ?? DateTime.now());

    const tabletBreakpoint = 600.0;
    const smallScreenBreakpoint = 380.0;

    // Device type checks
    bool isTablet = !kIsWeb && MediaQuery.of(context).size.width >= tabletBreakpoint;
    bool isSmallScreen = !kIsWeb && MediaQuery.of(context).size.width <= smallScreenBreakpoint;

    bool isSameDay(DateTime date1, DateTime date2) {
      return date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day == date2.day;
    }

    bool isBeforeOrSameDay(DateTime date1, DateTime date2) {
      return date1.year < date2.year ||
          (date1.year == date2.year && date1.month < date2.month) ||
          (date1.year == date2.year && date1.month == date2.month && date1.day <= date2.day);
    }


    if (events.isEmpty) {
      return Center(
        child: Column(
          children: [
            SizedBox(height: isSmallScreen ? 12 : 15),

            GestureDetector(
              onTap: () {
                logEvent('register day button tapped');
                setState(() {
                  registerDayOpacity = 1.0;
                });

                DateTime now = DateTime.now();
                DateTime today = DateTime(now.year, now.month, now.day);

                if (_selectedDay != null && isBeforeOrSameDay(_selectedDay!, today)) {
                  logEvent('navigating to registrarDiaView');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        RegistrarDiaView(
                            selectedDay: _selectedDay ?? DateTime.now())),
                  );
                } else {
                  logEvent('future day selected - showing no future day alert');
                  showAlert(context: context, alertTitle: loc?.alert ?? '',
                      alertText: loc?.noDaysFromFuture ?? '',
                      withoutSecondButton: true);
                }
              },
              onTapCancel: () {
                setState(() {
                  registerDayOpacity = 1.0;
                });
              },
              onTapDown: (_) {
                setState(() {
                  registerDayOpacity = 0.8;
                });
              },
              child: Opacity(
                opacity: registerDayOpacity,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: const Color.fromRGBO(5, 65, 149, 1.0),
                  ),
                  child: Text(loc?.registerMyDay ?? '',
                    style: TextStyle(fontSize: fontSize(17, viewModel), fontWeight: brightness == Brightness.dark ? FontWeight.w600 : null,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: events.map((event) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 0),
                // Divider(color: Color.fromRGBO(5, 65, 149, 1.0)),
                const SizedBox(height: 15),
                Text(formattedDate, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.transparent, // Set the border color
                        width: 1.0, // Set the border width
                      ),
                    ),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withValues(alpha:
                            0.2), // Background color of the chart
                      ),
                      padding: const EdgeInsets.only(bottom: 12, top: 24, right: 12, left: 12),
                      // Add padding to give space for the border
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceEvenly,
                          maxY: 5,
                          // Assuming the max value for emotions is 10
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 50,
                                // Adjust this size to allow for larger images
                                getTitlesWidget: (double value,
                                    TitleMeta meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: SizedBox(
                                      width: 44, // Set the desired width
                                      height: 44, // Set the desired height
                                      child: getImageForIndex(value.toInt()),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          gridData: const FlGridData(
                            show: false, // This removes the dashed lines
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: const Border(
                              left: BorderSide.none,
                              // Show left border
                              bottom: BorderSide(color: Colors.black),
                              // Show bottom border
                              top: BorderSide.none,
                              // Hide top border
                              right: BorderSide.none, // Hide right border
                            ),
                          ),
                          barGroups: [
                            BarChartGroupData(
                              barsSpace: 0,
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: event.emotions[0].toDouble(),
                                  color: const Color.fromRGBO(
                                      255, 160, 36, 1.0),
                                  width: 50,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(barBorderRadius),
                                    topRight: Radius.circular(barBorderRadius),
                                  ),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              barsSpace: 0,
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: event.emotions[1].toDouble(),
                                  color: const Color.fromRGBO(54, 134, 255, 1.0),
                                  width: 50,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(barBorderRadius),
                                    topRight: Radius.circular(barBorderRadius),
                                  ),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              barsSpace: 0,
                              x: 2,
                              barRods: [
                                BarChartRodData(
                                  toY: event.emotions[2].toDouble(),
                                  color: const Color.fromRGBO(205, 86, 59, 1.0),
                                  width: 50,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(barBorderRadius),
                                    topRight: Radius.circular(barBorderRadius),
                                  ),

                                ),
                              ],
                            ),
                            BarChartGroupData(
                              barsSpace: 0,
                              x: 3,
                              barRods: [
                                BarChartRodData(
                                  toY: event.emotions[3].toDouble(),
                                  color: const Color.fromRGBO(
                                      79, 221, 146, 1.0),
                                  width: 50,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(barBorderRadius),
                                    topRight: Radius.circular(barBorderRadius),
                                  ),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              barsSpace: 0,
                              x: 4,
                              barRods: [
                                BarChartRodData(
                                  toY: event.emotions[4].toDouble(),
                                  color: const Color.fromRGBO(
                                      141, 234, 255, 1.0),
                                  width: 50,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(barBorderRadius),
                                    topRight: Radius.circular(barBorderRadius),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (event.notes.isNotEmpty)
                const SizedBox(height: 25),
                if (event.notes.isNotEmpty)
                  Text('Notas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                if (event.notes.isNotEmpty)
                const SizedBox(height: 8),
                if (event.notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
                            child: Text(
                              event.notes,
                              textAlign: TextAlign.start,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 60),
              ],
            ),
          );
        }).toList(),
      );
    }
  }
}

Widget getImageForIndex(int index) {
  switch (index) {
    case 0:
      return Image.asset('assets/vectorEmojis/happy.png');
    case 1:
      return Image.asset('assets/vectorEmojis/peace.png');
    case 2:
      return Image.asset('assets/vectorEmojis/angry.png');
    case 3:
      return Image.asset('assets/vectorEmojis/afraid.png');
    case 4:
      return Image.asset('assets/vectorEmojis/sad.png');
    default:
      return Image.asset('assets/vectorEmojis/happy.png');
  }
}

String getImageStringForIndex(int index) {
  switch (index) {
    case 0:
      return 'assets/vectorEmojis/happy.png';
    case 1:
      return 'assets/vectorEmojis/peace.png';
    case 2:
      return 'assets/vectorEmojis/angry.png';
    case 3:
      return 'assets/vectorEmojis/afraid.png';
    case 4:
      return 'assets/vectorEmojis/sad.png';
    default:
      return 'assets/vectorEmojis/happy.png';
  }
}
