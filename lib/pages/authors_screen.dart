import 'package:flutter/material.dart';
import '../models/author.dart';
import '../db/db_helper.dart';
import '../widgets/app_drawer.dart';
import 'add_edit_author_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthorsScreen extends StatefulWidget {
  @override
  _AuthorsScreenState createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  late Future<List<Author>> _authors;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchAuthors();
  }

  void _fetchAuthors() {
    setState(() {
      _authors = _searchQuery.isEmpty
          ? DBHelper.instance.fetchAllAuthors()
          : DBHelper.instance.searchAuthors(_searchQuery);
    });
  }

  void _confirmDeleteAuthor(int id) async {
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
            'Are you sure you want to delete this author? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
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
      await DBHelper.instance.deleteAuthor(id);
      _fetchAuthors();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Author deleted successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _launchCaller(String number) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: number,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Authors Management'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search authors',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                _searchQuery = value;
                _fetchAuthors();
              },
            ),
          ),
          // Author List
          Expanded(
            child: FutureBuilder<List<Author>>(
              future: _authors,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No authors found.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                } else {
                  final authors = snapshot.data!;
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: authors.length,
                    itemBuilder: (context, index) {
                      final author = authors[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          leading: CircleAvatar(
                            radius: 30,
                            child: Text(
                              author.firstName[0],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Colors.blueAccent,
                          ),
                          title: Text(
                            '${author.firstName} ${author.lastName}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'Phone: ${author.phone}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Wrap(
                            spacing: -15,
                            children: [

                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _confirmDeleteAuthor(author.id!),
                              ),
                              IconButton(
                                icon: Icon(Icons.call,
                                    color: Colors.green), // Call icon
                                onPressed: () =>
                                    _launchCaller(author.phone), // Make a call
                              ),
                            ],
                          ),
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddEditAuthorScreen(author: author),
                              ),
                            ).then((value) => _fetchAuthors())
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
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditAuthorScreen()),
          ).then((value) => _fetchAuthors());
        },
        child: Icon(Icons.add),
        tooltip: 'Add Author',
      ),
    );
  }
}
