import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//เรียกใช้หน้า auth.dart
import 'auth.dart';

class LoginPage extends StatefulWidget {
//สร้างตัวแปร routeName เพื่อก าหนดชื่อเส้นทาง (Route) ส าหรับการน าทาง (Navigation) ไปยังหน้าต่าง ๆ ในแอป ตัวอย่างเช่น:
// '/login' เป็ นชื่อเส้นทางที่เชื่อมโยงกับหน้า Login (หน้าล็อกอิน)
  static const String routeName = '/login';
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //สร้าง _formKey เก็บค่าการป้ อนผ่านฟอร์ม
  final _formKey = GlobalKey<FormState>();
//สร้างตัวแปรที่เป็ นตัวแทนของ AuthService เพื่อให้สามารถเรียกใช้งานเมธอดต่าง ๆ ในคลาส AuthService ได้ที่อยู่ที่หน้า auth.dart ได้
  final AuthService _auth = AuthService();
  //กา หนดค่าเริ่มตน้ของ อีเมล์และรหัสผ่าน
  String _email = '';
  String _password = '';
  bool _isLoading = false; // เพิ่ม state ส าหรับ Loading
// แสดง Loading Indicator
  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login / Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _email = value.trim();
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _password = value.trim();
                  },
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const CircularProgressIndicator() // แสดง Loading Indicator
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _setLoading(true);
                            try {
                              //เรียกใช้ฟัง์กชัน signInWithEmailAndpassword ที่หน้า auth.dart
                              await _auth.signInWithEmailAndPassword(
                                  _email, _password, context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Login failed: $e'),
                                ),
                              );
                            } finally {
                              _setLoading(false);
                            }
                          }
                        },
                        child: const Text('Sign In'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _setLoading(true);
                            try {
                              //เรียกใช้ฟัง์กชัน registerWithEmailAndPassword ที่หน้า auth.dart
                              await _auth.registerWithEmailAndPassword(
                                  _email, _password, context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Sign up failed: $e'),
                                ),
                              );
                            } finally {
                              _setLoading(false);
                            }
                          }
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
