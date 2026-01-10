import 'package:league_music_player/services/apis/api_service.dart';

class MusicPlayerApi extends ApiService {
  late final String url = 'player';

  Future<Map<String, dynamic>?> next() async {
    return _extractResponse('next');
  }

  Future<Map<String, dynamic>?> previous() async {
    return _extractResponse('previous');
  }

  Future<Map<String, dynamic>?> _extractResponse(String endpoint) async {
    final response = await get('$url/$endpoint');
    if (isOk(response)) {
      final filename = _extractFilename(
        response!.headers['content-disposition'],
      );
      return {'filename': filename, 'bytes': response.bodyBytes};
    } else {
      return null;
    }
  }

  String? _extractFilename(String? header) {
    if (header == null) return null;
    final matchUtf8 = RegExp(
      r"filename\*=(?:UTF-8|utf-8)''(.+)",
    ).firstMatch(header);

    String? filename;

    if (matchUtf8 != null) {
      filename = Uri.decodeFull(matchUtf8.group(1)!);
    } else {
      final matchSimple = RegExp(r'filename="?([^";]+)"?').firstMatch(header);
      if (matchSimple != null) {
        filename = Uri.decodeFull(matchSimple.group(1)!);
      }
    }

    if (filename != null) {
      filename = filename.replaceAll(RegExp(r'\.[^.]+$'), '');
    }

    return filename;
  }
}
