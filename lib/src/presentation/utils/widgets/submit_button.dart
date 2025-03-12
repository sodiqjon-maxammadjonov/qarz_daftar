import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/pin/pin_bloc.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12.5),
      color: Colors.transparent,
      child: Card(
        elevation: 3,
        color: Colors.blue,
        child: InkWell(

          borderRadius: BorderRadius.circular(15), // Effekt radiusi
          splashFactory: InkRipple.splashFactory,
          splashColor: Colors.grey.withOpacity(0.3),
          onTap: () {
            context.read<PinBloc>().add(SubmitPin());
          },
          child: const Center(
            child: Icon(Icons.check, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}