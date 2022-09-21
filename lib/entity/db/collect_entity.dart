/// @author yi1993
/// @created at 2022/5/25
/// @description:
const String tableCollect = 'tableCollect';

class CollectEntity {
  int? id;
  late String book;
  late int date;
  late String data;
  late int sort;

  CollectEntity({
    this.id,
    required this.book,
    required this.date,
    required this.data,
    required this.sort,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'book': book,
      'date': date,
      'data': data,
      'sort': sort,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  CollectEntity.fromMap(Map<dynamic, dynamic> map) {
    id = map['id'];
    book = map['book'];
    date = map['date'];
    data = map['data'];
    sort = map['sort'];
  }

  @override
  String toString() {
    return 'CollectEntity{id: $id, book: $book, date: $date, data: $data, sort: $sort}';
  }
}
