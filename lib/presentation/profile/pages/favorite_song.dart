import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/common/widgets/favorite_button/favorite_button.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/constants/app_urls.dart';
import 'package:spotify_app/presentation/profile/bloc/favorite_song_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/favorite_song_state.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_state.dart';
import 'package:spotify_app/presentation/song_player/bloc/song_player_cubit.dart';
import 'dart:math';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/core/configs/assets/app_vectors.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';

class FavoriteSongPage extends StatefulWidget {
  const FavoriteSongPage({super.key});

  @override
  State<FavoriteSongPage> createState() => _FavoriteSongPageState();
}

class _FavoriteSongPageState extends State<FavoriteSongPage> {
  
  @override
  void initState() {
    context.read<FavoriteSongCubit>().getFavoriteSong();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FavoriteSongCubit()..getFavoriteSong(),
        ),
        BlocProvider(create: (context) => ProfileInfoCubit()..getUser()),
      ],
      child: Scaffold(
        backgroundColor: context.isDarkMode
            ? Colors.black
            : Colors.white, // Đặt nền đen sâu
        body: CustomScrollView(
          slivers: [
            // 1. SliverAppBar mới, chứa tất cả thông tin header
            SliverAppBar(
              expandedHeight: 450, // Chiều cao tối đa để chứa ảnh và nút
              backgroundColor: context.isDarkMode
                  ? Colors.black
                  : Colors.white, // AppBar trong suốt
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: context.isDarkMode ? Colors.white : Colors.black,
                ), // Nút back
                onPressed: () =>
                    Navigator.of(context).pop(), // Xử lý sự kiện back
              ),
              actions: [],
              // flexibleSpace là nơi Flutter tự động xử lý hiệu ứng "mờ dần"
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                // Đặt tất cả phần background được làm mờ vào đây
                background: _buildBlurredAlbumHeader(context),
                collapseMode: CollapseMode.parallax,
              ),
            ),

            // 2. PHẦN DANH SÁCH BÀI HÁT 
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: BlocBuilder<FavoriteSongCubit, FavoriteSongState>(
                builder: (context, state) {
                  if (state is FavoriteSongLoading) {
                    return const SliverToBoxAdapter(child: LoadingScreen());
                  }
                  if (state is FavoriteSongLoaded) {
                    return SliverList.separated(
                      // Hàm trả về Widget từng bài hát
                      itemBuilder: (context, index) =>
                          _songs(context, state, index),
                      itemCount: state.favoriteSongs.length,
                      separatorBuilder: (context, index) {
                        // Khoảng cách giữa các bài hát (không xuất hiện sau item cuối cùng)
                        return const SizedBox(height: 20);
                      },
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 300)),
          ],
        ),
      ),
    );
  }

  GestureDetector _songs(
    BuildContext context,
    FavoriteSongLoaded state,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<SongPlayerCubit>().loadSongs(
          state.favoriteSongs,
          index,
          'allSongFavorite',
        );
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const SongPlayerPage()),
        // ).then((value) {
        //   // print('state: $value');
        //   if (!context.mounted) return;
        //   context.read<AlbumCubit>().getAlbumSongs(widget.albumEntity.albumId!);
        // });

        Navigator.pushNamed(context, '/player').then((value) {
          // print('state: $value');
          if (!context.mounted) return;
          context.read<FavoriteSongCubit>().getFavoriteSong();
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(
                      '${AppUrls.coverFirestorage}${state.favoriteSongs[index].artist} - ${state.favoriteSongs[index].title}.jpg?${AppUrls.mediaAlt}',
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.favoriteSongs[index].title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    state.favoriteSongs[index].artist,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Row(
            children: [
              Text(
                state.favoriteSongs[index].duration.toString().replaceAll(
                  '.',
                  ':',
                ),
              ),
              const SizedBox(width: 20),
              FavoriteButton(
                key: Key(state.favoriteSongs[index].songId.toString()),
                songEntity: state.favoriteSongs[index],
                function: () {
                   context.read<FavoriteSongCubit>().removeSong(index);
                  
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredAlbumHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.isDarkMode ? Colors.grey : Colors.white,
                Colors.transparent,
              ],
            ),
          ),
        ),
        // 2. PHẦN NỘI DUNG HEADER NẰM TRÊN CÙNG
        Positioned(
          top: 80, // Cách AppBar một khoảng
          left: 20,
          right: 20,
          bottom: 20,
          child: Column(
            children: [
              // Ảnh album chính và bo góc
              BlocBuilder<FavoriteSongCubit, FavoriteSongState>(
                builder: (context, state) {
                  
                  if (state is FavoriteSongLoaded &&
                      state.favoriteSongs.isNotEmpty) {
                    final songEntity = state.favoriteSongs.first;
                    return Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            '${AppUrls.coverFirestorage}${songEntity.artist} - ${songEntity.title}.jpg?${AppUrls.mediaAlt}',
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.black45,
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                    );
                  }
                  return Container(
                    height: 200,
                    width: 200,
                    margin: const EdgeInsets.only(left: 15),
                    decoration: BoxDecoration(
                      color: AppColors.darkBackground,
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.red, Colors.pink[200]!],
                      ),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.black45,
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppVectors.heart,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                        height: 80,
                        width: 80,
                      ),
                    ),
                  );
                },
              ),

              // Tên nghệ sĩ và Album
              // HÀNG NÚT: Favorite, Comment, Shuffle
            ],
          ),
        ),
        Positioned(
          top: 300,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Playlist',
                  style: TextStyle(
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
                  builder: (context, state) {
                    if (state is ProfileInfoLoaded) {
                      return Text(
                        'Yêu Thích Của ${state.userEntity.fullName}',
                        style: TextStyle(
                          color: context.isDarkMode
                              ? Colors.white
                              : Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                    return Text(
                      'Yêu Thích',
                      style: TextStyle(
                        color: context.isDarkMode ? Colors.white : Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AppVectors.heart,
                          colorFilter: ColorFilter.mode(
                            context.isDarkMode ? Colors.white : Colors.black,
                            BlendMode.srcIn,
                          ),
                          height: 26,
                          width: 26,
                        ),
                        const SizedBox(width: 20),
                        SvgPicture.asset(
                          AppVectors.chatIcon,
                          colorFilter: ColorFilter.mode(
                            context.isDarkMode ? Colors.white : Colors.black,
                            BlendMode.srcIn,
                          ),
                          height: 26,
                          width: 26,
                        ),
                        const SizedBox(width: 20),
                        SvgPicture.asset(
                          AppVectors.shareIcon,
                          colorFilter: ColorFilter.mode(
                            context.isDarkMode ? Colors.white : Colors.black,
                            BlendMode.srcIn,
                          ),
                          height: 30,
                          width: 30,
                        ),
                      ],
                    ),

                    BlocBuilder<FavoriteSongCubit, FavoriteSongState>(
                      builder: (context, state) {
                        if (state is FavoriteSongLoaded) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  context.read<SongPlayerCubit>().loadSongs(
                                    state.favoriteSongs,
                                    Random().nextInt(
                                      state.favoriteSongs.length,
                                    ),
                                    // Random().nextInt(state.songs.length),
                                    'shuffleSongFavorite',
                                  );

                                  context.read<SongPlayerCubit>().shuffleSong();

                                  if (!context.mounted) return;
                                  Navigator.pushNamed(context, '/player').then((
                                    value,
                                  ) {
                                    // print('state: $value');
                                    if (!context.mounted) return;
                                    context
                                        .read<FavoriteSongCubit>()
                                        .getFavoriteSong();
                                  });
                                },
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    color: context.isDarkMode
                                        ? AppColors.darkGrey
                                        : AppColors.grey,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      AppVectors.shuffleIcon,
                                      colorFilter: ColorFilter.mode(
                                        context.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        BlendMode.srcIn,
                                      ),
                                      height: 20,
                                      width: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  context.read<SongPlayerCubit>().loadSongs(
                                    state.favoriteSongs,
                                    0,
                                    // Random().nextInt(state.songs.length),
                                    'allSongFavorite',
                                  );

                                  if (!context.mounted) return;
                                  Navigator.pushNamed(context, '/player').then((
                                    value,
                                  ) {
                                    // print('state: $value');
                                    if (!context.mounted) return;
                                    context
                                        .read<FavoriteSongCubit>()
                                        .getFavoriteSong();
                                  });
                                },
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 5),
                                      const Icon(Icons.play_arrow),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: Text(
                                          'Tất cả',
                                          style: TextStyle(
                                            color: context.isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                color: context.isDarkMode
                                    ? AppColors.darkGrey
                                    : AppColors.grey,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  AppVectors.shuffleIcon,
                                  colorFilter: ColorFilter.mode(
                                    context.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 5),
                                  const Icon(Icons.play_arrow),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      'Tất cả',
                                      style: TextStyle(
                                        color: context.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
