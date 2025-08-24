import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:empatiatrack/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '0/0_customColors.dart';
import '0/1_loginView.dart';
import '0/0_viewModelGlobal.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Crashlytics and set up error handling
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  if(!kDebugMode) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
      webProvider: ReCaptchaV3Provider('6Lemcn0dAAAAABLkf6aiiHvpGD6x-zF3nOSDU2M8'),
    );
  } else {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
      webProvider: ReCaptchaV3Provider('6Lemcn0dAAAAABLkf6aiiHvpGD6x-zF3nOSDU2M8'),
    );
  }

  // Unlock Firestore data directory
  if (Platform.isIOS) {
    final fileProtectionManager = FileProtectionManager();
    await fileProtectionManager.unlockFirestoreData();
  }

  // Set initial UI overlay style
  setSystemUIOverlayStyle(PlatformDispatcher.instance.platformBrightness);

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(const MyApp());
}

void setSystemUIOverlayStyle(Brightness brightness) {
  Brightness androidBrightness = (brightness == Brightness.dark) ? Brightness.light : Brightness.dark;

  SystemUiOverlayStyle overlayStyle = (Platform.isIOS)
      ? SystemUiOverlayStyle(
    statusBarBrightness: brightness,
    statusBarIconBrightness: brightness,
  )
      : SystemUiOverlayStyle(
    statusBarBrightness: androidBrightness,
    statusBarIconBrightness: androidBrightness,
  );

  SystemChrome.setSystemUIOverlayStyle(overlayStyle.copyWith(
    statusBarColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
  ));
}

ValueNotifier<Brightness> brightnessNotifier = ValueNotifier<Brightness>(PlatformDispatcher.instance.platformBrightness);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    brightnessNotifier.value = PlatformDispatcher.instance.platformBrightness;
    setSystemUIOverlayStyle(brightnessNotifier.value);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModelGlobal(),
      child:  MaterialApp(
        builder: (context, child) {
        // Wrap the child of MaterialApp with MediaQuery to ensure textScaleFactor is 1.0
        return MediaQuery(
        data: MediaQuery.of(context)
        .copyWith(textScaler: const TextScaler.linear(1.0)),
    child: child!,
    );
    },
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [
          Locale('en', ''),
          Locale('pt', ''),
        ],
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const LoginView(),
      ),
    );
  }
}

class FileProtectionManager {
  static const platform = MethodChannel('com.jogoempatia.empatiatrack.fileProtection');

  Future<void> unlockFirestoreData() async {
    try {
      await platform.invokeMethod('unlockFirestoreData');
      print("Firestore data directory unlocked.");
    } on PlatformException catch (e) {
      print("Failed to unlock Firestore data: '${e.message}'.");
    }
  }
}