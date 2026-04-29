import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/common/widgets/favorite_button/favorite_button.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/domain/entities/song/song.dart';
import 'package:spotify_app/presentation/search/bloc/search_list_cubit.dart';
import 'package:spotify_app/presentation/search/bloc/search_cubit.dart';
import 'package:spotify_app/presentation/search/bloc/search_state.dart';
import 'package:spotify_app/presentation/song_player/bloc/song_player_cubit.dart';

class SearchSongList extends StatefulWidget {
  final List<SongEntity> songs;
  final bool isFetchingMore;
  final bool hasMore;
  const SearchSongList({
    super.key,
    required this.songs,
    required this.isFetchingMore,
    required this.hasMore,
  });

  @override
  State<SearchSongList> createState() => _SearchSongListState();
}

class _SearchSongListState extends State<SearchSongList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 2. Lắng nghe sự kiện cuộn
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // 1. Dùng >= thay vì == để chắc chắn bắt được sự kiện
    // 2. Kiểm tra thêm: danh sách phải có bài mới cho load more

    if (context.read<SearchSongCubit>().searchController.text.isNotEmpty) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (widget.songs.isNotEmpty) {
          context.read<SearchSongCubit>().getMoreSongs();
        }
      }
    } else {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (widget.songs.isNotEmpty) {
          context.read<SearchListCubit>().getMoreSongs();
        }
      }
    }
  }

  @override
  void dispose() {
    // 3. Quan trọng: Phải dispose controller để tránh rò rỉ bộ nhớ
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchSongCubit, SearchSongState>(
      builder: (context, state) {
        if (state is SearchSongLoading) {
          return const LoadingScreen();
        }
        if (state is SearchSongLoaded) {
          return Expanded(
            child: ListView.separated(
              controller: _scrollController, // 4. Gán controller vào ListView
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                if (index < state.songs.length) {
                  return _buildSongItem(
                    context,
                    state.songs,
                    index,
                    context.read<SearchSongCubit>().searchId,
                  );
                }
                return state.isFetchingMore
                    ? const LoadingScreen()
                    : const SizedBox.shrink();
              },
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemCount: state.hasMore
                  ? state.songs.length + 1
                  : state.songs.length,
            ),
          );
        }
        return Expanded(
          child: ListView.separated(
            controller: _scrollController, // 4. Gán controller vào ListView
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              if (index < widget.songs.length) {
                return _buildSongItem(context, widget.songs, index, '');
              }
              return widget.isFetchingMore
                  ? const LoadingScreen()
                  : const SizedBox.shrink();
            },
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemCount: widget.hasMore
                ? widget.songs.length + 1
                : widget.songs.length,
          ),
        );
      },
    );
  }

  GestureDetector _buildSongItem(
    BuildContext context,
    List<SongEntity> songs,
    int index,
    String idPlayList,
  ) {
    return GestureDetector(
      onTap: () {
        // Logic chuyển sang màn hình Player của bạn
        context.read<SongPlayerCubit>().loadSongs(songs, index, idPlayList);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const SongPlayerPage()),
        // ).then((value) {
        //   // print('state: $value');
        //   if (!context.mounted) return;
        //   context.read<FavoriteSongCubit>().getFavoriteSong();
        // });
        Navigator.pushNamed(context, '/player').then((value) {
          // print('state: $value');
          if (!context.mounted) return;
          context.read<SearchListCubit>().getPlayList();
        });
        
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Icon Play
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.isDarkMode
                      ? AppColors.darkGrey
                      : const Color(0xffE6E6E6),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: context.isDarkMode
                      ? const Color(0xff959595)
                      : const Color(0xff555555),
                ),
              ),
              const SizedBox(width: 10),
              // Thông tin bài hát
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    songs[index].titleVie,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    songs[index].artistVie,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Thời lượng bài hát và nút Tim
          Row(
            children: [
              Text(songs[index].duration.toString().replaceAll('.', ':')),
              const SizedBox(width: 20),
              FavoriteButton(songEntity: songs[index]),
            ],
          ),
        ],
      ),
    );
  }
}
