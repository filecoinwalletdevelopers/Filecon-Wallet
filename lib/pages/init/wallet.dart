import 'package:fil/index.dart';

class WalletInitPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.primary,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          child: ImageAl,
                          onTap: () {
                            Get.back();
                          },
                        )
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  ),
                  ImageFil,
                  SizedBox(
                    height: 12,
                  ),
                  CommonText(
                    'Filecoin Wallet',
                    color: Colors.white,
                    size: 20,
                    weight: FontWeight.w800,
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 85, 0, 12),
                    child: CommonText(
                      'addWallet'.tr,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  TabCard(
                    items: [
                      CardItem(
                          label: 'createWallet'.tr,
                          onTap: () {
                            Get.toNamed(createWarnPage);
                          })
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CommonText(
                    'importWallet'.tr,
                    color: Colors.white,
                    size: 14,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TabCard(
                    items: [
                      CardItem(
                          label: 'pkImport'.tr,
                          onTap: () {
                            Get.toNamed(importPrivateKeyPage);
                          }),
                      CardItem(
                          label: 'mneImport'.tr,
                          onTap: () {
                            Get.toNamed(importMnePage);
                          })
                    ],
                  ),
                ],
              ),
            ),
            Spacer(),
            CommonText(
              'v1.0.0',
              color: Colors.white,
              size: 14,
            ),
            SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}
