import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:networld/src/src/core/network/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Track one-time initialization of GoogleSignIn as required by the 7.x API.
  bool _googleSignInInitialized = false;

  @override
  void initState() {
    _setupAuthListener();
    super.initState();
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
      }
    });
  }

  Future<AuthResponse> _googleSignIn() async {
    /// Web Client ID that you registered with Google Cloud.
    const webClientId = '940309657829-a4mb6orv23mi1v4sbjlsq34o5l5bjj9k.apps.googleusercontent.com';

    /// iOS Client ID that you registered with Google Cloud.
    const iosClientId = '940309657829-hh835gkesgu30oajfmqhn3sbi3k0v5ha.apps.googleusercontent.com';

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
      throw 'GoogleSignIn.authenticate() is not supported on this platform. '
          'For web, use Supabase signInWithOAuth instead.';
    }

    final googleUser = await googleSignIn.authenticate();
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw 'No ID Token found.';
    }

    return supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await _googleSignIn();
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Google sign-in failed: $e')),
              );
            }
          },
          child: const Text('Google login'),
        ),
      ),
    );
  }
}


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final profileImageUrl = user?.userMetadata?['avatar_url'];
    final fullName = user?.userMetadata?['full_name'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: () async {
              await supabase.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: const Text('Sign out'),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (profileImageUrl != null)
              ClipOval(
                child: Image.network(
                  profileImageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              fullName ?? '',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
