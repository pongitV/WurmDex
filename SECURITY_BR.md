# Política de Segurança [BR]

Idioma do Documento: [BR] | Document Language: [BR]
Alternar Idioma / Switch Language: [[EN] English (SECURITY_EN.md)](SECURITY_EN.md) | [[BR] Português do Brasil (SECURITY_BR.md)](SECURITY_BR.md)

---

## Versões Suportadas

| Versão | Suportada |
| --- | --- |
| 1.0.x | Sim |
| < 1.0 | Não |

---

## Notificação de Problemas de Segurança e Vulnerabilidades

Caso você identifique uma vulnerabilidade de segurança ou risco potencial à privacidade dos dados no WurmDex, envie um relatório detalhado por meio de divulgação privada ou abra uma issue no repositório oficial do projeto.

Ao reportar, favor incluir:
- Descrição clara da vulnerabilidade e do módulo afetado.
- Etapas para reproduzir o problema ou prova de conceito.
- Comportamento esperado versus comportamento observado.
- Ambiente operacional (versão do Windows ou nível da API do Android).

---

## Modelo de Segurança e Privacidade de Dados Locais

O WurmDex adota uma arquitetura estritamente orientada a dados locais (offline-first):
- Custódia de Dados: Todos os fichários, cartas registradas, históricos de compra, notas pessoais e preços-alvo ficam salvos no banco de dados SQLite embarcado, gerenciado pelo Drift ORM no armazenamento isolado do aplicativo.
- Tráfego de Rede: As requisições de rede limitam-se a consultas de leitura em endpoints REST públicos (TCGdex, AwesomeAPI, pokemontcg.io) sob criptografia TLS/HTTPS. Nenhuma informação pessoal ou registro de coleção é transmitido a servidores externos.
- Integridade de Backups: Arquivos JSON de backup são validados contra esquemas tipados antes da inserção, prevenindo corrupção do banco de dados ou injeção de dados anômalos durante a restauração.
