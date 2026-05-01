import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_state.dart';
import 'package:spotify_app/presentation/profile/ultils/args/profile_edit_args.dart';
import 'package:spotify_app/presentation/profile/ultils/enums/profile_enum.dart';

class AccountInfoWidget extends StatelessWidget {
  const AccountInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            SizedBox(width: 10),
            Text(
              'Thông tin tài khoản',
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
                            editType: EditType.phone,
                            initialValue: state.userEntity.phone ?? 'khong co',
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
                            'Số điện thoại',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Text(
                            '(+84) ${state.userEntity.phone}',
                            style: const TextStyle(
                              // color: Colors.grey,
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
                          'Email',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Text(
                          '${state.userEntity.email}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // const SizedBox(width: 5),
                        // const Icon(Icons.arrow_forward_ios, size: 14),
                        const SizedBox(width: 20),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/change-password').then((
                          value,
                        ) {
                          if (!context.mounted) return;
                          context.read<ProfileInfoCubit>().getUser();
                        });
                      },
                      child: const Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            'Mật khẩu',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Spacer(),
                          Text(
                            'Thay đổi',
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
                  const Row(
                    children: [
                      SizedBox(width: 10),
                      Text(
                        'Số điện thoại',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Spacer(),
                      Text(
                        '(+84) 123456789',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward_ios, size: 14),
                      SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      SizedBox(width: 10),
                      Text(
                        'Email',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Spacer(),
                      Text(
                        'BwV9A@example.com',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward_ios, size: 14),
                      SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/change-password').then((
                        value,
                      ) {
                        if (!context.mounted) return;
                        context.read<ProfileInfoCubit>().getUser();
                      });
                    },
                    child: const Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          'Mật khẩu',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Spacer(),
                        Text(
                          'Thay đổi',
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
