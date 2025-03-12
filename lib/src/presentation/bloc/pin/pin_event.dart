part of 'pin_bloc.dart';

@immutable
sealed class PinEvent extends Equatable {
  const PinEvent();

  @override
  List<Object> get props => [];
}

class EnterPinDigit extends PinEvent {
  final String digit;

  const EnterPinDigit(this.digit);

  @override
  List<Object> get props => [digit];
}

class ClearPin extends PinEvent {}

class ClearLastDigit extends PinEvent {}

class SubmitPin extends PinEvent {}

