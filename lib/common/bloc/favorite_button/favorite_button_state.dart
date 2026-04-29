abstract class FavoriteButtonState {}

class FavoriteButtonInitial extends FavoriteButtonState {}

class FavoriteButtonUpdated extends FavoriteButtonState {
  final bool isFavorite;

  FavoriteButtonUpdated({required this.isFavorite});
}

class FavoriteButtonUpdatedSongId extends FavoriteButtonState {
  final String songId; // Để biết bài nào vừa được đổi trạng thái
  FavoriteButtonUpdatedSongId({required this.songId});
}