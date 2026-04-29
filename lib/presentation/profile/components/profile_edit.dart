import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_state.dart';
import 'package:spotify_app/presentation/profile/ultils/enums/profile_enum.dart';
// Import UserCubit và BasicAppButton của bạn ở đây

class ProfileEditPage extends StatefulWidget {
  final EditType editType;
  final String initialValue;

  const ProfileEditPage({
    super.key,
    required this.editType,
    required this.initialValue,
  });

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController _controller;
  String? _selectedGender;
  DateTime? _selectedDate;

  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    if (widget.editType == EditType.gender) {
      _selectedGender = widget.initialValue;
    }
    if (widget.editType == EditType.birthday) {
      // Tách chuỗi 13/03/2001 thành mảng [13, 03, 2001]
      List<String> parts = widget.initialValue.split('/');
      if (parts.length == 3) {
        _selectedDate = DateTime(
          int.parse(parts[2]), // Năm
          int.parse(parts[1]), // Tháng
          int.parse(parts[0]), // Ngày
        );
      } else {
        _selectedDate = DateTime.now();
      }
    }
  }

  // --- WIDGET CHO TỪNG LOẠI ---

  Widget _buildEditField() {
    int maxLength = widget.editType == EditType.name ? 50 : 150;
    int maxLines = widget.editType == EditType.name ? 1 : 5;
    bool isIconClose = widget.editType == EditType.name;

    return TextField(
      controller: _controller,
      maxLength: maxLength,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 16),
      decoration:
          InputDecoration(
            // Đường gạch chân màu xanh khi focus (giống ảnh 1 & 4)
            // focusedBorder: const UnderlineInputBorder(
            //   borderSide: BorderSide(color: Color(0xff42C83C), width: 2),
            // ),
            // enabledBorder: const UnderlineInputBorder(
            //   borderSide: BorderSide(color: Colors.grey),
            // ),
            suffixIcon: isIconClose
                ? IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      _controller.clear();
                    },
                  )
                : null,
            // Custom text hiển thị (0/150) ở góc dưới
            counterStyle: const TextStyle(color: Colors.grey),
          ).copyWith(
            contentPadding: const EdgeInsets.all(20),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
    );
  }

  Widget _buildEditPhoneField() {
    return TextField(
      controller: _controller,
      style: const TextStyle(fontSize: 16),
      onChanged: (val) {
        if (_phoneError != null) setState(() => _phoneError = null);
      },
      decoration:
          InputDecoration(
            // Đường gạch chân màu xanh khi focus (giống ảnh 1 & 4)
            // focusedBorder: const UnderlineInputBorder(
            //   borderSide: BorderSide(color: Color(0xff42C83C), width: 2),
            // ),
            // enabledBorder: const UnderlineInputBorder(
            //   borderSide: BorderSide(color: Colors.grey),
            // ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                _controller.clear();
              },
            ),
            // Custom text hiển thị (0/150) ở góc dưới
            counterStyle: const TextStyle(color: Colors.grey),
          ).copyWith(
            contentPadding: const EdgeInsets.all(20),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
    );
  }

  Widget _buildGenderList() {
    List<String> options = ['Nam', 'Nữ', 'Khác'];
    return Column(
      children: options
          .map(
            (gender) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                title: Text(gender, style: const TextStyle(fontSize: 16)),
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                trailing: _selectedGender == gender
                    ? const Icon(Icons.check, color: Color(0xff42C83C))
                    : null,
                onTap: () => setState(() => _selectedGender = gender),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBirthdayPicker() {
    return Column(
      children: [
        // Hiển thị ngày đã chọn
        TextField(
          readOnly: true,
          decoration:
              InputDecoration(
                hintText:
                    "${_selectedDate?.day.toString().padLeft(2, '0')}/${_selectedDate?.month.toString().padLeft(2, '0')}/${_selectedDate?.year}",
                hintStyle: const TextStyle(fontSize: 16),
              ).copyWith(
                contentPadding: const EdgeInsets.all(20),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
        ),
        const Spacer(),
        // Lịch cuộn ở cuối màn hình (giống ảnh 2)
        SizedBox(
          height: 200,
          child: CupertinoTheme(
            data: const CupertinoThemeData(
              textTheme: CupertinoTextThemeData(
                dateTimePickerTextStyle: TextStyle(fontSize: 16),
              ),
            ),
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: _selectedDate,
              onDateTimeChanged: (date) => setState(() {
                _selectedDate = date;
              }),
            ),
          ),
        ),
      ],
    );
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^0[35789][0-9]{8}$').hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    String title = "";
    Widget mainContent = const SizedBox();

    // Map tiêu đề và nội dung
    if (widget.editType == EditType.name) {
      title = "Tên hiển thị";
      mainContent = _buildEditField();
    } else if (widget.editType == EditType.bio) {
      title = "Tiểu sử";
      mainContent = _buildEditField();
    } else if (widget.editType == EditType.gender) {
      title = "Giới tính";
      mainContent = _buildGenderList();
    } else if (widget.editType == EditType.birthday) {
      title = "Ngày sinh";
      mainContent = _buildBirthdayPicker();
    } else if (widget.editType == EditType.phone) {
      title = "Số điện thoại";
      mainContent = _buildEditPhoneField();
    }

    return Scaffold(
      backgroundColor: context.isDarkMode
          ? AppColors.darkBackground
          : Colors.white, // Màu nền tối của app
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nếu là ngày sinh, nội dung chiếm hết để đẩy picker xuống dưới
            widget.editType == EditType.birthday
                ? Expanded(child: mainContent)
                : mainContent,
            if (_phoneError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _phoneError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (widget.editType != EditType.birthday) const Spacer(),

            // Nút cập nhật dùng chung
            BlocConsumer<ProfileInfoCubit, ProfileInfoState>(
              listener: (context, state) {
                if (state is ProfileUpdatedSuccess) Navigator.pop(context);
              },
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    _onUpdate(context);
                  },
                  // onPressed: () async {
                  //   FocusManager.instance.primaryFocus?.unfocus();

                  //   Navigator.pop(context);
                  // },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cập nhật'),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _onUpdate(BuildContext context) {
    final cubit = context.read<ProfileInfoCubit>();
    final value = _controller.text.trim();
    // Dựa vào editType để quyết định gọi tham số nào trong Cubit

    switch (widget.editType) {
      case EditType.name:
        // Trim() để loại bỏ khoảng trắng thừa ở đầu/cuối tên
        cubit.updateUserInfo(displayName: _controller.text.trim());
        break;

      case EditType.bio:
        cubit.updateUserInfo(bio: _controller.text.trim());
        break;

      case EditType.gender:
        // _selectedGender là biến String bạn lưu khi người dùng chọn ListTile
        cubit.updateUserInfo(gender: _selectedGender);
        break;

      case EditType.birthday:
        if (_selectedDate != null) {
          // Format DateTime thành chuỗi dd/MM/yyyy để lưu lên Firebase
          final formattedDate =
              "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}";
          cubit.updateUserInfo(dob: formattedDate);
        }
        break;
      case EditType.phone:
        if (value.isEmpty) {
          setState(() => _phoneError = "Vui lòng nhập số điện thoại");
          return;
        }
        if (!_isValidPhone(value)) {
          setState(
            () => _phoneError =
                "Số điện thoại Việt Nam không hợp lệ (ví dụ: 0912...)",
          );
          return;
        }
        // Nếu hợp lệ thì gọi update
        cubit.updateUserInfo(phone: value);
        break;
    }
  }
}
