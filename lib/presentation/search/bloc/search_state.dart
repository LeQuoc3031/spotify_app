import 'package:spotify_app/domain/entities/song/song.dart';

abstract class SearchSongState {}

class SearchSongInitial extends SearchSongState {}

class SearchSongLoading extends SearchSongState {}

class SearchSongLoaded extends SearchSongState {
  final List<SongEntity> songs;
  final bool isFetchingMore;
  final bool hasMore;
  SearchSongLoaded({
    required this.songs,
    this.isFetchingMore = false,
    this.hasMore = true,
  });
}

class SearchSongError extends SearchSongState {}
