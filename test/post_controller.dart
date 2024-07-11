import 'dart:io';
import 'package:alfred/alfred.dart';
import 'package:test/test.dart';
import 'package:herenow_backend/controllers/post_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  group(
    'PostController',
    () {
      final app = Alfred();
      final controller = PostController();
      controller.registerRoutes(app);

      // 분리된 곳에서 서버 돌림
      setUpAll(() async {
        await app.listen(0); // 0 은 동적으로 available한 포트 할당함
      });

      // 테스트 끄타녹 서버 내림
      tearDownAll(() async {
        await app.close();
      });

      test('GET /posts returns list of posts', () async {
        final response = await http.get(
          Uri.parse(
            'http://localhost:${app.server!.port}/posts',
          ),
        );
        expect(
          response.statusCode,
          200,
        );
        expect(
          jsonDecode(response.body),
          isA<List>(),
        );
      });

      test('GET /posts/:id returns 404 for non-existent post', () async {
        final response = await http.get(
          Uri.parse(
            'http://localhost:${app.server!.port}/posts/non_existent_post',
          ),
        );
        expect(
          response.statusCode,
          404,
        );
      });

      test(
        'POST /posts creates a new post',
        () async {
          final newPost = {
            'title': 'Test Post',
            'address': 'Test Address',
            'category': 'Test Category',
            'image': 'Test Image',
            'content': 'Test Content',
          };
          final response = await http.post(
            Uri.parse(
              'http://localhost:${app.server!.port}/posts',
            ),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(newPost),
          );
          expect(
            response.statusCode,
            200,
          );
          final responseBody = jsonDecode(response.body);
          expect(
            responseBody['title'],
            newPost['title'],
          );
        },
      );
    },
  );
}
