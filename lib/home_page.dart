import 'package:flutter/material.dart';
//น าเข้า auth.dart เพื่อเรียกเมธอดที่อยู่ auth.dart
import 'auth.dart';

class HomePage extends StatelessWidget {
  static const String routeName = '/homepage';
  final AuthService _auth = AuthService();
  HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomePage'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await _auth.signOut(
                  context); // ส่ง context ไปยังฟังก์ชัน signOutเพื่อเรียกใช้ signout
            },
            icon: Icon(Icons.person, color: Colors.white),
            label: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'You are logged in!',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
