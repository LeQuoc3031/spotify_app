import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:spotify_app/common/helpers/format_duration.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/common/widgets/appbar/app_bar.dart';
import 'package:spotify_app/core/configs/constants/app_urls.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/domain/entities/song/song.dart';
import 'package:spotify_app/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:spotify_app/presentation/song_player/bloc/song_player_state.dart';

class LyricsView extends StatefulWidget {
  final SongEntity songEntity;
  const LyricsView({super.key, required this.songEntity});

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  double? dragValue;

  @override
  Widget build(BuildContext context) {
    // final topPadding = MediaQuery.of(context).viewPadding.top;
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      // padding: EdgeInsets.only(top: topPadding + 40),
      child: Stack(
        children: [
          BlocBuilder<SongPlayerCubit, SongPlayerState>(
            builder: (context, state) {
              if (state is SongPlayerLoaded) {
                return _buildBlurredBackground(
                  '${AppUrls.coverFirestorage}${state.songEntity?.artist} - ${state.songEntity?.title}.jpg?${AppUrls.mediaAlt}',
                  context,
                );
              }
              return _buildBlurredBackground(
                '${AppUrls.coverFirestorage}${widget.songEntity.artist} - ${widget.songEntity.title}.jpg?${AppUrls.mediaAlt}',
                context,
              );
            },
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: const BasicAppbar(title: Text('Lyrics')),
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BlocBuilder<SongPlayerCubit, SongPlayerState>(
                        buildWhen: (previous, current) {
                          if (previous is SongPlayerLoaded &&
                              current is SongPlayerLoaded) {
                            // Chỉ build lại khi câu lyric thay đổi
                            return previous.currentLyricIndex !=
                                current.currentLyricIndex;
                          }
                          return true;
                        },
                        builder: (context, state) {
                          if (state is SongPlayerLoading) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  color: Colors.blue,
                                ),
                              ),
                            );
                          }
                          if (state is SongPlayerLoaded) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: _lyricsView(
                                state,
                                context,
                              ), // Hàm vẽ danh sách lyric mình đã hướng dẫn ở trên
                            );
                          }
                          return Container();
                        },
                      ),

                      BlocBuilder<SongPlayerCubit, SongPlayerState>(
                        builder: (context, state) {
                          if (state is SongPlayerLoading) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: const Align(
                                alignment: Alignment.center,
                                child: SizedBox(height: 20, width: 20),
                              ),
                            );
                          }
                          if (state is SongPlayerLoaded) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.2,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                              ),
                              child: Column(
                                children: [
                                  Slider(
                                    padding: const EdgeInsets.all(0),
                                    value:
                                        dragValue ??
                                        context
                                            .read<SongPlayerCubit>()
                                            .songtPosition
                                            .inSeconds
                                            .toDouble(),
                                    min: 0.0,
                                    max: context
                                        .read<SongPlayerCubit>()
                                        .songDuration
                                        .inSeconds
                                        .toDouble(),
                                    onChanged: (value) {
                                      setState(() {
                                        dragValue =
                                            value; // Đang kéo thì giữ giá trị của tay người dùng
                                      });
                                    },
                                    onChangeEnd: (value) {
                                      context.read<SongPlayerCubit>().seek(
                                        Duration(seconds: value.toInt()),
                                      );
                                      setState(() {
                                        dragValue =
                                            null; // Buông tay thì trả lại quyền điều khiển cho Cubit
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatDuration(
                                          dragValue != null
                                              ? Duration(
                                                  seconds: dragValue!.toInt(),
                                                )
                                              : context
                                                    .read<SongPlayerCubit>()
                                                    .songtPosition,
                                        ),
                                      ),

                                      Text(
                                        formatDuration(
                                          context
                                              .read<SongPlayerCubit>()
                                              .songDuration,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.skip_previous,
                                          color: context.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        onPressed: () {
                                          context
                                              .read<SongPlayerCubit>()
                                              .previousSong();
                                        },
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          context
                                              .read<SongPlayerCubit>()
                                              .playOrPauseSong(
                                                widget.songEntity,
                                              );
                                          context
                                              .read<SongPlayerCubit>()
                                              .loadLyrics(
                                                '${AppUrls.lyricFirestorage}${widget.songEntity.artist} - ${widget.songEntity.title}.lrc.txt?${AppUrls.mediaAlt}',
                                                widget.songEntity,
                                              );
                                        },
                                        child: Container(
                                          height: 60,
                                          width: 60,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.primary,
                                          ),
                                          child: Icon(
                                            // context.read<SongPlayerCubit>().audioPlayer.playing
                                            state.isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.skip_next,
                                          color: context.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        onPressed: () => context
                                            .read<SongPlayerCubit>()
                                            .nextSong(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }
                          return Container();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lyricsView(SongPlayerLoaded state, BuildContext context) {
    // ItemScrollController dùng để điều khiển danh sách tự cuộn
    final ItemScrollController itemScrollController = ItemScrollController();
    final double containerHeight = MediaQuery.of(context).size.height * 0.6;
    const double itemHeight = 70.0;
    // Mỗi khi index thay đổi, ra lệnh cho danh sách cuộn đến dòng đó
    final int thresholdIndex = (containerHeight / 2 / itemHeight).floor();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.currentLyricIndex <= thresholdIndex) {
        // TRƯỜNG HỢP 1: Những câu đầu tiên
        // Giữ danh sách ở trên cùng (alignment: 0)
        itemScrollController.scrollTo(
          index: 0,
          alignment: 0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      } else {
        // TRƯỜNG HỢP 2: Đã hát qua nửa màn hình
        // Bắt đầu đưa câu đó vào giữa (alignment: 0.5)
        itemScrollController.scrollTo(
          index: state.currentLyricIndex,
          alignment: 0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
    // print('currentLyricIndex: ${state.currentLyricIndex}');
    return ScrollablePositionedList.builder(
      padding: EdgeInsets.only(bottom: containerHeight / 2),
      itemCount: state.lyrics.length,
      itemScrollController: itemScrollController,
      itemBuilder: (context, index) {
        if (index == -1) return const SizedBox.shrink();
        final isSelected = state.currentLyricIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Text(
            state.lyrics[index].text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? context.isDarkMode
                        ? Colors.white
                        : Colors.black
                  : context.isDarkMode
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.4),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlurredBackground(String? imageUrl, BuildContext context) {
    return Stack(
      children: [
        // Lớp 1: Ảnh gốc trải full
        imageUrl != null && imageUrl.isNotEmpty
            ? Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : Container(
                color: Colors.black,
              ), // Màu nền mặc định nếu không có ảnh
        // Lớp 2: BackdropFilter để làm mờ
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Độ mờ
            child: Container(
              color: context.isDarkMode
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.white.withValues(
                      alpha: 0.5,
                    ), // Lớp phủ tối để nổi bật text lyric
            ),
          ),
        ),
      ],
    );
  }
}
