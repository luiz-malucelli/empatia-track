import 'package:empatiatrack/0/0_calendarView.dart';
import 'package:empatiatrack/0/0_viewModelGlobal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

enum AlertPopData {
  firstButton,
  secondButton,
  thirdButton,
  noAction
}

class CustomDivider extends StatelessWidget {
  final Color? color;

  const CustomDivider({
    super.key,
    this.color = Colors.grey, // Default color is grey if not specified
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: color?.withValues(alpha: 0.3), // Custom opacity can be adjusted here
    );
  }
}

Future<AlertPopData?> showAlert( {
  required BuildContext context,
  required String alertTitle,
  required String alertText,
  String? firstButtonText,
  String? secondButtonText,
  String? thirdButtonText,
  VoidCallback? firstButtonAction,
  VoidCallback? secondButtonAction,
  VoidCallback? thirdButtonAction,
  bool withoutSecondButton = false,
}) async {
  final localizations = AppLocalizations.of(context);
  final firstButtonText0 = firstButtonText ?? localizations!.yes;
  final secondButtonText0 = secondButtonText ?? localizations!.no;

  return showDialog<AlertPopData>(
    context: context,
    barrierDismissible: false, // User must tap button to close the dialog
    builder: (BuildContext context) {
      double screenWidth = MediaQuery.of(context).size.width;
      double dialogMaxWidth = 400.0; // Set your desired max width for the dialog
      double padding = screenWidth > dialogMaxWidth ? (screenWidth - dialogMaxWidth) / 2 : 0;

      final brightness = Theme.of(context).brightness;
      return  PopScope(
          canPop: false,
          child: Padding(padding: EdgeInsets.symmetric(horizontal: padding),
              child: AlertDialog(backgroundColor: (brightness == Brightness.dark) ? const Color.fromRGBO(40, 40, 40, 1) : Theme.of(context).colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                title: Text(alertTitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                    color: (brightness == Brightness.dark) ? Colors.white : const Color.fromRGBO(30, 30, 30, 1)),),
                content: (alertText.isNotEmpty) ?
                SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[

                      Text(alertText, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: (brightness == Brightness.dark) ? Colors.white : const Color.fromRGBO(30, 30, 30, 1)
                      ),),
                    ],
                  ),
                ) : null,
                contentPadding: EdgeInsets.fromLTRB(24.0, alertText.isNotEmpty ? 10.0 : 0, 24.0, alertText.isNotEmpty ? 24.0 : 0), // Adjust bottom padding based on alertText
                actions: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons horizontally
                    children: [
                      const CustomDivider(),
                      SizedBox(height: 40, child:
                      TextButton( style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        minimumSize: const Size(88, 20),
                      ),
                        child: Text(withoutSecondButton ? 'OK' : firstButtonText0, style: const TextStyle(fontSize: 15)),
                        onPressed: () {
                          if (firstButtonAction != null) {
                            firstButtonAction();
                          }
                          Navigator.of(context).pop(AlertPopData.firstButton);
                        },
                      ),
                      ),
                      if (!withoutSecondButton)
                        const CustomDivider(),
                      if (!withoutSecondButton)
                        SizedBox(height: 40, child:
                        TextButton(
                          child: Text(secondButtonText0, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          onPressed: () {
                            if (secondButtonAction != null) {
                              secondButtonAction();
                            }
                            Navigator.of(context).pop(AlertPopData.secondButton);
                          },
                        ),
                        ),
                      if (thirdButtonText != null)
                        const CustomDivider(),
                      if (thirdButtonText != null)
                        SizedBox(height: 40, child:
                        TextButton(
                          child: Text(thirdButtonText, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          onPressed: () {
                            if (thirdButtonAction != null) {
                              thirdButtonAction();
                            }
                            Navigator.of(context).pop(AlertPopData.thirdButton);
                          },
                        ),
                        ),
                    ],
                  ),
                ],
                actionsAlignment: MainAxisAlignment.center, // Center the column of buttons
                actionsPadding: const EdgeInsets.only(bottom: 16), // Adjust padding as needed
              )
          )
      );
    },
  );
}

enum DataShown {
  byWeek,
  byMonth,
  byYear
}

enum FontSize {
  small,
  medium,
  large
}

extension FontSizeExtension on FontSize {
  String localized(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (loc != null) {
      switch (this) {
        case FontSize.small:
          return loc.small;
        case FontSize.medium:
          return loc.medium;
        case FontSize.large:
          return loc.large; // Make sure you have a corresponding getter in your AppLocalizations
      }
    } else {
      return '';
    }
  }
}

