import 'dart:convert';
import 'dart:typed_data';
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/web3dart.dart';

abstract class WalletAddressService {
  String generateMnemonic();
  Future<String> getPrivateKey(String mnemonic);
  Future<EthereumAddress> getPublicKey(String privateKey);
}

class WalletAddress implements WalletAddressService {
  @override
  String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  @override
  Future<String> getPrivateKey(String mnemonic) async {
    String seed = bip39.mnemonicToSeedHex(mnemonic);
    Chain chain = Chain.seed(seed);
    ExtendedKey key = chain.forPath("m/44'/60'/0'/0/0");
    String privateKey = key.privateKeyHex().substring(2);
    return privateKey;
  }

  @override
  Future<EthereumAddress> getPublicKey(String privateKey) async {
    final private = EthPrivateKey.fromHex(privateKey);
    final address = await private.extractAddress();
    return address;
  }
}
