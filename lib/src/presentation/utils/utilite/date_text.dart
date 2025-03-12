import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SanaText extends StatelessWidget {
  final DateTime date;
  final TextStyle? style;
  final String format;

  const SanaText({
    Key? key,
    required this.date,
    this.style,
    this.format = "dd.mm.yyyy",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(format, "uz").format(date);

    return Text(
      formattedDate,
      style: style ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
