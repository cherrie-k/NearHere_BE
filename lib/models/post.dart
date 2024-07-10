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

  // SQLite 처리용
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      address: json['address'],
      category: json['category'],
      image: json['image'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
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

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      title: map['title'],
      address: map['address'],
      category: map['category'],
      image: map['image'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}