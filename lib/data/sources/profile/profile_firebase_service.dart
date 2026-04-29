// data/sources/user_firebase_service.dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ProfileFirebaseService {
  Future<String> uploadAndChangeAvatar(File imageFile);
  Future<void> updateUserInfo(Map<String, dynamic> data);
}

class ProfileFirebaseServiceImpl implements ProfileFirebaseService {
  @override
  Future<String> uploadAndChangeAvatar(File imageFile) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw 'User not logged in';

      // 1. Upload ảnh lên Firebase Storage
      // Tạo đường dẫn file: users/{userId}/avatar.jpg
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(userId)
          .child('avatar.jpg');

      // Thực hiện upload
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // 2. Lấy đường link download (URL)
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 3. Cập nhật field 'avatarUrl' trong Firestore
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'avatarUrl': downloadUrl,
      });

      return downloadUrl; // Trả về URL mới để UI cập nhật ngay
    } catch (e) {
      print('uploadAndChangeAvatar error ==> $e');
      throw e.toString();
    }
  }

  @override
  Future<void> updateUserInfo(Map<String, dynamic> data) async {
    try {
      final String userId = FirebaseAuth.instance.currentUser!.uid;
      // Cập nhật các trường có trong Map vào document của user
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update(data);
    } catch (e) {
      print('updateUserInfo error ==> $e');
      throw e.toString();
    }
  }
}
