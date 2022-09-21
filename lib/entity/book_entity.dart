/// @author yi1993
/// @created at 2022/5/9
/// @description:
class BookEntity {
  //数据爬虫来源
  int? original;

  //目录地址
  String? path;

  //书名
  String? name;

  //封面
  String? picUrl;

  //类型
  String? type;

  //简介
  String? description;

  //作者
  String? author;

  //状态  完结/连载
  String? status;

  //字数
  String? message;

  BookEntity({
    this.original,
    this.path,
    this.name,
    this.picUrl,
    this.type,
    this.description,
    this.author,
    this.status,
    this.message,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'original': original,
        'path': path,
        'name': name,
        'picUrl': picUrl,
        'type': type,
        'description': description,
        'author': author,
        'status': status,
        'message': message,
      };

  BookEntity.fromJson(dynamic json) {
    original = json['original'];
    path = json['path'];
    name = json['name'];
    picUrl = json['picUrl'];
    type = json['type'];
    description = json['description'];
    author = json['author'];
    status = json['status'];
    message = json['message'];
  }

  @override
  String toString() {
    return 'BookEntity{original: $original, path: $path, name: $name, picUrl: $picUrl, type: $type, description: $description, author: $author, status: $status, message: $message}';
  }
}
