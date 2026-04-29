// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_app/core/configs/assets/app_vectors.dart';
import 'package:spotify_app/presentation/auth/bloc/auth_cubit.dart';
import 'package:spotify_app/presentation/auth/bloc/auth_state.dart';
import 'package:spotify_app/presentation/auth/pages/signup_or_signin.dart';
import 'package:spotify_app/presentation/dashboard/pages/dash_board.dart';
import 'package:spotify_app/presentation/intro/pages/get_started.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    redirect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: SvgPicture.asset(AppVectors.logo)));
  }

  // Future<void> redirect() async {
  //   await Future.delayed(const Duration(seconds: 2));

  //   // Thêm dòng này để kiểm tra "khe hở bất đồng bộ"
  //   if (!mounted) return;
  //   // Ứng dụng sẽ tạm dừng tại dòng đó trong 2 giây.
  //   // Trong 2 giây này, người dùng có thể đã nhấn nút Back hoặc chuyển sang màn hình khác
  //   //, khiến SplashPage bị hủy (dismiss).
  //   // Sau khi hết 2 giây, lệnh Navigator.pushReplacement được thực thi. Lúc này, nếu
  //   // bạn dùng context của một trang đã bị hủy, ứng dụng sẽ bị lỗi (crash) hoặc
  //   // gây ra hành vi không xác định.

  //   final authState = context.read<AuthCubit>().state;
  //   if (authState is Authenticated) {
  //     // Đã đăng nhập -> Vào Home luôn
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const DashBoardPage()),
  //     );
  //   } else {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const GetStartedPage()),
  //     );
  //   }
  // }

  Future<void> redirect() async {
    // 1. Chờ đợi để hiển thị Logo/Animation
    await Future.delayed(const Duration(seconds: 2));

    // 2. Kiểm tra mounted để tránh crash nếu user thoát app trong lúc delay
    if (!mounted) return;

    // 3. Lấy trạng thái hiện tại từ Cubit
    final authState = context.read<AuthCubit>().state;
    print('authState $authState');

    // 4. Kiểm tra thêm một lớp bảo mật: Firebase thực tế có đang đăng nhập không?
    // Điều này ngăn chặn trường hợp Hydrated nạp cache cũ nhưng Firebase đã hết hạn session.
    final firebaseUser = FirebaseAuth.instance.currentUser;

    // 5. Kiểm tra xem đây có phải lần đầu tiên mở app không
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    // 6. Điều hướng
    if (authState is Authenticated && firebaseUser != null) {
      // Chỉ vào DashBoard khi cả Cache và Firebase đều xác nhận có User
      // TH1: Đã đăng nhập -> Vào DashBoard
      _goToPage(const DashBoardPage());
    }else{
      if(isFirstTime){
        // TH2: Lần đầu tải và mở app -> Vào GetStarted
        _goToPage(const GetStartedPage());
      }else{
        // TH3: Đã từng mở app trước đó -> Vào SignupOrSignin
        _goToPage(const SignupOrSigninPage());
      }
    }
    
  }

  void _goToPage(Widget page) {
  Navigator.pushAndRemoveUntil(
    context, 
    MaterialPageRoute(builder: (context) => page), 
    (route) => false
  );
}
}
