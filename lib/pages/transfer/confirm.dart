import 'dart:math';
import 'package:fil/bloc/price/price_bloc.dart';
import 'package:fil/bloc/transfer/transfer_bloc.dart';
import 'package:fil/bloc/wallet/wallet_bloc.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/index.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:fil/routes/path.dart';
import 'package:oktoast/oktoast.dart';


class TransferConfirmPage extends StatefulWidget {
  @override
  State createState() => TransferConfirmPageState();
}

class TransferConfirmPageState extends State<TransferConfirmPage> {
  var nonceBoxInstance = OpenedBox.nonceInsance;
  Token token = Global.cacheToken;
  bool get isToken => token != null;
  String get title => token != null ? token.symbol : $store.net.coin;
  final EdgeInsets padding = EdgeInsets.symmetric(horizontal: 12, vertical: 14);
  ChainGas gas;
  String from = $store.wal.addr;
  String rpc = $store.net.rpc;
  String chainType = $store.net.chain;
  String to = '';
  String amount = '';
  bool loading = false;
  String prePage;
  bool isSpeedUp = false;
  List<CacheMessage> get pendingList {
    return OpenedBox.mesInstance.values
        .where((mes) =>
    mes.pending == 1 && mes.from == from && mes.rpc == rpc)
        .toList();
  }

  bool get showSpeed {
    return pendingList.isNotEmpty;
  }

  String get handlingFee {
    var fee = $store.gas.handlingFee;
    var unit = BigInt.from(pow(10, 18));
    var res = (BigInt.parse(fee)/unit).toStringAsFixed(9);
    var _handlingFee = stringCutOut(res,8);
    return _handlingFee;
  }

