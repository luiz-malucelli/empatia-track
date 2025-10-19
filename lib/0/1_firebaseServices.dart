import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../l10n/app_localizations.dart';
import '0_diaSalvo.dart';
import '0_utilityFunctions.dart';
import '1_userData.dart';

class FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isUserLoggedIn() async {
    try {
      // Attempt to get the current user
      User? user = _auth.currentUser;

      // Return true if the user is not null, false otherwise
      return user != null;
    } catch (e) {
      // Log the error if any exception occurs
      print("Error checking user login status: $e");
      return false;
    }
  }



  void signOutUser(void Function(bool, dynamic) completion) {
    logEvent('signOutUser function triggered');
    try {
      _auth.signOut();
      completion(true, null);
    } catch (signOutError) {
      print("Error signing out: $signOutError");
      completion(false, signOutError);
    }
  }

  void signOutCurrentUser() {
    logEvent('signOutCurrentUser function triggered');
    try {
      // Check if a user is currently signed in
      if (_auth.currentUser != null) {
        print("User still logged in, proceeding to log out");
        _auth.signOut();
        print("User signed out successfully.");
      } else {
        print("No user is currently logged in.");
      }
    } catch (signOutError) {
      print("Error signing out: $signOutError");
    }
  }

  void saveDiaSalvoToFirebase(DiaSalvo diaSalvo) {
    logEvent('saveDiaSalvoToFirebase function triggered');

    try {
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        print("No user logged in");
        return;
      }

      String userID = currentUser.uid;
      var userRef = _firestore.collection('users').doc(userID);
      String diaSalvoString = diaSalvo.date.toString();
      var savedMindmapRef = userRef.collection('diasSalvos').doc(diaSalvoString);

      var diaSalvoJson = diaSalvo.toJson(); // Convert DiaSalvo instance to Map

      savedMindmapRef.set(diaSalvoJson).then((_) {
        print('DiaSalvo saved successfully');
      }).catchError((error) {
        print('Error saving DiaSalvo: $error');
      });
    } catch (e) {
      print('An unexpected error occurred: $e');
    }
  }

  Future<AppleSignInResponse> signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider();
      if (kIsWeb) {
        // Use signInWithPopup for Web platforms
        final userCredential = await FirebaseAuth.instance.signInWithPopup(appleProvider);
        return AppleSignInResponse.success(userCredential);
      } else if (!Platform.isIOS) {
        // Return an Android-specific response
        return AppleSignInResponse.android();
      } else {
        // Generate a nonce
        final rawNonce = _generateNonce();

        // Create a SHA-256 hash of the nonce
        final hashedNonce = _sha256Of(rawNonce);

        // Start the Apple sign-in request
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
          ],
          nonce: hashedNonce,
        );

        // Create OAuth credential for Firebase
        final oauthCredential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
        );

        // Sign in with Firebase
        final userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);

        // Extract email and full name if available
        final String? email = appleCredential.email;

        // Check if it's the user's first sign-in and if the email/full name are available
        if (email != null) {
          print('email isn\'t null');
          // Store the email in Firestore or your preferred database
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
            'appleEmail': email ?? 'Unknown',
          }, SetOptions(merge: true)); // Use merge to update only the appleEmail field
        }

        return AppleSignInResponse.success(userCredential);
      }
    } catch (e) {
      // Return a failure response in case of error
      return AppleSignInResponse.failure(e);
    }
  }

  String _generateNonce([int length = 32]) {
    final charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = List<int>.generate(length, (_) => charset.codeUnitAt(DateTime.now().microsecond % charset.length));
    return String.fromCharCodes(random);
  }


  String _sha256Of(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<AppleLinkResponse> linkAppleAccountToExistingGoogleAccount() async {
    try {
      final appleProvider = AppleAuthProvider();

      if (kIsWeb) {
        // Use signInWithPopup for Web platforms
        final userCredential = await FirebaseAuth.instance.signInWithPopup(appleProvider);
        return AppleLinkResponse.success(userCredential, '');
      } else if (!Platform.isIOS) {
        // Return a custom response for Android (since Apple sign-in is not used on Android)
        return AppleLinkResponse.android();
      } else {
        // Generate a nonce for Apple sign-in
        final rawNonce = _generateNonce();
        final hashedNonce = _sha256Of(rawNonce);

        // Start the Apple sign-in request
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
          ],
          nonce: hashedNonce,
        );

        // Create OAuth credential for Firebase (Apple)
        final oauthCredential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
        );

        // Get the currently signed-in user (already authenticated with Google)
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser == null) {
          return AppleLinkResponse.failure('No user is currently signed in.');
        }

        // Link the Apple credential to the current user's Google account
        final userCredential = await currentUser.linkWithCredential(oauthCredential);

        // Extract email and store it in Firestore
        final String? appleEmail = appleCredential.email;

        if (appleEmail != null) {
          // Store the email in Firestore or your preferred database
          await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
            'appleEmail': appleEmail,
          }, SetOptions(merge: true)); // Use merge to update only the appleEmail field
        }

        logEvent('Apple account successfully linked to existing Google account.');

        return AppleLinkResponse.success(userCredential, appleEmail);
      }
    } catch (e) {
      print('Error linking Apple account: $e');
      return AppleLinkResponse.failure(e);
    }
  }



  Future<FunctionResponse> signInWithGoogle(BuildContext context) async {
    final AppLocalizations? loc = AppLocalizations.of(context);
    try {
      // Trigger the authentication flow
      final gsi = GoogleSignIn.instance;

      // WEB: use Firebase popup—GoogleSignIn.authenticate() isn’t supported there.
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final cred = await FirebaseAuth.instance.signInWithPopup(provider);
        final email = cred.user?.email;
        final uid = cred.user?.uid;

        if (email != null && uid != null) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set(
            {'googleEmail': email},
            SetOptions(merge: true),
          );
        }
        return FunctionResponse.success();
      }

      // MOBILE / DESKTOP:
      if (!gsi.supportsAuthenticate()) {
        // Very old/unsupported platform fallback
        return FunctionResponse.failure(loc?.failedToAuthenticateGoogle ?? 'Google Sign-In not supported on this platform.');
      }

      // Show the Google account picker and authenticate.
      try {
        final account = await GoogleSignIn.instance.authenticate();
        final idToken = (await account.authentication).idToken;
        if (idToken == null) {
          return FunctionResponse.failure(loc?.failedToAuthenticateGoogle ?? 'Failed to obtain Google ID token.');
        }

        final credential = GoogleAuthProvider.credential(idToken: idToken);
        final userCred = await FirebaseAuth.instance.signInWithCredential(credential);

        // Persist email if you want
        final email = account.email; // or userCred.user?.email
        final uid = userCred.user?.uid;
        if (email != null && uid != null) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set(
            {'googleEmail': email},
            SetOptions(merge: true),
          );
        }
        // If everything goes well, return a success response
        return FunctionResponse.success();

      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          // user canceled
          return FunctionResponse.failure('googleSignInCancelledByUser');
        }
        return FunctionResponse.failure('googleSignInFailed: ${e.description}');
      }

    } catch (e) {
      // Handle any errors that occur during the sign-in process
      return FunctionResponse.failure(e);
    }
  }

  Future<GoogleResponse> linkGoogleAccountToExistingAppleAccount() async {
    try {
      // Obtain Google credentials
      OAuthCredential? googleCredential;
      String googleEmail = '';

      try {
        final googleSignInResult = await getGoogleCredentialAndEmail();
        if (googleSignInResult.email != null) {
          googleEmail = googleSignInResult.email ?? '';
        }
        googleCredential = googleSignInResult.credential;
      } catch (e) {
        return GoogleResponse.failure("Error obtaining Google credentials: $e");
      }

      if (googleCredential == null) {
        return GoogleResponse.failure("Failed to obtain Google credentials.");
      }

      // Get the currently signed-in user (initially signed in with Apple ID)
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return GoogleResponse.failure("No user is currently signed in.");
      }

      // Link the Google credential to the existing Apple ID account
      UserCredential userCredential = await currentUser.linkWithCredential(googleCredential);

      print("Google account successfully linked to existing Apple ID account.");

      if (googleEmail.isNotEmpty) {
        // Store the email in Firestore or your preferred database
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
          'googleEmail': googleEmail,
        }, SetOptions(merge: true)); // Use merge to update only the email field
        print("Google email stored in Firestore.");
      }

      return GoogleResponse.success(googleEmail);
    } catch (e) {
      print("Error linking Google account: $e");
      return GoogleResponse.failure(e);
    }
  }


  Future<GoogleSignInResult> getGoogleCredentialAndEmail() async {
    try {
      // WEB: use Firebase popup; GoogleSignIn.authenticate() isn’t supported there.
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final userCred = await FirebaseAuth.instance.signInWithPopup(provider);

        final email = userCred.user?.email;
        final authCred = userCred.credential;
        if (authCred is! OAuthCredential) {
          throw Exception('Failed to obtain OAuthCredential on web.');
        }
        return GoogleSignInResult(email: email, credential: authCred);
      }

      // MOBILE / DESKTOP:
      final gsi = GoogleSignIn.instance;
      if (!gsi.supportsAuthenticate()) {
        throw Exception('Google Sign-In not supported on this platform.');
      }

      // Shows the Google account picker and authenticates.
      try {
        final account = await GoogleSignIn.instance.authenticate();
        // v7: for Firebase, you only need the ID token.
        final idToken = (await account.authentication).idToken;
        if (idToken == null) {
          throw Exception('Failed to obtain Google ID token.');
        }

        final cred = GoogleAuthProvider.credential(idToken: idToken);
        return GoogleSignInResult(email: account.email, credential: cred);
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
         throw Exception("Google sign-in canceled.");
        }
        rethrow;
      }

    } catch (e) {
      throw Exception('Error signing in with Google: $e');
    }
  }

  Future<FunctionResponse> unlinkAppleAccount() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return FunctionResponse.failure("No user is currently signed in.");
      }


      // Unlink the Apple account from the current user
      await currentUser.unlink('apple.com');

      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
        'appleEmail': '',
      }, SetOptions(merge: true));

      print("Apple account successfully unlinked.");
      return FunctionResponse.success();
    } catch (e) {
      print("Error unlinking Apple account: $e");
      return FunctionResponse.failure(e);
    }
  }


  Future<FunctionResponse> unlinkGoogleAccount() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return FunctionResponse.failure("No user is currently signed in.");
      }

      // Unlink the Google account from the current user
      await currentUser.unlink('google.com');

      print("Google account successfully unlinked.");
      return FunctionResponse.success();
    } catch (e) {
      print("Error unlinking Google account: $e");
      return FunctionResponse.failure(e);
    }
  }

  Future<void> signOutAll() async {
    // Firebase
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      logEvent('Firebase signOut failed: ${e}');
    }

    // Google (only if supported on this platform)
    final gsi = GoogleSignIn.instance;
    if (gsi.supportsAuthenticate()) {
      try {
        await gsi.signOut();
      } on GoogleSignInException catch (e) {
        logEvent('Google signOut failed: ${e.code} ${e.description}');
      } catch (e) {
        logEvent('Google signOut failed: ${e}');
      }
    }
  }





  Future<UserData?> fetchUserData() async {
    logEvent('fetchUserData function triggered');

    try {
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        print("No user logged in");
        return null;
      }

      String userID = currentUser.uid;
      var userRef = _firestore.collection('users').doc(userID);

      var document = await userRef.get();

      if (!document.exists) {
        print('Document does not exist');
        return null;
      }

      var data = document.data();
      if (data == null) return null; // Document data is null

      // Start populating fetchedUserData with document data
      var fetchedUserData = UserData();

      // Check linked providers (Google, Apple ID)
      List<UserInfo> providerData = currentUser.providerData;
      bool hasGoogle = false;
      bool hasApple = false;

      for (UserInfo provider in providerData) {
        if (provider.providerId == 'google.com') {
          hasGoogle = true;
        } else if (provider.providerId == 'apple.com') {
          hasApple = true;
        }
      }

      fetchedUserData.googleLinked = hasGoogle;
      fetchedUserData.appleLinked = hasApple;

      fetchedUserData.appleEmail = data['appleEmail'] as String?;
      if (fetchedUserData.appleEmail == null) {
        print('Error: appleEmail field is missing or not a string');
      } else {
        print('fetchedUserData.appleEmail is ${fetchedUserData.appleEmail}');
      }

      fetchedUserData.googleEmail = data['googleEmail'] as String?;
      if (fetchedUserData.googleEmail == null) {
        print('Error: googleEmail field is missing or not a string');
      } else {
        print('fetchedUserData.googleEmail is ${fetchedUserData.googleEmail}');
      }

      List<DiaSalvo> diasSalvos = [];
      var diasSalvossRef = userRef.collection('diasSalvos');

      try {
        var querySnapshot = await diasSalvossRef.get();
        for (var document in querySnapshot.docs) {
          var diaSalvo = DiaSalvo.fromJson(document.data());
          diasSalvos.add(diaSalvo);
        }
        fetchedUserData.diasSalvos = diasSalvos;
      } catch (error) {
        print('Error fetching diasSalvos: $error');
      }


      return fetchedUserData;
    } catch (e) {
      print('not returning fetcheduserdata because ERROR');
      print('Error fetching user data: $e');
      return null;
    }
  }


  Future<FunctionResponse> deleteUserAndDiasSalvos() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        print("No user logged in");
        return FunctionResponse.failure("No user logged in");
      }

      String userID = currentUser.uid;
      FirebaseFirestore db = _firestore;

      // Reference to the user's document
      DocumentReference userRef = db.collection('users').doc(userID);

      // Reference to the 'diasSalvos' subcollection under the user's document
      CollectionReference diasSalvosRef = userRef.collection('diasSalvos');

      // First, delete all documents within the 'diasSalvos' subcollection
      QuerySnapshot diasSalvosSnapshot = await diasSalvosRef.get();

      for (QueryDocumentSnapshot doc in diasSalvosSnapshot.docs) {
        await doc.reference.delete();
      }

      // After all documents in 'diasSalvos' are deleted, delete the user's document
      await userRef.delete();

      // Delete the Firebase Auth user account
      await currentUser.delete();

      print("User and all related diasSalvos documents deleted successfully.");
      return FunctionResponse.success(); // Return success
    } catch (e) {
      print("Error deleting user and diasSalvos documents: $e");
      return FunctionResponse.failure(e); // Return failure with error
    }
  }






}


