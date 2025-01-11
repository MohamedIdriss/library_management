import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/book.dart';
import '../models/author.dart';
import '../db/db_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class AddEditBookScreen extends StatefulWidget {
  final Book? book;

  const AddEditBookScreen({Key? key, this.book}) : super(key: key);

  @override
  _AddEditBookScreenState createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _isbnController = TextEditingController();
  DateTime? _dateSortie;
  int? _selectedAuthorId;
  File? _selectedImage;
  List<Author> _authors = [];
  bool _isImageUpdated = false;

  @override
  void initState() {
    super.initState();
    _fetchAuthors();

    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _isbnController.text = widget.book!.isbn;
      _dateSortie = widget.book!.dateSortie;
      _selectedAuthorId = widget.book!.writerId;
      if (widget.book!.photo != null && widget.book!.photo!.isNotEmpty) {
        _selectedImage = File(widget.book!.photo!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  Future<void> _fetchAuthors() async {
    final authors = await DBHelper.instance.getAuthors();
    setState(() {
      _authors = authors;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isImageUpdated = true;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateSortie ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateSortie) {
      setState(() {
        _dateSortie = picked;
      });
    }
  }

  void _saveBook() async {
    if (_formKey.currentState!.validate() && _selectedAuthorId != null && _dateSortie != null) {
      final book = Book(
        id: widget.book?.id,
        title: _titleController.text,
        isbn: _isbnController.text,
        dateSortie: _dateSortie!,
        photo: _selectedImage?.path ?? '',
        writerId: _selectedAuthorId!,
      );

      if (widget.book == null) {
        await DBHelper.instance.createBook(book);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Book added')));
      } else {
        await DBHelper.instance.updateBook(book);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Book updated')));
      }
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please complete all fields')));
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                      _isImageUpdated = false;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Delete Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Choose another Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.book == null ? 'Add Book' : 'Edit Book',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          onTap: _selectedImage == null ? _pickImage : _showImageOptions,
                          child: _selectedImage == null
                              ? Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 3,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.camera_alt,
                                size: 60,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                          )
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            prefixIcon: Icon(Icons.book, color: Colors.blueAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Title is required' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _isbnController,
                          decoration: InputDecoration(
                            labelText: 'ISBN',
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            prefixIcon: Icon(Icons.code, color: Colors.blueAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'ISBN is required' : null,
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: TextEditingController(
                                text: _dateSortie == null
                                    ? ''
                                    : _dateSortie!.toLocal().toString().split(' ')[0],
                              ),
                              decoration: InputDecoration(
                                labelText: 'Date of Release',
                                labelStyle: TextStyle(color: Colors.blueAccent),
                                prefixIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                              ),
                              validator: (value) => value!.isEmpty ? 'Date of release is required' : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<int>(
                          value: widget.book == null ? null : _selectedAuthorId,
                          decoration: InputDecoration(
                            labelText: 'Select Author',
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                          ),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedAuthorId = newValue;
                            });
                          },
                          items: _authors.map((author) {
                            return DropdownMenuItem<int>(
                              value: author.id,
                              child: Text('${author.firstName} ${author.lastName}'),
                            );
                          }).toList(),
                          validator: (value) => value == null ? 'Author is required' : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _saveBook,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.blueAccent,
                          ),
                          child: Text(
                            widget.book == null ? 'Add Book' : 'Update Book',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
