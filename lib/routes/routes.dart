import 'package:alfred/alfred.dart';
import '../controllers/image_controller.dart';
import '../controllers/post_controller.dart';

void registerRoutes(Alfred app) {
  final imageController = ImageController();
  final postController = PostController();

  imageController.registerRoutes(app);
  postController.registerRoutes(app);

  app.get('/', (req, res) async {
    res.send('Server is running');
  });
}