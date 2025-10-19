import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/l10n/app_localizations.dart';
import 'dart:io';
import '0_utilityFunctions.dart';
import '0_viewModelGlobal.dart';



class DeveloperInfo extends StatefulWidget {
  const DeveloperInfo({super.key});

  @override
  DeveloperInfoState createState() => DeveloperInfoState();
}

class DeveloperInfoState extends State<DeveloperInfo> {

  @override
  void initState() {
    super.initState();
  }






  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ViewModelGlobal>(context);
    final AppLocalizations? loc = AppLocalizations.of(context);

    final List<Map<String, String>> aboutTheDeveloperData = [];

    final List<Map<String, String>> aboutTheDeveloperDataLongAnswer = [];

    var brightness = Theme.of(context).brightness;
    Brightness androidBrightness = (brightness == Brightness.dark) ? Brightness.light : Brightness.dark;

    if (loc != null) {
      aboutTheDeveloperData.add({
        "question": loc.empatiaQuestion,
        "answer": loc.empatiaShortAnswer,
      });


      aboutTheDeveloperData.add({
        "question": loc.faceBehindQuestion,
        "answer": loc.faceBehindShortAnswer,
      });


      aboutTheDeveloperDataLongAnswer.add({
        "question": loc.empatiaQuestion,
        "answer": loc.empatiaLongAnswer,
      });

      aboutTheDeveloperDataLongAnswer.add({
        "question": loc.faceBehindQuestion,
        "answer": loc.faceBehindLongAnswer,
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: (Platform.isIOS) ? SystemUiOverlayStyle(statusBarBrightness: brightness, statusBarIconBrightness: brightness) : SystemUiOverlayStyle(statusBarBrightness: androidBrightness, statusBarIconBrightness: androidBrightness),
        centerTitle: true,
        title: Text(loc?.aboutTheDeveloper ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w600, fontSize: fontSize(22, viewModel)),
        ),
        leading: IconButton(
            icon: Icon(Icons.chevron_left,
              size: 30, color: Theme.of(context).colorScheme.onPrimary,), // Custom icon
            onPressed: () {
              Navigator.of(context).pop(false);
            }
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
          child:
          SingleChildScrollView(
              child:
              Column(children: [
                Row(children: [
                  Padding(padding: const EdgeInsets.only(left: 35, top: 10, bottom: 5),
                      child:
                      Text(loc?.quickInfo.toUpperCase() ?? '', style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: fontSize(15, viewModel),
                          fontWeight: FontWeight.w400)
                      )
                  )
                ]),
                Container(
                  decoration: BoxDecoration(
                    color: brightness == Brightness.dark ? Theme.of(context).colorScheme.surface : Color.fromRGBO(121, 198, 205, 1.0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: List.generate(
                      aboutTheDeveloperData.length,
                          (index) {
                        final isLastItem = index == aboutTheDeveloperData.length - 1;
                        return Column(
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Theme(
                                data: ThemeData(
                                  dividerColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  collapsedIconColor: Theme.of(context).colorScheme.primary,
                                  textColor: Theme.of(context).colorScheme.onSecondary,
                                  iconColor: Theme.of(context).colorScheme.primary,
                                  backgroundColor: Colors.transparent,
                                  tilePadding: const EdgeInsets.only(left: 25, right: 20, top: 0, bottom: 0),
                                  childrenPadding: const EdgeInsets.only(left: 25, right: 40, bottom: 15, top: 6),
                                  collapsedBackgroundColor: Colors.transparent,
                                  title: Text(
                                    aboutTheDeveloperData[index]["question"]!,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: fontSize(15, viewModel),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  children: <Widget>[
                                    Align(alignment: Alignment.centerLeft,
                                      child: Text(
                                        aboutTheDeveloperData[index]["answer"]!,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontSize: fontSize(15, viewModel),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!isLastItem) const CustomDivider(),
                            if (isLastItem) const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),



                Row(children: [
                  Padding(padding: const EdgeInsets.only(left: 35, top: 10, bottom: 5),
                      child:
                      Text(loc?.detailedInfo.toUpperCase() ?? '', style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: fontSize(15, viewModel),
                          fontWeight: FontWeight.w400)
                      )
                  )
                ]),

                Container(
                  decoration: BoxDecoration(
                    color: brightness == Brightness.dark ? Theme.of(context).colorScheme.surface : Color.fromRGBO(121, 198, 205, 1.0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: List.generate(
                      aboutTheDeveloperDataLongAnswer.length,
                          (index) {
                        final isLastItem = index == aboutTheDeveloperDataLongAnswer.length - 1;
                        return Column(
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Theme(
                                data: ThemeData(
                                  dividerColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  collapsedIconColor: Theme.of(context).colorScheme.primary,
                                  textColor: Theme.of(context).colorScheme.onSecondary,
                                  iconColor: Theme.of(context).colorScheme.primary,
                                  backgroundColor: Colors.transparent,
                                  tilePadding: const EdgeInsets.only(left: 25, right: 20, top: 0, bottom: 0),
                                  childrenPadding: const EdgeInsets.only(left: 25, right: 40, bottom: 15, top: 6),
                                  collapsedBackgroundColor: Colors.transparent,
                                  title: Text(
                                    aboutTheDeveloperDataLongAnswer[index]["question"]!,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: fontSize(15, viewModel),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  children: <Widget>[
                                    Text(
                                      aboutTheDeveloperDataLongAnswer[index]["answer"]!,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontSize: fontSize(15, viewModel),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!isLastItem) const CustomDivider(),
                            if (isLastItem) const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Row(children: [
                  Padding(padding: const EdgeInsets.only(left: 35, top: 10, bottom: 5),
                      child:
                      Text(loc?.contactInfo.toUpperCase() ?? '', style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: fontSize(15, viewModel),
                          fontWeight: FontWeight.w400)
                      )
                  )
                ]),

                Container(
                  decoration: BoxDecoration(
                    color: brightness == Brightness.dark ? Theme.of(context).colorScheme.surface : Color.fromRGBO(121, 198, 205, 1.0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 35, top: 20, bottom: 20),
                          child:
                          Text(
                            'info+app@jogoempatia.com',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: fontSize(15, viewModel), fontWeight: FontWeight.w700,
                            ),
                          ),

                        ),
                      ]
                  ),
                ),

                const SizedBox(height: 65)
              ])
          )
      ),

    );
  }
}
