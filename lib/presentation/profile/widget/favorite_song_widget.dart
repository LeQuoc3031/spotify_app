import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/assets/app_vectors.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/presentation/profile/bloc/favorite_song_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/favorite_song_state.dart';

class FavoriteSongWidget extends StatelessWidget {
  const FavoriteSongWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      sliver: SliverToBoxAdapter(
        child: BlocBuilder<FavoriteSongCubit, FavoriteSongState>(
          builder: (context, state) {
            if (state is FavoriteSongLoading) {
              return const SizedBox(height: 80, child: LoadingScreen());
            }

            if (state is FavoriteSongLoaded) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/favorite',
                    arguments: state.favoriteSongs,
                  ).then((value) {
                    if (!context.mounted) return;
                    context.read<FavoriteSongCubit>().getFavoriteSong();
                  });
                },
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? AppColors.darkGrey
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 55,
                        width: 55,
                        margin: const EdgeInsets.only(left: 15),
                        decoration: BoxDecoration(
                          color: AppColors.darkBackground,
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.red, Colors.pink[200]!],
                          ),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AppVectors.heart,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Yêu Thích',
                            style: TextStyle(
                              color: context.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${state.favoriteSongs.length} bài hát',
                            style: TextStyle(
                              color: context.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/favorite');
              },
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? AppColors.darkGrey
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 55,
                      width: 55,
                      margin: const EdgeInsets.only(left: 15),
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground,
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.red, Colors.pink[200]!],
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppVectors.heart,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Yêu Thích',
                          style: TextStyle(
                            color: context.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '0 bài hát',
                          style: TextStyle(
                            color: context.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
