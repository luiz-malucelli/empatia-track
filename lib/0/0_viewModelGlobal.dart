import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '0_diaSalvo.dart';
import '0_utilityFunctions.dart';
import '1_userData.dart';

class ViewModelGlobal extends ChangeNotifier {

  List<DiaSalvo> _diasSalvos = [];
  int _selectedIndex = 0;
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _calendarCurrentMonth = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime _calendarFocusedDay = DateTime.now();
  DataShown _dataShown = DataShown.byMonth;
  FontSize _fontSize = FontSize.small;
  String _googleEmail = '';
  bool _googleLinked = false;
  String _appleEmail = '';
  bool _appleLinked = false;
  bool _hasSeenExplanation = false;


  List<DiaSalvo> get diasSalvos => _diasSalvos;
  int get selectedIndex => _selectedIndex;
  DateTime get currentMonth => _currentMonth;
  DateTime get calendarCurrentMonth => _calendarCurrentMonth;
  DateTime get focusedDay => _focusedDay;
  DateTime get calendarFocusedDay => _calendarFocusedDay;
  DataShown get dataShown => _dataShown;
  FontSize get fontSize => _fontSize;
  String get googleEmail => _googleEmail;
  bool get googleLinked => _googleLinked;
  String get appleEmail => _appleEmail;
  bool get appleLinked => _appleLinked;
  bool get hasSeenExplanation =>_hasSeenExplanation;


  void loadUserData(UserData? userData) {

    _diasSalvos = userData?.diasSalvos ?? [];
    _appleEmail = userData?.appleEmail ?? '';
    _appleLinked = userData?.appleLinked ?? false;
    _googleEmail = userData?.googleEmail ?? '';
    _googleLinked = userData?.googleLinked ?? false;

    notifyListeners();
  }

  void logOutDataReset() {
    _diasSalvos = [];
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _calendarCurrentMonth = DateTime.now();
    _focusedDay = DateTime.now();
    _calendarFocusedDay = DateTime.now();
    _dataShown = DataShown.byMonth;
    _fontSize = FontSize.small;
    _googleEmail = '';
    _appleEmail = '';
  }

