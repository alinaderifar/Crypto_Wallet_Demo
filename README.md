# Crypto Wallet Demo

A **Flutter** demo of a non-custodial, multi-chain **crypto wallet** UI and app structure. It implements real navigation, local persistence, session routing, and a thin chain layer on public RPCs. **BIP-39/BIP-32** derivation, salted PIN hashing, connectivity-aware UI, and **native EVM sends** (sign + `eth_sendRawTransaction`) are wired for the selected EVM network (**Sepolia** by default for new wallets). Treat as a demo, not audited wallet software (see *Current limitations*).

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
| **Offline** | Global banner when connectivity is unavailable; send is disabled when offline. |

### Session and routing

- **`walletSessionNotifier`** (`ValueNotifier<bool>`) + **`GoRouter.refreshListenable`** drive redirects.
- **`WalletRepository.isSessionReady()`** is true when a wallet exists **and** onboarding is finished (`onboarding_done` in Hive). Legacy installs without that key but with a stored mnemonic are treated as onboarded.
- **Cold start:** If session is ready, onboarding routes redirect to **`/home`**.

### Architecture (high level)

- **State:** `flutter_bloc` — `AuthBloc`, `WalletBloc`, `ChainBloc`, `TransactionBloc`, `ConnectivityCubit`.
- **Routing:** `go_router` — `/onboarding/*`, `/home/*` (send, receive, chains, settings, transaction detail).
- **DI:** `get_it` — `lib/injection/service_locator.dart` (repositories, use cases, blocs). **`Hive.initFlutter()`** runs before the wallet box opens.
- **Local storage:** `hive` / `hive_flutter` for wallet payload and metadata (no `hive_generator`; add it back only if you introduce `@HiveType` adapters and align versions with `freezed` / `analyzer`).
- **Crypto:** `bip39` / `bip32` / `solana` (HD addresses), `encrypt` + `KeyManager` for AES-style mnemonic encryption in Hive (not a production KDF), salted PIN hash in Hive (`pin_hashing.dart`).
- **Networking:** `dio` JSON-RPC to public endpoints for **balance**, **gas price / fee estimate**, **tx list** (Blockscout-compatible API on Sepolia), and **broadcast**; `web3dart` + `http` for signing/sending; `connectivity_plus` for reachability.
- **UI:** `google_fonts` (Inter), `AppTheme` + `AppPalette` for light/dark surfaces and responsive horizontal padding.
- **Declared but mostly unwired:** `web3modal_flutter` (WalletConnect), `local_auth` (biometrics), `flutter_animate` / `shimmer` / `cached_network_image` (polish).

### Supported networks (in-app)

Sepolia (default for new wallets), Ethereum mainnet, Polygon, Solana mainnet — see `ChainConfig.supportedChains`. Tx history via explorer API is configured for **Sepolia**; other EVM chains may return empty history unless you set `accountExplorerApiBase` on `ChainConfig`.

### Repository / use-case shape

- **`WalletRepository`** — create/import wallet, accounts, `walletExists`, `isSessionReady`, `markOnboardingComplete`, `deleteWallet`, `verifyPin`, `unlockMnemonic`.
- **`ChainRepository`** — persisted selected chain, supported chains, `getBalance`, `getTransactions`, `estimateFee`, `broadcastSignedEvmTx` (direct `sendTransaction` is not the primary path).
- **`SendNativeEth`** — build/sign/broadcast native EVM transfer using decrypted mnemonic + selected RPC.
- **`AuthRepository`** — stub impl (reserved); onboarding auth uses wallet use cases **`CreateWallet`** / **`ImportWallet`**.

---

## Project layout (important paths)

```
lib/
  app/                 # MaterialApp.router, theme (AppTheme, AppPalette), go_router
  core/                # crypto (HD derivation), errors, network (connectivity, offline banner), security, types
  features/
    auth/              # onboarding pages, auth bloc, auth repository stub
    wallet/            # domain (entities, repos, use cases), data, presentation (pages, blocs)
    settings/
    shared/
  injection/           # GetIt registration
  main.dart
test/                  # unit + widget tests (connectivity, pin hash, either, offline banner)
.github/workflows/     # CI: analyze, test, Android/iOS/web build
```

---

## Run the app

```bash
flutter pub get
flutter run
```

Use a simulator or device; portrait orientations are preferred in `main.dart`.

### Quality checks

```bash
flutter analyze
flutter test
```

CI (`.github/workflows/ci.yml`) uses **Flutter 3.35.4** (Dart ≥3.8) so it matches `pubspec.yaml` `environment.sdk`. It runs analyze, tests with coverage, and release builds for Android, iOS, and web on push/PR.

---

## Current limitations (demo honesty)

- **Public RPC / explorer endpoints** can rate-limit or change; failures surface as errors in the UI. **No Infura/Etherscan API keys** are bundled — mainnet tx history is limited unless you add an API base on `ChainConfig`.
- **PIN security** uses salted SHA-256 (demo-only); production wallets should use a proper KDF (e.g. Argon2) and platform secure enclaves where available.
- **Onboarding PIN in `extra`** is convenient for the backup screen but is **not** a production pattern (memory-only routing argument).
- **Solana native send** is not implemented here (read path + address derivation only).
- **Activity tab**, **WalletConnect**, **biometrics**, and many **settings** rows remain placeholders.
- **`web3modal_flutter`** is noted in `pubspec.yaml` as deprecated in favor of Reown AppKit for future production work.

Treat keys and mnemonics as **sensitive** even in a demo; prefer **testnet** funds for experiments and avoid mainnet value you cannot afford to lose.

---

## Roadmap (short)

Further work could include Solana transfers, EIP-1559 fee UX, encrypted `extra` / in-memory vault for backup PIN handoff, explorer API keys, light balance caching, and wiring WalletConnect / biometrics.

---

## License / publish

`publish_to: 'none'` — adjust for your distribution model.
