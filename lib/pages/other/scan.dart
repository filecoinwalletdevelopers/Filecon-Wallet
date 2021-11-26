// import 'package:fil/index.dart';
import 'package:scan/scan.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/common/index.dart';
import 'package:fil/widgets/toast.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/style.dart';

enum ScanScene { Address, PrivateKey, Mne, Connect }

class ScanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ScanPageState();
  }
}

class ScanPageState extends State<ScanPage> {
  ScanController controller = ScanController();
  StoreController controller2 = Get.find();
  final picker = ImagePicker();
  ScanScene scene;
  @override
  void initState() {
    super.initState();
    scene = Get.arguments['scene'];
  }

  Future<bool> checkScanResultBySene(String result) async {
    var valid = false;
    switch (scene) {
      case ScanScene.Address:
        valid = await isValidChainAddress(result, $store.net);
        if (!valid) {
          showCustomError('wrongAddr'.tr);
        }
        break;
      case ScanScene.PrivateKey:
        return true;
        break;
      case ScanScene.Mne:
        return true;
      case ScanScene.Connect:
        return true;
      default:
        valid = true;
    }
    return valid;
  }

  void onCapture(data){
    setState(() async {
      controller.pause();
      bool valid = await checkScanResultBySene(data);
      if (valid) {
        Get.back(result: data);
      } else {
        controller.resume();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Positioned(
            child: ScanView(
              controller: controller,
              scanAreaScale: 1,
              scanLineColor: Colors.green.shade400,
              onCapture: (data)=>{onCapture(data)},
            ),
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
          ),
          Positioned(
            top: 40,
            left: 20,
            right: 0,
            height: NavHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  alignment: NavLeadingAlign,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
