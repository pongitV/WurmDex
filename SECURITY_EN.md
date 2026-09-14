# Security Policy [EN]

Document Language: [EN] | Idioma do Documento: [EN]
Switch Language / Alternar Idioma: [[EN] English (SECURITY_EN.md)](SECURITY_EN.md) | [[BR] Português do Brasil (SECURITY_BR.md)](SECURITY_BR.md)

---

## Supported Versions

| Version | Supported |
| --- | --- |
| 1.0.x | Yes |
| < 1.0 | No |

---

## Reporting Security Issues and Vulnerabilities

If you discover a security vulnerability or potential data privacy concern in WurmDex, please submit a detailed report via private disclosure or open an issue on the official project repository.

Please include:
- A clear description of the vulnerability and affected component.
- Steps to reproduce the issue or proof of concept.
- Expected versus actual behavior.
- Operating environment (Windows version or Android API level).

---

## Local Data Security and Privacy Model

WurmDex adopts an offline-first, local-first architecture:
- Data Residency: All user binders, cards, purchase histories, personal notes, and target prices reside exclusively in the embedded SQLite database managed through Drift ORM in private application storage.
- Network Transmission: Network requests are restricted to read-only queries against public REST endpoints (TCGdex, AwesomeAPI, pokemontcg.io) over TLS/HTTPS. No personal data or collection records are transmitted to external servers.
- Backup Integrity: Backup JSON files are strictly validated against typed schemas prior to insertion, preventing database corruption or anomalous data injection during restore operations.
