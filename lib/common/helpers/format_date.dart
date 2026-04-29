import 'package:intl/intl.dart';

String formatDate(dynamic releaseDate) {
  if (releaseDate == null) return '';

  // 1. Chuyển từ Timestamp sang DateTime
  DateTime date = releaseDate.toDate(); 

  // 2. Định dạng theo dd/MM/yyyy (Ngày/Tháng/Năm)
  return DateFormat('dd-MM-yyyy').format(date);
}