enum Result {
  success,
  failure,
}

class FunctionResponse {
  final Result result;
  final Object? error;


  FunctionResponse.success() : result = Result.success, error = null;
  FunctionResponse.failure(this.error) : result = Result.failure;
}

enum GoogleResult {
  success,
  failure,
}

class GoogleResponse {
  final GoogleResult result;
  final String? email;
  final Object? error;


  GoogleResponse.success(this.email) : result = GoogleResult.success, error = null;
  GoogleResponse.failure(this.error) : result = GoogleResult.failure, email = null;
}

enum AppleSignInResult {
  success,
  android,
  failure,
}

class AppleSignInResponse {
  final AppleSignInResult result;
  final Object? error;
  final UserCredential? userCredential;

  // Success Constructor
  AppleSignInResponse.success(this.userCredential)
      : result = AppleSignInResult.success,
        error = null;

  // Android Constructor
  AppleSignInResponse.android()
      : result = AppleSignInResult.android,
        error = null,
        userCredential = null;

  // Failure Constructor
  AppleSignInResponse.failure(this.error)
      : result = AppleSignInResult.failure,
        userCredential = null;
}

enum AppleLinkResult {
  success,
  android,
  failure,
}

class AppleLinkResponse {
  final AppleLinkResult result;
  final Object? error;
  final UserCredential? userCredential;
  final String? email;

  // Success Constructor
  AppleLinkResponse.success(this.userCredential, this.email)
      : result = AppleLinkResult.success,
        error = null;

  // Android Constructor
  AppleLinkResponse.android()
      : result = AppleLinkResult.android,
        error = null,
        userCredential = null,
        email = null;

  // Failure Constructor
  AppleLinkResponse.failure(this.error)
      : result = AppleLinkResult.failure,
        userCredential = null,
        email = null;
}


class GoogleSignInResult {
  final String? email;
  final OAuthCredential credential;

  GoogleSignInResult({required this.email, required this.credential});
}