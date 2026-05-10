# Crypto Wallet Demo

A **Flutter** demo of a non-custodial, multi-chain **crypto wallet** UI and app structure. It implements real navigation, local persistence, and session routing. **Batch 2** adds BIP-39/BIP-32 address derivation, salted PIN hashing, real RPC reads (balance, fee estimate, tx history where a keyless explorer API exists), and **native EVM sends** (sign + `eth_sendRawTransaction`) on the selected EVM network (Sepolia by default). Treat as a demo, not audited wallet software (see *Current limitations*).

**Version:** 0.1.0+1  
**SDK:** Dart `>=3.8.0 <4.0.0`

---

## What it does today

### User-facing flows

| Flow | Behavior |
|------|----------|
| **Welcome** | Entry screen; routes to create or import wallet. |
| **Create wallet** | PIN + terms → generates a **BIP-39** mnemonic, encrypts it in **Hive** via `WalletRepository` / `WalletLocalDataSource`, stores a **salted PIN hash**, derives ETH/SOL addresses (BIP-32 / Solana HD); marks onboarding incomplete until verify step completes. |
| **Import wallet** | Mnemonic + PIN → same persistence path; marks onboarding complete and can enter the home shell. |
| **Backup seed** | Shows the **real** decrypted phrase for the create flow (PIN passed via `go` `extra` only during onboarding — sensitive; production should use a secure channel). |
| **Verify PIN** | Checks **PIN hash** (or legacy decrypt fallback), then `markOnboardingComplete()` and session unlock → **Home**. |
| **Home shell** | Bottom navigation: **Wallet** (dashboard), **Activity** (placeholder), **Settings** (full settings list + **Log out** clears local wallet and returns to onboarding). |
| **Wallet tab** | **Native balance** from RPC for the selected chain; recent txs from explorer API when configured (Sepolia via Blockscout); chain chip opens network selection. |
| **Network select** | Updates selected chain in **Hive** + `ChainBloc` / `ChainRepository`, then refreshes balance. |
| **Send** | **EVM**: PIN dialog → decrypt mnemonic → sign legacy transfer → `eth_sendRawTransaction`. **Non-EVM**: informational snackbar only in this build. |
| **Receive** | Address for the **current chain** from `WalletBloc` + `ChainBloc` and copy UI. |
| **Transaction detail** | Static demo layout; hash can be copied to clipboard. |
| **Settings** | Sections from the product sketch (language, security, about, etc.); most rows are placeholders except **Log out**. |

### Session and routing

- **`walletSessionNotifier`** (`ValueNotifier<bool>`) + **`GoRouter.refreshListenable`** drive redirects.
- **`WalletRepository.isSessionReady()`** is true when a wallet exists **and** onboarding is finished (`onboarding_done` in Hive). Legacy installs without that key but with a stored mnemonic are treated as onboarded.
- **Cold start:** If session is ready, onboarding routes redirect to **`/home`**.

### Architecture (high level)

- **State:** `flutter_bloc` — `AuthBloc`, `WalletBloc`, `ChainBloc`, `TransactionBloc`.
- **Routing:** `go_router` — `/onboarding/*`, `/home/*` (send, receive, chains, settings, transaction detail).
- **DI:** `get_it` — `lib/injection/service_locator.dart` (repositories, use cases, blocs).
- **Local storage:** `hive` / `hive_flutter` for wallet payload and metadata.
- **Demo crypto:** `encrypt` + `KeyManager` for AES-style encryption of the mnemonic for Hive (not a production KDF); `flutter_secure_storage` is available for future platform-keychain flows.
- **Networking:** `dio` JSON-RPC to public endpoints for **balance**, **gas price / fee estimate**, **tx list** (Blockscout-compatible API on Sepolia), and **broadcast**; `web3dart` + `http` for signing/sending.
- **Optional future stack:** `web3dart`, `solana`, `web3modal_flutter`, `local_auth` are declared dependencies; integration is mostly **TODO** in code.

### Repository / use-case shape

- **`WalletRepository`** — create/import wallet, accounts, `walletExists`, `isSessionReady`, `markOnboardingComplete`, `deleteWallet`.
- **`ChainRepository`** — selected chain, supported chains, stub `getBalance` / `sendTransaction` / `getTransactions` / `estimateFee`.
- **`AuthRepository`** — empty interface + stub impl (reserved for future auth/session work); **auth flows use wallet use cases** (`CreateWallet` / `ImportWallet` from the wallet feature).

---

## Project layout (important paths)

```
lib/
  app/                 # MaterialApp.router, theme, go_router config
  core/                # errors, network_info, security (key_manager, secure_storage), types (either)
  features/
    auth/              # onboarding pages, auth bloc, auth repository stub
    wallet/            # domain (entities, repos, use cases), data, presentation (pages, blocs)
    settings/
    shared/
  injection/           # GetIt registration
  main.dart
```

---

## Run the app

```bash
flutter pub get
flutter run
```

Use a simulator or device; portrait orientations are preferred in `main.dart`.

---

## Current limitations (demo honesty)

- **Public RPC / explorer endpoints** can rate-limit or change; failures surface as errors in the UI. **No Infura/Etherscan API keys** are bundled — mainnet tx history is limited unless you add an API base on `ChainConfig`.
- **PIN security** uses salted SHA-256 (demo-only); production wallets should use a proper KDF (e.g. Argon2) and platform secure enclaves where available.
- **Onboarding PIN in `extra`** is convenient for the backup screen but is **not** a production pattern (memory-only routing argument).
- **Solana native send** is not implemented here (read path + address derivation only).
- **`web3modal_flutter`** is noted in `pubspec.yaml` as deprecated in favor of Reown AppKit for future production work.

Treat keys and mnemonics as **sensitive** even in a demo; do not use real mainnet funds with placeholder crypto.

---

## Roadmap (short)

Further work could include Solana transfers, EIP-1559 fee UX, encrypted `extra` / in-memory vault for backup PIN handoff, explorer API keys, and light balance caching.

---

## License / publish

`publish_to: 'none'` — adjust for your distribution model.
