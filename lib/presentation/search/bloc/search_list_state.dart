import 'package:spotify_app/domain/entities/song/song.dart';

abstract class SearchListState {}

class SearchListInitial extends SearchListState {}

class SearchListLoading extends SearchListState {}

class SearchListLoaded extends SearchListState {
  final List<SongEntity> songs;
  final bool isFetchingMore;
  final bool hasMore;
  SearchListLoaded({
    required this.songs,
    this.isFetchingMore = false,
    this.hasMore = true, // Mặc định là còn dữ liệu
  });
}

class SearchListLoadFailure extends SearchListState {}
