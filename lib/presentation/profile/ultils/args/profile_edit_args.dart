import 'package:spotify_app/presentation/profile/ultils/enums/profile_enum.dart';

class ProfileEditArgs {
  final EditType editType;
  final String initialValue;

  ProfileEditArgs({required this.editType, required this.initialValue});
}