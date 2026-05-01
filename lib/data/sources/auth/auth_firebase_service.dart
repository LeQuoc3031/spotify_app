// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify_app/core/configs/constants/app_urls.dart';
import 'package:spotify_app/data/models/auth/create_user_req.dart';
import 'package:spotify_app/data/models/auth/signin_user_req.dart';
import 'package:spotify_app/data/models/auth/user.dart';

abstract class AuthFirebaseService {
  Future<Either> signIn(SigninUserReq signinUserReq);
  Future<Either> signUp(CreateUserReq createUserReq);
  Future<Either> getUser();
}

class AuthFirebaseServiceImpl implements AuthFirebaseService {
  @override
  Future<Either> signIn(SigninUserReq signinUserReq) async {
    try {
      // 1. Đăng nhập với Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: signinUserReq.email,
            password: signinUserReq.password,
          );
      print("===> ĐĂNG NHẬP THÀNH CÔNG");

      // 2. Lấy dữ liệu chi tiết từ Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        // 3. Chuyển đổi dữ liệu từ Firestore sang UserModel
        final userModel = UserModel.fromJson(userDoc.data()!);
        return Right(userModel);
      } else {
        return const Left('Không tìm thấy thông tin người dùng');
      }
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'invalid-email') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for that user.';
      }

      print(e);

      return Left(message);
    }
  }

  @override
  Future<Either> signUp(CreateUserReq createUserReq) async {
    try {
      final data = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: createUserReq.email,
        password: createUserReq.password,
      );
      FirebaseFirestore.instance.collection('Users').doc(data.user?.uid).set({
        'userId': data.user?.uid,
        'fullName': createUserReq.fullName,
        'email': data.user?.email,
        'avatarUrl': AppUrls.defaultImage,
        'biography': '',
        'birthday': '',
        'gender': '',
        'phone': '',
      });

      print("===> ĐĂNG KÝ THÀNH CÔNG");
      final userModel = UserModel(
        userId: data.user?.uid,
        fullName: createUserReq.fullName,
        email: data.user?.email,
        avatarUrl: AppUrls.defaultImage,
      );

      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      }
      print(e);

      return Left(message);
    }
  }

  @override
  Future<Either> getUser() async {
    try {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      final user = await firebaseFirestore
          .collection('Users')
          .doc(firebaseAuth.currentUser?.uid)
          .get();

      UserModel userModel = UserModel.fromJson(user.data()!)
      ;

      return Right(userModel);
    } catch (e) {
      print('getUser error: $e');
      return const Left('An error occurred!');
    }
  }
}
