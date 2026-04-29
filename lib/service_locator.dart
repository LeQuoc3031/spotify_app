import 'package:get_it/get_it.dart';
import 'package:spotify_app/data/repository/album/album_repository_impl.dart';
import 'package:spotify_app/data/repository/artist/artist_repository_impl.dart';
import 'package:spotify_app/data/repository/auth/auth_repository_impl.dart';
import 'package:spotify_app/data/repository/playlist/play_list_repository_impl.dart';
import 'package:spotify_app/data/repository/profile/profile_repository_impl.dart';
import 'package:spotify_app/data/repository/song/song_repository_impl.dart';
import 'package:spotify_app/data/sources/album/album_firebase_service.dart';
import 'package:spotify_app/data/sources/artist/artist_firebase_service.dart';
import 'package:spotify_app/data/sources/auth/auth_firebase_service.dart';
import 'package:spotify_app/data/sources/play_list/play_list_service.dart';
import 'package:spotify_app/data/sources/song/song_firebase_service.dart';
import 'package:spotify_app/data/sources/profile/profile_firebase_service.dart';
import 'package:spotify_app/domain/repository/album/album_repository.dart';
import 'package:spotify_app/domain/repository/artist/artist_repository.dart';
import 'package:spotify_app/domain/repository/auth/auth_repository.dart';
import 'package:spotify_app/domain/repository/playlist/play_list_repository.dart';
import 'package:spotify_app/domain/repository/profile/profile_repository.dart';
import 'package:spotify_app/domain/repository/song/song_repository.dart';
import 'package:spotify_app/domain/usecases/album/add_or_remove_favorite_album_usecase.dart';
import 'package:spotify_app/domain/usecases/album/delete_album_usecase.dart';
import 'package:spotify_app/domain/usecases/album/get_album_song_usecase.dart';
import 'package:spotify_app/domain/usecases/album/get_favorite_album_usecase.dart';
import 'package:spotify_app/domain/usecases/album/is_favorite_album_usecase.dart';
import 'package:spotify_app/domain/usecases/artist/get_artist_album_usecase.dart';
import 'package:spotify_app/domain/usecases/artist/get_artist_song_usecase.dart';
import 'package:spotify_app/domain/usecases/artist/get_artist_usecase.dart';
import 'package:spotify_app/domain/usecases/auth/get_user_usecase.dart';
import 'package:spotify_app/domain/usecases/auth/signin_usecase.dart';
import 'package:spotify_app/domain/usecases/auth/signup_usecase.dart';
import 'package:spotify_app/domain/usecases/playlist/add_song_to_playlist_usecase.dart';
import 'package:spotify_app/domain/usecases/playlist/create_play_list_usecase.dart';
import 'package:spotify_app/domain/usecases/playlist/delete_play_list_usecase.dart';
import 'package:spotify_app/domain/usecases/playlist/get_play_list_usecase.dart';
import 'package:spotify_app/domain/usecases/playlist/get_song_in_playlist_usecase.dart';
import 'package:spotify_app/domain/usecases/playlist/remove_song_from_playlist_usecase.dart';
import 'package:spotify_app/domain/usecases/profile/update_profile_info_usecase.dart';
import 'package:spotify_app/domain/usecases/profile/upload_and_change_avatar_usecase.dart';
import 'package:spotify_app/domain/usecases/song/add_or_remove_favorite_song_usecase.dart';
import 'package:spotify_app/domain/usecases/song/add_recently_played_usecase.dart';
import 'package:spotify_app/domain/usecases/song/get_favorite_songs_usecase.dart';
import 'package:spotify_app/domain/usecases/song/get_news_songs_usecase.dart';
import 'package:spotify_app/domain/usecases/song/get_search_list_usecase.dart';
import 'package:spotify_app/domain/usecases/song/get_recently_played_usecase.dart';
import 'package:spotify_app/domain/usecases/song/is_favorite_song_usecase.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Sử dụng registerLazySingleton giúp app khởi động nhanh
  // và chỉ tốn RAM cho những gì người dùng thực sự sử dụng.
  // Tiết kiệm bộ nhớ lúc khởi động. Sau khi đã khởi tạo lần đầu, nó sẽ
  // được lưu lại và dùng chung cho các lần gọi sau (giống Singleton thường).

  // Service
  sl.registerLazySingleton<AuthFirebaseService>(
    () => AuthFirebaseServiceImpl(),
  );

  sl.registerLazySingleton<SongFirebaseService>(
    () => SongFirebaseServiceImpl(),
  );

  sl.registerLazySingleton<ArtistFirebaseService>(
    () => ArtistFirebaseServiceImpl(),
  );

  sl.registerLazySingleton<AlbumFirebaseService>(
    () => AlbumFirebaseServiceImpl(),
  );

  sl.registerLazySingleton<ProfileFirebaseService>(
    () => ProfileFirebaseServiceImpl(),
  );

  sl.registerLazySingleton<PlayListService>(() => PlayListServiceImpl());

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  sl.registerLazySingleton<SongRepository>(() => SongRepositoryImpl());

  sl.registerLazySingleton<ArtistRepository>(() => ArtistRepositoryImpl());

  sl.registerLazySingleton<AlbumRepository>(() => AlbumRepositoryImpl());

  sl.registerLazySingleton<PlayListRepository>(() => PlayListRepositoryImpl());

  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl());

  // UseCase
  sl.registerLazySingleton<SignupUseCase>(() => SignupUseCase());

  sl.registerLazySingleton<SigninUseCase>(() => SigninUseCase());

  sl.registerLazySingleton<GetNewsSongsUseCase>(() => GetNewsSongsUseCase());

  sl.registerLazySingleton<GetSearchListUseCase>(() => GetSearchListUseCase());

  sl.registerLazySingleton<AddOrRemoveFavoriteSongUseCase>(
    () => AddOrRemoveFavoriteSongUseCase(),
  );

  sl.registerLazySingleton<IsFavoriteSongUseCase>(
    () => IsFavoriteSongUseCase(),
  );

  sl.registerLazySingleton<GetUserUseCase>(() => GetUserUseCase());

  sl.registerLazySingleton<GetFavoriteSongsUseCase>(
    () => GetFavoriteSongsUseCase(),
  );

  sl.registerLazySingleton<GetArtistsUseCase>(() => GetArtistsUseCase());

  sl.registerLazySingleton<GetArtistAlbumUseCase>(
    () => GetArtistAlbumUseCase(),
  );

  sl.registerLazySingleton<GetArtistSongUseCase>(() => GetArtistSongUseCase());

  sl.registerLazySingleton<GetAlbumSongUseCase>(() => GetAlbumSongUseCase());

  sl.registerLazySingleton<AddRecentlyPlayedUseCase>(
    () => AddRecentlyPlayedUseCase(),
  );

  sl.registerLazySingleton<GetRecentlyPlayedUseCase>(
    () => GetRecentlyPlayedUseCase(),
  );

  sl.registerLazySingleton<CreatePlayListUseCase>(
    () => CreatePlayListUseCase(),
  );

  sl.registerLazySingleton<GetPlayListUseCase>(() => GetPlayListUseCase());

  sl.registerLazySingleton<DeletePlayListUseCase>(
    () => DeletePlayListUseCase(),
  );

  sl.registerLazySingleton<AddSongToPlaylistUseCase>(
    () => AddSongToPlaylistUseCase(),
  );

  sl.registerLazySingleton<RemoveSongFromPlaylistUseCase>(
    () => RemoveSongFromPlaylistUseCase(),
  );

  sl.registerLazySingleton<GetSongInPlaylistUseCase>(
    () => GetSongInPlaylistUseCase(),
  );

  sl.registerLazySingleton<AddOrRemoveFavoriteAlbumUseCase>(
    () => AddOrRemoveFavoriteAlbumUseCase(),
  );

  sl.registerLazySingleton<IsFavoriteAlbumUseCase>(
    () => IsFavoriteAlbumUseCase(),
  );

  sl.registerLazySingleton<GetFavoriteAlbumUseCase>(
    () => GetFavoriteAlbumUseCase(),
  );

  sl.registerLazySingleton<DeleteAlbumUseCase>(() => DeleteAlbumUseCase());

  sl.registerLazySingleton<UploadAndChangeAvatarUseCase>(
    () => UploadAndChangeAvatarUseCase(),
  );

  sl.registerLazySingleton<UpdateProfileInfoUseCase>(
    () => UpdateProfileInfoUseCase(),
  );

  // Chỉ dùng registerSingleton khi bạn cần đảm bảo class đó
  // phải chạy ngay lập tức để thiết lập cấu hình hệ thống hoặc
  // các biến môi trường cần thiết cho các bước tiếp theo

  // sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());

  // sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  // sl.registerSingleton<SignupUseCase>(SignupUseCase());

  // sl.registerSingleton<SigninUseCase>(SigninUseCase());
}
