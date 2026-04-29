import 'package:spotify_app/domain/entities/song/song.dart';

abstract class FavoriteSongState {}

class FavoriteSongInitial extends FavoriteSongState {}

class FavoriteSongLoading extends FavoriteSongState {}

class FavoriteSongLoaded extends FavoriteSongState {
    final List<SongEntity> favoriteSongs;
    FavoriteSongLoaded({required this.favoriteSongs});
}

class FavoriteSongFailure extends FavoriteSongState {}