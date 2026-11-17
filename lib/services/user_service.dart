import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';

class UserPhotoException implements Exception {
  const UserPhotoException(this.message);
  final String message;

  @override
  String toString() => message;
}

class UserService {
  UserService({http.Client? client, this.timeout = const Duration(seconds: 60)})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;

  Uri _photoUrl(int idUsuario) =>
      Uri.parse('${ApiConfig.baseUrl}/usuarios/$idUsuario/foto');

  Future<String> uploadFotoUsuario({
    required int idUsuario,
    required List<int> bytes,
    required String nomeArquivo,
    String? mimeType,
  }) async {
    if (bytes.isEmpty) {
      throw const UserPhotoException('A imagem selecionada está vazia.');
    }

    final request = http.MultipartRequest('POST', _photoUrl(idUsuario));
    request.files.add(http.MultipartFile.fromBytes(
      'foto',
      bytes,
      filename: nomeArquivo,
      contentType: _contentType(nomeArquivo, mimeType),
    ));

    final response = await _withConnectionErrors(() async {
      final streamedResponse = await _client.send(request);
      return http.Response.fromStream(streamedResponse);
    });
    _checkStatus(response, 'enviar');

    final data = _readJson(response);
    final photoUrl = data?['photoUrl'];
    final uri = photoUrl is String ? Uri.tryParse(photoUrl.trim()) : null;
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw const UserPhotoException('O servidor não retornou uma URL válida para a foto.');
    }
    return photoUrl.toString().trim();
  }

Future<void> removerFotoUsuario(int idUsuario) async {
    final response = await _withConnectionErrors(
      () => _client.delete(_photoUrl(idUsuario)),
    );
    _checkStatus(response, 'remover');
  }

  Future<http.Response> _withConnectionErrors(
    Future<http.Response> Function() operation,
  ) async {
    try {
      return await operation().timeout(timeout);
    } on TimeoutException {
      throw const UserPhotoException('O servidor demorou para responder. Tente novamente.');
    } on http.ClientException {
      throw const UserPhotoException('Não foi possível conectar ao servidor. Verifique sua conexão.');
    }
  }

  Map<String, dynamic>? _readJson(http.Response response) {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data is Map<String, dynamic> ? data : null;
    } on FormatException {
      return null;
    }
  }

  void _checkStatus(http.Response response, String action) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    final data = _readJson(response);
    for (final key in ['erro', 'mensagem', 'error']) {
      final message = data?[key];
      if (message is String && message.trim().isNotEmpty) {
        throw UserPhotoException(message.trim());
      }
    }
    throw UserPhotoException(
      'Não foi possível $action a foto (HTTP ${response.statusCode}).',
    );
  }

  MediaType _contentType(String filename, String? mimeType) {
    if (mimeType != null) {
      try {
        final type = MediaType.parse(mimeType);
        if (type.type == 'image' && type.subtype != '*') return type;
      } on FormatException {
        // Alguns seletores não informam o MIME; usar a extensão nesse caso.
      }
    }
    final extension = filename.split('.').last.toLowerCase();
    final subtype = switch (extension) {
      'jpg' || 'jpeg' => 'jpeg',
      'png' => 'png',
      'webp' => 'webp',
      'gif' => 'gif',
      'heic' => 'heic',
      'heif' => 'heif',
      'bmp' => 'bmp',
      _ => null,
    };
    if (subtype == null) {
      throw const UserPhotoException('Não foi possível reconhecer o formato da imagem.');
    }
    return MediaType('image', subtype);
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}