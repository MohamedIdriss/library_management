import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/book.dart';
import '../db/db_helper.dart';
import '../widgets/app_drawer.dart';

class FavoriteBooksScreen extends StatefulWidget {
  @override
  _FavoriteBooksScreenState createState() => _FavoriteBooksScreenState();
}

class _FavoriteBooksScreenState extends State<FavoriteBooksScreen> {
  late Future<List<Book>> _favoriteBooks = Future.value([]);
  List<Book> _filteredFavoriteBooks = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFavoriteBooks();
    _searchController.addListener(_filterFavoriteBooks);
  }

  Future<void> _fetchFavoriteBooks() async {
    final books = await DBHelper.instance.fetchFavoriteBooks();
    setState(() {
      _favoriteBooks = Future.value(books);
      _filteredFavoriteBooks = books;
    });
  }

  void _filterFavoriteBooks() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _fetchFavoriteBooks();
    } else {
      _favoriteBooks.then((books) {
        setState(() {
          _filteredFavoriteBooks = books
              .where((book) => book.title.toLowerCase().contains(query))
              .toList();
        });
      });
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
    await _fetchFavoriteBooks();
    _filterFavoriteBooks();
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
          'Favorite Books',
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
                hintText: 'Search favorite books',
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
              future: _favoriteBooks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (_filteredFavoriteBooks.isEmpty) {
                  return const Center(
                    child: Text('No favorite books found.'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: _filteredFavoriteBooks.length,
                    itemBuilder: (context, index) {
                      final book = _filteredFavoriteBooks[index];
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
                            width: 50,
                            height: 70,
                            child: book.photo != null && book.photo!.isNotEmpty
                                ? Image.file(
                              File(book.photo!),
                              width: 50,
                              height: 70,
                              fit: BoxFit.cover,
                            )
                                : Icon(Icons.book,
                                size: 50, color: Colors.grey),
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
                          trailing: IconButton(
                            icon: Icon(
                              Icons.favorite,
                              color: Colors.yellow,
                            ),
                            onPressed: () => _toggleFavorite(book.id!),
                          ),

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
    );
  }
}
