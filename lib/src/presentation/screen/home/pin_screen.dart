import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qarz_daftar/src/presentation/bloc/pin/pin_bloc.dart';
import 'package:qarz_daftar/src/presentation/screen/home/home_screen.dart';
import 'package:qarz_daftar/src/core/constant/constants.dart';
import 'package:qarz_daftar/src/presentation/utils/utilite/floating_snackbar.dart';
import 'package:qarz_daftar/src/presentation/utils/widgets/backSpace_button.dart';
import 'package:qarz_daftar/src/presentation/utils/widgets/num_button.dart';
import 'package:qarz_daftar/src/presentation/utils/widgets/submit_button.dart';

class PinScreen extends StatelessWidget {
  const PinScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PinBloc, PinState>(
      listener: (context, state) {
        if (state is PinSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (state is PinError) {
          FloatingSnackbar.show(context: context, message: state.errorMessage,isError: true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(Constants.appName),
            centerTitle: true,
          ),
          body: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
              const Text(
                'PIN kodni kiriting',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildPinDisplay(state),
              const SizedBox(height: 40),
              Expanded(
                child: _buildNumPad(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPinDisplay(PinState state) {
    final digitCount = state is PinEntering ? state.digitCount : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
            (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < digitCount ? Colors.blue : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildNumPad(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.5,
      padding: const EdgeInsets.all(20),
      children: [
        ...List.generate(
          9,
              (index) => NumButton(digit: '${index + 1}',),
        ),
        BackspaceButton(),
        NumButton(digit:  '0'),
        SubmitButton(),
      ],
    );
  }


}