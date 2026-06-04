import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/result_model.dart';

class ApiService {
  // Ganti sesuai kondisi:
  // Emulator Android → http://10.0.2.2:8000
  // Linux desktop   → http://localhost:8000
  // Device fisik    → http://192.168.x.x:8000
  static const _base = 'http://localhost:8000';

  static Future<AnalysisResult> analyze(File image) async {
    final req = http.MultipartRequest('POST', Uri.parse('$_base/analyze'));
    req.files.add(await http.MultipartFile.fromPath('file', image.path));
    final res = await req.send().timeout(const Duration(seconds: 30));
    final body = await res.stream.bytesToString();
    if (res.statusCode != 200) {
      final err = jsonDecode(body)['detail'] ?? 'Server error';
      throw Exception(err);
    }
    return AnalysisResult.fromJson(jsonDecode(body));
  }
}
