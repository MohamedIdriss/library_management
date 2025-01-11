class Book {
  final int? id;
  final String title;
  final String isbn;
  final DateTime dateSortie;
  final String photo;
  final int writerId;
   bool favorite;

  Book({this.id, required this.title, required this.isbn, required this.dateSortie, required this.photo, required this.writerId, this.favorite = false,});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isbn': isbn,
      'dateSortie': dateSortie.toIso8601String(),
      'photo': photo,
      'writerId': writerId,
      'favorite': favorite ? 1 : 0
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      isbn: map['isbn'],
      dateSortie: DateTime.parse(map['dateSortie']),
      photo: map['photo'],
      writerId: map['writerId'],
      favorite: map['favorite'] == 1,
    );
  }
}
