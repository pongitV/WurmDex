<p align="center">
  <img src="assets/icons/icon.jpg" width="120" height="120" alt="WurmDex Logo" />
</p>

# WurmDex [EN]

Pokemon TCG Collection Tracker, Virtual Binder, Trade Evaluator, and Financial Portfolio Engine

Document Language: [EN] | Idioma do Documento: [EN]
Switch Language / Alternar Idioma: [[EN] English (README_EN.md)](README_EN.md) | [[BR] Português do Brasil (README_BR.md)](README_BR.md)

---

## Project Specifications [EN]

- Language Identifier: [EN] (English)
- Project Purpose: Personal recreation and hobby project created strictly for fun.
- Stability Warning: This software is designed for study and personal leisure, subject to structural refactoring and architectural updates without prior notice.
- Supported Interface Languages: [BR] Português (Brasil) and [EN] English (United States).
- Core Technologies: Dart 3.5+, Flutter 3.24+, C++ (Windows Desktop Native Runner), SQLite 3 via Drift ORM, Dio, and Riverpod.
- Supported Platforms: Windows Desktop (x64, Windows 10/11) and Android (API level 21+, ARM64/x86_64).
- Software License: GNU General Public License v3.0 (GPL-3.0).

---

## Pre-compiled Releases (Download)

Ready-to-run release packages are available directly from the repository `dist/` directory:

- **Android (APK)**: [`dist/android/WurmDex-release.apk`](dist/android/WurmDex-release.apk)
- **Windows Desktop (EXE)**: [`dist/windows/wurmdex.exe`](dist/windows/wurmdex.exe) (run directly from the `dist/windows` directory, containing all bundled dependencies and DLLs for standalone execution)

---

## Legal Disclaimer and Intellectual Property Notice

WurmDex is an independent, non-commercial, open-source fan application developed strictly for educational, archival, and personal collector entertainment purposes.

### Nintendo and The Pokemon Company

Pokemon, Pokemon character names, card designs, illustrations, logos, symbols, and related brand assets are registered trademarks and copyrighted material of:
- Nintendo Co., Ltd.
- Creatures Inc.
- GAME FREAK inc.
- The Pokemon Company and The Pokemon Company International.

WurmDex is not affiliated with, endorsed by, approved by, or in any way officially associated with Nintendo, The Pokemon Company, Creatures Inc., or GAME FREAK inc. No copyright or trademark infringement is intended. All intellectual property remains the exclusive property of their respective owners.

### Third-Party Marketplaces and Data Providers

- LigaPokemon is a Brazilian trading card marketplace operated by its respective owners. WurmDex provides market references and external search hyperlinks solely for user convenience under fair use principles.
- TCGPlayer is a registered trademark of TCGplayer, Inc. / eBay Inc. Marketplace quotes in USD and external hyperlinks are utilized strictly for informational reference.
- Cardmarket is a registered trademark of Sammelkartenmarkt GmbH & Co. KG.
- TCGdex is an open-source, community-driven Pokemon card database.
- PokeAPI is an open-source educational Pokemon database.
- AwesomeAPI is an open financial service for foreign exchange rate queries.

### Visual Identity and Application Assets

The application icon, official WurmDex mascot, and graphical interface elements are original community creations, completely free of proprietary sprites, corporate logos, or trademarked graphics as identifiers for the Windows executable (.EXE) or Android package (.APK).

WurmDex does not sell physical products, does not process monetary transactions, does not display advertisements, and does not charge any access fees or subscriptions.

---

## Architecture and Core Capabilities

