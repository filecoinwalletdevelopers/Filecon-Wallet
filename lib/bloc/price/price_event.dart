part of 'price_bloc.dart';

class PriceEvent {
  const PriceEvent();
}

class SetPriceEvent  extends PriceEvent {
     final String marketPrice;
     SetPriceEvent({this.marketPrice});
}

class GetPriceEvent extends PriceEvent{
  final Network net;
  GetPriceEvent({this.net});
}


