import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth_api_app/providers/token_providers.dart';
import 'package:auth_api_app/services/firebase_services_auth.dart';

/// Handles session state and automatic token refreshing
class SessionNotifier extends StateNotifier<Map<String, String?>> {
  final AuthTokensNotifier _authTokensNotifier;
  final Ref _ref;
  Timer? _refreshTimer;

  SessionNotifier(this._authTokensNotifier, this._ref) : super({});

  /// Initialize the session and schedule refresh if needed
  Future<void> initializeSession(String idToken, String refreshToken) async {
    state = {
      'idToken': idToken,
      'refreshToken': refreshToken,
    };
    
    await checkAndRefreshToken(idToken, refreshToken);
  }

  /// Checks if the token is near expiration and refreshes or schedules accordingly
  Future<void> checkAndRefreshToken(String? idToken, String? refreshToken) async {
    if (idToken == null || refreshToken == null) return;

    final parseTokenExpiry = _ref.read(tokenExpiryProvider);
    final idTokenExpiry = parseTokenExpiry(idToken);
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    const bufferTime = 600; // 10 minutes

    if (idTokenExpiry <= currentTime + bufferTime) {
      await refreshSession(refreshToken); // Refresh if token is about to expire
    } else {
      _scheduleTokenRefresh(idToken, refreshToken); // Schedule ahead of expiry
    }
  }

  /// Refreshes the session using the refresh token
  Future<void> refreshSession(String? refreshToken) async {
    if (refreshToken == null) return;

    try {
      final tokens = await AuthServices().refreshTokens(refreshToken);

      if (tokens != null) {
        // Update state and tokens
        final newIdToken = tokens['idToken']!;
        final newRefreshToken = tokens['refreshToken']!;

        state = {
          'idToken': newIdToken,
          'refreshToken': newRefreshToken,
        };

        await _authTokensNotifier.saveTokens(newIdToken, newRefreshToken);
        _scheduleTokenRefresh(newIdToken, newRefreshToken);
      }
    } catch (e) {
      throw Exception('Error al refrescar la sesión');
    }
  }

  /// Schedules a refresh 10 minutes before token expiry
  void _scheduleTokenRefresh(String idToken, String refreshToken) {
    _refreshTimer?.cancel();

    final parseTokenExpiry = _ref.read(tokenExpiryProvider);
    final idTokenExpiry = parseTokenExpiry(idToken);
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    const bufferTime = 600; // 10 minutes

    final timeUntilExpiry = idTokenExpiry - currentTime;

    if (timeUntilExpiry > bufferTime) {
      final refreshIn = Duration(seconds: timeUntilExpiry - bufferTime);
      _refreshTimer = Timer(refreshIn, () => refreshSession(refreshToken));
    }
  }

  /// Clears session and cancels timer on logout
  void logout() {
    _refreshTimer?.cancel();
    state = {};
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

/// Decodes JWT and returns the expiration timestamp (exp) in seconds
final tokenExpiryProvider = Provider<int Function(String)>((ref) {
  return (String idToken) {
    final parts = idToken.split('.');
    if (parts.length != 3) throw Exception("Token malformado");

    final payload = base64Url.normalize(parts[1]);
    final payloadMap = jsonDecode(utf8.decode(base64Url.decode(payload)));

    return payloadMap['exp'];
  };
});

/// Session provider that manages current tokens and schedules refresh
final sessionProvider = StateNotifierProvider<SessionNotifier, Map<String, String?>>((ref) {
  final authTokensNotifier = ref.read(authTokenProvider.notifier);
  return SessionNotifier(authTokensNotifier, ref);
});

/// Prints human-readable expiration date of a token (for debugging)
// void printTokenExpiry(int expiryTimestamp) {
//   final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp * 1000);
//   print("El idToken expirará en: $expiryDate");
// }
