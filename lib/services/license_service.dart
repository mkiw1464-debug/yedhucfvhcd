import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/license_model.dart';

class LicenseService {
  static const String _apiUrl =
      'https://ffexxxx.vercel.app/api/licenses/validate';
  static const String _keyPref = 'ff_license_key';
  static const String _hwidPref = 'ff_hwid';

  static Future<String?> getSavedKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPref);
  }

  static Future<void> saveKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPref, key);
  }

  static Future<void> clearKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPref);
  }

  static Future<LicenseResponse> validate({
    required String key,
    required String deviceId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'key': key, 'hwid': deviceId}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return LicenseResponse.fromJson(json);
      } else {
        return LicenseResponse(valid: false, status: 'invalid');
      }
    } catch (e) {
      throw Exception('network_error');
    }
  }

  /// Mask key: show first 4 and last 4 chars, rest as asterisks
  static String maskKey(String key) {
    if (key.length <= 8) return key.replaceAll(RegExp(r'.'), '*');
    final visible = 4;
    final start = key.substring(0, visible);
    final end = key.substring(key.length - visible);
    final masked = '•' * (key.length - visible * 2);
    return '$start$masked$end';
  }
}
