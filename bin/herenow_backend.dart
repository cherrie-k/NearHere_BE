// import 'package:herenow_backend/herenow_backend.dart' as herenow_backend;

// void main(List<String> arguments) {
//   print('Hello world: ${herenow_backend.calculate()}!');
// }

import 'package:alfred/alfred.dart';
import 'package:herenow_backend/routes/routes.dart';
import 'package:herenow_backend/utils/database_helper.dart';

void main() async {
  try {
    final dbHelper = DatabaseHelper();
    await dbHelper.init();

    final app = Alfred();

    // 루트 등록
    registerRoutes(app);

    await app.listen(3000);
    print('Server running on port 3000');
  } catch (e, stacktrace) {
    print('Failed to start server: $e');
    print(stacktrace);
  }
}