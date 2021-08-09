import 'package:fil/chain/net.dart';
import 'package:fil/index.dart';

class AddressBookAddPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddressBookAddPageState();
  }
}

class AddressBookAddPageState extends State<AddressBookAddPage> {
  TextEditingController addrCtrl = TextEditingController();
  TextEditingController nameCtrl = TextEditingController();
  Wallet wallet;
  var box = OpenedBox.addressBookInsance;
  int mode = 0;
  Network net = $store.net;
  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments['mode'] != null) {
      wallet = Get.arguments['wallet'] as Wallet;
      mode = 1;
      addrCtrl.text = wallet.addr;
      nameCtrl.text = wallet.label;
    }
  }

  bool checkValid() {
    var addr = addrCtrl.text.trim();
    var name = nameCtrl.text.trim();
    if (!isValidChainAddress(addr, net)) {
      showCustomError('enterValidAddr'.tr);
      return false;
    }
    if (name == '' || name.length > 20) {
      showCustomError('enterTag'.tr);
      return false;
    }
    if (box.containsKey('${addr}_${net.rpc}') && !edit) {
      showCustomError('errorExist'.tr);
      return false;
    }
    return true;
  }

  void handleConfirm() {
    if (!checkValid()) {
      return;
    }
    if (net.rpc != $store.net.rpc) {
      showDialog();
    } else {
      confirmAdd();
    }
  }

  void confirmAdd() {
    var address = addrCtrl.text.trim();
    var label = nameCtrl.text.trim();
    if (edit) {
      box.delete(wallet.address);
    }
    box.put('${address}_${net.rpc}',
        ContactAddress(label: label, address: address, rpc: net.rpc));
    showCustomToast(!edit ? 'addAddrSucc'.tr : 'changeAddrSucc'.tr);
    Get.back();
  }

  bool get edit {
    return wallet != null;
  }

  void showDialog() {
    showCustomDialog(
        context,
        Column(
          children: [
            CommonTitle(
              '添加地址簿',
              showDelete: true,
            ),
            Container(
                child: CommonText.center(
                    '您当前在${$store.net.label}下，添加的该地址为${net.label}下，添加后需切换至${net.label}才可查看，是否继续添加'),
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                )),
            Divider(
              height: 1,
            ),
            Container(
              height: 40,
              child: Row(
                children: [
                  Expanded(
                      child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      child: CommonText(
                        'cancel'.tr,
                      ),
                      alignment: Alignment.center,
                    ),
                    onTap: () {
                      Get.back();
                    },
                  )),
                  Container(
                    width: .2,
                    color: CustomColor.grey,
                  ),
                  Expanded(
                      child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      child: CommonText(
                        'add'.tr,
                        color: CustomColor.primary,
                      ),
                      alignment: Alignment.center,
                    ),
                    onTap: () {
                      Get.back();
                      confirmAdd();
                    },
                  )),
                ],
              ),
            )
          ],
        ));
  }

  void handleScan() {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
        .then((scanResult) {
      if (scanResult != '') {
        if (isValidAddress(scanResult)) {
          addrCtrl.text = scanResult;
        } else {
          showCustomError('wrongAddr'.tr);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: !edit ? 'addAddr'.tr : 'manageAddr'.tr,
      footerText: !edit ? 'add'.tr : 'save'.tr,
      grey: true,
      onPressed: handleConfirm,
      actions: [
        Padding(
          child: GestureDetector(
              onTap: handleScan,
              child: Image(
                width: 20,
                image: AssetImage('icons/scan.png'),
              )),
          padding: EdgeInsets.only(right: 10),
        )
      ],
      body: Padding(
        child: Column(
          children: [
            NetEntranceWidget(
              net: net,
              onChange: (net) {
                setState(() {
                  this.net = net;
                });
              },
            ),
            SizedBox(
              height: 12,
            ),
            Field(
              controller: addrCtrl,
              label: 'contactAddr'.tr,
              append: GestureDetector(
                child: Image(width: 20, image: AssetImage('icons/cop.png')),
                onTap: () async {
                  var data = await Clipboard.getData(Clipboard.kTextPlain);
                  addrCtrl.text = data.text;
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Field(
              controller: nameCtrl,
              label: 'remark'.tr,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      ),
    );
  }
}
