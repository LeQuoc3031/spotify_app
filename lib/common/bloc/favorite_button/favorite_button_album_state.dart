abstract class FavoriteButtonAlbumState {}

class FavoriteButtonAlbumInitial extends FavoriteButtonAlbumState {}

class FavoriteButtonAlbumUpdated extends FavoriteButtonAlbumState {
  final bool isFavorite;
  FavoriteButtonAlbumUpdated({required this.isFavorite});
}

class FavoriteButtonUpdatedAlbumId extends FavoriteButtonAlbumState {
  final String albumId; // Để biết bài nào vừa được đổi trạng thái
  FavoriteButtonUpdatedAlbumId({required this.albumId});
}
