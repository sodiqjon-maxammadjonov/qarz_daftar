import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/pin/pin_bloc.dart';

class BackspaceButton extends StatelessWidget {
  const BackspaceButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12.5), // Yumaloq effekt uchun
      color: Colors.transparent,
      child: Card(
        child: InkWell(
          onTap: () {
            context.read<PinBloc>().add(ClearLastDigit());
          },
          borderRadius: BorderRadius.circular(15), // Effekt radiusi
          splashFactory: InkRipple.splashFactory,
          splashColor: Colors.grey.withOpacity(0.3),
          highlightColor: Colors.transparent, // Bosish effekti ko'rinmasligi uchun
          child: const Padding(
            padding: EdgeInsets.all(16.0), // Kattaroq bosish zonasi
            child: Icon(Icons.backspace, size: 24),
          ),
        ),
      ),
    );
  }
}
