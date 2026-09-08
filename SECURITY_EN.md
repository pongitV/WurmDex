# Security Policy [EN]

Document Language: [EN] | Idioma do Documento: [EN]
Switch Language / Alternar Idioma: [[EN] English (SECURITY_EN.md)](SECURITY_EN.md) | [[BR] Português do Brasil (SECURITY_BR.md)](SECURITY_BR.md)

## Supported Versions

| Version | Supported |
| --- | --- |
| 1.0.x | Yes |
| < 1.0 | No |

## Reporting Security Issues and Vulnerabilities

If you discover a security vulnerability or potential data privacy concern in WurmDex, please submit a detailed report via private disclosure or open an issue on the project GitHub repository.

Please include:
- A clear description of the vulnerability and affected component.
- Reproduction steps or proof of concept.
- Expected versus actual behavior.
- Operating system environment (Windows version or Android API level).

## Local Data Security Model

WurmDex adopts an offline-first, local-first architecture:
- Data Residency: All user binders, cards, purchase histories, and target prices reside locally in an embedded SQLite database managed through Drift ORM.
- Network Transmission: Network requests are restricted to read-only queries against public REST endpoints (TCGdex, AwesomeAPI, pokemontcg.io) over TLS/HTTPS.
- Backup Integrity: Backup JSON files are strictly parsed with typed schemas to prevent arbitrary code execution or database corruption during restore operations.
