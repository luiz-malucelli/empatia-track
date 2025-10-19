import 'dart:io';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '0_diaSalvo.dart';
import '0_printChartsView.dart';
import '0_utilityFunctions.dart';
import '0_viewModelGlobal.dart';

class ChartsView extends StatefulWidget {
  const ChartsView({super.key});

  @override
  State<ChartsView> createState() => _ChartsViewState();
}

class _ChartsViewState extends State<ChartsView> {
  double showWeekDataOpacity = 1.0;
  double showMonthDataOpacity = 1.0;
  double showYearDataOpacity = 1.0;
  DateTime _today = DateTime.now();
  int currentIndex = 0;
  bool shareGraphMenuOpen = false;

  @override
  void initState() {
    super.initState();
    randomizeCurrentIndex();
  }

  void randomizeCurrentIndex() {
    final viewModel = Provider.of<ViewModelGlobal>(context, listen: false);
    final highlights = viewModel.filteredHighlights;

    if (highlights.isNotEmpty) {
      final random = Random();
      currentIndex = random.nextInt(highlights.length);
      setState(() {});
    }
    // print('currentIndex is: $currentIndex');

  }

  bool _isCurrentMonth(DateTime focusedDay) {
    DateTime now = DateTime.now();
    return focusedDay.year == now.year && focusedDay.month == now.month;
  }

  bool _isCurrentYear(DateTime focusedDay) {
    return focusedDay.year == _today.year;
  }


  void _onLeftChevronTap() {
    final viewModel = Provider.of<ViewModelGlobal>(context, listen: false);
    DateTime newFocusedDay = DateTime.now();
    switch (viewModel.dataShown) {
      case DataShown.byWeek:
        newFocusedDay = DateTime(viewModel.focusedDay.year, viewModel.focusedDay.month - 1);
      case DataShown.byMonth:
        newFocusedDay = DateTime(viewModel.focusedDay.year, viewModel.focusedDay.month - 1);
      case DataShown.byYear:
        newFocusedDay = DateTime(viewModel.focusedDay.year - 1, viewModel.focusedDay.month);
    }
    viewModel.updateFocusedDay(newFocusedDay);
    viewModel.updateCurrentMonth(newFocusedDay);
  }

  void _onRightChevronTap() {
    final viewModel = Provider.of<ViewModelGlobal>(context, listen: false);
    DateTime newFocusedDay = viewModel.focusedDay;
    switch (viewModel.dataShown) {
      case DataShown.byWeek:
        if (!_isCurrentMonth(viewModel.focusedDay)) {
          newFocusedDay = DateTime(viewModel.focusedDay.year, viewModel.focusedDay.month + 1);
        }
      case DataShown.byMonth:
        if (!_isCurrentMonth(viewModel.focusedDay)) {
          newFocusedDay = DateTime(viewModel.focusedDay.year, viewModel.focusedDay.month + 1);
        }
      case DataShown.byYear:
        if (!_isCurrentYear(viewModel.focusedDay)) {
          newFocusedDay = DateTime(viewModel.focusedDay.year + 1, viewModel.focusedDay.month);
        }
    }
    viewModel.updateFocusedDay(newFocusedDay);
    viewModel.updateCurrentMonth(newFocusedDay);

  }

  void _weekLeftChevronTap() {
    final viewModel = Provider.of<ViewModelGlobal>(context, listen: false);
    DateTime newFocusedDay = viewModel.focusedDay;

    newFocusedDay = _previousWeek(viewModel.focusedDay);

    viewModel.updateFocusedDay(newFocusedDay);
    viewModel.updateCurrentMonth(newFocusedDay);
  }

  void _weekRightChevronTap() {
    final viewModel = Provider.of<ViewModelGlobal>(context, listen: false);
    DateTime newFocusedDay = viewModel.focusedDay;
    if (!_isCurrentWeek(viewModel.focusedDay)) {
      newFocusedDay = _nextWeek(viewModel.focusedDay);
    }
    viewModel.updateFocusedDay(newFocusedDay);
    viewModel.updateCurrentMonth(newFocusedDay);
  }

  DateTime _previousWeek(DateTime date) {
    return date.subtract(Duration(days: 7));
  }

  DateTime _nextWeek(DateTime date) {
    return date.add(Duration(days: 7));
  }


  bool _isCurrentWeek(DateTime date) {
    DateTime now = DateTime.now();

    // Calculate the start of the current week (Monday)
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    // Calculate the end of the current week (Sunday)
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    // Check if the given date is within the current week
    return date.isAfter(startOfWeek.subtract(Duration(days: 1))) && date.isBefore(endOfWeek.add(Duration(days: 1)));
  }
  
 


  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ViewModelGlobal>(context, listen: false);
    final AppLocalizations? loc = AppLocalizations.of(context);
    final locale = loc?.appLanguage ?? '';
    final formatLocale = locale == 'en' ? 'en_US' : 'pt_BR' ;
    var brightness = Theme.of(context).brightness;
    final dataShown = viewModel.dataShown;
    final highlights = viewModel.filteredHighlights;

