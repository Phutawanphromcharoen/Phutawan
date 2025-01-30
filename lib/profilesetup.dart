import 'package:finalprojectphutawan/auth.dart';
import 'package:finalprojectphutawan/home_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

//Method หลักทีRun
void main() {
  runApp(ProfileSetup());
}
//Class stateless สั่งแสดงผลหนาจอ
class ProfileSetup extends StatelessWidget {
    static const String routeName = '/profilesetup';
  const ProfileSetup({super.key});
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: ProfileSetup(),
    );
  }
}
//Class stateful เรียกใช้การทํางานแบบโต้ตอบ
class profilesetup extends StatefulWidget {
  @override
  State<profilesetup > createState() => _MyHomePageState();
}

class _MyHomePageState extends State<profilesetup> {
//ส่วนเขียน Code ภาษา dart เพื่อรับค่าจากหน้าจอมาคํานวณหรือมาทําบางอย่างและส่งค่ากลับไป
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final prefix = ['นาย', 'นาง', 'นางสาว'];
  String? _selectedPrefix;
  DateTime? birthdayDate;
//สร้างฟังก์ชันให้เลือกวันที่
  Future<void> pickProductionDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: birthdayDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != birthdayDate) {
      setState(() {
        birthdayDate = pickedDate;
        _birthDateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  String? _profileImageUrl;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _profileImage = pickedFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Future<void> _uploadProfile(String uid) async {
    try {
      String? downloadUrl;
      if (_profileImage != null) {
        final storageRef =
            FirebaseStorage.instance.ref().child('profilesphu/$uid.jpg');
        if (kIsWeb) {
          await storageRef.putData(await _profileImage!.readAsBytes());
        } else {
          await storageRef.putFile(File(_profileImage!.path));
        }
        downloadUrl = await storageRef.getDownloadURL();
      } else {
        downloadUrl = _profileImageUrl;
      }
      await _dbRef.child('usersชื่อนศ.ภาษาอังกฤษ/$uid').set({
        'prefix': _selectedPrefix ?? '', // ถ้า null ให้ใช้ค่าว่าง
        'firstName': _firstName.text.trim(), // ตัดช่องว่างด้านหน้าและหลัง
        'lastName': _lastName.text.trim(),
        'username': _username.text.trim(),
        'phoneNumber': _phoneNumber.text.trim(),
        'birthDate':
            birthdayDate?.toIso8601String() ?? '', // ถ้า null ให้ส่งค่าว่าง
        'profileImage': downloadUrl ?? '', // ถ้า null ให้ส่งค่าว่าง
        'profileComplete': true,
      });
      setState(() {
        _profileImageUrl = downloadUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading profile: $e')),
      );
    }
  }

  void _submitForm() async {
    final user = AuthService().currentUser;
    if (_formKey.currentState!.validate() && user != null) {
      _formKey.currentState!.save();
      await _uploadProfile(user.uid);
// ส่งข้อมูลกลับไปยังหน้า HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

//ส่วนการออกแบบหน้าจอ
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('………'),
      ),
      //ส่วนการออกแบบหน้าจอ
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      builder: (context) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: Icon(Icons.camera),
                              title: Text('ถ่ายรูป: Take a Photo'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text(
                                  'เลือกรูปจากแกลอรี่: Choose from Gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    child: FutureBuilder<Uint8List?>(
                      future: _profileImage != null
                          ? _profileImage!.readAsBytes()
                          : null,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: MemoryImage(snapshot.data!),
                          );
                        } else if (_profileImageUrl != null) {
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(_profileImageUrl!),
                          );
                        } else {
                          return CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.camera_alt, size: 50),
                          );
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedPrefix,
                  decoration:
                      InputDecoration(labelText: 'คํานําหน้าชื่อ (Prefix)'),
                  items: prefix
                      .map((category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPrefix = value!;
                    });
                  },
                ),
                TextFormField(
                  controller: _firstName,
                  decoration: InputDecoration(labelText: 'ชื่อ (First Name)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อ';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _lastName,
                  decoration: InputDecoration(labelText: 'นามสกุล (Last Name)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกนามสกุล';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _username,
                  decoration:
                      InputDecoration(labelText: 'ชื่อผู้ใช้ (Username)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อผู้ใช้';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneNumber,
                  decoration: InputDecoration(
                      labelText: 'เบอร์โทรศัพท์ (Phone Number)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกเบอร์โทร';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _birthDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'วันเกิด (BirthDay)',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => pickProductionDate(context),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาเลือกวันเกิด';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
// ดําเนินการเมื่อฟอร์มผ่านการตรวจสอบ
                        _submitForm();
                      }
                    },
                    child: Text('บันทึก'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
