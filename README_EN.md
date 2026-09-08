<p align="center">
  <img src="assets/icons/icon.jpg" width="120" height="120" alt="WurmDex Logo" />
</p>

# WurmDex [EN]

Pokemon TCG Collection Tracker, Virtual Binder and Financial Portfolio Engine

Document Language: [EN] | Idioma do Documento: [EN]
Switch Language / Alternar Idioma: [[EN] English (README_EN.md)](README_EN.md) | [[BR] Português do Brasil (README_BR.md)](README_BR.md)

---

## Project Specifications [EN]

- Language Identifier: [EN] (English)
- Project Purpose: Personal recreation and hobby project created strictly for fun.
- Stability Warning: This software is subject to sudden breaking changes, refactorings, and architectural revisions without prior notice.
- Supported Interface Languages: [BR] Português (Brasil) and [EN] English (United States).
- Primary Programming Languages and Frameworks: Dart 3.5+, Flutter 3.24+, C++ (Windows Desktop Runner), SQLite 3 via Drift ORM.
- Supported Operating Systems: Windows Desktop (x64, Windows 10/11), Android (API level 21+, ARM64/x86_64).
- Software License: GNU General Public License v3.0 (GPL-3.0).

---

## Legal Disclaimer and Intellectual Property Notice

WurmDex is an independent, non-commercial, open-source fan application developed strictly for educational, archival, and personal hobbyist entertainment purposes.

### Nintendo and The Pokemon Company

Pokemon, Pokemon character names, card designs, logos, symbols, and related assets are registered trademarks and copyrighted material of:
- Nintendo Co., Ltd.
- Creatures Inc.
- GAME FREAK inc.
- The Pokemon Company and The Pokemon Company International.

WurmDex is NOT affiliated with, endorsed by, sponsored by, or in any way officially associated with Nintendo, The Pokemon Company, Creatures Inc., or GAME FREAK inc. No copyright or trademark infringement is intended. All intellectual property remains the exclusive property of their respective owners.

### Third-Party Marketplaces and Data Providers

- LigaPokemon is a Brazilian marketplace platform operated by its respective owners. WurmDex provides market references and external search hyperlinks solely for user convenience under fair use principles.
- TCGPlayer is a registered trademark of TCGplayer, Inc. / eBay Inc. Marketplace URLs and quotes are utilized strictly for informational reference.
- Cardmarket is a registered trademark of Sammelkartenmarkt GmbH & Co. KG.
- TCGdex is a community-driven open-source card database.
- PokeAPI is an open-source educational Pokemon database.
- AwesomeAPI is an open financial exchange rate data provider.

WurmDex does not sell cards, does not process monetary transactions, does not display advertisements, and does not charge any access or subscription fees.

---

## Architecture and Core Capabilities

