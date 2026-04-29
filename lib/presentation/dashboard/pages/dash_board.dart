// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/core/configs/assets/app_vectors.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/presentation/artist/pages/artist_list_page.dart';
import 'package:spotify_app/presentation/home/pages/home.dart';
import 'package:spotify_app/presentation/search/pages/search_page.dart';
import 'package:spotify_app/presentation/profile/pages/profile.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
 
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(), // Thay bằng SearchPage() của bạn
    const ArtistListPage(), // Thay bằng LibraryPage()
    const ProfilePage(), // Thay bằng ProfilePage()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 80, // Tùy chỉnh độ cao tùy ý
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? Colors.black.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          border: const Border(
            top: BorderSide(color: Colors.white10, width: 0.5),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double totalWidth = constraints.maxWidth;
            double itemWidth = totalWidth / 4; // Chia cho 4 icon
            double indicatorWidth = 20; // Độ rộng thanh ngang

            return Stack(
              children: [
                // LỚP 1: Thanh ngang trượt (Nằm trên cùng)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  top: 0,
                  // Công thức tính vị trí left để thanh ngang luôn nằm giữa icon
                  left:
                      (_selectedIndex * itemWidth) +
                      (itemWidth - indicatorWidth) / 2,
                  child: Container(
                    width: indicatorWidth,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xff42C83C),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // LỚP 2: Các Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCustomItem(0, AppVectors.homeIcon, 'Home'),
                    _buildCustomItem(1, AppVectors.searchIcon, 'Search'),
                    _buildCustomItem(2, AppVectors.heartRounded, 'Favorites'),
                    _buildCustomItem(3, AppVectors.profileIcon, 'Profile'),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomItem(int index, String icon, String label) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(
                isSelected ? AppColors.primary : Colors.grey,
                BlendMode.srcIn, // Giữ màu sắc của SVG theo màu đã chọn
              ),
              height: 26,
              width: 26,
            ),
            const Spacer(flex: 2), // Đẩy icon lên vị trí đẹp hơn
          ],
        ),
      ),
    );
  }
}
