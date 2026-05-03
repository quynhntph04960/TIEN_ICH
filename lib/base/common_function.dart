import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

bool isNullOrEmpty(dynamic object) {
  if (object == null) return true;
  if (object == "null") return true;
  if (object is String) {
    return object.isEmpty;
  }
  if (object is List) {
    return object.isEmpty;
  }
  if (object is Map) {
    return object.isEmpty;
  }
  if (object is Set) {
    return object.isEmpty;
  }
  return false;
}

bool isNullOrZero(dynamic object) {
  if (object == null) return true;
  if (object is int) {
    if (object == 0) return true;
  }
  if (object is double) {
    if (object == 0 || object == 0.0) return true;
  }
  if (object is String) {
    if (object == "0") return true;
  }
  return isNullOrEmpty(object);
}

bool isNotNullOrEmpty(dynamic object) {
  return !isNullOrEmpty(object);
}

String convertImageBase64(String image64) {
  final bytes = File(image64).readAsBytesSync();
  String img64 = base64Encode(bytes);
  return img64;
}

/// dành riêng cho check version configs_app, xem kỹ trước khi sửa
/// version1 = store or google play
/// version2 = api return
int compareVersion(String version1, String version2) {
  if (version1 == version2) return 0;
  List<int> list1 = version1.split(".").map((e) => int.parse(e)).toList();
  List<int> list2 = version2.split(".").map((e) => int.parse(e)).toList();
  int minLength = min(list1.length, list2.length);
  for (int i = 0; i < minLength; i++) {
    if (list1[i].compareTo(list2[i]) == 0) {
      continue;
    } else {
      return list1[i].compareTo(list2[i]);
    }
  }
  return list1.length.compareTo(list2.length);
}

String stringMap(dynamic param) {
  if (isNullOrEmpty(param) || param is List) return "";

  if (param is int || param is String || param is double || param is bool) {
    return "/$param";
  }

  // param = map thì đi tiếp
  String valueGet = "";
  param.forEach((key, value) {
    if (isNullOrEmpty(key)) {
      valueGet = value.toString();
    } else {
      if (isNullOrEmpty(valueGet)) {
        valueGet = "$key=${value.toString()}";
      } else {
        valueGet = "$valueGet&$key=${value.toString()}";
      }
    }
  });

  if (isNullOrEmpty(valueGet)) return "";

  if (param.length == 1) {
    valueGet = "/$valueGet";
  } else {
    valueGet = "?$valueGet";
  }

  return valueGet;
}

// dùng cho textFormField
bool validateAndSave(GlobalKey<FormState> key) {
  FormState? form = key.currentState;
  if (form?.validate() ?? false) {
    form?.save();
    return true;
  }
  return false;
}

// ẩn bàn phím
void hideKeyboard() {
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

// ẩn bàn phím và tắt focus trên textField
void hideKeyboardAndUnFocus() {
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

// kiểm tra số điện thoại xem có đúng không
bool isPhoneNumberValid(String phoneNumber) {
  RegExp regex = RegExp(r'^(?:\+84|0)(?:\d{9,10})$');
  return regex.hasMatch(phoneNumber);
}

bool isWebLink(String text) {
  RegExp regExp = RegExp(
    r'^(?:http|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?$',
    caseSensitive: false,
    multiLine: false,
  );
  return regExp.hasMatch(text);
}

String formatCurrency(dynamic amount) {
  if (isNullOrEmpty(amount)) return "0";
  NumberFormat currencyFormat = NumberFormat('#,##0', 'en_US');

  double value = 0;
  if (amount is String) {
    value = double.tryParse(amount) ?? 0;
  } else if (amount is double) {
    value = amount;
  } else if (amount is int) {
    value = amount.toDouble();
  } else {
    value = double.tryParse(amount) ?? 0;
  }
  // Sử dụng đối tượng để định dạng số tiền và trả về chuỗi kết quả
  return currencyFormat.format(value);
}

bool isValidVietnamPhone(String phone) {
  phone = phone.trim();

  // ✅ Chỉ check số Việt Nam
  final vnRegex = RegExp(r'^(?:\+84|84|0)(3|5|7|8|9)\d{8}$');
  return vnRegex.hasMatch(phone);
}

// mã hoá email
String maskEmail(String email) {
  if (!email.contains('@')) return email;

  final parts = email.split('@');
  final local = parts[0];
  final domain = parts[1];

  if (local.length <= 2) {
    // quá ngắn thì che toàn bộ trừ ký tự đầu
    return '${local[0]}*@$domain';
  }

  final first = local[0];
  final last = local[local.length - 1];
  final masked = '*' * (local.length - 2);

  return '$first$masked$last@$domain';
}

// kiểm tra email
bool isValidEmail(String? email) {
  if (isNullOrEmpty(email)) return false;
  // Biểu thức chính quy kiểm tra định dạng email
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email ?? "");
}

/// Ví dụ 1: 1000 => 1.000
// Formatter cho dấu chấm trong TextField
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (isNullOrEmpty(newValue.text)) return newValue;

    final text = newValue.text.replaceAll(',', '');
    final newString = NumberFormat("#,###").format(int.parse(text));
    return TextEditingValue(
      text: newString.replaceAll(".", ","),
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
