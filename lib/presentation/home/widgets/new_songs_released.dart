import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/common/helpers/format_date.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/common/widgets/favorite_button/favorite_button.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/constants/app_urls.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/presentation/home/bloc/new_songs_released_cubit.dart';
import 'package:spotify_app/presentation/home/bloc/new_songs_released_state.dart';

class NewSongsReleased extends StatefulWidget {
  const NewSongsReleased({super.key});

  @override
  State<NewSongsReleased> createState() => _NewSongsReleasedState();
}

class _NewSongsReleasedState extends State<NewSongsReleased> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<NewSongsReleasedCubit>()..getNewSongsReleased(),
      child: BlocBuilder<NewSongsReleasedCubit, NewSongsReleasedState>(
        bloc: context.read<NewSongsReleasedCubit>(),
        builder: (context, state) {
          if (state is NewSongsReleasedLoading) {
            return const LoadingScreen();
          }
          if (state is NewSongsReleasedLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "New Songs Released",
                  style: TextStyle(
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 142,
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? AppColors.darkGrey
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 142,
                        width: 142,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(
                              '${AppUrls.coverFirestorage}${state.songs[0].artist} - ${state.songs[0].title}.jpg?${AppUrls.mediaAlt}',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.songs[0].titleVie,
                                style: TextStyle(
                                  color: context.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                state.songs[0].artistVie,
                                style: TextStyle(
                                  color: context.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              Text(
                                "Release: ${formatDate(state.songs[0].releaseDate)}",
                                style: TextStyle(
                                  color: context.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  FavoriteButton(songEntity: state.songs[0]),

                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        context
                                            .read<NewSongsReleasedCubit>()
                                            .playOrPauseSong(state.songs[0]);
                                      });
                                    },
                                    child: Container(
                                      height: 32,
                                      width: 32,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary,
                                      ),
                                      child: Icon(
                                        context
                                                .read<NewSongsReleasedCubit>()
                                                .audioPlayer
                                                .playing
                                            ? Icons.pause
                                            : Icons.play_arrow,

                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
