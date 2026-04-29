import 'package:flutter/material.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';

class StatusPage extends StatelessWidget {
  final bool isSuccess;
  final String? message; // Nhận thông báo lỗi tại đây

  const StatusPage({super.key, required this.isSuccess, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1C1B1B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon đỏ hoặc xanh
            Icon(
              isSuccess ? Icons.check_circle : Icons.error_outline,
              size: 100,
              color: isSuccess ? const Color(0xff42C83C) : Colors.red,
            ),
            const SizedBox(height: 25),
            Text(
              isSuccess ? "Đổi mật khẩu thành công!" : "Đổi mật khẩu thất bại",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            // Hiển thị nội dung lỗi cụ thể
            if (!isSuccess)
              Text(
                message ?? "Đã có lỗi xảy ra vui lòng thử lại",
                style: const TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                // onPressed: () async {
                //   FocusManager.instance.primaryFocus?.unfocus();

                //   Navigator.pop(context);
                // },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(isSuccess ? "Hoàn thành" : "Thử lại"),
              ),
              // BasicAppButton(
              //   title: isSuccess ? "Hoàn thành" : "Thử lại",
              //   onPressed: () => Navigator.pop(context),
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
