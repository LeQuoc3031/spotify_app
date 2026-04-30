// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify_app/common/widgets/appbar/app_bar.dart';
import 'package:spotify_app/common/widgets/button/basic_app_button.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/assets/app_vectors.dart';
import 'package:spotify_app/data/models/auth/create_user_req.dart';
import 'package:spotify_app/presentation/auth/bloc/auth_cubit.dart';
import 'package:spotify_app/presentation/auth/bloc/auth_state.dart';
import 'package:spotify_app/presentation/auth/pages/signin.dart';
import 'package:spotify_app/presentation/dashboard/pages/dash_board.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  String? fullnameError;
  String? emailError;
  String? passwordError;

  // Hàm kiểm tra định dạng email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Hàm kiểm tra định dạng password (6-20 ký tự, chữ, số, ký tự đặc biệt)
  bool _isValidPassword(String password) {
    return password.length >= 6 &&
        password.length <= 20 &&
        RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  void showLoadingProgress(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho phép nhấn ra ngoài để đóng
      builder: (context) => const LoadingScreen(),
    );
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        bottomNavigationBar: _signinText(context),
        appBar: BasicAppbar(
          title: SvgPicture.asset(AppVectors.logo, height: 40, width: 40),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
          child: BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is SignupLoading) {
                showLoadingProgress(context);
              }
              if (state is SignupSuccess) {
                
                Navigator.pop(context);
                
                context.read<AuthCubit>().updatedUser(state.userEntity);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashBoardPage(),
                  ),
                  (route) => false,
                );
              }
              if (state is SignupFailure) {
                setState(() {
                  Navigator.pop(context);
                  // Kiểm tra nội dung lỗi trả về từ Cubit để gán vào biến error tương ứng
                  if (state.errorMessage.contains("email")) {
                    emailError = state.errorMessage;
                    passwordError = null;
                  } else if (state.errorMessage.contains("password")) {
                    passwordError = state.errorMessage;
                    emailError = null;
                  } else {
                    // Các lỗi chung khác
                    emailError = null;
                    passwordError = null;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
                  }
                });
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _registerText(),
                const SizedBox(height: 50),
                _fullnameField(context),
                if (fullnameError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 15),
                    child: Text(
                      fullnameError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 20),
                _emailField(context),
                if (emailError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 15),
                    child: Text(
                      emailError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 20),
                _passwordField(context),
                if (passwordError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 15),
                    child: Text(
                      passwordError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 20),
                BasicAppButton(
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      fullnameError = null;
                      emailError = null;
                      passwordError = null;
                    });

                    // 1. Kiểm tra để trống
                    if (_fullnameController.text.isEmpty ||
                        _emailController.text.isEmpty ||
                        _passwordController.text.isEmpty) {
                    
                      setState(() {
                        fullnameError = "Full name không được để trống";
                        emailError = "Email không được để trống";
                        passwordError = "Mật khẩu không được để trống";
                      });
                      return;
                    }

                    // 2. Kiểm tra định dạng Email
                    if (!_isValidEmail(_emailController.text)) {
                      setState(() => emailError = "Email không đúng định dạng");
                      return;
                    }

                    // 3. Kiểm tra định dạng Password
                    if (!_isValidPassword(_passwordController.text)) {
                      setState(
                        () => passwordError =
                            "Mật khẩu 6-20 ký tự, gồm chữ, số và ký tự đặc biệt",
                      );
                      return;
                    }

                    // 4.gọi Cubit
                    context.read<AuthCubit>().signup(
                      CreateUserReq(
                        fullName: _fullnameController.text.toString(),
                        email: _emailController.text.toString(),
                        password: _passwordController.text.toString(),
                      ),
                    );
                    
                  },
                  title: 'Create Account',
                ),
                const SizedBox(height: 20),
                _divider(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Xử lý đăng ký Google
                      },
                      icon: SvgPicture.asset(
                        'assets/vectors/google_logo.svg',
                        width: 30,
                      ),
                    ),
                    const SizedBox(width: 40),
                    IconButton(
                      onPressed: () {
                        // Xử lý đăng ký Apple
                      },
                      icon: SvgPicture.asset(
                        'assets/vectors/apple_logo.svg',
                        width: 30,
                      ),
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

  Widget _registerText() {
    return const Center(
      child: Text(
        'Register',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      ),
    );
  }

  Widget _fullnameField(BuildContext context) {
    return TextField(
      controller: _fullnameController,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      decoration: const InputDecoration(
        hintText: 'Full Name',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _emailController,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      decoration: const InputDecoration(
        hintText: 'Enter Email',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
        ),
        hintText: 'Password',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _divider() {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 0.5, color: Colors.grey)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Or',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800], // Hoặc AppColors.grey của bạn
            ),
          ),
        ),
        const Expanded(child: Divider(thickness: 0.5, color: Colors.grey)),
      ],
    );
  }

  Widget _signinText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Do you have an account?',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SigninPage()),
              );
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
