class Post {
  String id;
  String title;
  String address;
  String category;
  String? image;
  String content;
  DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    required this.address,
    required this.category,
    this.image,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'category': category,
      'image': image,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}