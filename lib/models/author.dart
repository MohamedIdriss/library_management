class Author {
  final int? id;
  final String firstName;
  final String lastName;
  final String phone;

  Author({this.id, required this.firstName, required this.lastName, required this.phone});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
    };
  }

  factory Author.fromMap(Map<String, dynamic> map) {
    return Author(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phone: map['phone'],
    );
  }
}
