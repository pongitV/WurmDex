# Política de Segurança [BR]

Idioma do Documento: [BR] | Document Language: [BR]
Alternar Idioma / Switch Language: [[EN] English (SECURITY_EN.md)](SECURITY_EN.md) | [[BR] Português do Brasil (SECURITY_BR.md)](SECURITY_BR.md)

## Versões Suportadas

| Versão | Suportada |
| --- | --- |
| 1.0.x | Sim |
| < 1.0 | Não |

## Notificação de Problemas de Segurança e Vulnerabilidades

Caso você identifique uma vulnerabilidade de segurança ou risco potencial à privacidade dos dados no WurmDex, envie um relatório detalhado por meio de divulgação privada ou abra uma issue no repositório do projeto no GitHub.

Ao reportar, favor incluir:
- Descrição clara da vulnerabilidade e do módulo afetado.
- Etapas para reproduzir o problema ou prova de conceito.
- Comportamento esperado versus comportamento observado.
- Ambiente operacional (versão do Windows ou nível da API do Android).

## Modelo de Segurança de Dados Locais

O WurmDex adota uma arquitetura estritamente orientada a dados locais (offline-first):
- Custódia de Dados: Todos os fichários, cartas registradas, históricos de compra e preços-alvo ficam salvos no banco SQLite embarcado, gerenciado pelo Drift ORM.
- Tráfego de Rede: As requisições de rede limitam-se a consultas de leitura em endpoints REST públicos (TCGdex, AwesomeAPI, pokemontcg.io) sob criptografia TLS/HTTPS.
- Integridade de Backups: Arquivos JSON de backup são rigorosamente validados contra esquemas tipados antes da inserção, prevenindo corrupção do banco de dados ou execução arbitrária durante a restauração.
