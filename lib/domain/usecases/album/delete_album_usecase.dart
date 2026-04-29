import 'package:spotify_app/core/usecase/usecase.dart';
import 'package:spotify_app/domain/repository/album/album_repository.dart';
import 'package:spotify_app/service_locator.dart';

class DeleteAlbumUseCase implements Usecase<void, List<String>> {
  @override
  Future<void> call({List<String>? params}) async {
    return await sl<AlbumRepository>().deleteAlbums(params!);
  }
}
