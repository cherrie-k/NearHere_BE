import 'package:alfred/alfred.dart';
import 'package:test/test.dart';
import 'package:herenow_backend/controllers/image_controller.dart';
import 'package:http/http.dart' as http;

// % dart test 로 돌린다!
void main() {
  group(
    'ImageController',
    () {
      final app = Alfred();
      final controller = ImageController();
      controller.registerRoutes(app);

      // 분리된 곳에서 서버 돌림
      setUpAll(
        () async {
          await app.listen(0); // 0 은 동적으로 available한 포트 할당함
        },
      );

      // 테스트 끝난 후 서버 내림
      tearDownAll(
        () async {
          await app.close();
        },
      );

      test(
        'GET /images/* 이미지 없으면 returns 404',
        () async {
          final response = await http.get(
            Uri.parse(
              'http://localhost:${app.server!.port}/images/non_existent_image.jpg',
            ),
          );
          expect(
            response.statusCode,
            404,
          );
        },
      );

      test(
        'POST /upload multipart/form-data content 아니면 returns 400',
        () async {
          final response = await http.post(
            Uri.parse(
              'http://localhost:${app.server!.port}/upload',
            ),
            headers: {
              'Content-Type': 'text/plain',
            },
            body: 'This is not a file',
          );
          expect(
            response.statusCode,
            400,
          );
        },
      );
    },
  );
}
