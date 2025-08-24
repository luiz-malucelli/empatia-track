import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

import '../l10n/app_localizations.dart';
import '0_chartsView.dart';
import '0_utilityFunctions.dart';
import '0_viewModelGlobal.dart';

class PrintCharts extends StatefulWidget {
  final int currentIndex;
  final bool saveImage;

  const PrintCharts({
    super.key,
    required this.currentIndex,
    required this.saveImage,
  });

  @override
  PrintChartsState createState() => PrintChartsState();
}

class PrintChartsState extends State<PrintCharts> {
  final ScreenshotController screenshotController = ScreenshotController();
  double showWeekDataOpacity = 1.0;
  double showMonthDataOpacity = 1.0;
  double showYearDataOpacity = 1.0;
  DateTime _today = DateTime.now();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    initializeCurrentIndex();

    // Delay the capture to give the UI time to render
    Future.delayed(const Duration(milliseconds: 500), () {
      showLoadingDialog(context);

      preloadImageAndThenCapture();

    });
  }

  void preloadImageAndThenCapture() {
    preloadImages(context).then((_) {
      if (widget.saveImage) {
        captureAndSaveImage();
      } else {
        captureAndSharePDF();
      }
    });
  }

  void initializeCurrentIndex() {
    currentIndex = widget.currentIndex;
    setState(() {});

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

  bool _isCurrentWeek(DateTime date) {
    DateTime now = DateTime.now();

    // Calculate the start of the current week (Monday)
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    // Calculate the end of the current week (Sunday)
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    // Check if the given date is within the current week
    return date.isAfter(startOfWeek.subtract(Duration(days: 1))) && date.isBefore(endOfWeek.add(Duration(days: 1)));
  }


  Future<void> captureAndSaveImage() async {
    // Capture the screenshot
    final Uint8List? imageBytes = await screenshotController.capture();
    if (imageBytes != null) {
      // Save the image to the photo album
      await _saveImageToPhotoAlbum(imageBytes);
      hideLoadingDialog(context);
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveImageToPhotoAlbum(Uint8List bytes) async {
    String formattedDate = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());

    try {
      // Get the temporary directory to save the image file
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;

      // Generate a unique file name for the image
      final String fileName = "Empatia Track - $formattedDate.png";

      // Create a file and write the image data to it
      final File imageFile = File('$tempPath/$fileName');
      await imageFile.writeAsBytes(bytes);

      // Save the image to the photo album using GallerySaver
      await GallerySaver.saveImage(imageFile.path);
      print('Image saved to photo album.\nwith name: $fileName');
    } catch (e) {
      print('Failed to save image to photo album: $e');
    }
  }

  Future<void> captureAndSharePDF() async {
    final Uint8List? imageBytes = await screenshotController.capture();

    if (imageBytes != null) {
      // Get the dimensions of the image
      ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      ui.Image image = (await codec.getNextFrame()).image;
      int width = image.width;
      int height = image.height;

      // Generate PDF document
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(width.toDouble(), height.toDouble()), // Set page format to match image dimensions
          build: (pw.Context context) {
            // Convert imageBytes to an image widget
            final image = pw.MemoryImage(imageBytes);
            // Return the image widget
            return pw.Expanded(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            );
          },
        ),
      );

      if (!kIsWeb) {
        // Non-web platform logic (mobile/desktop)
        final String pdfPath = await _savePDFTemporarily(pdf);
        if (pdfPath.isNotEmpty) {
          final List<XFile> files = [XFile(pdfPath, mimeType: 'application/pdf')];
          final box = context.findRenderObject() as RenderBox?;
          final position = box!.localToGlobal(Offset.zero) & box.size;
          await Share.shareXFiles(files, sharePositionOrigin: position);
        }
      } else {
        // Web platform logic
        final Uint8List pdfBytes = await pdf.save();
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'capturedContent.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      }

      // Hide loading dialog and navigate back, if applicable
      hideLoadingDialog(context);
      Navigator.of(context).pop();
    }
  }

  Future<String> _savePDFTemporarily(pw.Document pdf) async {
    String formattedDate = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/Empatia Track - $formattedDate.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ViewModelGlobal>(context, listen: false);
    final AppLocalizations? loc = AppLocalizations.of(context);
    final locale = loc?.appLanguage ?? '';
    final formatLocale = locale == 'en' ? 'en_US' : 'pt_BR' ;
    var brightness = Theme.of(context).brightness;
    final dataShown = viewModel.dataShown;

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


    return Scaffold(backgroundColor: Theme.of(context).colorScheme.onSecondary,
        body: ListView(
            controller: ScrollController(),
            children: [
              Container(color: Theme.of(context).colorScheme.onSecondary,
                  child:
                  SingleChildScrollView(padding: EdgeInsets.all(0),
                      child:
                  Screenshot(
                      controller: screenshotController,
                      child: Container(color: Theme.of(context).colorScheme.onSecondary,

                          child:
                          SingleChildScrollView(padding: EdgeInsets.all(0),
                            child:

                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [

                                const SizedBox(height: 10),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                          onPressed: () {},
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
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  ),

                                const SizedBox(height: 15),


                                Text(replaceUnderscores(summaryString), textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: fontSize(18, viewModel), fontWeight: FontWeight.w600, height: 1.2), ),

                                buildEventList(viewModel, viewModel.currentMonth, dataShown, context),
        /*
                                if (highlights.isNotEmpty)
                                  const SizedBox(height: 50),
                                if (highlights.isNotEmpty)
                                  Text(loc?.highlights ?? '', style: TextStyle(fontSize: fontSize(20, viewModel), fontWeight: FontWeight.w500, height: 0.5)),
                                if (highlights.isNotEmpty)
                                  SizedBox(height: highlights.length > 1 ? 0 : 11),
                                if (highlights.isNotEmpty)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (highlights.length > 1)
                                        IconButton(
                                          icon: Icon(Icons.chevron_left, color: brightness == Brightness.dark ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
                                          onPressed: _goToPrevious,
                                        ),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(fontSize: fontSize(18, viewModel),  fontWeight: brightness == Brightness.dark ? FontWeight.w300 : FontWeight.w400,),
                                      ),
                                      if (highlights.length > 1)
                                        IconButton(
                                          icon: Icon(Icons.chevron_right, color: brightness == Brightness.dark ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
                                          onPressed: _goToNext,
                                        ),
                                    ],
                                  ),
                                if (highlights.length == 1)
                                  const SizedBox(height: 11),
                                if (highlights.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Colors.white.withValues(alpha: brightness == Brightness.dark ? 0.2 : 0.2),
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
                                if (highlights.isNotEmpty)
                                  const SizedBox(height: 20),
        */
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
                                            color: Colors.white.withValues(alpha: brightness == Brightness.dark ? 0.2 : 0.2), // Background color of the chart
                                          ),
                                          padding: EdgeInsets.only(bottom: 24, top: 36, right: dataShown == DataShown.byWeek ? 35 : dataShown == DataShown.byMonth ? 30 : 25, left: dataShown == DataShown.byWeek ? 35 : 25),
                                          // Add padding to give space for the border
                                          child: LineChartSample(viewModel: viewModel, month: viewModel.currentMonth, dataShown: dataShown,))),
                                ),

                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                          )
                      )
                  )
                  )
              )
            ])
    );
  }
}