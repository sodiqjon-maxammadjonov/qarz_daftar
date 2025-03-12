import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'pin_event.dart';
part 'pin_state.dart';

class PinBloc extends Bloc<PinEvent, PinState> {
  static const String correctPin = '1797'; // To'g'ri PIN kod

  PinBloc() : super(PinInitial()) {
    on<EnterPinDigit>(_onEnterPinDigit);
    on<ClearPin>(_onClearPin);
    on<ClearLastDigit>(_onClearLastDigit);
    on<SubmitPin>(_onSubmitPin);
  }

  void _onEnterPinDigit(EnterPinDigit event, Emitter<PinState> emit) {
    final currentState = state;

    if (currentState is PinEntering) {
      if (currentState.digitCount < 4) {
        final newPin = currentState.enteredPin + event.digit;
        emit(PinEntering(newPin, newPin.length));
      }
    } else {
      emit(PinEntering(event.digit, 1));
    }
  }

  void _onClearPin(ClearPin event, Emitter<PinState> emit) {
    emit(PinInitial());
  }

  void _onClearLastDigit(ClearLastDigit event, Emitter<PinState> emit) {
    final currentState = state;

    if (currentState is PinEntering && currentState.enteredPin.isNotEmpty) {
      final newPin = currentState.enteredPin.substring(0, currentState.enteredPin.length - 1);
      if (newPin.isEmpty) {
        emit(PinInitial());
      } else {
        emit(PinEntering(newPin, newPin.length));
      }
    }
  }

  void _onSubmitPin(SubmitPin event, Emitter<PinState> emit) async {
    final currentState = state;

    if (currentState is PinEntering) {
      emit(PinSubmitting());

      await Future.delayed(const Duration(milliseconds: 300)); // Simulyatsiya qilingan tekshirish vaqti

      if (currentState.enteredPin == correctPin) {
        emit(PinSuccess());
      } else {
        emit(const PinError('Noto\'g\'ri PIN kod!'));
        await Future.delayed(const Duration(seconds: 1));
        emit(PinInitial());
      }
    }
  }
}