/// @author yi1993
/// @created at 2022/5/26
/// @description:
const String tableRecord = 'tableRecord';

class RecordEntity {
  int? id;
  late String book;
  late int position;
  late double alignment;

  RecordEntity({
    this.id,
    required this.book,
    required this.position,
    required this.alignment,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'book': book,
      'position': position,
      'alignment': alignment,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  RecordEntity.fromMap(Map<dynamic, dynamic> map) {
    id = map['id'];
    book = map['book'];
    position = map['position'];
    alignment = map['alignment'];
  }

  @override
  String toString() {
    return 'RecordEntity{id: $id, book: $book, position: $position, alignment: $alignment}';
  }
}
