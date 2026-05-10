import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:solana/solana.dart' show Ed25519HDKeyPair;
import 'package:web3dart/web3dart.dart';

/// BIP-39 + BIP-32 (ETH m/44'/60'/0'/0/0) and Solana standard HD path via [Ed25519HDKeyPair].
class HdWalletDerivation {
  HdWalletDerivation._();

  static String generateMnemonic() => bip39.generateMnemonic();

  static bool isValidMnemonic(String phrase) =>
      bip39.validateMnemonic(phrase.trim());

  static Future<WalletDerivedAddresses> deriveAddresses(String mnemonic) async {
    final m = mnemonic.trim();
    final seed = bip39.mnemonicToSeed(m);
    final root = bip32.BIP32.fromSeed(seed);
    final ethChild = root.derivePath("m/44'/60'/0'/0/0");
    final ethPriv = ethChild.privateKey;
    if (ethPriv == null) {
      throw StateError('Could not derive Ethereum private key');
    }
    final cred = EthPrivateKey(Uint8List.fromList(ethPriv));
    final hex = cred.address.hex;
    final ethAddress = hex.startsWith('0x') ? hex : '0x$hex';

    final solKp = await Ed25519HDKeyPair.fromMnemonic(m);
    final solAddress = solKp.publicKey.toBase58();

    return WalletDerivedAddresses(
      ethAddress: ethAddress,
      solAddress: solAddress,
    );
  }

  static Future<Uint8List> ethPrivateKeyBytes(String mnemonic) async {
    final seed = bip39.mnemonicToSeed(mnemonic.trim());
    final root = bip32.BIP32.fromSeed(seed);
    final ethChild = root.derivePath("m/44'/60'/0'/0/0");
    final ethPriv = ethChild.privateKey;
    if (ethPriv == null) {
      throw StateError('Could not derive Ethereum private key');
    }
    return Uint8List.fromList(ethPriv);
  }
}

class WalletDerivedAddresses {
  final String ethAddress;
  final String solAddress;

  const WalletDerivedAddresses({
    required this.ethAddress,
    required this.solAddress,
  });
}