  @override
  void initState(){
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['to'] != null) {
        to = Get.arguments['to'];
      }
      if (Get.arguments['amount'] != null) {
        amount = Get.arguments['amount'];
      }
      if (Get.arguments['prePage'] != null) {
        prePage = Get.arguments['prePage'];
      }
      if (Get.arguments['isSpeedUp'] != null) {
        isSpeedUp = Get.arguments['isSpeedUp'];
      }

    }
  }
  @override
  Widget build(BuildContext context){
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => PriceBloc()..add(GetPriceEvent($store.net.chain))
          ),
          BlocProvider(
              create: (context) => TransferBloc()..add(
                  GetNonceEvent(rpc, chainType, from)
              )
          )
        ],
        child: BlocBuilder<TransferBloc,TransferState>(
            builder:(ctx,data){
              return BlocListener<TransferBloc,TransferState>(
                  listener: (context,state){
                    if(state.transactionHash!=''){
                      pushMsgCallBack(state.nonce,state.transactionHash);
                    }
                  },
                  child: BlocBuilder<PriceBloc,PriceState>(
                      builder:(context,state){
                        return CommonScaffold(
                          grey: true,
                          title: 'send'.tr + title,
                          footerText: 'next'.tr,
                          onPressed:(){
                            showPassDialog(context, (String pass) async {
                              try{
                                var wal = $store.wal;
                                var ck = await wal.getPrivateKey(pass);
                                pushMsg(data.nonce,ck,ctx);
                              }catch(error){
                                print('error');
                              }
                            });
                          },
                          body:_body(state)
                        );
                      }
                  )

              );
            }
        )
    );
  }
  Widget _body(state){
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Container(
                padding: padding,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText.grey(dotString(str: $store.wal.addr)),
                    Image(width: 18, image: AssetImage('icons/right-bg.png')),
                    CommonText.grey(dotString(str: to)),
                  ],
                ),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: CustomRadius.b8),
              ),
              Column(
                  children:[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText.main('amount'.tr),
                        Visibility(
                            child: CommonText(
                              getAmountUsdPrice(state.usdPrice),
                              color: CustomColor.grey,
                            ),
                          visible: state.usdPrice > 0,
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      padding: padding,
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                      child: CommonText.grey(amount+$store.net.coin),
                      decoration: BoxDecoration(
                          color: Color(0xffe6e6e6), borderRadius: CustomRadius.b8
                      ),
                    ),
                    Obx(() => SetGas(
                          maxFee: handlingFee,
                          gas: gas,
                          usdPrice:state.usdPrice
                        )
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText.main('totalPay'.tr),
                        CommonText(
                            getUsdTotalPrice(state.usdPrice),
                          color: CustomColor.grey,
                        )
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      padding: padding,
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CommonText(
                            getTotal()
                          ),
                          CommonText.grey(
                            "Amount + Gas Fee"
                          )
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Color(0xffe6e6e6), borderRadius: CustomRadius.b8
                      ),
                    ),
                  ]
              )
            ]
        )
    );
  }

  String getAmountUsdPrice(usd){
    bool isToken = token != null;
    if(isToken){
      return '';
    }else{
      var _amount = double.parse(amount);
      var usdPrice = formatDouble((usd * _amount).toStringAsFixed(2));
      String unit = '\$ ';
      return unit + usdPrice;
    }
  }

  String getUsdTotalPrice(usd){
    try{
      var _amount = double.parse(amount);
      var _fee = double.parse(handlingFee);
      String unit = '\$ ';
      var res = ((_amount + _fee)*usd).toStringAsFixed(8);
      return unit + res;
    }catch(error){
      return '';
    }
  }

  String getTotal(){
    try{
      var _amount = double.parse(amount);
      var _fee = double.parse(handlingFee);
      var total = (_amount + _fee).toString();
      return total + $store.net.coin;
    }catch(error){
      return '';
    }
  }

  bool checkGas(){
    var handlingFee = BigInt.parse($store.gas.handlingFee);
    var bigIntBalance =  BigInt.tryParse(isToken ? token.balance : $store.wal.balance);
    var bigIntAmount = BigInt.from((double.tryParse(amount) * pow(10, isToken ? token.precision : 18)));

    if (isToken) {
      var mainBigIntBalance = BigInt.parse($store.wal.balance);
      if ((bigIntAmount > bigIntBalance) || (handlingFee > mainBigIntBalance)) {
        showCustomError('errorLowBalance'.tr);
        return false;
      }
    } else {
      if (bigIntBalance < handlingFee + bigIntAmount) {
        showCustomError('errorLowBalance'.tr);
        return false;
      }
    }
    return true;
  }

  void pushMsg(int nonce,String ck,context) async {
    if (loading) {
      return;
    }
    if (!Global.online) {
      showCustomError('errorNet'.tr);
      return;
    }
    try {
      if(isSpeedUp){
        bool valid = checkGas();
        if(valid){
          pendingList.sort((a, b) {
            if (a.nonce != null && b.nonce != null) {
              return b.nonce.compareTo(a.nonce);
            } else {
              return -1;
            }
          });
          var lastMessage = pendingList.last;
          bool _isToken = lastMessage.token != null;
          BlocProvider.of<TransferBloc>(context).add(SendTransactionEvent(
              rpc,
              chainType,
              from,
              lastMessage.to,
              lastMessage.value,
              ck,
              lastMessage.nonce,
              $store.gas,
              _isToken,
              lastMessage.token
          ));
        }
      }else{
        bool valid = checkGas();
        if(valid){
          var value = getChainValue(amount, precision: token?.precision ?? 18);
          this.loading = true;
          showCustomLoading('Loading');
          var realNonce = nonce;
          var nonceKey = '$from\_${$store.net.rpc}';
          if(nonceBoxInstance.get(nonceKey) != null){
            realNonce = max(nonce, nonceBoxInstance.get(nonceKey).value);
          }
          BlocProvider.of<TransferBloc>(context).add(SendTransactionEvent(
              rpc,
              chainType,
              from,
              to,
              value,
              ck,
              realNonce,
              $store.gas,
              isToken,
              token
          ));
        }
      }

    } catch (e) {
      this.loading = false;
      dismissAllToast();
      showCustomError('sendFail'.tr);
      print(e);
    }
  }

  void pushMsgCallBack(nonce,hash){
    try{
      this.loading = false;
      var value = getChainValue(amount, precision: token?.precision ?? 18);
      var nonceKey = '$from\_${rpc}';
      var gasKey = '$from\_$nonce\_${rpc}';
      var _gas = {
        "gasLimit":$store.gas.gasLimit,
        "gasPremium":$store.gas.gasPremium,
        "gasPrice":$store.gas.gasPrice,
        "rpcType":$store.gas.rpcType,
        "gasFeeCap":$store.gas.gasFeeCap,
        "maxPriorityFee":$store.gas.maxPriorityFee,
        "maxFeePerGas":$store.gas.maxFeePerGas
      };
      ChainGas transferGas = ChainGas.fromJson(_gas);
      $store.setGas(transferGas);
      OpenedBox.gasInsance.put(gasKey, ChainGas(
          gasLimit:$store.gas.gasLimit,
          gasPremium:$store.gas.gasPremium,
          gasPrice:$store.gas.gasPrice,
          rpcType:$store.gas.rpcType,
          gasFeeCap:$store.gas.gasFeeCap,
          maxPriorityFee:$store.gas.maxPriorityFee,
          maxFeePerGas:$store.gas.maxFeePerGas
      ));
      OpenedBox.mesInstance.put(
          hash,
          CacheMessage(
              pending: 1,
              from: from,
              to: to,
              value: value,
              owner: from,
              nonce: nonce,
              hash: hash,
              rpc: rpc,
              token: token,
              gas: $store.gas,
              exitCode:-1,
              fee: $store.gas.handlingFee ?? 0,
              blockTime:
              (DateTime.now().millisecondsSinceEpoch / 1000).truncate()));
      var realNonce = nonce;
      if(nonceBoxInstance.get(nonceKey) != null){
        realNonce = nonce > nonceBoxInstance.get(nonceKey).value ? nonce : nonceBoxInstance.get(nonceKey).value;
      }
      var oldNonce = nonceBoxInstance.get(nonceKey);
      if(oldNonce != null){
        nonceBoxInstance.put(
            nonceKey, Nonce(value: realNonce + 1, time: oldNonce.time));
      }

      if (mounted) {
        goBack();
      }
    }catch(error){
      print('error');
    }
  }

  void goBack() {
    Get.offAndToNamed(walletMainPage);
    // if (prePage != walletMainPage) {
    //   Get.offAndToNamed(walletMainPage);
    // } else {
    //   Get.back();
    // }
  }

}

