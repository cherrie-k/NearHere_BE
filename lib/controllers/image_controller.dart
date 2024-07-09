import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

// 클래스 이미지 관련 라우트 관리
class ImageController {
  final Directory imageDir = Directory('images');

  ImageController();

  // 라우트 등록
  void registerRoutes(Alfred app) {
    app.get('/images/*', _serveImage);
    app.get('/list-images', _listImages);
    app.post('/upload', _uploadImage);
  }

  // 이미지 제공 메소드
  Future<void> _serveImage(HttpRequest req, HttpResponse res) async {
    final filePath = path.join('images', req.uri.pathSegments.last);
    final file = File(filePath);
    if (await file.exists()) {
      // 파일의 MIME 타입 설정하고
      final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream'; 
      res.headers.contentType = ContentType.parse(mimeType);
      // 파일 스트림을 응답으로 전송
      await res.addStream(file.openRead());
      await res.close();
    } else {
      res.statusCode = HttpStatus.notFound;
      await res.send('File not found'); // 404
    }
  }

  // 서버에 있는 이미지 목록 전체 제공
  Future<void> _listImages(HttpRequest req, HttpResponse res) async {
    if (!await imageDir.exists()) {
      return res.json([]);
    }

    final files = await imageDir.list().toList();
    final host = req.headers.host!.split(':').first;
    final port = req.headers.host!.split(':').length > 1
        ? req.headers.host!.split(':').last
        : '3000';

    final imageUrls = files.map((file) {
      final filename = path.basename(file.path);
      return 'http://$host:$port/images/$filename';
    }).toList();

    await res.json(imageUrls);
  }

  Future<void> _uploadImage(HttpRequest req, HttpResponse res) async {
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final contentType = req.headers.contentType?.mimeType;

    // 예외처리 코드

    // 컨텐츠 타입 multipart/form-data 인지 확인해줘야함
    if (contentType != 'multipart/form-data') {
      res.statusCode = HttpStatus.badRequest;
      await res.send('Invalid content type');
      return;
    }

    final boundary = req.headers.contentType?.parameters['boundary'];
    if (boundary == null) {
      res.statusCode = HttpStatus.badRequest;
      await res.send('Missing boundary');
      return;
    }

    final transformer = MimeMultipartTransformer(boundary);
    final parts = await transformer.bind(req).toList();

    for (var part in parts) {
      final contentDisposition = part.headers['content-disposition'];
      final name =
          RegExp(r'name="([^"]+)"').firstMatch(contentDisposition!)?.group(1);
      final filename = RegExp(r'filename="([^"]+)"')
          .firstMatch(contentDisposition)
          ?.group(1);

      if (name == 'file' && filename != null) {
        final filePath = path.join(imageDir.path, filename);
        final file = File(filePath);
        final sink = file.openWrite();
        await sink.addStream(part);  // 파일 스트림 씀
        await sink.close();

        final host = req.headers.host!.split(':').first;
        final port = req.headers.host!.split(':').length > 1
            ? req.headers.host!.split(':').last
            : '3000';

        // 업로드한 파일 URL 생성
        final fileUrl = 'http://$host:$port/images/$filename';
        await res.json({'url': fileUrl});
        return;
      }
    }

    res.statusCode = HttpStatus.badRequest;
    await res.send('No file found in request');
  }
}
