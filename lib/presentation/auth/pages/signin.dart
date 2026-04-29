// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify_app/common/widgets/appbar/app_bar.dart';
import 'package:spotify_app/common/widgets/button/basic_app_button.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/assets/app_vectors.dart';
import 'package:spotify_app/data/models/auth/signin_user_req.dart';
import 'package:spotify_app/domain/usecases/auth/signin_usecase.dart';
import 'package:spotify_app/presentation/auth/bloc/auth_cubit.dart';
import 'package:spotify_app/presentation/auth/pages/signup.dart';
import 'package:spotify_app/presentation/dashboard/pages/dash_board.dart';
import 'package:spotify_app/service_locator.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _signInText(),
              const SizedBox(height: 50),
              _emailField(context),
              const SizedBox(height: 20),
              _passwordField(context),
              const SizedBox(height: 20),
              BasicAppButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible:
                        false, // Quan trọng: Người dùng không thể nhấn ra ngoài để đóng
                    builder: (context) => const LoadingScreen(),
                  );

                  var result = await sl<SigninUseCase>().call(
                    params: SigninUserReq(
                      email: _emailController.text.toString(),
                      password: _passwordController.text.toString(),
                    ),
                  );

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }

                  result.fold(
                    (l) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    (r) {
                      context.read<AuthCubit>().updatedUser(r);
                      print('SIGNIN USER: $r');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashBoardPage(),
                        ),
                        (route) => false,
                      );
                      // print("===> ĐĂNG KÝ THÀNH CÔNG, ĐANG CHUYỂN TRANG...");
                    },
                  );
                },
                title: 'Sign In',
              ),
              const SizedBox(height: 21),
              _divider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInText() {
    return const Text(
      'Sign In',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
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
            'Not A Member?',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignupPage()),
              );
            },
            child: const Text('Register Now'),
          ),
        ],
      ),
    );
  }
}
