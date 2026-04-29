import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_state.dart';
import 'package:spotify_app/presentation/profile/ultils/args/profile_edit_args.dart';
import 'package:spotify_app/presentation/profile/ultils/enums/profile_enum.dart';

class InforAboutYouWidget extends StatelessWidget {
  const InforAboutYouWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            SizedBox(width: 10),
            Text(
              'Giới thiệu về bạn',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 5),
        BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
          builder: (context, state) {
            if (state is ProfileInfoLoaded) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? AppColors.darkGrey
                      : AppColors.lightBackground,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/profile-edit',
                          arguments: ProfileEditArgs(
                            editType: EditType.name,
                            initialValue:
                                state.userEntity.fullName ?? 'khong co',
                          ),
                        ).then((value) {
                          if (!context.mounted) return;
                          context.read<ProfileInfoCubit>().getUser();
                        });
                      },
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          const Text(
                            'Tên hiển thị',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Text(
                            state.userEntity.fullName ?? 'khong co',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.arrow_forward_ios, size: 14),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        const Text(
                          'ID',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 100,
                          child: Text(
                            '${state.userEntity.userId}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/profile-edit',
                          arguments: ProfileEditArgs(
                            editType: EditType.bio,
                            initialValue:
                                state.userEntity.biography ?? 'khong co',
                          ),
                        ).then((value) {
                          if (!context.mounted) return;
                          context.read<ProfileInfoCubit>().getUser();
                        });
                      },
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          const Text(
                            'Tiểu sử',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 150,
                            child: Text(
                              state.userEntity.biography ?? 'khong co',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
    
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.arrow_forward_ios, size: 14),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
    
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/profile-edit',
                          arguments: ProfileEditArgs(
                            editType: EditType.birthday,
                            initialValue:
                                state.userEntity.birthday ?? 'khong co',
                          ),
                        ).then((value) {
                          if (!context.mounted) return;
                          context.read<ProfileInfoCubit>().getUser();
                        });
                      },
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          const Text(
                            'Sinh nhật',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Text(
                            state.userEntity.birthday ?? 'khong co',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.arrow_forward_ios, size: 14),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/profile-edit',
                          arguments: ProfileEditArgs(
                            editType: EditType.gender,
                            initialValue:
                                state.userEntity.gender ?? 'khong co',
                          ),
                        ).then((value) {
                          if (!context.mounted) return;
                          context.read<ProfileInfoCubit>().getUser();
                        });
                      },
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          const Text(
                            'Giới tính',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Text(
                            state.userEntity.gender ?? 'khong co',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.arrow_forward_ios, size: 14),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? AppColors.darkGrey
                    : AppColors.lightBackground,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/profile-edit',
                        arguments: ProfileEditArgs(
                          editType: EditType.name,
                          initialValue: '',
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          'Tên hiển thị',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Spacer(),
                        Text(
                          '',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward_ios, size: 14),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      SizedBox(width: 10),
                      Text(
                        'ID',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Spacer(),
                      Text(
                        '1234566789',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/profile-edit',
                        arguments: ProfileEditArgs(
                          editType: EditType.bio,
                          initialValue: '',
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          'Tiểu sử',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Spacer(),
                        Text(
                          '',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward_ios, size: 14),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
    
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/profile-edit',
                        arguments: ProfileEditArgs(
                          editType: EditType.birthday,
                          initialValue: '',
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          'Sinh nhật',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Spacer(),
                        Text(
                          '',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward_ios, size: 14),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/profile-edit',
                        arguments: ProfileEditArgs(
                          editType: EditType.gender,
                          initialValue: '',
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          'Giới tính',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Spacer(),
                        Text(
                          '',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward_ios, size: 14),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
