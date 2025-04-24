import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Image.asset(
                'assets/logo.png', // Replace with your logo asset
                height: 150,
                width: 150,
                fit: BoxFit.fill,
              ),
              // Employee ID Input Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Employee Name',
                  labelStyle: TextStyle(color: Colors.grey),
                  hintText: 'Enter your Name',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'Employee ID',
                  labelStyle: TextStyle(color: Colors.grey),
                  hintText: 'Enter your ID',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: 20),
              // Proceed Button
              ElevatedButton(
                onPressed: () {
                  if (_idController.text.isNotEmpty && _nameController.text.isNotEmpty) {
                    Navigator.pushNamed(context, '/face-verification');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter your Employee ${_nameController.text.isEmpty ? 'Name' : 'ID'}')),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  child: Text(
                    'Proceed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
