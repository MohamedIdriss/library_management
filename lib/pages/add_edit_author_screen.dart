import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/author.dart';
import '../db/db_helper.dart';

class AddEditAuthorScreen extends StatefulWidget {
  final Author? author;

  const AddEditAuthorScreen({Key? key, this.author}) : super(key: key);

  @override
  _AddEditAuthorScreenState createState() => _AddEditAuthorScreenState();
}

class _AddEditAuthorScreenState extends State<AddEditAuthorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.author != null) {
      _firstNameController.text = widget.author!.firstName;
      _lastNameController.text = widget.author!.lastName;
      _phoneController.text = widget.author!.phone;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveAuthor() async {
    if (_formKey.currentState!.validate()) {
      final author = Author(
        id: widget.author?.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text,
      );

      if (widget.author == null) {
        await DBHelper.instance.createAuthor(author);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Author added successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.greenAccent,
          ),
        );
      } else {
        await DBHelper.instance.updateAuthor(author);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Author updated successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.blueAccent,
          ),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.author == null ? 'Add Author' : 'Edit Author',
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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Author Details' ,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
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
                          validator: (value) =>
                          value!.isEmpty ? 'First name is required' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            prefixIcon: Icon(Icons.person_outline, color: Colors.blueAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                          ),
                          validator: (value) =>
                          value!.isEmpty ? 'Last name is required' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            prefixIcon: Icon(Icons.phone, color: Colors.blueAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                          value!.isEmpty ? 'Phone number is required' : null,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveAuthor,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.blueAccent,
                          ),
                          child: Text(
                            widget.author == null ? 'Add Author' : 'Update Author',
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
