import 'package:flutter/material.dart';

class FaceVerificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Face Verification")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.face, size: 100),
            SizedBox(height: 20),
            Text("Verifying face..."),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simulate face matched
                Navigator.pushReplacementNamed(context, '/clock');
              },
              child: Text("Simulate Face Match"),
            ),
          ],
        ),
      ),
    );
  }
}