    const tabletBreakpoint = 600.0;
    const smallScreenBreakpoint = 380.0;

    // Device type checks
    bool isTablet = !kIsWeb && MediaQuery.of(context).size.width >= tabletBreakpoint;
    bool isSmallScreen = !kIsWeb && MediaQuery.of(context).size.width <= smallScreenBreakpoint;

    if (currentIndex >= highlights.length) {
      final random = Random();
      if (highlights.length > 1) {
      currentIndex = random.nextInt(highlights.length);
      } else {
        currentIndex = 0;
      };  // Adjust currentIndex if it's out of range
    }
      bool hasHighlights = viewModel.filteredHighlights.isNotEmpty;
      DiaSalvo? currentHighlight = hasHighlights ? viewModel.filteredHighlights[currentIndex] : null;
    String formattedDate = hasHighlights
        ? DateFormat.yMMMMd(formatLocale).format(DateFormat('yyyy-MM-dd').parse(currentHighlight!.date))
        : '';


    void _goToPrevious() {
      setState(() {
        if (currentIndex > 0) {
          currentIndex--;
        } else {
          currentIndex = highlights.length - 1;
        }
      });
      print('currentIndex is $currentIndex');
    }

    void _goToNext() {
      setState(() {
        if (currentIndex < highlights.length - 1) {
          currentIndex++;
        } else {
          currentIndex = 0;
        }
      });
      print('currentIndex is $currentIndex');
    }

    void _goToHighlight() {
      final hightlightDate = DateTime.parse(highlights[currentIndex].date);
      final viewModel = Provider.of<ViewModelGlobal>(context, listen: false);
      viewModel.updateCalendarFocusedDay(hightlightDate); // update the calendar focused day
      viewModel.updateCalendarCurrentMonth(hightlightDate); // update the calendar selected day
      viewModel.updateCurrentMonth(hightlightDate); // update the charts day
      viewModel.setSelectedIndex(0);
    }

    void _goToHightlightMenu(TapUpDetails details) async {
      final position = details.globalPosition;

      final selected = await showMenu<String>(
        color: brightness == Brightness.dark ? Theme.of(context).colorScheme.surface : Color.fromRGBO(
            112, 196, 204, 1.0),
        context: context,
        position: RelativeRect.fromLTRB(
          position.dx,
          position.dy,
          position.dx,
          position.dy,
        ),
        items: [
          PopupMenuItem<String>(
            value: 'goToHighlight',
            child: Text(loc?.checkHighlight ?? '', style: TextStyle(fontSize: fontSize(16, viewModel))),
          ),
        ],
      );

      if (selected == 'goToHighlight') {
        _goToHighlight();
      }
    }


    String dataShownType() {
      switch (dataShown) {
        case DataShown.byWeek:
          return loc?.appLanguage == 'en' ? 'week' : 'semana';
        case DataShown.byMonth:
          return  loc?.appLanguage == 'en' ? 'month' : 'mês';
        case DataShown.byYear:
          return  loc?.appLanguage == 'en' ? 'year' : 'ano';
      }
    }

    String dataShownString = dataShownType();

    String capitalizeFirstLetter(String input) {
      if (input == null || input.isEmpty) {
        return input;
      }
      return input[0].toUpperCase() + input.substring(1);
    }

    String summaryString = loc?.appLanguage == 'en' ? '${capitalizeFirstLetter(dataShownString)} summary' :
    'Resumo d_ $dataShownString' ;

    String pointString = loc?.appLanguage == 'en' ? 'Points used per day\nthroughout the $dataShownString' :
    'Pontos distribuídos por dia\nao longo ${(dataShown == DataShown.byWeek ? 'da' : 'do')} $dataShownString';

    String replaceUnderscores(String input) {
      switch (dataShown) {
        case DataShown.byWeek:
          return input.replaceAll('_', 'a');
        case DataShown.byMonth:
          return input.replaceAll('_', 'o');
        case DataShown.byYear:
          return input.replaceAll('_', 'o');
      }
    }

