// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:marquee/marquee.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotify_app/common/bloc/favorite_button/favorite_button_album_cubit.dart';
import 'package:spotify_app/common/bloc/favorite_button/favorite_button_cubit.dart';
import 'package:spotify_app/common/bloc/navigation_bar/navigation_cubit.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/core/configs/constants/app_urls.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/core/configs/theme/app_theme.dart';
import 'package:spotify_app/domain/entities/album/album.dart';
import 'package:spotify_app/domain/entities/artist/artist.dart';
import 'package:spotify_app/domain/entities/playlist/play_list.dart';
import 'package:spotify_app/firebase_options.dart';
import 'package:spotify_app/presentation/album/pages/album.dart';
import 'package:spotify_app/presentation/artist/bloc/artist_search_cubit.dart';
import 'package:spotify_app/presentation/artist/bloc/artist_song_cubit.dart';
import 'package:spotify_app/presentation/artist/pages/artist_profile_page.dart';
import 'package:spotify_app/presentation/auth/bloc/auth_cubit.dart';
import 'package:spotify_app/presentation/auth/pages/signin.dart';
import 'package:spotify_app/presentation/auth/pages/signup.dart';
import 'package:spotify_app/presentation/auth/pages/signup_or_signin.dart';
import 'package:spotify_app/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:spotify_app/presentation/home/bloc/new_songs_released_cubit.dart';
import 'package:spotify_app/presentation/home/bloc/news_songs_cubit.dart';
import 'package:spotify_app/presentation/home/bloc/recently_played_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/favorite_album_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/favorite_song_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/play_list_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_cubit.dart';
import 'package:spotify_app/presentation/profile/components/status.dart';
import 'package:spotify_app/presentation/profile/pages/favorite_song.dart';
import 'package:spotify_app/presentation/profile/pages/play_list_song.dart';
import 'package:spotify_app/presentation/profile/components/profile_edit.dart';
import 'package:spotify_app/presentation/profile/pages/profile_info.dart';
import 'package:spotify_app/presentation/profile/pages/profile_setting.dart';
import 'package:spotify_app/presentation/profile/ultils/args/profile_edit_args.dart';
import 'package:spotify_app/presentation/profile/components/change_password.dart';
import 'package:spotify_app/presentation/profile/ultils/args/status_args.dart';
import 'package:spotify_app/presentation/search/bloc/search_list_cubit.dart';
import 'package:spotify_app/presentation/search/bloc/search_cubit.dart';
import 'package:spotify_app/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:spotify_app/presentation/song_player/bloc/song_player_state.dart';
import 'package:spotify_app/presentation/song_player/pages/song_player.dart';
import 'package:spotify_app/presentation/splash/pages/splash.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/service_locator.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

