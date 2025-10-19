import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> initGoogleSignIn({
  String? clientId,        // iOS/web client ID if needed
  String? serverClientId,  // Web client ID if you need server auth codes
}) async {
  final signIn = GoogleSignIn.instance;
  await signIn.initialize(
    clientId: clientId,
    serverClientId: serverClientId,
  );
  // Optional: try silent/lightweight auth
  unawaited(signIn.attemptLightweightAuthentication());
}

Future<UserCredential?> signInWithGoogle() async {
  final signIn = GoogleSignIn.instance;

  // On mobile, this is supported and shows the Google UI:
  if (signIn.supportsAuthenticate()) {
    final GoogleSignInAccount account = await signIn.authenticate();

    // v7: only idToken lives under authentication
    final idToken = (await account.authentication).idToken;
    if (idToken == null) {
      throw StateError('Google idToken is null');
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return FirebaseAuth.instance.signInWithCredential(credential);
  } else {
    // (Web or other platform-specific fallback)
    // Render the GIS button on web, etc.
    throw UnsupportedError('authenticate() not supported on this platform');
  }
}