    String _getCurrentWeekRange(DateTime date) {
      DateTime startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

      DateFormat dateFormat;
      if (locale == 'en') {
        dateFormat = DateFormat('MM/dd');
      } else if (locale == 'pt') {
        dateFormat = DateFormat('dd/MM');
      } else {
        dateFormat = DateFormat.yMd(); // Default to locale-specific date format
      }

      String formattedStartOfWeek = dateFormat.format(startOfWeek);
      String formattedEndOfWeek = dateFormat.format(endOfWeek);

      return '$formattedStartOfWeek - $formattedEndOfWeek';
    }

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
        actions: [Padding(
          padding: EdgeInsets.only(right: Platform.isIOS ? 15 : 13),
          child:
          PopupMenuButton(color: brightness == Brightness.dark ? Theme.of(context).colorScheme.surface : Color.fromRGBO(121, 198, 205, 1.0),
            position: PopupMenuPosition.under,
            child: Icon(Platform.isIOS ? CupertinoIcons.share : Icons.share, size: Platform.isIOS ? 28 : 26, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: shareGraphMenuOpen ? 0.5 : 1)
            ),
            onOpened: () {
              setState(() {
                shareGraphMenuOpen = true;
              });
            },
            onCanceled: () {
              setState(() {
                shareGraphMenuOpen = false;
              });
            },
            onSelected: (value) async {

              switch (value) {
                
                case 'sharePdf':
                  logEvent('share button - share pdf option tapped');
                  preloadImages(context).then((_) {
                    Navigator.push(
                      context,
                      VerticalSlideRoute(page: PrintCharts(currentIndex: currentIndex, saveImage: false)),
                    );
                  });

                  break;

                case 'saveImage':
                  logEvent('share button - save image option tapped');

                  if (Platform.isIOS) {
                    PermissionStatus status = await Permission.photos.request();
                    print('Photos permission status: $status');

                    final String libraryDenied = Platform.isIOS ? loc
                        ?.libraryDeniedSaveImageIOS ?? '' :
                    loc?.libraryDeniedSaveImageAndroid ?? '';

                    if (status.isGranted) {
                      preloadImages(context).then((_) {
                        Navigator.push(
                          context,
                          VerticalSlideRoute(page: PrintCharts(
                              currentIndex: currentIndex, saveImage: true)),
                        );
                      });
                    } else if (status.isDenied || status.isPermanentlyDenied) {
                      showAlert(context: context, alertTitle: loc?.alert ?? '',
                          alertText: libraryDenied, withoutSecondButton: true);
                    }
                  } else if (Platform.isAndroid) {
                    preloadImages(context).then((_) {
                      Navigator.push(
                        context,
                        VerticalSlideRoute(page: PrintCharts(
                            currentIndex: currentIndex, saveImage: true)),
                      );
                    });
                  }

                  break;
              }
              setState(() {
                shareGraphMenuOpen = false;
              });
            },

            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              if (!kIsWeb)
                PopupMenuItem<String>(
                  value: 'sharePdf',
                  child: Row(children: [
                    Text(loc?.sharePdf ?? '', style: TextStyle(fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface)),
                    const Expanded(child:
                    SizedBox()),
                    Icon(CupertinoIcons.doc, color: Theme.of(context).colorScheme.onSurface)
                  ]),
                ),
              if (!kIsWeb)
                const PopupMenuDivider(),
              if (!kIsWeb)PopupMenuItem<String>(
                value: 'saveImage',
                child: Row(children: [
                  Text(loc?.saveImagePhotos ?? '', style: TextStyle(fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface)),
                  const Expanded(child:
                  SizedBox()),
                  Icon(CupertinoIcons.photo, color: Theme.of(context).colorScheme.onSurface)
                ]),
              ),
              // Add more menu items as needed
            ],
          ),
            /*IconButton(icon: Icon(Platform.isIOS ? Icons.ios_share : Icons.share), onPressed: () {},),*/
        )],
      ),
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      body: ListView(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                const SizedBox(height: 10),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen && viewModel.fontSize == FontSize.large ? 8 : 20),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showWeekDataOpacity = 1.0;
                              viewModel.updateDataShown(DataShown.byWeek);
                            });

                          },
                          onTapCancel: () {
                            setState(() {
                              showWeekDataOpacity = 1.0;
                            });
                          },
                          onTapDown: (_) {
                            setState(() {
                              showWeekDataOpacity = 0.5;
                            });
                          },
                          child: Opacity(
                            opacity: showWeekDataOpacity,
                            child:   Container(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: brightness == Brightness.dark ? Colors.transparent : dataShown == DataShown.byWeek ? Color.fromRGBO(5, 65, 149, 1.0) : Colors.transparent,
                                border: Border.all(
                                  color: brightness == Brightness.dark ? dataShown == DataShown.byWeek ? Theme.of(context).colorScheme.primary : Colors.transparent : dataShown == DataShown.byWeek ? Color.fromRGBO(5, 65, 149, 1.0) : Colors.transparent, // Border color
                                  width: 2.0, // Border width
                                ),
                              ),
                              child: Text(
                                loc?.week ?? '',
                                style: TextStyle(fontSize: fontSize(18, viewModel), color: dataShown == DataShown.byWeek ? Colors.white : Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.center,
                            child:  GestureDetector(
                              onTap: () {
                                setState(() {
                                  showMonthDataOpacity = 1.0;
                                  viewModel.updateDataShown(DataShown.byMonth);
                                });

                              },
                              onTapCancel: () {
                                setState(() {
                                  showMonthDataOpacity = 1.0;
                                });
                              },
                              onTapDown: (_) {
                                setState(() {
                                  showMonthDataOpacity = 0.5;
                                });
                              },
                              child: Opacity(
                                opacity: showMonthDataOpacity,
                                child:   Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: brightness == Brightness.dark ? Colors.transparent : dataShown == DataShown.byMonth ? Color.fromRGBO(5, 65, 149, 1.0) : Colors.transparent,
                                    border: Border.all(
                                      color: brightness == Brightness.dark ? dataShown == DataShown.byMonth ? Theme.of(context).colorScheme.primary : Colors.transparent : dataShown == DataShown.byMonth ? Color.fromRGBO(5, 65, 149, 1.0) : Colors.transparent, // Border color
                                      width: 2.0, // Border width
                                    ),
                                  ),
                                  child: Text(
                                    loc?.month ?? '',
                                    style: TextStyle(fontSize: fontSize(18, viewModel), color: dataShown == DataShown.byMonth ? Colors.white : Theme.of(context).colorScheme.onSurface),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),



                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.center,
                            child:  GestureDetector(
                          onTap: () {
                            setState(() {
                              showYearDataOpacity = 1.0;
                              viewModel.updateDataShown(DataShown.byYear);
                            });
                          },
                          onTapCancel: () {
                            setState(() {
                              showYearDataOpacity = 1.0;
                            });
                          },
                          onTapDown: (_) {
                            setState(() {
                              showYearDataOpacity = 0.5;
                            });
                          },
                          child: Opacity(
                            opacity: showYearDataOpacity,
                            child:   Container(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: brightness == Brightness.dark ? Colors.transparent : dataShown == DataShown.byYear ? Color.fromRGBO(5, 65, 149, 1.0) : Colors.transparent,
                                border: Border.all(
                                  color: brightness == Brightness.dark ? dataShown == DataShown.byYear ? Theme.of(context).colorScheme.primary : Colors.transparent : dataShown == DataShown.byYear ? Color.fromRGBO(5, 65, 149, 1.0) : Colors.transparent, // Border color
                                  width: 2.0, // Border width
                                ),
                              ),
                              child: Text(
                                loc?.year ?? '',
                                style: TextStyle(fontSize: fontSize(18, viewModel), color: dataShown == DataShown.byYear ? Colors.white : Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  ]),
                ),

                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: brightness == Brightness.dark ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
                        onPressed: _onLeftChevronTap,
                      ),
                      if (dataShown != DataShown.byYear)
                      GestureDetector(
                        onTap: () async {
                          logEvent('in charts view month/year text tapped - now showing DateSelectorDialog');
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DateSelectorDialog(viewModel: viewModel);
                            },
                          );
                        },
                        child: Row(mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat.yMMMM(formatLocale).format(viewModel.currentMonth),
                              style: TextStyle(
                                fontWeight: _isCurrentMonth(viewModel.currentMonth) ? FontWeight.w500 : FontWeight.w400,
                                fontSize: fontSize(17, viewModel),
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(CupertinoIcons.chevron_down, color: Theme.of(context).colorScheme.onSurface, size: 15,)
                          ],
                        ),
                      ),
                      if (dataShown == DataShown.byYear)
                        PopupMenuButton<String>(
                          onSelected: (String result) {
                            // Parse the selected month or year
                            DateTime selectedDate;
                           if (dataShown == DataShown.byYear) {
                              selectedDate = DateFormat.y(formatLocale).parse(result);
                            } else {
                              return;
                            }

                            // Update the current month in the view model
                            viewModel.updateCurrentMonth(selectedDate);
                            print(result); // This will print the selected month or year
                          },
                          itemBuilder: (BuildContext context) {
                            List<PopupMenuItem<String>> items = [];
                            if (dataShown == DataShown.byYear) {
                              for (int i = 0; i < 18; i++) {
                                int year = DateTime.now().year - i;
                                String formattedYear = DateFormat.y(formatLocale).format(DateTime(year));
                                items.add(
                                  PopupMenuItem<String>(
                                    value: formattedYear,
                                    child: Text(formattedYear, style: TextStyle(fontSize: fontSize(16, viewModel)),),
                                  ),
                                );
                              }
                            }
                            return items;
                          },
                          child: Row(mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat.y(formatLocale).format(viewModel.currentMonth),
                                style: TextStyle(
                                  fontWeight: _isCurrentYear(viewModel.currentMonth) ? FontWeight.w500 : FontWeight.w400,
                                  fontSize: fontSize(17, viewModel),
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(CupertinoIcons.chevron_down, color: Theme.of(context).colorScheme.onSurface, size: 15,)
                            ],
                          ),
                        ),

                      if (dataShown != DataShown.byYear)
                      IconButton(
                        icon: _isCurrentMonth(viewModel.currentMonth) ? Container() : Icon(Icons.chevron_right, color: brightness == Brightness.dark ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
                        onPressed: _isCurrentMonth(viewModel.currentMonth) ? null : _onRightChevronTap,
                      ),
                      if (dataShown == DataShown.byYear)
                      IconButton(
                        icon: _isCurrentYear(viewModel.currentMonth) ? Container() : Icon(Icons.chevron_right, color: brightness == Brightness.dark ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
                        onPressed: _isCurrentYear(viewModel.currentMonth) ? null : _onRightChevronTap,
                      ),
                    ],
                  ),
                ),


                if (dataShown == DataShown.byWeek)
                  Divider(),

                if (dataShown == DataShown.byWeek)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left, color: brightness == Brightness.dark ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
                          onPressed: _weekLeftChevronTap,
                        ),

                          PopupMenuButton<String>(
                            onSelected: (String result) {
                              // Parse the selected month or year
                              DateTime selectedDate;
                              if (dataShown == DataShown.byYear) {
                                selectedDate = DateFormat.y(formatLocale).parse(result);
                              } else {
                                return;
                              }

                              // Update the current month in the view model
                              viewModel.updateCurrentMonth(selectedDate);
                              print(result); // This will print the selected month or year
                            },
                            itemBuilder: (BuildContext context) {
                              List<PopupMenuItem<String>> items = [];
                              if (dataShown == DataShown.byYear) {
                                DateTime currentMonth = viewModel.currentMonth;
                                for (int i = 0; i < 18; i++) {
                                  int year = currentMonth.year - i;
                                  String formattedYear = DateFormat.y(formatLocale).format(DateTime(year));
                                  items.add(
                                    PopupMenuItem<String>(
                                      value: formattedYear,
                                      child: Text(formattedYear, style: TextStyle(fontSize: fontSize(16, viewModel)),),
                                    ),
                                  );
                                }
                              }
                              return items;
                            },
                            child: Row(mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getCurrentWeekRange(viewModel.currentMonth),
                                  style: TextStyle(
                                    fontWeight: _isCurrentWeek(viewModel.currentMonth) ? FontWeight.w500 : FontWeight.w400,
                                    fontSize: fontSize(17, viewModel),
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),


                        IconButton(
                          icon: _isCurrentWeek(viewModel.currentMonth) ? Container() : Icon(Icons.chevron_right, color: brightness == Brightness.dark ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
                          onPressed: _isCurrentWeek(viewModel.currentMonth) ? null : _weekRightChevronTap,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 15),


                Text(replaceUnderscores(summaryString), textAlign: TextAlign.center,
                  style: TextStyle(fontSize: fontSize(18, viewModel), fontWeight: FontWeight.w600, height: 1.2), ),

                buildEventList(viewModel, viewModel.currentMonth, dataShown, context),

                if (highlights.isNotEmpty) ... [
                  const SizedBox(height: 50),
                  Text(loc?.highlights ?? '', style: TextStyle(fontSize: fontSize(20, viewModel), fontWeight: FontWeight.w500, height: 0.5)),
                  SizedBox(height: highlights.length > 1 ? 0 : 11),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (highlights.length > 1)
                        IconButton(
                          icon: Icon(Icons.chevron_left, color: brightness == Brightness.dark ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
                          onPressed: _goToPrevious,
                        ),
                      GestureDetector(
                        onTapUp: _goToHightlightMenu,
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: fontSize(18, viewModel),
                            fontWeight:
                            brightness == Brightness.dark ? FontWeight.w300 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (highlights.length > 1)
                        IconButton(
                          icon: Icon(Icons.chevron_right, color: brightness == Brightness.dark ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
                          onPressed: _goToNext,
                        ),
                    ],
                  ),
                ],

                if (highlights.length == 1)
                  const SizedBox(height: 11),
                if (highlights.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: GestureDetector(onTapUp: _goToHightlightMenu,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: brightness == Brightness.dark ? Theme.of(context).colorScheme.surface : Colors.white.withValues(alpha: brightness == Brightness.dark ? 0.2 : 0.2),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
                            child: Text(currentHighlight?.notes ?? '',
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: fontSize(18, viewModel)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (highlights.isNotEmpty)
                  const SizedBox(height: 20),

                const SizedBox(height: 35),

                Text(pointString, textAlign: TextAlign.center,
                style: TextStyle(fontSize: fontSize(18, viewModel), fontWeight: FontWeight.w600, height: 1.2), ),

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
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: brightness == Brightness.dark ? Theme.of(context).colorScheme.surface : Colors.white.withValues(alpha: brightness == Brightness.dark ? 0.2 : 0.2),
                          ),
                          padding: EdgeInsets.only(bottom: 24, top: 36, right: dataShown == DataShown.byWeek ? 35 : dataShown == DataShown.byMonth ? 30 : 25, left: dataShown == DataShown.byWeek ? 35 : 25),
                          // Add padding to give space for the border
                          child: LineChartSample(viewModel: viewModel, month: viewModel.currentMonth, dataShown: dataShown,))),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }



}

Widget buildEventList(ViewModelGlobal viewModel, DateTime month, DataShown dataShown, BuildContext context) {
  final AppLocalizations? loc = AppLocalizations.of(context);
  final absoluteValues = dataShown == DataShown.byMonth ? viewModel.getSumOfEmotionsForMonth(month) :
  dataShown == DataShown.byYear ? viewModel.getSumOfEmotionsForYear(month) : viewModel.getSumOfEmotionsForWeek(month);
  double barBorderRadius = 5;
  var brightness = Theme.of(context).brightness;

  bool valueIsZero(value) {
    return value == 0.0;
  }

  bool allValuesAreZero = absoluteValues.every((value) => value == 0);

  int findMaxValue(List<int> values) {
    return values.reduce((a, b) => a > b ? a : b);
  }

  int calculateSum(List<int> values) {
    return values.reduce((a, b) => a + b);
  }

  final maxValue = findMaxValue(absoluteValues).toDouble();
  final absoluteSum = calculateSum(absoluteValues).toDouble();

  String dataShownType() {
    switch (dataShown) {
      case DataShown.byWeek:
        return loc?.appLanguage == 'en' ? 'week' : 'semana';
      case DataShown.byMonth:
        return  loc?.appLanguage == 'en' ? 'month' : 'mês';
      case DataShown.byYear:
        return  loc?.appLanguage == 'en' ? 'year' : 'ano';
    }
  }

  String dataShownString = dataShownType();


  String replaceUnderscores(String input) {
    switch (dataShown) {
      case DataShown.byWeek:
        return input.replaceAll('_', 'a');
      case DataShown.byMonth:
        return input.replaceAll('_', 'o');
      case DataShown.byYear:
        return input.replaceAll('_', 'o');
    }
  }

  String emptyInfoString = loc?.appLanguage == 'en' ? 'No day has been\nregistered on this $dataShownString.\n\nRegister at least two days on the calendar to see the $dataShownString summary.'
      : 'Nenhum dia registrado\n${dataShown != DataShown.byWeek ? 'neste' : 'nesta'} $dataShownString.\n\nRegistre pelo menos dois dias no calendário para ver o resumo d_ $dataShownString.';

  if (absoluteValues.isEmpty) {
    return const SizedBox.shrink();
  } else {
    return  Center(
      child: Column(
        children: [
          const SizedBox(height: 5),
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
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: brightness == Brightness.dark ? Theme.of(context).colorScheme.surface : Colors.white.withValues(alpha: brightness == Brightness.dark ? 0.2 : 0.2),
                ),
                padding: EdgeInsets.only(bottom: 14, top: paddingSize(42, viewModel), right: 12, left: 12),
                // Add padding to give space for the border
                child: Stack(alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceEvenly,
                        maxY: maxValue,
                        // Assuming the max value for emotions is 10
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (BarChartGroupData group) {
                              // Return the color you want based on the group data
                              // You can customize this logic as needed
                              return Colors.transparent; // Change this to your desired color
                            },
                            tooltipPadding: const EdgeInsets.all(0),
                            tooltipHorizontalOffset: 1,
                            tooltipHorizontalAlignment: FLHorizontalAlignment.center,
                            tooltipMargin: 3,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${(rod.toY / absoluteSum * 100).toStringAsFixed(1)}%',
                                TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize(14, viewModel),
                                ),
                              );
                            },
                          ),
                          touchCallback: (_, __) {},
                        ),
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
                            showingTooltipIndicators: valueIsZero(absoluteValues[0]) ? null : [0],
                            barsSpace: 0,
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: absoluteValues[0].toDouble(),
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
                            showingTooltipIndicators: valueIsZero(absoluteValues[1]) ? null : [0],
                            barsSpace: 0,
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: absoluteValues[1].toDouble(),
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
                            showingTooltipIndicators: valueIsZero(absoluteValues[2]) ? null : [0],
                            barsSpace: 0,
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: absoluteValues[2].toDouble(),
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
                            showingTooltipIndicators: valueIsZero(absoluteValues[3]) ? null : [0],
                            barsSpace: 0,
                            x: 3,
                            barRods: [
                              BarChartRodData(
                                toY: absoluteValues[3].toDouble(),
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
                            showingTooltipIndicators: valueIsZero(absoluteValues[4]) ? null : [0],
                            barsSpace: 0,
                            x: 4,
                            barRods: [
                              BarChartRodData(
                                toY: absoluteValues[4].toDouble(),
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
                    if (allValuesAreZero)
                      Positioned(top: -8,
                          child: SizedBox(width: 230,
                              child: Text(replaceUnderscores(emptyInfoString), textAlign: TextAlign.center,)))
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
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


class LineChartSample extends StatelessWidget {
  final ViewModelGlobal viewModel;
  final DateTime month;
  final DataShown dataShown;

  LineChartSample({required this.viewModel, required this.month, required this.dataShown});

  @override
  Widget build(BuildContext context) {
    final data = dataShown == DataShown.byMonth
        ? viewModel.getDailySumsForMonth(month)
        : dataShown == DataShown.byYear ?
        viewModel.getMonthlyAveragesForYear(month.year)
        : viewModel.getDailySumsForWeek(month);
    final AppLocalizations? loc = AppLocalizations.of(context);
    final locale = loc?.appLanguage ?? '';
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLargeEnough = screenWidth > 800;

    List<FlSpot> spots = data.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
        .toList();

    // Sort spots by x-value (day)
    spots.sort((a, b) => a.x.compareTo(b.x));

    final maxYAxisValue = data.isEmpty
        ? 0.0
        : data.values.reduce((a, b) => a > b ? a : b);

    List<String> _getWeekdayLabels() {
      if (locale == 'pt') {
        return ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
      } else {
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      }
    }

    final absoluteValues = dataShown == DataShown.byMonth ? viewModel.getSumOfEmotionsForMonth(month) :
    dataShown == DataShown.byYear ? viewModel.getSumOfEmotionsForYear(month) : viewModel.getSumOfEmotionsForWeek(month);

    bool allValuesAreZero = absoluteValues.every((value) => value == 0);

    String dataShownType() {
      switch (dataShown) {
        case DataShown.byWeek:
          return loc?.appLanguage == 'en' ? 'week' : 'semana';
        case DataShown.byMonth:
          return  loc?.appLanguage == 'en' ? 'month' : 'mês';
        case DataShown.byYear:
          return  loc?.appLanguage == 'en' ? 'year' : 'ano';
      }
    }

    String dataShownString = dataShownType();


    String replaceUnderscores(String input) {
      switch (dataShown) {
        case DataShown.byWeek:
          return input.replaceAll('_', 'a');
        case DataShown.byMonth:
          return input.replaceAll('_', 'o');
        case DataShown.byYear:
          return input.replaceAll('_', 'o');
      }
    }

    String emptyInfoString = loc?.appLanguage == 'en' ? 'No day has been\nregistered on this $dataShownString.\n\nRegister at least two days on the calendar to see the $dataShownString summary.'
        : 'Nenhum dia registrado\n${dataShown != DataShown.byWeek ? 'neste' : 'nesta'} $dataShownString.\n\nRegistre pelo menos dois dias no calendário para ver o resumo d_ $dataShownString.';

    return  Stack(alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (dataShown == DataShown.byMonth) {
                      // Custom logic to hide the label for the 30th day if the month has 31 days
                      int day = value.toInt();
                      if (month.month == 2 && day > 28) {
                        // Handle February
                        if (DateTime(month.year, month.month + 1, 0).day == 29 && day == 29) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              day.toString(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return Container();
                      } else if (!isLargeEnough && day == 30 && DateTime(month.year, month.month + 1, 0).day == 31) {
                        return Container(); // Hide 30 if there are 31 days in the month
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            day.toString(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                    } else if (dataShown == DataShown.byYear) {
                      // Show months for the year
                      int monthIndex = value.toInt();

                      if (monthIndex >= 1 && monthIndex <= 12) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            monthIndex.toString(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    } else if (dataShown == DataShown.byWeek) {
                      // Show days of the week
                      int dayIndex = value.toInt();
                      String locale = Localizations.localeOf(context).languageCode; // Get the current locale
                      List<String> weekdayLabels = _getWeekdayLabels();

                      if (dayIndex >= 1 && dayIndex <= 7) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            weekdayLabels[dayIndex - 1], // Get the appropriate label for the day
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }
                    return Container();
                  },
                  reservedSize: 30,
                  interval: dataShown == DataShown.byYear ? 1 : null,

                ),
              ),

            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                left: BorderSide.none,
                bottom: BorderSide(color: Colors.black),
                top: BorderSide.none,
                right: BorderSide.none,
              ),
            ),
            minX: 1,
            maxX: dataShown == DataShown.byMonth ? DateTime(month.year, month.month + 1, 0).day.toDouble() : dataShown == DataShown.byYear ? 12 : 7,
            minY: 0,
            maxY: maxYAxisValue, // Adjust according to your maximum y-axis value
            lineBarsData: [
              LineChartBarData(
                shadow: const Shadow(color: Colors.black),
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.5,
                isStrokeCapRound: true,
                isStepLineChart: false,
                isStrokeJoinRound: true,
                preventCurveOverShooting: true,
                barWidth: 3,
                color: Theme.of(context).colorScheme.onPrimary,
                belowBarData: BarAreaData(show: true, color: Colors.white.withValues(alpha: 0.3)),
                dotData: FlDotData(
                  show: true,
                  checkToShowDot: (spot, barData) {
                    return true; // Always show dots
                  },
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 6, // Dot size
                      color: Theme.of(context).colorScheme.onPrimary, // Dot color
                    );
                  },
                ),
                dashArray: [10, 10],
              ),
            ],
          ),
        ),
        if (allValuesAreZero)
          Positioned(top: 0,
              child: SizedBox(width: 230,
                  child: Text(replaceUnderscores(emptyInfoString), textAlign: TextAlign.center,)))
      ]);
  }
}