final ValueNotifier<String?> currentRouteName = ValueNotifier<String?>(null);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Cập nhật tên route khi bạn push màn hình mới
    currentRouteName.value = route.settings.name;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Cập nhật lại tên route của màn hình phía dưới khi back về
    currentRouteName.value = previousRoute?.settings.name;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => NavigationCubit()),
        BlocProvider(create: (context) => FavoriteButtonCubit()),
        BlocProvider(create: (context) => FavoriteSongCubit()),
        BlocProvider(create: (context) => SearchListCubit()),
        BlocProvider(create: (context) => SearchSongCubit()),
        BlocProvider(create: (context) => SongPlayerCubit()),
        BlocProvider(create: (context) => ArtistSearchCubit()),
        BlocProvider(create: (context) => RecentlyPlayedCubit()),
        BlocProvider(create: (context) => NewSongsReleasedCubit()),
        BlocProvider(create: (context) => NewsSongsCubit()),
        BlocProvider(create: (context) => ArtistSongCubit()),
        BlocProvider(create: (context) => PlayListCubit()),
        BlocProvider(create: (context) => FavoriteButtonAlbumCubit()),
        BlocProvider(create: (context) => FavoriteAlbumCubit()),
        BlocProvider(create: (context) => ProfileInfoCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            onGenerateRoute: (settings) {
              // 1. Kiểm tra tên route
              if (settings.name == '/artist') {
                // 2. Lấy dữ liệu arguments và ép kiểu về ArtistEntity
                final artist = settings.arguments as ArtistEntity;

                // 3. Trả về Route với dữ liệu thật
                return MaterialPageRoute(
                  settings:
                      settings, // BẮT BUỘC có dòng này để MyRouteObserver hoạt động
                  builder: (context) => ArtistProfilePage(artistEntity: artist),
                );
              }

              if (settings.name == '/album') {
                // 2. Lấy dữ liệu arguments và ép kiểu về ArtistEntity
                final album = settings.arguments as AlbumEntity;

                // 3. Trả về Route với dữ liệu thật
                return MaterialPageRoute(
                  settings:
                      settings, // BẮT BUỘC có dòng này để MyRouteObserver hoạt động
                  builder: (context) => AlbumPage(albumEntity: album),
                );
              }

              if (settings.name == '/favorite') {
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => const FavoriteSongPage(),
                );
              }

              if (settings.name == '/profile-info') {
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => const ProfileInfoPage(),
                );
              }

              if (settings.name == '/profile-edit') {
                final args = settings.arguments as ProfileEditArgs;
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => ProfileEditPage(
                    editType: args.editType,
                    initialValue: args.initialValue,
                  ),
                );
              }

              if (settings.name == '/status') {
                final args = settings.arguments as StatusArgs;
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => StatusPage(
                    isSuccess: args.isSuccess,
                    message: args.message,
                  ),
                );
              }

              if (settings.name == '/setting') {
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => const ProfileSettingPage(),
                );
              }

              if (settings.name == '/change-password') {
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => const ChangePassword(),
                );
              }

              if (settings.name == '/playlist') {
                // 2. Lấy dữ liệu arguments và ép kiểu về ArtistEntity
                final playlist = settings.arguments as PlayListEntity;

                // 3. Trả về Route với dữ liệu thật
                return MaterialPageRoute(
                  settings:
                      settings, // BẮT BUỘC có dòng này để MyRouteObserver hoạt động
                  builder: (context) =>
                      PlayListSongPage(playlistEntity: playlist),
                );
              }

              // Xử lý các route khác (như /player) tương tự ở đây...
              if (settings.name == '/player') {
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => const SongPlayerPage(),
                );
              }

              if (settings.name == '/signup-signin') {
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => const SignupOrSigninPage(),
                );
              }

              if (settings.name == '/signin') {
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => const SigninPage(),
                );
              }

              if (settings.name == '/signup') {
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => const SignupPage(),
                );
              }

              return null;
            },

            navigatorObservers: [MyRouteObserver(), routeObserver],
            title: 'Flutter Demo',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return Scaffold(
                body: Stack(
                  children: [
                    child!,
                    ValueListenableBuilder<String?>(
                      valueListenable: currentRouteName,
                      builder: (context, name, _) {
                        print("Current Route Name: $name");

                        // Nếu là màn hình player thì ẩn thanh mini đi
                        // if (name == '/player') {
                        //   return const SizedBox();
                        // }
                        // Kiểm tra trạng thái Cubit để hiện Mini Player
                        double bottomPadding =
                            name == '/artist' ||
                                name == '/album' ||
                                name == '/favorite' ||
                                name == '/playlist'
                            ? 0.0
                            : 80.0;
                        final bool isPlayerPage =
                            name == '/player' ||
                            name == '/profile-info' ||
                            name == '/setting' ||
                            name == '/profile-edit' ||
                            name == '/change-password' ||
                            name == '/status' ||
                            name == '/signup-signin' ||
                            name == '/signin' ||
                            name == '/signup';

                        return BlocBuilder<SongPlayerCubit, SongPlayerState>(
                          builder: (context, state) {
                            // Kiểm tra điều kiện để hiện Player
                            final bool showPlayer =
                                state is SongPlayerLoaded && !isPlayerPage;

                            return AnimatedPositioned(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              left: 10, // Cách lề trái 10
                              right: 10, // Cách lề phải 10
                              bottom: showPlayer ? bottomPadding : -110,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 500),
                                opacity: showPlayer ? 1.0 : 0.0,
                                child: (state is SongPlayerLoaded)
                                    ? myMiniPlayed(state, context)
                                    : const SizedBox.shrink(),
                              ),
                            );

                            // if (state is SongPlayerLoaded) {
                            //   return MyMiniPlayed(bottomPadding, state, context);
                            // }
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
            home: const SplashPage(),
          );
        },
      ),
    );
  }

  GestureDetector myMiniPlayed(SongPlayerLoaded state, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.pushNamed(context, '/player');
        navigatorKey.currentState?.pushNamed('/player').then((value) {
          if (!context.mounted) return;
          context.read<NewSongsReleasedCubit>().getNewSongsReleased();
        });
      },
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.isDarkMode ? AppColors.darkGrey : AppColors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    transform: Matrix4.translationValues(10, -10, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(
                          '${AppUrls.coverFirestorage}${state.songEntity?.artist} - ${state.songEntity?.title}.jpg?${AppUrls.mediaAlt}',
                        ),

                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 20,
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent, // Đầu trái mờ
                                Colors.black, // Giữa rõ
                                Colors.black, // Giữa rõ
                                Colors.transparent, // Đầu phải mờ
                              ],
                              stops: [
                                0.0,
                                0.1,
                                0.9,
                                1.0,
                              ], // Định nghĩa vùng mờ (10% mỗi đầu)
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final textStyle = TextStyle(
                                color: context.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              );

                              final textTitle =
                                  '   ${state.songEntity?.titleVie ?? ''} / ${state.songEntity?.title ?? ''}';

                              final textPainter = TextPainter(
                                text: TextSpan(
                                  text: textTitle,
                                  style: textStyle,
                                ),
                                maxLines: 1,
                                textDirection: TextDirection.ltr,
                              )..layout();

                              if (textPainter.size.width <
                                  constraints.maxWidth) {
                                return Text(
                                  textTitle,
                                  style: textStyle,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              return Marquee(
                                text: textTitle,
                                style: textStyle,
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                blankSpace: 50.0,
                                velocity: 30.0,
                                pauseAfterRound: const Duration(seconds: 2),
                              );
                            },
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 150,
                        height: 15,
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent, // Đầu trái mờ
                                Colors.black, // Giữa rõ
                                Colors.black, // Giữa rõ
                                Colors.transparent, // Đầu phải mờ
                              ],
                              stops: [
                                0.0,
                                0.1,
                                0.9,
                                1.0,
                              ], // Định nghĩa vùng mờ (10% mỗi đầu)
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final textStyle = TextStyle(
                                color: context.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 10,
                              );

                              final textArtist =
                                  '   ${state.songEntity?.artistVie ?? ''} / ${state.songEntity?.artist ?? ''}';

                              final textPainter = TextPainter(
                                text: TextSpan(
                                  text: textArtist,
                                  style: textStyle,
                                ),
                                maxLines: 1,
                                textDirection: TextDirection.ltr,
                              )..layout();

                              if (textPainter.size.width <
                                  constraints.maxWidth) {
                                return Text(
                                  textArtist,
                                  style: textStyle,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              return Marquee(
                                text: textArtist,
                                style: textStyle,
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                blankSpace: 50.0,
                                velocity: 30.0,
                                pauseAfterRound: const Duration(seconds: 2),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  IconButton(
                    icon: Icon(
                      Icons.skip_previous,
                      color: context.isDarkMode ? Colors.white : Colors.black,
                      size: 24,
                    ),
                    onPressed: () =>
                        context.read<SongPlayerCubit>().previousSong(),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<SongPlayerCubit>().playOrPauseSong(
                        state.songEntity!,
                      );
                      context.read<SongPlayerCubit>().loadLyrics(
                        '${AppUrls.lyricFirestorage}${state.songEntity?.artist} - ${state.songEntity?.title}.lrc.txt?${AppUrls.mediaAlt}',
                        state.songEntity!,
                      );
                    },
                    child: Container(
                      height: 24,
                      width: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: Icon(
                        // context.read<SongPlayerCubit>().audioPlayer.playing
                        state.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 15,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.skip_next,
                      color: context.isDarkMode ? Colors.white : Colors.black,
                      size: 24,
                    ),
                    onPressed: () => context.read<SongPlayerCubit>().nextSong(),
                  ),

                  const SizedBox(width: 10),
                ],
              ),

              const Spacer(),

              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: SliderComponentShape.noThumb,
                  trackHeight: 1.0,
                ),
                child: Slider(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  value: context
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
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
