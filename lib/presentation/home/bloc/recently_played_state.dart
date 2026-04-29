import 'package:spotify_app/domain/entities/song/song.dart';

abstract class RecentlyPlayedState {}

class RecentlyPlayedInitial extends RecentlyPlayedState {}

class RecentlyPlayedLoading extends RecentlyPlayedState {}

class RecentlyPlayedLoaded extends RecentlyPlayedState {
  final List<SongEntity> songs;

  RecentlyPlayedLoaded({required this.songs});
}

class RecentlyPlayedLoadFailure extends RecentlyPlayedState {}
