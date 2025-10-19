import 'dart:io';

import 'package:empatiatrack/0/0_customListElements.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '0_utilityFunctions.dart';
import '0_viewModelGlobal.dart';
import '1_firebaseServices.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  double deleteAccountButtonOpacity = 1.0;

  @override
  void initState() {
    super.initState();
  }

  void logOutNeeded() {
    Navigator.of(context).pop(AccountViewResult.logOutNeeded);
  }


  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ViewModelGlobal>(context);
    final AppLocalizations? loc = AppLocalizations.of(context);
    var brightness = Theme.of(context).brightness;
    final FirebaseServices firebaseServices = FirebaseServices();
    final googleLinked = viewModel.googleLinked;
    final googleEmail = viewModel.googleEmail;
    final appleLinked = viewModel.appleLinked;
    final appleEmail = viewModel.appleEmail;

    String appleAccountString() {
      if (appleLinked) {
        if (appleEmail.isNotEmpty) {
          return appleEmail;
        } else {
          return loc?.appleIdLinked ?? '';
        }
      } else {
        return loc?.linkAppleId ?? '';
      }
    }

    String googleAccountString() {
      if (googleLinked) {
        if (googleEmail.isNotEmpty) {
          return googleEmail;
        } else {
          return loc?.googleAccountLinked ?? '';
        }
      } else {
        return loc?.linkGoogleAccount ?? '';
      }
    }

    Brightness androidBrightness = (brightness == Brightness.dark) ? Brightness.light : Brightness.dark;


    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: (Platform.isIOS) ? SystemUiOverlayStyle(statusBarBrightness: brightness, statusBarIconBrightness: brightness) : SystemUiOverlayStyle(statusBarBrightness: androidBrightness, statusBarIconBrightness: androidBrightness),
          centerTitle: true,
          title: Text(loc?.myAccount ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600, fontSize: fontSize(22, viewModel)),
          ),
          leading: IconButton(
              icon: Icon(Icons.chevron_left,
                size: 30, color: Theme.of(context).colorScheme.onPrimary,), // Custom icon
              onPressed: () {
                Navigator.of(context).pop(AccountViewResult.noActionNeeded);
              }
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [

              const SizedBox(height: 15),

              CustomSection(sectionTitle: 'Apple ID', bgOpacity: brightness == Brightness.dark ? 1.0 : 0.9,
                  children: [
                GestureDetector(
                  onTap: () async {
                    if (!appleLinked) {
                      logEvent('link apple account tapped');
                      AlertPopData? alertData = await showAlert(context: context, alertTitle: loc?.alert ?? '', alertText: loc?.linkAppleIdAlert ?? '');

                      if (alertData == AlertPopData.firstButton) {
                        showLoadingDialog(context);
                        final linkAppleIdResponse = await firebaseServices.linkAppleAccountToExistingGoogleAccount();

                        switch (linkAppleIdResponse.result) {

                          case AppleLinkResult.success:
                            viewModel.setAppleLinked(true);
                            if (linkAppleIdResponse.email != null) {
                              viewModel.setAppleEmail(linkAppleIdResponse.email ?? '');
                            }
                            hideLoadingDialog(context);
                            showAlert(context: context, alertTitle: loc?.alert ?? '', alertText: loc?.appleIdLinkedSuccessfully ?? '', withoutSecondButton: true);
                          case AppleLinkResult.android:
                            hideLoadingDialog(context);
                            showAlert(context: context, alertTitle: loc?.alert ?? '', alertText: loc?.signInWithAppleAndroidAlert ?? '', withoutSecondButton: true);
                          case AppleLinkResult.failure:
                            logEvent('erro ao vincular conta apple');
                            hideLoadingDialog(context);
                            showAlert(context: context, alertTitle: loc?.alert ?? '', alertText: '${loc?.error} ${localizedFirebaseErrorMessage(linkAppleIdResponse.error, context)}', withoutSecondButton: true);
                        }

                      }

                    // } else if (appleLinked && googleLinked) {
                    //   logEvent('unlink apple account tapped. both providers are linked');
                    //   AlertPopData? alertData = await showAlert(context: context, alertTitle: loc?.alert ?? '', alertText: loc?.unlinkAppleIdAlert ?? '');
                    //
                    //   if (alertData == AlertPopData.firstButton) {
                    //     showLoadingDialog(context);
                    //     final unlinkResponse = await firebaseServices.unlinkAppleAccount();
                    //
                    //     switch (unlinkResponse.result) {
                    //
                    //       case Result.success:
                    //         viewModel.setAppleLinked(false);
                    //
                    //         hideLoadingDialog(context);
                    //         showAlert(context: context, alertTitle: loc?.alert ?? '', alertText: loc?.appleIdUnlinkedSuccessfully ?? '', withoutSecondButton: true);
                    //       case Result.failure:
                    //         hideLoadingDialog(context);
                    //         showAlert(context: context, alertTitle: loc?.alert ?? '', alertText: '${loc?.error} ${localizedFirebaseErrorMessage(unlinkResponse.error, context)}', withoutSecondButton: true);
                    //     }
                    //   }

                    } else {
                      logEvent('unlink apple account tapped. this is the only provider');
                    }


                  },
                  child: CustomListItem(primaryColor: false,
                      fontSize: fontSize(15, viewModel),
                      listItemString: appleAccountString(), children: [
                        if (!appleLinked)
                        const CustomNavigationIcon(),
                      ]),
                ),
              ]),

              const SizedBox(height: 32),

              CustomSection(sectionTitle: 'Google', bgOpacity: brightness == Brightness.dark ? 1.0 : 0.9,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (!googleLinked) {
                          logEvent('link google account tapped');

                          AlertPopData? alertData = await showAlert(context: context, alertTitle: loc?.alert ?? '', alertText: loc?.linkGoogleAccountAlert ?? '');

                          if (alertData == AlertPopData.firstButton) {
                            logEvent('link google confirm button tapped');

                            showLoadingDialog(context);

                            final linkGoogleAccountResponse = await firebaseServices.linkGoogleAccountToExistingAppleAccount();

                            switch (linkGoogleAccountResponse.result) {

                              case GoogleResult.success:
                                viewModel.setGoogleLinked(true);
                                if (linkGoogleAccountResponse.email != null) {
                                  viewModel.setGoogleEmail(linkGoogleAccountResponse.email ?? '');
                                }
                                hideLoadingDialog(context);
                                showAlert(context: context, alertTitle: loc?.alert ?? '', alertText: loc?.googleAccountLinkedSuccessfully ?? '', withoutSecondButton: true);

                              case GoogleResult.failure:
                                logEvent('erro ao vincular conta google');
                                hideLoadingDialog(context);
                                showAlert(context: context, alertTitle: loc?.alert ?? '', alertText: '${loc?.error} ${localizedFirebaseErrorMessage(linkGoogleAccountResponse.error, context)}', withoutSecondButton: true);
                            }

                          }

                        } else if (appleLinked && googleLinked) {
                          logEvent('unlink google account tapped. both providers are linked');

                          if (!Platform.isAndroid) {
                            AlertPopData? alertData = await showAlert(
                                context: context,
                                alertTitle: loc?.alert ?? '',
                                alertText: loc?.unlinkGoogleAccountAlert ?? '');

                            if (alertData == AlertPopData.firstButton) {
                              showLoadingDialog(context);
                              final unlinkResponse = await firebaseServices
                                  .unlinkGoogleAccount();

                              switch (unlinkResponse.result) {
                                case Result.success:
                                  viewModel.setGoogleLinked(false);

                                  hideLoadingDialog(context);
                                  showAlert(context: context,
                                      alertTitle: loc?.alert ?? '',
                                      alertText: loc
                                          ?.googleAccountUnlinkedSuccessfully ??
                                          '',
                                      withoutSecondButton: true);
                                case Result.failure:
                                  hideLoadingDialog(context);
                                  showAlert(context: context,
                                      alertTitle: loc?.alert ?? '',
                                      alertText: '${loc
                                          ?.error} ${localizedFirebaseErrorMessage(
                                          unlinkResponse.error, context)}',
                                      withoutSecondButton: true);
                              }
                            }
                          } else {
                            logEvent('platform is android, unlinking google not available');
                          }

                        } else {
                          logEvent('unlink google account tapped. this is the only provider');
                        }


                      },
                      child: CustomListItem(primaryColor: false,
                          fontSize: fontSize(15, viewModel),
                          listItemString: googleAccountString(), children: [
                            if (!googleLinked || appleLinked && googleLinked && !Platform.isAndroid)
                            const CustomNavigationIcon(),
                          ]),
                    ),
                  ]),

              const SizedBox(height: 45),

              GestureDetector(
                onTap: () {
                  logEvent('delete data button tapped');
                  setState(() {
                    deleteAccountButtonOpacity = 0.7;
                  });

                  showAlert(context: context, alertTitle: loc?.alert ?? '',
                      alertText: loc?.deleteAccountAlert ?? '').then((data) async {
                    if (data == AlertPopData.firstButton) {
                      logEvent('delete account confirmed by choosing first button');

                      showLoadingDialog(context);

                      final deleteResponse = await firebaseServices.deleteUserAndDiasSalvos();

                      switch (deleteResponse.result) {

                        case Result.success:
                          hideLoadingDialog(context);
                          logOutNeeded();
                        case Result.failure:
                          hideLoadingDialog(context);
                          showAlert(context: context, alertTitle: loc?.alert ?? '', alertText: '${loc?.error} ${localizedFirebaseErrorMessage(deleteResponse.error, context)}', withoutSecondButton: true);
                      }



                    }
                  });


                },
                onTapCancel: () {
                  setState(() {
                    deleteAccountButtonOpacity = 1.0;
                  });
                },
                onTapDown: (_) {
                  setState(() {
                    deleteAccountButtonOpacity = 0.8;
                  });
                },
                child: Opacity(
                  opacity: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: (brightness == Brightness.dark ? Theme.of(context).colorScheme.surface : Color.fromRGBO(121, 198, 205, 1.0)).withValues(alpha: deleteAccountButtonOpacity),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 6),
                        child:
                        Container(
                          padding: const EdgeInsets.only(bottom: 10, top: 10, right: 20, left: 20),
                          child: Text(loc?.deleteAccount ?? '', textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: brightness == Brightness.dark ? FontWeight.w600 : FontWeight.w500,
                                  color: (brightness == Brightness.dark) ? Color.fromRGBO(
                                      253, 124, 124, 1.0) : Color.fromRGBO(
                                      193, 77, 77, 1.0),
                                  fontSize: fontSize(15, viewModel))),
                        )
                    ),
                  )
                ),
              ),

            ],
          ),
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
              color: isSelected ? Colors.blue : Colors.grey,
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