import 'package:fil/index.dart';

Future<String> initSharedPreferences() async {
  var initialRoute = mainPage;
  var instance = await SharedPreferences.getInstance();
  Global.store = instance;

  /// If the the app was opened for the first time, English is preferred.
  /// If there is a cached lang code in device, set language to that
  var langCode = instance.getString(StoreKeyLanguage);
  if (langCode != null) {
    Global.langCode = langCode;
  } else {
    Global.langCode = 'en';
  }
  var box = Hive.box<Wallet>(addressBox);
  var activeWalletAddr = instance.getString('currentWalletAddress');
  var wcSession = instance.getString('wcSession');
  if (wcSession == null) {
    instance.setString('wcSession', '');
  } else {
    Global.wcSession = wcSession;
  }
  if (activeWalletAddr != null) {
    var wal = box.get(activeWalletAddr);
    if (wal == null) {
      initialRoute = initLangPage;
    } else {
      singleStoreController.setWallet(wal);
    }
  } else {
    initialRoute = initLangPage;
  }
  return initialRoute;
}
