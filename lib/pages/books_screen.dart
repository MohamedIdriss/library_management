import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/book.dart';
import '../db/db_helper.dart';
import '../widgets/app_drawer.dart';
import 'add_edit_book_screen.dart';

class BooksScreen extends StatefulWidget {
  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  late Future<List<Book>> _books =
      Future.value([]);
  List<Book> _filteredBooks = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _searchController.addListener(_filterBooks);
  }

  Future<void> _fetchBooks() async {
    final books = await DBHelper.instance.fetchAllBooks();
    setState(() {
      _books = Future.value(books);
      _filteredBooks = books;
    });
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _fetchBooks();
    } else {
      _books.then((books) {
        setState(() {
          _filteredBooks = books
              .where((book) => book.title.toLowerCase().contains(query))
              .toList();
        });
      });
    }
  }

  void _deleteBook(int id) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Confirm Deletion'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this book? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirmDelete ?? false) {
      await DBHelper.instance.deleteBook(id);
      _fetchBooks();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Book deleted successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
  int _isfavorited = 0;

  void _toggleFavorite(int BookId) async {

    setState(() {
      if (_isfavorited == 0) {
        _isfavorited= 1;
      } else {
        _isfavorited = 0;
      }
    });
    print(_isfavorited);
    await DBHelper.instance.toggleFavorite(BookId, _isfavorited);
    await _fetchBooks();
    _filterBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(
          'Books Management',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search books',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: _books,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (_filteredBooks.isEmpty) {
                  return const Center(
                    child: Text('No books found.'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: _filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = _filteredBooks[index];
                      print("::::::::::::::::::::");
                      print(book.favorite);
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: SizedBox(
                            width:
                                50,
                            height:
                                70,
                            child: book.photo != null && book.photo!.isNotEmpty
                                ? Image.file(
                                    File(book
                                        .photo!),
                                    width: 50,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(Icons.book,
                                    size: 50,
                                    color: Colors.grey),
                          ),
                          title: Text(
                            book.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'ISBN: ${book.isbn}\nDate: ${DateFormat('yyyy-MM-dd').format(book.dateSortie)}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon : Icon(book.favorite ? Icons.favorite : Icons.favorite_border),
                                color: book.favorite ? Colors.yellow : Colors.grey,
                                onPressed: () => _toggleFavorite(book.id!),


                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () => _deleteBook(book.id!),
                              ),
                            ],
                          ),
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddEditBookScreen(book: book),
                              ),
                            ).then((value) => _fetchBooks())
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditBookScreen(),
            ),
          ).then((value) => _fetchBooks());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
