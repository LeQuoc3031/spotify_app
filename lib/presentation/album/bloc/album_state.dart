import 'package:spotify_app/domain/entities/song/song.dart';

abstract class AlbumState {}

class AlbumInitial extends AlbumState {}

class AlbumLoading extends AlbumState {}

class AlbumLoaded extends AlbumState {
  final List<SongEntity> songs;
  AlbumLoaded({required this.songs});
}

class AlbumLoadFailure extends AlbumState {}
