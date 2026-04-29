import 'package:spotify_app/core/usecase/usecase.dart';
import 'package:spotify_app/domain/repository/playlist/play_list_repository.dart';
import 'package:spotify_app/service_locator.dart';

class CreatePlayListUseCase implements Usecase<void, String> {
  @override
  Future<void> call({String? params}) async {
    return await sl<PlayListRepository>().createPlayList(params!);
  }
}
