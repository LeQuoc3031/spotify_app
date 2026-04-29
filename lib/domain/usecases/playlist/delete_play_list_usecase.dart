import 'package:spotify_app/core/usecase/usecase.dart';
import 'package:spotify_app/domain/repository/playlist/play_list_repository.dart';
import 'package:spotify_app/service_locator.dart';

class DeletePlayListUseCase implements Usecase<void, List<String>> {
  @override
  Future<void> call({List<String>? params}) async {
    return await sl<PlayListRepository>().deletePlayList(params!);
  }
}
