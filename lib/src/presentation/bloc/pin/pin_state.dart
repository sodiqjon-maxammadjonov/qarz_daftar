part of 'pin_bloc.dart';

@immutable
sealed class PinState extends Equatable {
  const PinState();

  @override
  List<Object> get props => [];
}

class PinInitial extends PinState {}

class PinEntering extends PinState {
  final String enteredPin;
  final int digitCount;

  const PinEntering(this.enteredPin, this.digitCount);

  @override
  List<Object> get props => [enteredPin, digitCount];
}

class PinSubmitting extends PinState {}

class PinSuccess extends PinState {}

class PinError extends PinState {
  final String errorMessage;

  const PinError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

