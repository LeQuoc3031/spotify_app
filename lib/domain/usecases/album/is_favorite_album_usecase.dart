import 'package:spotify_app/core/usecase/usecase.dart';
import 'package:spotify_app/domain/repository/album/album_repository.dart';
import 'package:spotify_app/service_locator.dart';

class IsFavoriteAlbumUseCase implements Usecase<bool, String> {
  @override
  Future<bool> call({String? params}) async {
    return await sl<AlbumRepository>().isFavoriteAlbum(params!);
  }
}
