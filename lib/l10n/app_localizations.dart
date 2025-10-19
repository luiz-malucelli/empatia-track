import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @empatiaAppName.
  ///
  /// In en, this message translates to:
  /// **'Empatia Track'**
  String get empatiaAppName;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'en'**
  String get appLanguage;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @alert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// No description provided for @noDaysFromFuture.
  ///
  /// In en, this message translates to:
  /// **'You cannot register days from the future.'**
  String get noDaysFromFuture;

  /// No description provided for @noMonthFromFuture.
  ///
  /// In en, this message translates to:
  /// **'You cannot select a future month.'**
  String get noMonthFromFuture;

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @deleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete data'**
  String get deleteData;

  /// No description provided for @deleteDataAlert.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the data from the device\'s memory?'**
  String get deleteDataAlert;

  /// No description provided for @registerMyDay.
  ///
  /// In en, this message translates to:
  /// **'Register my day'**
  String get registerMyDay;

  /// No description provided for @howWasYourDay.
  ///
  /// In en, this message translates to:
  /// **'How was your day?'**
  String get howWasYourDay;

  /// No description provided for @useUpToFivePoints.
  ///
  /// In en, this message translates to:
  /// **'Use up to 5 points'**
  String get useUpToFivePoints;

  /// No description provided for @hinTextNotes.
  ///
  /// In en, this message translates to:
  /// **'Write notes about your day\n(optional)\n'**
  String get hinTextNotes;

  /// No description provided for @saveMyDay.
  ///
  /// In en, this message translates to:
  /// **'Save my day'**
  String get saveMyDay;

  /// No description provided for @highlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get highlights;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @pointsUsed.
  ///
  /// In en, this message translates to:
  /// **'Points used per day through the'**
  String get pointsUsed;

  /// No description provided for @checkHighlight.
  ///
  /// In en, this message translates to:
  /// **'Check out this day'**
  String get checkHighlight;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @useTheBlueButtons.
  ///
  /// In en, this message translates to:
  /// **'Use the blue buttons'**
  String get useTheBlueButtons;

  /// No description provided for @toUseYourPoints.
  ///
  /// In en, this message translates to:
  /// **'to use your points.'**
  String get toUseYourPoints;

  /// No description provided for @joy.
  ///
  /// In en, this message translates to:
  /// **'Joy'**
  String get joy;

  /// No description provided for @peace.
  ///
  /// In en, this message translates to:
  /// **'Peace'**
  String get peace;

  /// No description provided for @anger.
  ///
  /// In en, this message translates to:
  /// **'Anger'**
  String get anger;

  /// No description provided for @worry.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get worry;

  /// No description provided for @sadness.
  ///
  /// In en, this message translates to:
  /// **'Sadness'**
  String get sadness;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// No description provided for @saveImagePhotos.
  ///
  /// In en, this message translates to:
  /// **'Save image'**
  String get saveImagePhotos;

  /// No description provided for @aboutTheDeveloper.
  ///
  /// In en, this message translates to:
  /// **'About the developer'**
  String get aboutTheDeveloper;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by:'**
  String get developedBy;

  /// No description provided for @quickInfo.
  ///
  /// In en, this message translates to:
  /// **'Quick info'**
  String get quickInfo;

  /// No description provided for @detailedInfo.
  ///
  /// In en, this message translates to:
  /// **'Detailed info'**
  String get detailedInfo;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact info'**
  String get contactInfo;

  /// No description provided for @empatiaQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is the goal of Empatia Produtos Psicopedagógicos?'**
  String get empatiaQuestion;

  /// No description provided for @empatiaShortAnswer.
  ///
  /// In en, this message translates to:
  /// **'Since 2018 our goal has been to provide a safe and engaging space for children and adults to learn and grow.'**
  String get empatiaShortAnswer;

  /// No description provided for @empatiaLongAnswer.
  ///
  /// In en, this message translates to:
  /// **'Empatia Produtos Psicopedagógicos is a brazilian company, and since its founding has been dedicated to providing a safe and engaging space for children and adults to learn and grow.\n\nOur journey began with the launch of Jogo Empatia, an innovative emotional intelligence card game designed to foster empathy and understanding. This initial product featured a single box with 3 different types of cards: feelings, what\'s important, and choices.\n\nIn 2020, we launched two new boxes, introducing 6 new types of cards: areas of life, thoughts, paths of self-discovery, body awareness, body parts, and bodily sensations.\n\nAll of the cards were designed to be modular, allowing users to mix and match cards to create unique and personalized learning experiences.\n\nIn 2024, we are excited to bring the essence of our physical products to the digital world with the launch of the Empatia app. This app version of our beloved card game continues our mission of fostering emotional intelligence and personal growth, providing a modern and accessible platform for users to explore and develop their skills.\n\nAnd after the launch of the Empatia app, in collaboration with mental health professionals, we developed the Empatia Track app to assist and support everyone seeking to understand their mental health.'**
  String get empatiaLongAnswer;

  /// No description provided for @faceBehindQuestion.
  ///
  /// In en, this message translates to:
  /// **'The face behind Empatia'**
  String get faceBehindQuestion;

  /// No description provided for @faceBehindShortAnswer.
  ///
  /// In en, this message translates to:
  /// **'Luiz Flávio Moreira Malucelli has been developing educational tools for over 8 years, focusing on creating a positive impact.\n\nThe Empatia Track app, entirely written by him and developed in collaboration with mental health professionals, aims to assist and support everyone seeking to understand their mental health.\n\nIf you are enjoying Empatia Track, make sure to also check Empatia app, available at App Store. Explore more than 300+ cards and create emotional maps to better understand yourself.'**
  String get faceBehindShortAnswer;

  /// No description provided for @faceBehindLongAnswer.
  ///
  /// In en, this message translates to:
  /// **'Luiz Flávio Moreira Malucelli is the founder and the driving force behind Empatia Produtos Psicopedagógicos.\n\nWith over 8 years of experience in developing educational tools, Luiz has been dedicated to creating meaningful and impactful learning experiences for children and adults alike.\n\nDriven by a passion for education and technology, Luiz embarked on the journey to create apps designed to foster growth and understanding.\n\nHis dedication and expertise are reflected in every aspect of the app, which he single-handedly developed.\n\nFor Luiz, Empatia is a mission to empower individuals to learn and thrive in a safe and nurturing environment.'**
  String get faceBehindLongAnswer;

  /// No description provided for @libraryDeniedSaveImageIOS.
  ///
  /// In en, this message translates to:
  /// **'Photo library access is required to save an image of your charts. \n\nPlease enable it in the Settings app under Settings > Empatia Track.'**
  String get libraryDeniedSaveImageIOS;

  /// No description provided for @libraryDeniedSaveImageAndroid.
  ///
  /// In en, this message translates to:
  /// **'Photo library access is required to save an image of your charts.\n\nPlease enable it in the devices Settings app under Settings > Apps > Empatia Track > Permissions.'**
  String get libraryDeniedSaveImageAndroid;

  /// No description provided for @welcomeToEmpatiaTrack.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nEmpatia Track'**
  String get welcomeToEmpatiaTrack;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @agreeToTermsAndPrivacy1_2.
  ///
  /// In en, this message translates to:
  /// **'By pressing continue, you agree to our'**
  String get agreeToTermsAndPrivacy1_2;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @agreeToTermsAndPrivacy2_2.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get agreeToTermsAndPrivacy2_2;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @signInWithAppleAndroidAlert.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple is only available on iOS devices. Please use an alternative sign-in method.'**
  String get signInWithAppleAndroidAlert;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get error;

  /// No description provided for @failedToAuthenticateGoogle.
  ///
  /// In en, this message translates to:
  /// **'Failed to authenticate with Google.'**
  String get failedToAuthenticateGoogle;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get myAccount;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountAlert.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get deleteAccountAlert;

  /// No description provided for @accountDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account deleted succesfully'**
  String get accountDeletedSuccessfully;

  /// No description provided for @appleIdLinked.
  ///
  /// In en, this message translates to:
  /// **'Apple ID linked'**
  String get appleIdLinked;

  /// No description provided for @linkAppleId.
  ///
  /// In en, this message translates to:
  /// **'Link Apple ID'**
  String get linkAppleId;

  /// No description provided for @googleAccountLinked.
  ///
  /// In en, this message translates to:
  /// **'Google account linked'**
  String get googleAccountLinked;

  /// No description provided for @linkGoogleAccount.
  ///
  /// In en, this message translates to:
  /// **'Link Google account'**
  String get linkGoogleAccount;

  /// No description provided for @linkAppleIdAlert.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to link your Apple ID?'**
  String get linkAppleIdAlert;

  /// No description provided for @unlinkAppleIdAlert.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unlink your Apple ID'**
  String get unlinkAppleIdAlert;

  /// No description provided for @linkGoogleAccountAlert.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to link your Google account?'**
  String get linkGoogleAccountAlert;

  /// No description provided for @unlinkGoogleAccountAlert.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unlink your Google account?'**
  String get unlinkGoogleAccountAlert;

  /// No description provided for @appleIdLinkedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Apple ID linked successfully'**
  String get appleIdLinkedSuccessfully;

  /// No description provided for @googleAccountLinkedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Google account linked successfully'**
  String get googleAccountLinkedSuccessfully;

  /// No description provided for @appleIdUnlinkedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Apple ID linked successfully'**
  String get appleIdUnlinkedSuccessfully;

  /// No description provided for @googleAccountUnlinkedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Google account linked successfully'**
  String get googleAccountUnlinkedSuccessfully;

  /// No description provided for @invalidCustomToken.
  ///
  /// In en, this message translates to:
  /// **'The custom token format is invalid. Please try again.'**
  String get invalidCustomToken;

  /// No description provided for @customTokenMismatch.
  ///
  /// In en, this message translates to:
  /// **'There\'s a mismatch in the custom token. Please check and try again.'**
  String get customTokenMismatch;

  /// No description provided for @invalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in credentials are no longer valid. Please sign in again.'**
  String get invalidCredential;

  /// No description provided for @operationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This sign-in method is not allowed.'**
  String get operationNotAllowed;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use. Please use a different email.'**
  String get emailAlreadyInUse;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is badly formatted. Please enter a valid email.'**
  String get invalidEmail;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get wrongPassword;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'You\'ve made too many requests in a short period. Please wait before trying again.'**
  String get tooManyRequests;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found with this information. Please check and try again.'**
  String get userNotFound;

  /// No description provided for @accountExistsWithDifferentCredential.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address.'**
  String get accountExistsWithDifferentCredential;

  /// No description provided for @requiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'This operation is sensitive and requires recent authentication. Please sign in again before retrying this request.'**
  String get requiresRecentLogin;

  /// No description provided for @providerAlreadyLinked.
  ///
  /// In en, this message translates to:
  /// **'This provider is already linked to your account.'**
  String get providerAlreadyLinked;

  /// No description provided for @noSuchProvider.
  ///
  /// In en, this message translates to:
  /// **'The specified provider is not linked to your account.'**
  String get noSuchProvider;

  /// No description provided for @invalidUserToken.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get invalidUserToken;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'A network error occurred. Check your internet connection and try again.'**
  String get networkError;

  /// No description provided for @userTokenExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session token has expired. Please sign in again.'**
  String get userTokenExpired;

  /// No description provided for @userMismatch.
  ///
  /// In en, this message translates to:
  /// **'The action you are trying to perform is not available to your account.'**
  String get userMismatch;

  /// No description provided for @credentialAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'These sign-in credentials are already associated with another user account.'**
  String get credentialAlreadyInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak. Please choose a stronger password.'**
  String get weakPassword;

  /// No description provided for @keychainError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred trying to access the keychain.'**
  String get keychainError;

  /// No description provided for @internalError.
  ///
  /// In en, this message translates to:
  /// **'An internal error occurred. Please try again later.'**
  String get internalError;

  /// No description provided for @defaultFirebaseError.
  ///
  /// In en, this message translates to:
  /// **'An unknown Firebase error occurred. Please try again.'**
  String get defaultFirebaseError;

  /// No description provided for @defaultError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get defaultError;

  /// No description provided for @phoneLinkedToOtherAccountError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error related to your linked phone number occurred. Please try again.'**
  String get phoneLinkedToOtherAccountError;

  /// No description provided for @verificationCodeIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Please make sure you\'ve entered the correct 6-digit verification code we sent via SMS. Check your message and try again.'**
  String get verificationCodeIncorrect;

  /// No description provided for @userDisabled.
  ///
  /// In en, this message translates to:
  /// **'Your account has been disabled. Please contact info+app@jogoempatia.com for support.'**
  String get userDisabled;

  /// No description provided for @invalidAPIKey.
  ///
  /// In en, this message translates to:
  /// **'An issue occurred with the app\'s API key. Please restart the app. If the problem persists, contact support at info+app@jogoempatia.com'**
  String get invalidAPIKey;

  /// No description provided for @appNotAuthorized.
  ///
  /// In en, this message translates to:
  /// **'This app is currently not authorized to use Firebase Authentication. Please restart the app. If the problem persists, contact support at info+app@jogoempatia.com'**
  String get appNotAuthorized;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
