import 'package:spotify_app/domain/entities/song/song.dart';

abstract class ArtistSongState {}

class ArtistSongInitial extends ArtistSongState {}

class ArtistSongLoading extends ArtistSongState {}

class ArtistSongLoaded extends ArtistSongState {
  final List<SongEntity> songs;
  ArtistSongLoaded({required this.songs});
}

class ArtistSongFailure extends ArtistSongState {}