import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NumberText extends StatelessWidget {
  final int number;
  final TextStyle? style;

  const NumberText({
    super.key,
    required this.number,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final formattedNumber = NumberFormat("#,###", "en_US").format(number).replaceAll(",", " ");

    return Text(
      formattedNumber,
      style: style ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
