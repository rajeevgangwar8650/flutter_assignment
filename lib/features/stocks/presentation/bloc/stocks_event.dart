import 'package:equatable/equatable.dart';

abstract class StocksEvent extends Equatable {
  const StocksEvent();

  @override
  List<Object?> get props => [];
}

class GetStocksEvent extends StocksEvent {
  const GetStocksEvent();
}