  Map<DateTime, List<String>> get events {
    Map<DateTime, List<String>> events = {};
    for (var dia in _diasSalvos) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(dia.date);
      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(dia.notes);
    }
    return events;
  }

  List<DiaSalvo> get filteredHighlights {
    switch (dataShown) {
      case DataShown.byWeek:
      return getFilteredDiaSalvosForWeek(currentMonth);
      case DataShown.byMonth:
        return getFilteredDiaSalvosForMonth(currentMonth);
      case DataShown.byYear:
        return getFilteredDiaSalvosForYear(currentMonth);
    }
  }



  // Function to get the sum of emotions for a specific week
  List<int> getSumOfEmotionsForWeek(DateTime week) {
    List<int> sumEmotions = List<int>.filled(5, 0); // Initialize a list with 5 zeros

    // Calculate the start of the week (Monday)
    DateTime startOfWeek = week.subtract(Duration(days: week.weekday - 1));
    // Calculate the end of the week (Sunday)
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    for (var dia in _diasSalvos) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(dia.date);
      if (date.isAfter(startOfWeek.subtract(Duration(days: 1))) && date.isBefore(endOfWeek.add(Duration(days: 1)))) {
        for (int i = 0; i < dia.emotions.length; i++) {
          sumEmotions[i] += dia.emotions[i];
        }
      }
    }
    return sumEmotions;
  }

  List<DiaSalvo> getFilteredDiaSalvosForWeek(DateTime week) {
    List<DiaSalvo> filteredDiaSalvos = [];

    // Calculate the start of the week (Monday)
    DateTime startOfWeek = week.subtract(Duration(days: week.weekday - 1));
    // Calculate the end of the week (Sunday)
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    for (var dia in _diasSalvos) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(dia.date);
      if (date.isAfter(startOfWeek.subtract(Duration(days: 1))) && date.isBefore(endOfWeek.add(Duration(days: 1)))) {
        if (dia.emotions[0] + dia.emotions[1] >= 3) {
          filteredDiaSalvos.add(dia);
        }
      }
    }
    // Filter out items where notes are empty
    filteredDiaSalvos = filteredDiaSalvos.where((dia) => dia.notes.isNotEmpty).toList();

    // Sort the filtered items by the difference between the first two emotions
    filteredDiaSalvos.sort((a, b) => (b.emotions[0] - b.emotions[1]).abs().compareTo((a.emotions[0] - a.emotions[1]).abs()));

    // Find the best pair for the first item in the list
    List<DiaSalvo> result = findPairForFirstItem(filteredDiaSalvos);

    // If no pair is found, return the first two items in chronological order
    if (result.isEmpty) {
      result = filteredDiaSalvos.take(2).toList();
    }

    // Ensure the results are in chronological order
    result.sort((a, b) => DateFormat('yyyy-MM-dd').parse(a.date).compareTo(DateFormat('yyyy-MM-dd').parse(b.date)));

    return result;
  }

  List<DiaSalvo> findPairForFirstItem(List<DiaSalvo> sortedDiaSalvos) {
    if (sortedDiaSalvos.isEmpty) return [];

    DiaSalvo firstItem = sortedDiaSalvos[0];
    List<int> firstEmotions = [firstItem.emotions[0], firstItem.emotions[1]];

    Map<List<int>, List<List<int>>> pairs5 = {
      [5, 0]: [[0, 5], [1, 4]],
      [0, 5]: [[5, 0], [4, 1]],
      [4, 1]: [[1, 4]],
      [1, 4]: [[4, 1]],
      [3, 2]: [[2, 3]],
      [2, 3]: [[3, 2]],
    };

    Map<List<int>, List<List<int>>> pairs4 = {
      [4, 0]: [[0, 4]],
      [3, 1]: [[1, 3], [2, 2]],
      [2, 2]: [[2, 2]],
      [1, 3]: [[3, 1], [2, 2]],
      [0, 4]: [[4, 0]],
    };

    Map<List<int>, List<List<int>>> pairs3 = {
      [2, 1]: [[1, 2]],
      [1, 2]: [[2, 1]],
    };

    List<int> key = [firstEmotions[0], firstEmotions[1]];

    // Function to find the best pair with priority
    DiaSalvo? findBestPair(DiaSalvo firstItem, List<List<int>> possiblePairs) {
      for (var pair in possiblePairs) {
        for (var candidate in sortedDiaSalvos.sublist(1)) {
          if (candidate.emotions[0] == pair[0] && candidate.emotions[1] == pair[1]) {
            return candidate;
          }
        }
      }
      return null;
    }

    // Handle pairs where i1 + i2 == 5
    if (firstEmotions[0] + firstEmotions[1] == 5 && pairs5.containsKey(key)) {
      DiaSalvo? bestPair = findBestPair(firstItem, pairs5[key]!);
      if (bestPair != null) {
        return [firstItem, bestPair];
      }
    }

    // Handle pairs where i1 + i2 == 4
    if (firstEmotions[0] + firstEmotions[1] == 4 && pairs4.containsKey(key)) {
      DiaSalvo? bestPair = findBestPair(firstItem, pairs4[key]!);
      if (bestPair != null) {
        return [firstItem, bestPair];
      }
    }

    // Handle pairs where i1 + i2 == 3
    if (firstEmotions[0] + firstEmotions[1] == 3 && pairs3.containsKey(key)) {
      DiaSalvo? bestPair = findBestPair(firstItem, pairs3[key]!);
      if (bestPair != null) {
        return [firstItem, bestPair];
      }
    }

    // If no pairs found, return an empty list
    return [];
  }


  List<DiaSalvo> getFilteredDiaSalvosForMonth(DateTime month) {
    List<DiaSalvo> filteredDiaSalvos = [];

    for (var dia in _diasSalvos) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(dia.date);
      if (date.year == month.year && date.month == month.month) {
        if (dia.emotions[0] + dia.emotions[1] >= 3) {
          filteredDiaSalvos.add(dia);
        }
      }
    }

    // Filter out items where notes are empty
    filteredDiaSalvos = filteredDiaSalvos.where((dia) => dia.notes.isNotEmpty).toList();

    // Sort the filtered items by the difference between the first two emotions
    filteredDiaSalvos.sort((a, b) => (b.emotions[0] - b.emotions[1]).abs().compareTo((a.emotions[0] - a.emotions[1]).abs()));

    // Group the pairs together
    List<DiaSalvo> groupedDiaSalvos = groupPairs(filteredDiaSalvos);

    // Take the top 4 items (or fewer if there are less than 4)
    List<DiaSalvo> topItems = groupedDiaSalvos.take(4).toList();

    // Sort the top items by date in ascending order
    topItems.sort((a, b) => DateFormat('yyyy-MM-dd').parse(a.date).compareTo(DateFormat('yyyy-MM-dd').parse(b.date)));

    return topItems;
  }

  List<DiaSalvo> groupPairs(List<DiaSalvo> sortedDiaSalvos) {
    List<DiaSalvo> result = [];
    Map<List<int>, List<List<int>>> pairs5 = {
      [5, 0]: [[0, 5], [1, 4]],
      [0, 5]: [[5, 0], [4, 1]],
      [4, 1]: [[1, 4]],
      [1, 4]: [[4, 1]],
      [3, 2]: [[2, 3]],
      [2, 3]: [[3, 2]],
    };

    Map<List<int>, List<List<int>>> pairs4 = {
      [4, 0]: [[0, 4]],
      [3, 1]: [[1, 3], [2, 2]],
      [2, 2]: [[2, 2]],
      [1, 3]: [[3, 1], [2, 2]],
      [0, 4]: [[4, 0]],
    };

    Map<List<int>, List<List<int>>> pairs3 = {
      [2, 1]: [[1, 2]],
      [1, 2]: [[2, 1]],
    };

    Set<int> usedIndices = Set();

    // Find pairs and group them
    for (int i = 0; i < sortedDiaSalvos.length; i++) {
      if (usedIndices.contains(i)) continue;
      DiaSalvo firstItem = sortedDiaSalvos[i];
      List<int> firstEmotions = [firstItem.emotions[0], firstItem.emotions[1]];
      List<int> key = [firstEmotions[0], firstEmotions[1]];

      bool foundPair = false;
      if (firstEmotions[0] + firstEmotions[1] == 5 && pairs5.containsKey(key)) {
        List<List<int>> possiblePairs = pairs5[key]!;
        for (var pair in possiblePairs) {
          for (int j = i + 1; j < sortedDiaSalvos.length; j++) {
            if (sortedDiaSalvos[j].emotions[0] == pair[0] && sortedDiaSalvos[j].emotions[1] == pair[1]) {
              result.add(firstItem);
              result.add(sortedDiaSalvos[j]);
              usedIndices.add(i);
              usedIndices.add(j);
              foundPair = true;
              break;
            }
          }
          if (foundPair) break;
        }
      }

      if (firstEmotions[0] + firstEmotions[1] == 4 && pairs4.containsKey(key)) {
        List<List<int>> possiblePairs = pairs4[key]!;
        for (var pair in possiblePairs) {
          for (int j = i + 1; j < sortedDiaSalvos.length; j++) {
            if (sortedDiaSalvos[j].emotions[0] == pair[0] && sortedDiaSalvos[j].emotions[1] == pair[1]) {
              result.add(firstItem);
              result.add(sortedDiaSalvos[j]);
              usedIndices.add(i);
              usedIndices.add(j);
              foundPair = true;
              break;
            }
          }
          if (foundPair) break;
        }
      }

      if (firstEmotions[0] + firstEmotions[1] == 3 && pairs3.containsKey(key)) {
        List<List<int>> possiblePairs = pairs3[key]!;
        for (var pair in possiblePairs) {
          for (int j = i + 1; j < sortedDiaSalvos.length; j++) {
            if (sortedDiaSalvos[j].emotions[0] == pair[0] && sortedDiaSalvos[j].emotions[1] == pair[1]) {
              result.add(firstItem);
              result.add(sortedDiaSalvos[j]);
              usedIndices.add(i);
              usedIndices.add(j);
              foundPair = true;
              break;
            }
          }
          if (foundPair) break;
        }
      }

      if (!foundPair) {
        result.add(firstItem);
        usedIndices.add(i);
      }
    }

    // If less than 4 items found, add more items to result to make it a maximum of 4
    for (int i = 0; i < sortedDiaSalvos.length && result.length < 4; i++) {
      if (!usedIndices.contains(i)) {
        result.add(sortedDiaSalvos[i]);
      }
    }

    return result;
  }

  List<DiaSalvo> getFilteredDiaSalvosForYear(DateTime year) {
    List<DiaSalvo> filteredDiaSalvos = [];

    for (var dia in _diasSalvos) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(dia.date);
      if (date.year == year.year) {
        if (dia.emotions[0] + dia.emotions[1] >= 3) {
          filteredDiaSalvos.add(dia);
        }
      }
    }

    // Filter out items where notes are empty
    filteredDiaSalvos = filteredDiaSalvos.where((dia) => dia.notes.isNotEmpty).toList();

    // Sort the filtered items by the difference between the first two emotions
    filteredDiaSalvos.sort((a, b) => (b.emotions[0] - b.emotions[1]).abs().compareTo((a.emotions[0] - a.emotions[1]).abs()));

    // Group the pairs together
    List<DiaSalvo> groupedDiaSalvos = groupPairs(filteredDiaSalvos);

    // Select top 12 items with month diversity
    List<DiaSalvo> topItems = selectTopItemsWithDiversity(groupedDiaSalvos, 12);

    // Sort the top items by date in ascending order
    topItems.sort((a, b) => DateFormat('yyyy-MM-dd').parse(a.date).compareTo(DateFormat('yyyy-MM-dd').parse(b.date)));

    return topItems;
  }

  List<DiaSalvo> selectTopItemsWithDiversity(List<DiaSalvo> groupedDiaSalvos, int maxItems) {
    List<DiaSalvo> result = [];
    Map<int, int> monthCounts = {};

    // Count the number of items available for each month
    for (var dia in groupedDiaSalvos) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(dia.date);
      int month = date.month;
      monthCounts[month] = (monthCounts[month] ?? 0) + 1;
    }

    // Initialize the month selection count
    Map<int, int> selectedMonthCounts = {};

    // Iterate over the sorted items and select up to maxItems
    int i = 0;
    while (result.length < maxItems && i < groupedDiaSalvos.length) {
      DiaSalvo current = groupedDiaSalvos[i];
      DateTime date = DateFormat('yyyy-MM-dd').parse(current.date);
      int currentMonth = date.month;

      // Check if there are ties with the next item(s)
      List<DiaSalvo> tiedItems = [current];
      while (i + 1 < groupedDiaSalvos.length && areItemsTied(groupedDiaSalvos[i], groupedDiaSalvos[i + 1])) {
        i++;
        tiedItems.add(groupedDiaSalvos[i]);
      }

      // Sort tied items by month diversity
      tiedItems.sort((a, b) {
        DateTime dateA = DateFormat('yyyy-MM-dd').parse(a.date);
        DateTime dateB = DateFormat('yyyy-MM-dd').parse(b.date);
        int monthA = dateA.month;
        int monthB = dateB.month;
        return (selectedMonthCounts[monthA] ?? 0).compareTo((selectedMonthCounts[monthB] ?? 0));
      });

      // Add the top item(s) to the result, considering month diversity
      for (var dia in tiedItems) {
        if (result.length >= maxItems) break;
        DateTime date = DateFormat('yyyy-MM-dd').parse(dia.date);
        int month = date.month;

        result.add(dia);
        selectedMonthCounts[month] = (selectedMonthCounts[month] ?? 0) + 1;
      }

      i++;
    }

    return result;
  }

  bool areItemsTied(DiaSalvo a, DiaSalvo b) {
    return (a.emotions[0] == b.emotions[0] && a.emotions[1] == b.emotions[1]) ||
        (a.emotions[0] == b.emotions[1] && a.emotions[1] == b.emotions[0]);
  }


  // Function to get the sum of emotions for a specific month
  List<int> getSumOfEmotionsForMonth(DateTime month) {
    List<int> sumEmotions = List<int>.filled(5, 0); // Initialize a list with 5 zeros

    for (var dia in _diasSalvos) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(dia.date);
      if (date.year == month.year && date.month == month.month) {
        for (int i = 0; i < dia.emotions.length; i++) {
          sumEmotions[i] += dia.emotions[i];
        }
      }
    }
    return sumEmotions;
  }

  // Function to get the sum of emotions for each day in the specified week
  Map<int, int> getDailySumsForWeek(DateTime week) {
    Map<int, int> dailySums = {};

    // Calculate the start of the week (Monday)
    DateTime startOfWeek = week.subtract(Duration(days: week.weekday - 1));
    // Calculate the end of the week (Sunday)
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    for (var dia in _diasSalvos) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(dia.date);
      if (date.isAfter(startOfWeek.subtract(Duration(days: 1))) && date.isBefore(endOfWeek.add(Duration(days: 1)))) {
        int dayOfWeek = date.weekday;
        int sumEmotions = dia.emotions.reduce((a, b) => a + b);
        if (dailySums.containsKey(dayOfWeek)) {
          dailySums[dayOfWeek] = dailySums[dayOfWeek]! + sumEmotions;
        } else {
          dailySums[dayOfWeek] = sumEmotions;
        }
      }
    }

    return dailySums;
  }


  // Function to get the sum of emotions for each day in the specified month
  Map<int, int> getDailySumsForMonth(DateTime month) {
    Map<int, int> dailySums = {};

    for (var dia in _diasSalvos) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(dia.date);
      if (date.year == month.year && date.month == month.month) {
        int day = date.day;
        int sumEmotions = dia.emotions.reduce((a, b) => a + b);
        if (dailySums.containsKey(day)) {
          dailySums[day] = dailySums[day]! + sumEmotions;
        } else {
          dailySums[day] = sumEmotions;
        }
      }
    }

    return dailySums;
  }

  // Function to get the average of daily sums for each month in the specified year
  Map<int, double> getMonthlyAveragesForYear(int year) {
    Map<int, List<int>> monthlySums = {};

    // Collect daily sums for each month
    for (var dia in _diasSalvos) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(dia.date);
      if (date.year == year) {
        int month = date.month;
        int sumEmotions = dia.emotions.reduce((a, b) => a + b);
        if (monthlySums.containsKey(month)) {
          monthlySums[month]!.add(sumEmotions);
        } else {
          monthlySums[month] = [sumEmotions];
        }
      }
    }

    // Calculate the average daily sum for each month
    Map<int, double> monthlyAverages = {};
    monthlySums.forEach((month, sums) {
      double average = sums.reduce((a, b) => a + b) / sums.length;
      monthlyAverages[month] = average;
    });

    return monthlyAverages;
  }

  // Function to get the sum of emotions for a specific year
  List<int> getSumOfEmotionsForYear(DateTime year) {
    List<int> sumEmotions = List<int>.filled(5, 0); // Initialize a list with 5 zeros

    for (var dia in _diasSalvos) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(dia.date);
      if (date.year == year.year) {
        for (int i = 0; i < dia.emotions.length; i++) {
          sumEmotions[i] += dia.emotions[i];
        }
      }
    }
    return sumEmotions;
  }

  void addDiaSalvo(DiaSalvo diaSalvo) {
    _diasSalvos.add(diaSalvo);
    notifyListeners();
    saveDiasSalvos(); // Save to device whenever the list changes
  }

  Future<void> saveDiasSalvos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonStringList = _diasSalvos.map((dia) => jsonEncode(dia.toJson())).toList();
    prefs.setStringList('diasSalvos', jsonStringList);
    print('updated diasSalvos on device');
  }

  Future<void> loadDiasSalvos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonStringList = prefs.getStringList('diasSalvos');
    if (jsonStringList != null) {
      print('diasSalvos is not NULL');
      _diasSalvos = jsonStringList.map((jsonString) => DiaSalvo.fromJson(jsonDecode(jsonString))).toList();
      notifyListeners();
    }
  }

  Future<void> deleteDiasSalvos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('diasSalvos');
    print('deleted diasSalvos from device');

    _diasSalvos = [];
    notifyListeners();
  }

  List<DiaSalvo> getDiaSalvoByDate(DateTime date) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return _diasSalvos.where((dia) => dia.date == formattedDate).toList();
  }

  void setSelectedIndex(int value) {
    if (_selectedIndex != value) {
      _selectedIndex = value;
      notifyListeners();
    }
  }

  void updateCurrentMonth(DateTime month) {
      _currentMonth = month;
      notifyListeners();
  }

  void updateCalendarCurrentMonth(DateTime month) {
    _calendarCurrentMonth = month;
    notifyListeners();
  }

  void updateFocusedDay(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  void updateCalendarFocusedDay(DateTime day) {
    _calendarFocusedDay = day;
    notifyListeners();
  }

  void updateDataShown(DataShown value) {
    if (_dataShown != value) {
      _dataShown = value;
      notifyListeners();
    }
  }

  void updateFontSize(FontSize value) {
    if (_fontSize != value) {
      _fontSize = value;
      notifyListeners();
    }
  }

  Future<void> saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('empatiaTrackFontSize', _fontSize.name);
  }

  Future<void> loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final fontSizeString = prefs.getString('empatiaTrackFontSize') ?? FontSize.small.name;
    _fontSize = FontSize.values.byName(fontSizeString);
  }

  Future<void> saveHasSeenExplanation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('empatiaTrackExplanation', true);
    _hasSeenExplanation = true;
  }

  Future<void> loadHasSeenExplanation() async {
    final prefs = await SharedPreferences.getInstance();
    final boolValue = prefs.getBool('empatiaTrackExplanation') ?? false;
    _hasSeenExplanation = boolValue;
  }

  void setAppleLinked(bool value) {
    if (_appleLinked != value) {
      _appleLinked = value;
      notifyListeners();
    }
  }

  void setGoogleLinked(bool value) {
    if (_googleLinked != value) {
      _googleLinked = value;
      notifyListeners();
    }
  }

  void setAppleEmail(String value) {
    if (_appleEmail != value) {
      _appleEmail = value;
      notifyListeners();
    }
  }

  void setGoogleEmail(String value) {
    if (_googleEmail != value) {
      _googleEmail = value;
      notifyListeners();
    }
  }

}