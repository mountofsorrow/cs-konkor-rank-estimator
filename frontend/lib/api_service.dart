import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your backend URL
  // For local development, use: http://10.0.2.2:8000 (Android emulator)
  // For local development, use: http://localhost:8000 (iOS simulator/web)
  // For physical device, use: http://YOUR_COMPUTER_IP:8000
  static const String baseUrl = 'http://localhost:8000';

  static Future<Map<String, dynamic>> predictRank({
    required int quota,
    required double effectiveGPA,
    required double mathematics,
    required double english,
    required double specialized1,
    required double specialized2,
    required double specialized3,
    required double specialized4,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/predict');
      final requestBody = {
        'Quota': quota,
        'EffectiveGPA': effectiveGPA,
        'Mathematics': mathematics,
        'English': english,
        'Specialized1': specialized1,
        'Specialized2': specialized2,
        'Specialized3': specialized3,
        'Specialized4': specialized4,
      };

      print('Making request to: $url');
      print('Request body: $requestBody');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout. Please check your connection.');
            },
          );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to get prediction: ${response.statusCode} - ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      print('ClientException: ${e.message}');
      throw Exception(
        'Connection failed. Make sure your backend is running at $baseUrl. Error: ${e.message}',
      );
    } on Exception catch (e) {
      print('Exception: $e');
      rethrow;
    } catch (e) {
      print('Unknown error: $e');
      throw Exception('Error: $e');
    }
  }
}