### 1. Universal Card Display Standard
Every Pokemon card rendered across the catalog, expansions, pokedex gallery, custom collections, and wishlist uses the standardized component `CardGridItem`:
- Strict compliance with official physical card dimensions of 63mm x 88mm (~0.7159), displaying the full card without corner clipping or visual distortions (BoxFit.contain).
- Three-tier vertical metadata structure:
  - Top: Card Name and formatted collector identifier (e.g., Charizard-ex #199/197).
  - Middle: Official expansion set name.
  - Bottom: Condition Badge (NM, SP, MP, HP, DMG) aligned left, paired with live market valuation aligned right.
- Automatic baseline valuation derived from card rarity (Common, Uncommon, Rare, Holo, Double Rare, Ultra Rare, Special Illustration, Hyper Rare) when API summary listings lack immediate pricing, preventing empty indicators.

### 2. Multi-Market Real-Time Pricing Engine
- Native support for Brazilian Real (BRL / R$) and United States Dollar (USD / $).
- Real-time foreign exchange rate synchronization via AwesomeAPI with offline cache fallback.
- Authentic LigaPokemon pricing centered on Preço Médio (average price) as the primary market benchmark.
- Condition-specific valuations (Near Mint, Slightly Played, Moderately Played, Heavily Played, Damaged) parsed directly from LigaPokemon marketplace listings and offers tables without arbitrary percentage scaling or artificial multiplier formulas.
- Interactive historical price chart powered by fl_chart:
  - Strict currency formatting with two decimal places on all axis labels and touch tooltips.
  - 4 selectable timeframes: 1 Week (7 days), 1 Month (30 days), 1 Year (365 days), and All-Time history.
  - Cubic curve overshoot prevention (preventCurveOverShooting) with safe vertical margins to avoid overlap with date labels.
- Dedicated Completed Sales and Purchases Inspector:
  - Displays verified buyer-paid transactions distinct from listed asking prices.
  - Aggregated metrics: Average Paid, Lowest Paid, Highest Paid, and Transaction Count.
  - External shortcuts to verify transaction records in the default web browser.

### 3. Fair Trade Evaluator
- Comprehensive trade balancing workbench comparing two sides: "You Give" (Your Cards) versus "You Receive" (Their Cards).
- Dynamic valuation calculation, net value difference, and objective trade verdict (Balanced/Fair Trade, Advantageous to You, or Unfavorable to You).
- **Clickable Card Title**: Tapping the card name or collector number on any trade card opens the complete catalog card details screen (`CardDetailsScreen`), providing high-resolution art, live LigaPokemon quotes, charts, and sales history.
- **Interactive Condition Selector**: Dedicated dropdown for each card (Near Mint, Slightly Played, Moderately Played, Heavily Played, Damaged) that dynamically recalculates value based on authentic LigaPokemon prices for that specific condition.
- **Custom Price Editing**: Tap directly on the card valuation to enter an agreed custom price.
- **Average Price Refresh**: Top bar action button to re-fetch live Preço Médio quotes across all trade cards directly from LigaPokemon.
- **Filter and Sorting Controls**: Filter views (All Cards, Your Cards Only, Received Cards Only) and sort cards by Highest Value, Lowest Value, or Name (A-Z).
- **Clipboard Summary Export**: One-tap quick action to copy a formatted text summary of the trade to the system clipboard.

### 4. 3D Virtual Binder (Virtual Binder Mode)
- 9-pocket page grid (3x3), reproducing the tactile feel of physical trading card albums.
- Page turn transitions featuring metallic rings, leather border textures, and smooth page flipping.
- Real-time foil reflection shaders over holographic cards with interactive gesture manipulation.

### 5. Financial Portfolio and Collection Management
- Aggregated collection valuation: Total Invested (recorded acquisition cost basis) versus Current Market Value.
- Continuous calculation of unrealized Gain or Loss with color-coded percentage indicators.
- Top 10 most valuable cards ranking.
- Analytical distribution breakdowns by condition, card language, finish (Regular, Holofoil, Reverse Holo), and expansion.
- Unlimited custom folder and binder creation with acquisition cost tracking.

### 6. LigaPokemon Price Radar (Sealed Products and Singles)
- Continuous monitoring of products registered via direct LigaPokemon URLs.
- Real-time detection of in-stock availability, lowest offered price, store seller names, and pre-order indicators.
- Automated local operating system notifications when listings enter target price ranges.
- Single-item or bulk price checks with status messages reflecting average market price updates.
- One-tap button to open the original listing in the default web browser.

### 7. Wishlist & Target Price Alerts
- Track desired cards with customized target price ranges (minimum and maximum price) and desired condition.
- Dynamic comparison between target budgets and real-time market valuations.
- Thematic folder organization and quick filtering by price status.

### 8. Semantic Bilingual Search & WorldDex
- Cross-language search normalization between English and Portuguese.
- Flexible queries by Pokemon name, national/world catalog number, card number, expansion name, artist, and rarity.
- Complete offline WorldDex covering all 9 generations with type effectiveness, weaknesses, and card release galleries.

### 9. Local-First Storage, Backup and Privacy
- 100% offline-capable storage using an embedded SQLite database managed via Drift ORM.
- Zero analytics, telemetry SDKs, behavioral tracking, or cookies.
- Comprehensive backup export and import in JSON format compatible with native system file managers.
- Restore modes for Merge or Total Replacement with schema validation to prevent data corruption.

### 10. Unified Navigation & Session Persistence
- Ergonomic 4-button bottom navigation dock (Catalog, Liga Radar, Collections, More) identical across Windows Desktop and Android.
- Stylized "More Features" menu for rapid access to WorldDex, Set Checklists, Wishlist, Trade Evaluator, and Settings.
- Full session persistence: selected visual theme, active language, and display preferences are automatically restored on launch.

### 11. Custom Visual Themes & Integrated Clicker Mini-Games
- Built-in visual themes: Dark Mode (Default), Antique Book Page Light, Botanical Grass, Wurmple Coral, Oceanic Lugia (#249), Shiny Wurmple (#265), Shiny Lugia (#249), and Secret Dark Lugia (Shadow XD001, unlocked by creating a collection named "DarkLugia").
- Incremental clicker mini-games for multiple Pokemon (Wurmple, Lugia, Dark Lugia) featuring upgrade progression and points shops to unlock exclusive themes:
  - **Wurmple Clicker**: Full-screen mini-game with Swarm upgrades, particle animations, and a points shop to unlock the Shiny Wurmple Theme (#265).
  - **Lugia Clicker**: Aerodynamic mini-game activated by the dynamic Lugia mascot icon, unlocking the Shiny Lugia Theme (#249).
  - **Dark Lugia Clicker**: Secret shadow-themed mini-game activated by creating the "DarkLugia" collection.
  - **Extra Themes Manager in Settings**: Passcode "011" protected panel allowing users to unlock or lock extra themes via dropdown on demand.

---

## Directory Structure

```
WurmDex/
|-- android/                         # Native Android platform configuration
|-- assets/
|   |-- icons/                       # Application icons (icon.jpg)
|   `-- images/                      # Static branding assets and illustrations
|-- build/                           # Compilation artifacts
|-- dist/                            # Pre-compiled release distribution packages
|   |-- windows/                     # wurmdex.exe and Win32 runtime dependencies
|   `-- android/                     # WurmDex-release.apk
|-- lib/
|   |-- core/                        # Shared modules, database, themes, and constants
|   |   |-- constants/               # Card aspect ratios, official URLs, default parameters
|   |   |-- database/                # SQLite schemas, DAOs, and Drift ORM migrations
|   |   |-- localization/            # Bilingual localization dictionary (pt-BR / en-US)
|   |   |-- navigation/              # Centralized route orchestration (AppNavigator)
|   |   |-- network/                 # Dio HTTP client with caching and retry policies
|   |   |-- providers/               # Riverpod reactive state providers
|   |   |-- theme/                   # Theme engine and color schemes
|   |   `-- widgets/                 # Universal UI components (CardGridItem, Badges)
|   `-- features/                    # Functional application modules
|       |-- card_details/            # Single card view, historical price chart, sales sheet
|       |-- catalog/                 # Search engine and card catalog
|       |-- collections/             # Virtual binders, folders, financial dashboard
|       |-- easter_egg/              # Clicker mini-games and secret theme management
|       |-- home/                    # Main dashboard, TCG news feed, market alerts
|       |-- monitoring/              # LigaPokemon Price Radar and product watcher
|       |-- navigation/              # Main scaffold and bottom navigation dock
|       |-- pokedex/                 # Pokedex index and species gallery
|       |-- sets/                    # Expansion set explorer and master set checklist
|       |-- settings/                # Preferences, currency, JSON backup, legal notices
|       |-- trade/                   # Fair Trade trade balance calculator
|       `-- wishlist/                # Wishlist with target price alert tracking
|-- scripts/                         # Build automation scripts for Windows and Android
|-- test/                            # Comprehensive automated unit and widget test suite
|-- windows/                         # Native Windows C++ runner (Win32)
|-- LICENSE                          # GNU General Public License v3.0
|-- pubspec.yaml                     # Flutter package manifest and dependencies
|-- README_BR.md                     # Full documentation in Portuguese [BR]
|-- README_EN.md                     # Full documentation in English [EN]
|-- README.md                        # Root repository overview
|-- SECURITY_BR.md                   # Security and privacy policy in Portuguese [BR]
`-- SECURITY_EN.md                   # Security and privacy policy in English [EN]
```

---

## Build and Compilation Instructions

### Environment Prerequisites

1. Flutter SDK version 3.24.0 or higher.
2. Dart SDK version 3.5.0 or higher.
3. For Windows Desktop builds:
   - Windows 10 or Windows 11 (64-bit).
   - Visual Studio 2022 Community with the "Desktop development with C++" workload installed.
4. For Android builds:
   - Android SDK (API 34) and Java Development Kit (JDK 17).

### Dependency Setup

```bash
flutter pub get
```

### Running Automated Tests

Run the complete test suite covering unit, widget, and integration tests:

```bash
flutter test
```

### Compiling for Windows Desktop

Generate the optimized 64-bit release executable for Windows:

```bash
flutter build windows --release
```

The output binary is generated at:
`build/windows/x64/runner/Release/wurmdex.exe`

### Compiling for Android

Generate the release APK package:

```bash
flutter build apk --release
```

The output package is generated at:
`build/app/outputs/flutter-apk/app-release.apk`

### Automation Scripts

Convenience build automation scripts are located in the `scripts/` directory:

Using PowerShell:
```powershell
.\scripts\build.ps1 -Target windows
.\scripts\build.ps1 -Target apk
.\scripts\build.ps1 -Target all
```

Using Windows Command Prompt (CMD):
```cmd
scripts\build.bat windows
scripts\build.bat apk
scripts\build.bat all
```

---

## Security and Privacy Policy

- Zero Analytics: WurmDex contains no telemetry libraries, trackers, advertising identifiers, or analytics SDKs.
- Local Storage: Your card collections, personal notes, and financial purchase prices reside exclusively in your local device SQLite database.
- Safe Networking: Network requests utilize TLS/HTTPS encrypted connections exclusively for public card data, live currency rates, and news feeds.
- Input Sanitization: The backup restore routine parses structured JSON schemas and rejects malformed or corrupted data files.

---

## Project Usage and Contributions

This is a personal hobby project developed strictly for fun.

For this reason, the author does not seek, accept, or review external contributions, feature requests, or pull requests.

However, you are warmly invited and encouraged to clone, fork the repository, and freely use this codebase as a foundation, inspiration, or template for your own independent projects under the terms of the GNU General Public License v3.0.
