import 'package:empatiatrack/0/0_tabMenu.dart';
import 'package:empatiatrack/0/0_utilityFunctions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '0_viewModelGlobal.dart';
import '1_firebaseServices.dart';
import '1_userData.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ViewModelGlobal>(context);
    var brightness = Theme.of(context).brightness;
    final AppLocalizations? loc = AppLocalizations.of(context);
    final FirebaseServices firebaseServices = FirebaseServices();

    const tabletBreakpoint = 600.0;
    const smallScreenBreakpoint = 380.0;

    // Device type checks
    bool isTablet = !kIsWeb && MediaQuery.of(context).size.width >= tabletBreakpoint;
    bool isSmallScreen = !kIsWeb && MediaQuery.of(context).size.width <= smallScreenBreakpoint;

    Future<void> login() async {
      final result = await firebaseServices.fetchUserData();

      if (result is UserData) {
        logEvent('result is UserData');
        viewModel.loadUserData(result);
      } else {
        logEvent('result IS NOT UserData');
      }

      viewModel.setSelectedIndex(0);

      hideLoadingDialog(context);

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => TabMenu(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child; // No animation, just return the child widget
          },
        ),
      ).then((result) {
        print('then block of code');
        viewModel.logOutDataReset();

        switch (result) {
          case SettingsViewResult.accountDeleted:
            showAlert(context: context, alertTitle: loc?.alert ?? '', alertText: loc?.accountDeletedSuccessfully ?? '', withoutSecondButton: true);
          case SettingsViewResult.noActionNeeded:
            break;
        }
      });
    }

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
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      bottomNavigationBar:
      Padding(
        padding: EdgeInsets.only(left: isSmallScreen ? 5 : 16.0, right: isSmallScreen ? 5 : 16.0, bottom: 35),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '${loc?.agreeToTermsAndPrivacy1_2}\n',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: isSmallScreen ? 15 : 16, height: 1.4),
            children: [
              TextSpan(
                text: loc?.termsOfUse ?? '',
                style: TextStyle(color: brightness == Brightness. dark ? Theme.of(context).colorScheme.primary : const Color.fromRGBO(5, 65, 149, 1.0), decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri.parse(termsOfUse()));
                  },
              ),
              TextSpan(
                text: ' ${loc?.agreeToTermsAndPrivacy2_2} ',
              ),
              TextSpan(
                text: loc?.privacyPolicy ?? '',
                style: TextStyle(color: brightness == Brightness. dark ? Theme.of(context).colorScheme.primary : const Color.fromRGBO(5, 65, 149, 1.0), decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri.parse(privacyPolicy()));
                  },
              ),
              const TextSpan(
                text: '',
              ),
            ],
          ),
        ),
      ),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [


              Expanded(child: SizedBox()),

              ActiveFirebaseUserCheck(automaticLogin: () async {
                bool isUserLoggedIn = await firebaseServices.isUserLoggedIn();
                print('inside automaticLogin');

                if (isUserLoggedIn) {
                  showLoadingDialog(context);
                  logEvent('user is logged in');
                  login();
                } else {
                  logEvent('no user logged in');
                }
              }),

              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 80,
                      child: Image.asset('assets/vectorEmojis/peace.png')),

                  SizedBox(width: 10),

                  Text(loc?.welcomeToEmpatiaTrack ?? '', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),


                  SizedBox(width: 17),
                ],
              ),

              SizedBox(height: 25),

              Container(width: 290, height: 50,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(5, 65, 149, 1.0),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: TextButton(onPressed: () async {
                  try {
                    showLoadingDialog(context);
                    final appleSignInResponse = await firebaseServices.signInWithApple();

                    switch (appleSignInResponse.result) {
                      case AppleSignInResult.success:
                        login();
                      case AppleSignInResult.android:
                        logEvent("Sign in with apple tapped on android");
                        hideLoadingDialog(context);
                        showAlert(context: context, alertTitle: loc?.alert ?? '', alertText: loc?.signInWithAppleAndroidAlert ?? '', withoutSecondButton: true);
                      case AppleSignInResult.failure:
                        logEvent("Sign in with apple error: ${appleSignInResponse.error}");
                        hideLoadingDialog(context);
                        showAlert(context: context, alertTitle: loc?.alert ?? '', alertText: '${loc?.error} ${localizedFirebaseErrorMessage(appleSignInResponse.error, context)}', withoutSecondButton: true);
                    }
                  } catch (e) {
                    logEvent("Unexpected error: $e");
                  }
                }, child:
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 8),
                    Transform.translate(offset: const Offset(0, -1),
                      child: SizedBox(width: 17,
                        child: SvgPicture.asset(
                          'assets/apple-icon.svg',
                          colorFilter: ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: SizedBox(),),
                    Text(loc?.continueWithApple ?? '', style:
                    TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w400)
                    ),
                    Expanded(child: SizedBox(),),
                  ],
                )
              ),
             ),

              SizedBox(height: 25),

              Container(width: 290, height: 50,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(5, 65, 149, 1.0),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: TextButton(onPressed: () async {
                  try {
                    showLoadingDialog(context);
                    final googleSignInResponse = await firebaseServices.signInWithGoogle(context);
                    switch (googleSignInResponse.result) {
                      case Result.success:
                        login();
                      case Result.failure:
                      if (googleSignInResponse.error == 'googleSignInCancelledByUser') {
                        hideLoadingDialog(context);
                        logEvent('Google sign in cancelled by user');
                      } else {
                        logEvent('Sign in with google error: ${googleSignInResponse.error}');
                        hideLoadingDialog(context);
                        AlertPopData? data = await showAlert(context: context, alertTitle: loc?.alert ?? '', alertText: '${loc?.error} ${localizedFirebaseErrorMessage(googleSignInResponse.error, context)}', withoutSecondButton: true);

                        if (data == AlertPopData.firstButton) {
                          if (googleSignInResponse.error.toString().contains('ID Token expired')) {
                            print('entered block for google sign out');

                            final GoogleSignIn googleSignIn = GoogleSignIn();

                            try {
                              // Sign out the user to clear any cached session
                              await googleSignIn.disconnect();
                              print('Google disconnect successful');
                            } catch (e) {
                              print('Google disconnect failed: $e');
                            }
                          }
                        }
                      }
                    }

                  } catch (e) {
                    // Handle unexpected exceptions
                    print('Unexpected error: $e');
                  }

                }, child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 8),
                    SizedBox(width: 20,
                      child: SvgPicture.asset(
                      'assets/google-icon.svg',
                      ),
                    ),
                    Expanded(child: SizedBox(),),
                    Text(loc?.continueWithGoogle ?? '', style:
                      TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w400)
                    ),
                    Expanded(child: SizedBox(),),
                  ],
                )
                ),
              ),
              Expanded(child: SizedBox()),


        ],
      )),
    );
  }
}


class ActiveFirebaseUserCheck extends StatefulWidget {
  final VoidCallback automaticLogin;

  const ActiveFirebaseUserCheck({super.key, required this.automaticLogin});

  @override
  ActiveFirebaseUserCheckState createState() => ActiveFirebaseUserCheckState();
}

class ActiveFirebaseUserCheckState extends State<ActiveFirebaseUserCheck> {

  @override
  void initState() {
    super.initState();
    logEvent('active firebase user check initialized');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logEvent('addPostFrameCallback called');
      checkExistingUserAndLogin();
    });
  }

  void checkExistingUserAndLogin()  {
    widget.automaticLogin();
  }


  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}