double fontSize(double size, ViewModelGlobal viewModel) {
  switch (viewModel.fontSize) {

    case FontSize.small:
      return size;
    case FontSize.medium:
      return size + 2;
    case FontSize.large:
      return size + 4;
  }
}

double paddingSize(double size, ViewModelGlobal viewModel) {
  switch (viewModel.fontSize) {

    case FontSize.small:
      return size;
    case FontSize.medium:
      return size + 4;
    case FontSize.large:
      return size + 6;
  }
}

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent users from dismissing the dialog
    builder: (BuildContext context) {
      return  const PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent, // Make the dialog transparent
            elevation: 0,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          )
      );
    },
  );
}

void hideLoadingDialog(BuildContext context) {
  Navigator.of(context).pop();
}

Future<void> preloadImages(BuildContext context) async {
  // Retrieve image paths
  final String image1Path = getImageStringForIndex(0);
  final String image2Path = getImageStringForIndex(1);
  final String image3Path = getImageStringForIndex(2);
  final String image4Path = getImageStringForIndex(3);
  final String image5Path = getImageStringForIndex(4);


  // Preload images
  await Future.wait([
    precacheImage(AssetImage(image1Path), context),
    precacheImage(AssetImage(image2Path), context),
    precacheImage(AssetImage(image3Path), context),
    precacheImage(AssetImage(image4Path), context),
    precacheImage(AssetImage(image5Path), context),
  ]);

}

class VerticalSlideRoute extends PageRouteBuilder {
  final Widget page;
  VerticalSlideRoute({required this.page})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1), // Start from bottom
            end: Offset.zero, // End at center
          ).animate(animation),
          child: child,
        ),
  );
}

void logEvent(String message) {
  try {
    print(message); // This will log to the console
    FirebaseCrashlytics.instance.log(message); // This will log to Crashlytics
  } catch (e) {
    // Handle the logging error, e.g., print an error message to the console
    print("Error logging event: $e");
  }
}

enum AccountViewResult {
  logOutNeeded,
  noActionNeeded
}

enum SettingsViewResult {
  accountDeleted,
  noActionNeeded
}

String localizedFirebaseErrorMessage(Object? error, BuildContext context) {
  final AppLocalizations? loc = AppLocalizations.of(context);

// Handle FirebaseAuthException
  if (error is FirebaseAuthException && loc != null) {
    switch (error.code) {

    //signInWithEmailAndPassword
      case 'wrong-password':
        return loc.wrongPassword;
      case 'invalid-email':
        return loc.invalidEmail;
      case 'user-disabled':
        return loc.userDisabled;
      case 'user-not-found':
        return loc.userNotFound;

    //createUserWithEmailAndPassword
      case 'email-already-in-use':
        return loc.emailAlreadyInUse;
      case 'operation-not-allowed':
        return loc.operationNotAllowed;
      case 'weak-password':
        return loc.weakPassword;

    //signInWithCredential
      case 'account-exists-with-different-credential':
        return loc.accountExistsWithDifferentCredential;
      case 'invalid-credential':
        return loc.invalidCredential;
      case 'invalid-verification-code':
        return loc.verificationCodeIncorrect;
      case 'invalid-verification-id':
        return error.toString();

    //reauthenticateWithCredential
      case 'user-mismatch':
        return loc.userMismatch;
      case 'credential-too-old-login-again':
        return loc.invalidCredential;
      case 'too-many-requests':
        return loc.tooManyRequests;

      default:
        return error.toString();
    }
  }  // Handle FirebaseFirestoreException
  else if (error is FirebaseException && loc != null) {
    switch (error.code) {
      case 'aborted':
        return error.toString();
      case 'already-exists':
        return error.toString();
      case 'cancelled':
        return error.toString();
      case 'data-loss':
        return error.toString();
      case 'deadline-exceeded':
        return error.toString();
      case 'failed-precondition':
        return error.toString();
      case 'internal':
        return loc.internalError;
      case 'invalid-argument':
        return error.toString();
      case 'not-found':
        return error.toString();
      case 'ok':
        return error.toString();
      case 'out-of-range':
        return error.toString();
      case 'permission-denied':
        return error.toString();
      case 'resource-exhausted':
        return error.toString();
      case 'unauthenticated':
        return error.toString();
      case 'unavailable':
        return error.toString();
      case 'unimplemented':
        return error.toString();
      case 'unknown':
        return error.toString();

      default:
        return error.toString();
    }

  } else {
    return error.toString();
  }
}