class DateSelectorDialog extends StatefulWidget {
  final ViewModelGlobal viewModel;
  final bool isCalendar;

  DateSelectorDialog({required this.viewModel, this.isCalendar = false});

  @override
  _DateSelectorDialogState createState() => _DateSelectorDialogState();
}

class _DateSelectorDialogState extends State<DateSelectorDialog> {
  late int chosenYear;
  late int chosenMonth;
  late DateTime focusedDay;

  @override
  void initState() {
    super.initState();
    if (widget.isCalendar) {
      chosenYear = widget.viewModel.calendarFocusedDay.year;
      chosenMonth = widget.viewModel.calendarFocusedDay.month;

    } else {
      chosenYear = widget.viewModel.currentMonth.year;
      chosenMonth = widget.viewModel.currentMonth.month;
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    final now = DateTime.now();
    bool isCurrentYear = chosenYear == now.year;
    final AppLocalizations? loc = AppLocalizations.of(context);
    final locale = loc?.appLanguage ?? '';
    final formatLocale = locale == 'en' ? 'en_US' : 'pt_BR' ;

    void increaseYear() {
      setState(() {
        chosenYear++;
      });
    }


    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                chosenYear--;
              });
            },
          ),
          PopupMenuButton<int>(
            onSelected: (int result) {
              setState(() {
                chosenYear = result;
              });
            },
            itemBuilder: (BuildContext context) {
              return List.generate(18, (index) {
                int year = DateTime.now().year - index;
                return PopupMenuItem<int>(
                  value: year,
                  child: Text(year.toString(), style: TextStyle(fontSize: 15),),
                );
              });
            },
            child: Text(
              '$chosenYear',
              style: TextStyle(fontSize: 18),
            ),
          ),

          IconButton(
            icon: isCurrentYear ? Container() : Icon(Icons.chevron_right),
            onPressed: isCurrentYear ? null : increaseYear,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < 3; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (index) {
                int month = i * 4 + index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      chosenMonth = month;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: chosenMonth == month ? brightness == Brightness.dark ? Theme.of(context).colorScheme.onPrimary : Colors.blue : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: SizedBox(width: 35,
                        child: Text(
                          DateFormat.MMM(formatLocale).format(DateTime(0, month)),
                          style: TextStyle(
                            color: chosenMonth == month ? brightness == Brightness.dark ? Theme.of(context).colorScheme.onPrimary : Colors.blue : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            DateTime selectedDate = DateTime(chosenYear, chosenMonth, 1);
            DateTime now = DateTime.now();

            // Check if the selected date is in the future
            if (selectedDate.isAfter(DateTime(now.year, now.month, 1))) {
              showAlert(context: context, alertTitle: loc?.alert ?? '', alertText: loc?.noMonthFromFuture ?? '', withoutSecondButton: true);
              /*// Display an error message or handle the future date selection
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: Color.fromRGBO(
                    177, 59, 78, 1.0),
                    content: Text('You cannot select a future month', textAlign: TextAlign.center,)),
              );*/
            } else {
              // Update the current month and close the dialog
              if (widget.isCalendar) {
                widget.viewModel.updateCalendarFocusedDay(selectedDate);
                Navigator.of(context).pop();
              } else {
                widget.viewModel.updateCurrentMonth(selectedDate);
                widget.viewModel.updateFocusedDay(selectedDate);
                Navigator.of(context).pop();
              }
            }
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}