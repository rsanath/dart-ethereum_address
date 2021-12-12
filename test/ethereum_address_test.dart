import 'dart:typed_data';

import "package:convert/convert.dart" show hex;
import "package:ethereum_address/ethereum_address.dart";
import "package:test/test.dart";

void main() {
  group("ethereumAddressFromPublicKey", () {
    test("deriving Ethereum addresses from compressed public keys", () {
      ({
        "028a8c59fa27d1e0f1643081ff80c3cf0392902acbf76ab0dc9c414b8d115b0ab3":
            "0xD11A13f484E2f2bD22d93c3C3131f61c05E876a9",
        "024ff6fdcb22e9f6a6e2efa88df7e97120883874a6c127b0decc01be7ebfde9289":
            "0xEA6695e4F122822C51B711D0f3d6CcaF1D9F5579",
        "0360176e6591e6782fc4efdc3d0bd26882ccbb42217c6c52cb28cd75e542b8849c":
            "0x0bFD0a556b97EDf81e2ACC5fAd6d642e338AbC58",
        "03c4252fcb1ef1298b213f7158c9d53030337bff3c91865754cd8e145132dc6d53":
            "0x000bF7ebE7f830F0a682FC4d2931c12716F7ba65",
        "037d267213eaf480b638a017657b97998c8d2be26ae236fc4301c6eed756e52ce4":
            "0x0000de016A766eA5dE351835912b92696225f916"
      }).forEach((publicKey, address) {
        expect(
          ethereumAddressFromPublicKey(hex.decode(publicKey) as Uint8List),
          equals(address),
        );
      });
    });

    test("deriving Ethereum addresses from uncompressed public keys", () {
      ({
        "048a8c59fa27d1e0f1643081ff80c3cf0392902acbf76ab0dc9c414b8d115b0ab3ab95ca5cc375db4bfa147cf4c1742b67ade817160bb3a776498e8e185cb06be2":
            "0xD11A13f484E2f2bD22d93c3C3131f61c05E876a9",
        "044ff6fdcb22e9f6a6e2efa88df7e97120883874a6c127b0decc01be7ebfde9289bdc3d2656abab51f96f87507b9159844e6e5b205c348ec28717bfcfb49fea6c4":
            "0xEA6695e4F122822C51B711D0f3d6CcaF1D9F5579",
        "0460176e6591e6782fc4efdc3d0bd26882ccbb42217c6c52cb28cd75e542b8849c955e8cc1e7a811ac89673c4658883a0255927d6f85168b8b6d941f6913a2892f":
            "0x0bFD0a556b97EDf81e2ACC5fAd6d642e338AbC58",
        "04c4252fcb1ef1298b213f7158c9d53030337bff3c91865754cd8e145132dc6d5327e8f1dbc307d7b9e880dab9af3cb48153c2636c5f768b5a3d4657017c7a4035":
            "0x000bF7ebE7f830F0a682FC4d2931c12716F7ba65",
        "047d267213eaf480b638a017657b97998c8d2be26ae236fc4301c6eed756e52ce4710a85bba8972095047f10615040da9984626fa394ea3230604222629a3c28af":
            "0x0000de016A766eA5dE351835912b92696225f916"
      }).forEach((publicKey, address) {
        expect(
          ethereumAddressFromPublicKey(hex.decode(publicKey) as Uint8List),
          equals(address),
        );
      });
    });
  });

  group("checksumEthereumAddress", () {
    test("converts an address to a mixed-case checksum address", () {
      ({
        "0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed":
            "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed",
        "0xfb6916095ca1df60bb79ce92ce3ea74c37c5d359":
            "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359",
        "0xdbf03b407c01e7cd3cbea99509d93f8dddc8c6fb":
            "0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB",
        "0xd1220a0cf47c7b9be7a2e6ba89f429762e7b9adb":
            "0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb",
        "0XD1220A0CF47C7B9BE7A2E6BA89F429762E7B9ADB":
            "0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb",
        "d1220a0cf47c7b9be7a2e6ba89f429762e7b9adb":
            "0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb",
        "D1220A0CF47C7B9BE7A2E6BA89F429762E7B9ADB":
            "0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb"
      }).forEach((address, checksumAddress) {
        expect(
          checksumEthereumAddress(address),
          equals(checksumAddress),
        );
      });
    });

    test("throws an error if an invalid address is given", () {
      [
        "0x5aaeb6053f3e94c9b9a09f33669435e7ef1beae",
        "5aaeb6053f3e94c9b9a09f33669435e7ef1beae",
        "5aaeb6053f3e94c9b9a09f33669435e7ef1beaedf",
      ].forEach((address) {
        expect(
          () => checksumEthereumAddress(address),
          throwsA(
            predicate(
              (dynamic e) =>
                  e is ArgumentError &&
                  e.name == "address" &&
                  e.message == "invalid address",
            ),
          ),
        );
      });
    });
  });

  group("isValidEthereumAddress", () {
    test("rejects addresses that are too short", () {
      [
        "0x5aaeb6053f3e94c9b9a09f33669435e7ef1beae",
        "5aaeb6053f3e94c9b9a09f33669435e7ef1beae",
      ].forEach((addr) {
        expect(isValidEthereumAddress(addr), isFalse);
      });
    });

    test("rejects addresses that are too long", () {
      [
        "0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaedf",
        "5aaeb6053f3e94c9b9a09f33669435e7ef1beaedf",
      ].forEach((addr) {
        expect(isValidEthereumAddress(addr), isFalse);
      });
    });

    test("rejects addresses that are mixed-case and has invalid checksum", () {
      [
        "0x5Aaeb6053F3E94C9b9A09f33669435E7Ef1BeAed",
        "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5D359",
        "5Aaeb6053F3E94C9b9A09f33669435E7Ef1BeAed",
        "fB6916095ca1df60bB79Ce92cE3Ea74c37c5D359",
      ].forEach((addr) {
        expect(isValidEthereumAddress(addr), isFalse);
      });
    });

    test("rejects addresses with invalid characters", () {
      [
        "0x5aaeb60!3f3e94c9b9a09f33669435e7ef1beaed",
        r"0xfb6916095ca1df60bb79ce92c$3ea74c37c5d359",
        "5AAEB6053F3E94CYB9A09F33669435E7EF1BEAED",
        "fb6916095ca1df60bb79ce92ce3ea74c37c5ggzz",
      ].forEach((addr) {
        expect(isValidEthereumAddress(addr), isFalse);
      });
    });

    test("accepts addresses with valid mixed-case checksum", () {
      [
        "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed",
        "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359",
        "5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed",
        "fB6916095ca1df60bB79Ce92cE3Ea74c37c5d359",
      ].forEach((addr) {
        expect(isValidEthereumAddress(addr), isTrue);
      });
    });

    test("accepts addresses that are not mixed-case", () {
      [
        "0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed",
        "0xfb6916095ca1df60bb79ce92ce3ea74c37c5d359",
        "0X5AAEB6053F3E94C9B9A09F33669435E7EF1BEAED",
        "5aaeb6053f3e94c9b9a09f33669435e7ef1beaed",
        "fb6916095ca1df60bb79ce92ce3ea74c37c5d359",
        "5AAEB6053F3E94C9B9A09F33669435E7EF1BEAED",
      ].forEach((addr) {
        expect(isValidEthereumAddress(addr), isTrue);
      });
    });
  });
}
