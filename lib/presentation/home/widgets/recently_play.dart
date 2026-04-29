import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/constants/app_urls.dart';
import 'package:spotify_app/presentation/home/bloc/recently_played_cubit.dart';
import 'package:spotify_app/presentation/home/bloc/recently_played_state.dart';
import 'package:spotify_app/presentation/song_player/bloc/song_player_cubit.dart';

class RecentlyPlayed extends StatefulWidget {
  const RecentlyPlayed({super.key});

  @override
  State<RecentlyPlayed> createState() => _RecentlyPlayedState();
}

class _RecentlyPlayedState extends State<RecentlyPlayed> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecentlyPlayedCubit()..getRecentlyPlayed(),
      child: BlocBuilder<RecentlyPlayedCubit, RecentlyPlayedState>(
        builder: (context, state) {
          if (state is RecentlyPlayedLoading) {
            return const Column(
              children: [SizedBox(height: 40), LoadingScreen()],
            );
          }

          if (state is RecentlyPlayedLoaded && state.songs.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  "Recently played",
                  style: TextStyle(
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 14),
                    itemCount: state.songs.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        context.read<SongPlayerCubit>().loadSongs(
                          state.songs,
                          index,
                          'recentlyPlayed',
                        );

                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const SongPlayerPage(),
                        //   ),
                        // );
                        Navigator.pushNamed(context, '/player');
                      },
                      child: SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                // color: Colors.blue,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      '${AppUrls.coverFirestorage}${state.songs[index].artist} - ${state.songs[index].title}.jpg?${AppUrls.mediaAlt}',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              state.songs[index].titleVie,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              state.songs[index].artistVie,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
