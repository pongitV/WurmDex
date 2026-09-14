<p align="center">
  <img src="assets/icons/icon.jpg" width="120" height="120" alt="WurmDex Logo" />
</p>

# WurmDex

Pokemon TCG Collection Tracker, Virtual Binder, Trade Evaluator, and Financial Portfolio Engine for Windows Desktop and Android.

Languages / Idiomas: [[EN] English (README_EN.md)](README_EN.md) | [[BR] Portugues do Brasil (README_BR.md)](README_BR.md)

---

## Overview

WurmDex is an open-source, local-first portfolio manager and collection tracker for the Pokemon Trading Card Game (TCG). Built with Flutter, Dart, C++, and SQLite, it offers an authentic market analysis workflow tailored for collectors, traders, and competitive players.

### Core Features

- **Authentic Multi-Market Pricing**: Direct pricing from LigaPokemon (BRL) and TCGPlayer (USD) with real-time currency conversion via AwesomeAPI. Primary reference values are centered on the Preço Médio (average price) and authentic condition quotes directly from marketplace offers without artificial multiplier formulas.
- **Fair Trade Evaluator**: Comprehensive trade balancing tool comparing total market values for two parties. Features clickable card titles opening full catalog card details, condition-specific pricing (Near Mint, Slightly Played, Moderately Played, Heavily Played, Damaged), custom price editing, live average price refresh, filtering, and formatted clipboard summary export.
- **LigaPokemon Price Radar**: Continuous price monitoring for singles and sealed products entered via LigaPokemon URLs, with automated detection of in-stock deals, store identifiers, pre-order status, and target price alerts.
- **Wishlist & Target Price Alerts**: Track cards with custom target prices, condition preferences, and dedicated folder organization.
- **Collection & Folder Management**: Organize cards across custom binders and folders with condition tracking, finishes (Foil, Reverse Holo, Regular), and recorded acquisition costs.
- **Interactive 3x3 Virtual Binder**: Realistic 9-pocket page binder experience with smooth double-page spread navigation and simulated illumination.
- **Card Details & Market Analytics**: High-resolution card views, interactive price history charts across multiple timeframes (7 days, 30 days, 365 days, and all-time), recent verified sales data, and marketplace external shortcuts.
- **WorldDex & Expansions**: Comprehensive species database covering all generations alongside full TCG set checklists with master set progress statistics.
- **Unified Navigation & Session Persistence**: Ergonomic four-button bottom dock (Catalog, Liga Radar, Collections, More) with full session persistence for active themes, language, and display settings across restarts.
- **Custom Visual Themes & Clicker Mini-Games**: Dark Mode, Antique Book Page Light, Botanical Grass, Wurmple Coral, Oceanic Lugia (#249), Shiny Wurmple (#265), Shiny Lugia (#249), and Secret Dark Lugia (Shadow XD001). Includes integrated clicker progression mini-games and an extra theme manager in Settings.
- **Local-First Architecture & Privacy**: Fully offline-capable SQLite database (via Drift ORM), zero telemetry or tracking, and full JSON backup and restore capabilities.

---

## Pre-compiled Releases (Download)

Ready-to-run binaries are available directly from the repository `dist/` directory:

- **Android (APK)**: [`dist/android/WurmDex-release.apk`](dist/android/WurmDex-release.apk)
- **Windows Desktop (EXE)**: [`dist/windows/wurmdex.exe`](dist/windows/wurmdex.exe) (run directly from the `dist/windows` directory with bundled runtime libraries)

---

## Documentation

Comprehensive documentation is provided in both languages:

- [English Documentation (README_EN.md)](README_EN.md)
- [Documentacao em Portugues do Brasil (README_BR.md)](README_BR.md)
- [Security Policy [EN] (SECURITY_EN.md)](SECURITY_EN.md)
- [Politica de Seguranca [BR] (SECURITY_BR.md)](SECURITY_BR.md)

---

## Project Purpose and Code Usage

WurmDex is a personal hobby project developed strictly for recreation and educational study.

- The software is subject to refactoring, architectural revisions, and updates without prior notice.
- The author does not seek, accept, or review external contributions, pull requests, or feature requests.
- You are welcome to clone, fork, and adapt this repository as a learning reference, foundation, or template for your own independent projects under the terms of the GNU General Public License v3.0.

---

## Legal Notice and Intellectual Property

WurmDex is an independent, non-commercial fan application developed for educational, archival, and personal entertainment purposes.

- Pokemon and all related character names, marks, card artwork, symbols, and logos are registered trademarks and copyrights of Nintendo Co., Ltd., Creatures Inc., GAME FREAK inc., and The Pokemon Company.
- WurmDex is not affiliated with, endorsed by, or sponsored by Nintendo, Creatures Inc., GAME FREAK inc., or The Pokemon Company.
- Market data from LigaPokemon, TCGPlayer, Cardmarket, TCGdex, and PokeAPI are utilized strictly for informational and reference purposes under fair use principles.
- Application icons, mascot illustrations, and user interface styling are original community creations, ensuring full compliance without using proprietary sprites or corporate trademarks as application identity.

---

## License

This project is licensed under the terms of the [GNU General Public License v3.0](LICENSE).
