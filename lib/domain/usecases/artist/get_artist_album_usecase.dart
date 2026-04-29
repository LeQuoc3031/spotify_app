import 'package:dartz/dartz.dart';
import 'package:spotify_app/core/usecase/usecase.dart';
import 'package:spotify_app/domain/repository/artist/artist_repository.dart';
import 'package:spotify_app/service_locator.dart';

class GetArtistAlbumUseCase implements Usecase<Either, String> {
  @override
  Future<Either> call({String? params}) async {
    return await sl<ArtistRepository>().getArtistAlbums(params!);
  }
}
