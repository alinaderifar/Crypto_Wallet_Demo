# Crypto Wallet Demo

A **Flutter** demo of a non-custodial, multi-chain **crypto wallet** UI and app structure. It implements real navigation, local persistence, and session routing; **chain balances, signing, and broadcasts are still stubs** unless you extend the data layer (see *Current limitations*).

**Version:** 0.1.0+1  
**SDK:** Dart `>=3.8.0 <4.0.0`

---

## What it does today

### User-facing flows

| Flow | Behavior |
|------|----------|
| **Welcome** | Entry screen; routes to create or import wallet. |
| **Create wallet** | PIN + terms → persists encrypted mnemonic in **Hive** via `WalletRepository` / `WalletLocalDataSource`; marks onboarding incomplete until verify step completes. |
| **Import wallet** | Mnemonic + PIN → same persistence path; marks onboarding complete and can enter the home shell. |
| **Backup seed** | UI to review a recovery phrase (demo content unless wired to the stored mnemonic). |
| **Verify PIN** | Stub verification then `markOnboardingComplete()` and session unlock → **Home**. |
| **Home shell** | Bottom navigation: **Wallet** (dashboard), **Activity** (placeholder), **Settings** (full settings list + **Log out** clears local wallet and returns to onboarding). |
| **Wallet tab** | Balance and token rows are **placeholders**; chain chip opens network selection. |
| **Network select** | Updates selected chain in `ChainBloc` / `ChainRepository` (in-memory + config); RPC calls remain simulated. |
| **Send** | Form validation; shows a demo snackbar instead of broadcasting a transaction. |
| **Receive** | Static demo address and copy-style UI. |
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
- **Networking:** `dio` is wired in `ChainRemoteDataSource` (timeouts/headers); methods still return **stub** balances, fees, and tx hashes after short delays.
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

- **No real HD derivation** in production form — Ethereum/Solana addresses in `WalletRepositoryImpl` are still **placeholders** unless you replace `_deriveAccounts`.
- **No real RPC** — balances, fees, history, and “send” do not hit live networks in the shipped stub implementations.
- **PIN verify** on the verify screen is a **stub** (timed delay + navigate); not compared to a stored hash yet.
- **Backup phrase** may not match the stored mnemonic until you load the real phrase from secure storage into that screen.
- **`web3modal_flutter`** is noted in `pubspec.yaml` as deprecated in favor of Reown AppKit for future production work.

Treat keys and mnemonics as **sensitive** even in a demo; do not use real mainnet funds with placeholder crypto.

---

## Roadmap (short)

Planned improvements include: analyzer/theme cleanups, `NetworkInfo`-aware UI, real **testnet** read (balance) and optional send on one chain, real backup phrase wiring, PIN hash verification, and light caching — see project issues or your internal task list for **Batch 1 / 2** tracking.

---

## License / publish

`publish_to: 'none'` — adjust for your distribution model.
