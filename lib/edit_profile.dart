import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EditProfilePage(),
    );
  }
}
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController currentNicknameController = TextEditingController();
  final TextEditingController newNicknameController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  File? profileImage;
  String? profileImageUrl;

  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async{
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    if (userDoc.exists) {
      profileImageUrl = userDoc['profileImageUrl'];
      currentNicknameController.text = userDoc['nickname'] ?? '';
    }
    setState(() {});
  }

  Future<void> pickImage() async{
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      );
      if (croppedImage != null) {
        setState((){
          profileImage = File(croppedImage.path);
        });
      }
    }
  }

  Future<void> updateProfile() async {
    final userNewNickname = newNicknameController.text.trim();

    if (profileImage != null) {
      final storageRef = FirebaseStorage.instance.ref().child("profileImage/${user?.uid}.jpg");
      await storageRef.putFile(profileImage!);//저장
      profileImageUrl = await storageRef.getDownloadURL();//download url 가져오기
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'profileImageUrl':profileImageUrl,
      });
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'profileImageUrl':null,
      });
    }

    if (userNewNickname.isNotEmpty){
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'nickname':userNewNickname,
      });

      setState(() {
        currentNicknameController.text = userNewNickname;
        newNicknameController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.white,
        ),
        title: Text(
          '프로필 변경',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Stack(
              children: [
                profileImage != null
                    ? CircleAvatar(
                  radius: 75,
                  backgroundImage: FileImage(profileImage!),
                )
                    : (profileImageUrl != null && profileImageUrl!.isNotEmpty
                    ? CircleAvatar(
                  radius: 75,
                  backgroundImage: NetworkImage(profileImageUrl!),
                )
                    : Icon(
                  Icons.account_circle,
                  size: 150,
                  color: Colors.grey,
                )),

                Positioned(
                  bottom: -10,
                  right: -10,
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            children: [
                              SimpleDialogOption(
                                onPressed: () async {
                                  Navigator.pop(context); // Close the dialog
                                  await pickImage(); // Call the image picker function
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.photo_library),
                                    SizedBox(width: 10),
                                    Text('이미지 선택'),
                                  ],
                                ),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    profileImage = null;
                                    profileImageUrl = null;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.refresh),
                                    SizedBox(width: 10),
                                    Text('기본 이미지'),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 40),
            Row(
              children: [
                Text(
                  '현재 닉네임',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: currentNicknameController,
                    enabled: false,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                )
              ],
            ),

            SizedBox(height: 15),
            Row(
              children: [
                Text(
                  '   새 닉네임',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: newNicknameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: '한글 및 영어로 10자 이내',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      counterText: '',
                    ),
                    maxLength: 10,
                  ),
                )
              ],
            ),
            SizedBox(height: 100),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                minimumSize: Size(150, 50),
              ),
              onPressed: () {
                updateProfile();
                print("프로필이 변경되었습니다.");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('프로필이 변경되었습니다.')),
                );
              },
              child: Text(
                '변경',
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}