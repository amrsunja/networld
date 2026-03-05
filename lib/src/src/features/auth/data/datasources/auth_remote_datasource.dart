import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/network/supabase.dart';
import 'package:networld/src/src/core/utils/env_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authRemoteDataProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthRemoteDatasource(),
);

class AuthRemoteDatasource {
  /// Track one-time initialization of GoogleSignIn as required by the 7.x API.
  static bool _googleSignInInitialized = false;

  Future<void> loginWithGoogle() async {
    /// Web Client ID that you registered with Google Cloud.
    final webClientId = EnvServices.googleAuthWebClientId;

    /// iOS Client ID that you registered with Google Cloud.
    final iosClientId = EnvServices.googleAuthIOSClientId;

    final googleSignIn = GoogleSignIn.instance;

    // As of google_sign_in 7.x, initialize must be called exactly once.
    if (!_googleSignInInitialized) {
      await googleSignIn.initialize(
        clientId: iosClientId,
        serverClientId: webClientId,
      );
      _googleSignInInitialized = true;
    }

    // On platforms that support it (Android/iOS/macOS), use authenticate().
    if (!googleSignIn.supportsAuthenticate()) {
      // For web and other unsupported platforms, fall back to Supabase OAuth.
      await supabase.auth.signInWithOAuth(OAuthProvider.google);
      return;
    }

    final googleUser = await googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('No ID Token found from Google Sign-In.');
    }

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  Future<void> loginWithApple() async {
    // Intentionally left unimplemented for now.
    // When adding Apple login, implement the appropriate flow here.
    throw UnimplementedError('Apple login is not implemented yet.');
  }

  Future<void> logout() async {
    await supabase.auth.signOut();

    // Best-effort sign out from Google; safe to call even if not signed in.
    await GoogleSignIn.instance.signOut();
  }

  Future<bool> isAuthenticated() async {
    // Supabase persists the session locally; if a session is present,
    // the user is considered authenticated.
    return supabase.auth.currentSession != null;
  }
}

