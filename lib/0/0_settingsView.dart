import 'package:empatiatrack/0/0_customListElements.dart';
import 'package:empatiatrack/0/0_developerInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '0_utilityFunctions.dart';
import '0_viewModelGlobal.dart';
import '1_accountView.dart';
import '1_firebaseServices.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  double logOutButtonOpacity = 1.0;

  logOutNeededAccountDeleted() {
    final FirebaseServices firebaseServices = FirebaseServices();

    firebaseServices.signOutUser((success, error) {
      if (!success) {
        firebaseServices.signOutCurrentUser();
      }
    });
    Navigator.of(context).pop(SettingsViewResult.accountDeleted);
  }

  logOut() {
    final FirebaseServices firebaseServices = FirebaseServices();

    firebaseServices.signOutUser((success, error) {
      if (!success) {
        firebaseServices.signOutCurrentUser();
      }
    });
    Navigator.of(context).pop(SettingsViewResult.noActionNeeded);
  }


  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ViewModelGlobal>(context);
    final AppLocalizations? loc = AppLocalizations.of(context);
    var brightness = Theme.of(context).brightness;
    final fontSizeGlobal = viewModel.fontSize;

    String termsOfUse() {
      if (loc?.appLanguage == 'en') {
        return 'https://en.jogoempatia.com/empatia-track-termos-de-uso';
      } else {
        return 'https://pt.jogoempatia.com/empatia-track-termos-de-uso';
      }
    }

    String privacyPolicy() {
      if (loc?.appLanguage == 'en') {
        return 'https://en.jogoempatia.com/empatia-track-politica-de-privacidade';
      } else {
        return 'https://pt.jogoempatia.com/empatia-track-politica-de-privacidade';
      }
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

      ),
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ListView(
          children: [

            const SizedBox(height: 15),

            CustomSection(sectionTitle: '', bgOpacity: brightness == Brightness.dark ? 1.0 : 0.9,
                children: [
              CustomListItem(primaryColor: false,
                  listItemString: loc?.textSize ?? '',
                  fontSize: fontSize(15, viewModel),
                  children: [
                    CustomPopupMenuButton<FontSize>(fontSize: fontSize(15, viewModel),
                        menuItems: generateMenuItems<FontSize>(fontSizeGlobal, FontSize.values, fontSize(16, viewModel) ,(item) => item.localized(context),
                        ),
                        popupMenuItemString: fontSizeGlobal.localized(context),
                        onSelected: (value) {
                          setState(() {
                            viewModel.updateFontSize(value);
                            viewModel.saveFontSize();
                          });
                        })
                  ]),
              CustomDivider(),
              GestureDetector(
                onTap: () {
                  logEvent('navigating to MyAccount view');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        AccountView()),
                  ).then((result) {
                    switch (result) {
                      case AccountViewResult.logOutNeeded:
                        logOutNeededAccountDeleted();
                      case AccountViewResult.noActionNeeded:
                        break;

                    }
                  });


                },
                child: CustomListItem(primaryColor: false,
                    fontSize: fontSize(15, viewModel),
                    listItemString: loc?.myAccount ?? '', children: [
                      const CustomNavigationIcon(),
                    ]),
              ),
            ]),

            const SizedBox(height: 32),

            CustomSection(sectionTitle: '', bgOpacity: brightness == Brightness.dark ? 1.0 : 0.9,
                children: [
                  GestureDetector(
                    onTap: () {
                      logEvent('navigating to DeveloperInfo view');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            DeveloperInfo()),
                      );


                    },
                    child: CustomListItem(primaryColor: false,
                        fontSize: fontSize(15, viewModel),
                        listItemString: loc?.aboutTheDeveloper ?? '', children: [
                          const CustomNavigationIcon(),
                        ]),
                  ),
                ]),

            const  SizedBox(height: 30),

            CustomSection(sectionTitle: 'Links', children: [
              GestureDetector(onTap: () {
                launchUrl(Uri.parse(termsOfUse()));
              },
                child: CustomListItem(listItemString: loc?.termsOfUse ?? '', fontSize: fontSize(15, viewModel),
                    children: const [
                      CustomNavigationIcon(),
                    ]),
              ),
              const CustomDivider(),
              GestureDetector(onTap: () {
                launchUrl(Uri.parse(privacyPolicy()));
              },
                child: CustomListItem(listItemString: loc?.privacyPolicy ?? '', fontSize: fontSize(15, viewModel),
                    children: const [
                      CustomNavigationIcon(),
                    ]),
              ),
            ]),

            const SizedBox(height: 32),

            GestureDetector(
              onTap: () {
                setState(() {
                  logOutButtonOpacity = 1.0;
                });
                logOut();
              },
              onTapCancel: () {
                setState(() {
                  logOutButtonOpacity = 1.0;
                });
              },
              onTapDown: (_) {
                setState(() {
                  logOutButtonOpacity = 0.8;
                });
              },
              child: Opacity(
                opacity: logOutButtonOpacity,
                child: CustomSection(
                    sectionTitle: '', bgOpacity: brightness == Brightness.dark ? 1.0 : 0.9,
                    children: [
                  Container(padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(loc?.logOut ?? '',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: (brightness == Brightness.dark) ? Color.fromRGBO(
                                    253, 124, 124, 1.0) : Color.fromRGBO(
                                    193, 77, 77, 1.0),
                                fontSize: fontSize(15, viewModel))
                        ),


                      ],
                    ),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('${loc?.developedBy}\nEmpatia Produtos Psicopedagógicos', textAlign: TextAlign.center,
                style: TextStyle(fontSize: fontSize(15, viewModel), fontWeight: FontWeight.w400, height: 1.5),
              ),
            ),

            // const SizedBox(height: 20)

          ],
        ),
      ),
    );
  }
  List<PopupMenuItem<T>> generateMenuItems<T>(
      T selectedItem,
      List<T> allValues,
      double fontSize,
      String Function(T) getDisplayString,
      ) {
    return allValues.map((item) {
      bool isSelected = item == selectedItem;
      return PopupMenuItem<T>(
        value: item,
        child: Row(
          children: [
            Icon(
              isSelected ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
              color: isSelected ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8) : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              getDisplayString(item),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: fontSize, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      );
    }).toList();
  }
}