### 1. Universal Card Display Standard
Every Pokemon card across the catalog, sets, pokedex gallery, and custom collections is rendered using a standardized component (CardGridItem):
- Strict adherence to the official physical card aspect ratio of 63mm x 88mm (~0.7159) without corner clipping.
- Structured three-tier metadata hierarchy:
  - Top Line: Card Name and formatted collector identifier (e.g., Charizard-ex #199/197).
  - Middle Line: Expansion Set Name.
  - Bottom Line: Conservation Condition Badge (NM, LP, MP, HP, DMG) aligned left, paired with live Market Valuation aligned right.
- Automatic market-baseline pricing fallback derived from card rarity (Common, Uncommon, Rare, Holo, Double Rare, Ultra Rare, Special Illustration, Secret) preventing empty price indicators.

### 2. Live Pricing and Multi-Market Quotation Engine
- Dual-currency financial tracking: Brazilian Real (BRL / R$) and United States Dollar (USD / $).
- Real-time exchange rate sync via AwesomeAPI with offline cache fallback.
- Direct quote aggregation comparing LigaPokemon (domestic Brazilian market) with TCGPlayer (international market converted to BRL).
- Interactive historical price chart powered by fl_chart:
  - Strict two-decimal currency formatting (e.g., R$ 25,50 or $ 14,20) on both axis titles and interactive touch tooltips, eliminating floating-point rounding artifacts.
  - Four selectable time range filters: 1 Week (7 days), 1 Month (30 days), 1 Year (365 days), and Since Launch (All-Time).
  - Curve boundaries configured with overshoot prevention (preventCurveOverShooting) and generous vertical safety buffers to prevent line intersection with date labels.
- Dedicated Completed Purchases and Sales History inspector:
  - Displays real buyer-paid transactions distinct from asking prices.
  - Platform toggle between LigaPokemon and TCGPlayer.
  - Summary metrics: Average Paid, Lowest Paid, Highest Paid, and Transaction Count.
  - Direct external links to completed marketplace transaction listings.

### 3. Virtual Binder Mode (3D Folio)
- Realistic 3x3 binder pages (9 cards per sheet) mimicking physical trading card albums.
- Perspective camera transformation with metallic binder rings and leather margin textures.
- Card glow shaders, foil simulation, and real-time interactive gestures.

### 4. Financial Portfolio Management
- Real-time aggregation of collection value: Total Invested vs. Current Estimated Market Value.
- Unrealized Gain and Loss calculation with colored percentage indicators.
- Top 10 most valuable cards ranking.
- Distribution breakdown by condition, language, finish (Regular, Holofoil, Reverse Holo), and expansion.

### 5. Semantic Bilingual Search and Pokedex
- Cross-language search normalization (Portuguese and English).
- Support for queries by Pokemon name, national Pokedex number, card collector number, set name, artist, and rarity.
- Offline Pokedex database covering all generations with type attributes and stats.

### 6. Local-First Storage, Backup and Privacy
- Native SQLite persistence via Drift ORM with zero telemetry, analytics, or external trackers.
- All collection data remains locally on the user's device.
- Full backup export and import in JSON format compatible with native file pickers and sharing sheets.
- Merge and Replace restore options with validation to prevent data corruption.

---

## Directory Structure

```
WurmDex/
|-- android/                         # Native Android project configuration
|-- assets/
|   |-- icons/                       # Application icons (icon.jpg)
|   `-- images/                      # Static branding assets
|-- build/                           # Compilation artifacts
|-- dist/                            # Ready-to-use binaries
|   |-- windows/                     # wurmdex.exe and runtime dependencies
|   `-- android/                     # WurmDex-release.apk
|-- lib/
|   |-- core/                        # Shared utilities, database, theme, constants
|   |   |-- constants/               # Global aspect ratios, URLs, default rates
|   |   |-- database/                # Drift SQLite schema, DAOs, and migrations
|   |   |-- localization/            # AppStrings bilingual dictionary (pt-BR / en-US)
|   |   |-- navigation/              # Centralized route orchestration
|   |   |-- network/                 # Dio client with caching and retry policies
|   |   |-- providers/               # Riverpod state notifiers
|   |   |-- theme/                   # Theme engine (Dark, Light, Grass, Wurmple)
|   |   `-- widgets/                 # Universal UI components (CardGridItem, Badges)
|   `-- features/                    # Feature modules
|       |-- card_details/            # Single card viewer, pricing chart, sales modal
|       |-- catalog/                 # Search engine and card models
|       |-- collections/             # Folders, virtual binder, portfolio dashboard
|       |-- home/                    # Dashboard, news feed, price watch
|       |-- navigation/              # Main scaffold and bottom navigation bar
|       |-- pokedex/                 # Pokedex index and card gallery
|       |-- sets/                    # Expansion set explorer and completion checklist
|       |-- settings/                # Preferences, currency, themes, backup, legal
|       `-- trade/                   # Fair Trade trade balance calculator
|-- scripts/                         # Build scripts for Windows and Android
|-- test/                            # Comprehensive unit and widget test suite
|-- windows/                         # Native Windows runner (C++ / Win32)
|-- LICENSE                          # GNU General Public License v3.0
|-- pubspec.yaml                     # Project manifest and package dependencies
|-- README_BR.md                     # Documentation in Portuguese [BR]
|-- README_EN.md                     # Documentation in English [EN]
|-- SECURITY_BR.md                   # Security Policy in Portuguese [BR]
`-- SECURITY_EN.md                   # Security Policy in English [EN]
```

---

## Build and Compilation Instructions

### Prerequisites

1. Flutter SDK version 3.24.0 or higher.
2. Dart SDK version 3.5.0 or higher.
3. For Windows Desktop build:
   - Windows 10 or 11 (64-bit).
   - Visual Studio 2022 Community with the "Desktop development with C++" workload installed.
4. For Android build:
   - Android SDK (API 34) and Java Development Kit (JDK 17).

### Dependency Setup

```bash
flutter pub get
```

### Running Test Suite

Verify all unit, widget, and architecture tests before building:

```bash
flutter test
```

### Compiling for Windows Desktop

To build the optimized release binary for Windows:

```bash
flutter build windows --release
```

The output executable is generated at:
`build/windows/x64/runner/Release/wurmdex.exe`

### Compiling for Android

To build the signed release APK:

```bash
flutter build apk --release
```

The output package is generated at:
`build/app/outputs/flutter-apk/app-release.apk`

### Automation Scripts

Convenience build automation scripts are provided in the `scripts/` directory:

Using PowerShell:
```powershell
.\scripts\build.ps1 -Platform windows
.\scripts\build.ps1 -Platform apk
.\scripts\build.ps1 -Platform all
```

Using Windows Command Prompt:
```cmd
scripts\build.bat windows
scripts\build.bat apk
scripts\build.bat all
```

---

## Security and Privacy Policy

- Zero Analytics: WurmDex contains no telemetry libraries, trackers, advertising identifiers, or analytics SDKs.
- Local Storage: Your card collections, personal notes, and financial purchase prices are stored exclusively on your local device SQLite database.
- Safe Networking: Network calls utilize TLS/HTTPS endpoints exclusively for public card information, live currency exchange quotes, and official RSS feeds.
- Input Sanitization: Backup import functions perform schema validation and reject malformed or non-compliant payloads.

---

## Project Usage and Contributions

This is a personal project developed strictly for fun (hobby).

For this reason, the author does NOT seek, accept, or desire external contributions, feature requests, or pull requests.

However, you are warmly invited and encouraged to clone, fork the repository, and freely use this codebase as a foundation, inspiration, or template for your own projects under the terms of the GNU GPL-3.0 license.