class SetGas extends StatelessWidget {
  final String maxFee;
  final ChainGas gas;
  final double usdPrice;
  SetGas({@required this.maxFee, this.gas,this.usdPrice});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText.main('fee'.tr),
                CommonText(
                  getUsdPrice(),
                  color: CustomColor.grey,
                )
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            decoration: BoxDecoration(
                color: Color(0xff5C8BCB), borderRadius: CustomRadius.b8),
            child: Row(
              children: [
                CommonText(
                  maxFee+$store.net.coin,
                  size: 14,
                  color: Colors.white,
                ),
                Spacer(),
                CommonText(
                  'advanced'.tr,
                  color: Colors.white,
                  size: 14,
                ),
                Image(width: 18, image: AssetImage('icons/right-w.png'))
              ],
            ),
          )
        ],
      ),
      onTap: () {
        Get.toNamed(filGasPage);
      },
    );
  }

  String getUsdPrice(){
    try{
      var _amount = double.parse(maxFee);
      var _usdPrice = (usdPrice * _amount).toStringAsFixed(8);
      String unit = '\$ ';
      return unit + _usdPrice;
    }catch(error){
      return '';
    }
  }
}

class SpeedupSheet extends StatelessWidget {
  final Noop onSpeedUp;
  final Noop onNew;
  SpeedupSheet({this.onSpeedUp, this.onNew});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonTitle(
          'sendConfirm'.tr,
          showDelete: true,
        ),
        Container(
            padding: EdgeInsets.fromLTRB(15, 15, 15, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText('hasPending'.tr),
                SizedBox(
                  height: 15,
                ),
                TapItemCard(
                  items: [
                    CardItem(
                      label: 'speedup'.tr,
                      onTap: () {
                        Get.back();
                        onSpeedUp();
                      },
                    )
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                TapItemCard(
                  items: [
                    CardItem(
                      label: 'continueNew'.tr,
                      onTap: () {
                        Get.back();
                        onNew();
                      },
                    )
                  ],
                ),
              ],
            ))
      ],
    );
  }
}
