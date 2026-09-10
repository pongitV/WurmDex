<p align="center">
  <img src="assets/icons/icon.jpg" width="120" height="120" alt="WurmDex Logo" />
</p>

# WurmDex [BR]

Gerenciador de Coleções, Fichário Virtual e Acompanhamento de Mercado para Pokémon TCG

Idioma do Documento: [BR] | Document Language: [BR]
Alternar Idioma / Switch Language: [[EN] English (README_EN.md)](README_EN.md) | [[BR] Português do Brasil (README_BR.md)](README_BR.md)

---

## Especificações do Projeto [BR]

- Identificador de Idioma: [BR] (Português do Brasil)
- Propósito do Projeto: Projeto recreativo e pessoal desenvolvido estritamente por diversão (hobby).
- Aviso de Estabilidade: Este software foi concebido por pura diversão e está sujeito a mudanças bruscas de arquitetura, refatorações profundas e alterações estruturais sem aviso prévio.
- Idiomas Suportados na Interface do App: [BR] Português (Brasil) e [EN] Inglês (Estados Unidos).
- Linguagens de Programação e Tecnologias: Dart 3.5+, Flutter 3.24+, C++ (Runner Nativo do Windows Desktop), SQLite 3 com Drift ORM.
- Plataformas Suportadas: Windows Desktop (x64, Windows 10/11) e Android (API 21+, ARM64/x86_64).
- Licença de Software: GNU General Public License v3.0 (GPL-3.0).

---

## Downloads Pré-Compilados (Instalação Direta)

Os pacotes prontos para uso estão disponíveis diretamente na pasta `dist/` do repositório:

- **Android (APK)**: [`dist/android/WurmDex-release.apk`](dist/android/WurmDex-release.apk)
- **Windows Desktop (EXE)**: [`dist/windows/wurmdex.exe`](dist/windows/wurmdex.exe) (execute diretamente da pasta `dist/windows` com todas as dependências e DLLs inclusas)

---

## Isenção de Responsabilidade Legal e Direitos de Propriedade Intelectual

O WurmDex é um aplicativo de código aberto, gratuito, sem fins lucrativos e desenvolvido exclusivamente para propósitos educacionais, de arquivo e entretenimento recreativo de colecionadores.

### Nintendo e The Pokemon Company

Pokemon, nomes de personagens Pokemon, designs de cartas, ilustrações, logotipos, símbolos e elementos visuais são marcas registradas e propriedades intelectuais protegidas de:
- Nintendo Co., Ltd.
- Creatures Inc.
- GAME FREAK inc.
- The Pokemon Company e The Pokemon Company International.

O WurmDex NÃO possui qualquer vínculo oficial, afiliação, endosso, aprovação ou patrocínio da Nintendo, The Pokemon Company, Creatures Inc. ou GAME FREAK inc. Nenhuma infração de direitos autorais ou violação de marca é pretendida. Toda a propriedade intelectual permanece sob titularidade exclusiva de seus respectivos donos.

### Marketplaces e Provedores de Dados de Terceiros

- LigaPokemon é uma plataforma brasileira de marketplace pertencente aos seus respectivos proprietários. O WurmDex fornece referências de cotação e atalhos de hiperlink externos exclusivamente para conveniência e consulta do colecionador, sob preceitos de uso justo (fair use).
- TCGPlayer é marca registrada de TCGplayer, Inc. / eBay Inc. Preços e hiperlinks externos são utilizados puramente como índice referencial.
- Cardmarket é marca registrada de Sammelkartenmarkt GmbH & Co. KG.
- TCGdex é um banco de dados aberto comunitário.
- PokeAPI é uma API aberta de dados educacionais sobre Pokemon.
- AwesomeAPI é um serviço de consulta pública de taxas cambiais.

### Identidade Visual e Ativos do Aplicativo
- O ícone do aplicativo, o mascote oficial do WurmDex e os elementos de interface (como o ícone de menu estilizado) são obras originais da comunidade, sem a utilização de sprites, logotipos ou gráficos proprietários como identidade do executável (.EXE) ou pacote Android (.APK).

O WurmDex não comercializa cartas, não intermedia transações financeiras, não exibe anúncios publicitários e não cobra qualquer taxa ou assinatura de seus usuários.

---

## Arquitetura e Recursos Principais

### 1. Padrão Universal de Exibição de Cartas
Todas as cartas exibidas no aplicativo (catálogo, expansões, galeria da pokedex, pastas de coleções e listas de desejos) adotam o componente unificado (CardGridItem):
- Conformidade física rigorosa com a proporção oficial de cartas Pokemon (63mm x 88mm / ~0.7159), exibindo a carta por inteiro sem corte de cantos ou bordas (BoxFit.contain).
- Estrutura de metadados em 3 níveis verticais dedicados:
  - Nível Superior (Encima): Nome da carta e número de colecionador formatado (ex.: Charizard-ex #199/197).
  - Nível Intermediário (Meio): Nome da coleção / expansão oficial.
  - Nível Inferior (Embaixo): Badge de estado de conservação (NM, SP, MP, HP, DMG) posicionado à esquerda, alinhado ao valor médio de mercado destacado à direita.
- Estimativa de piso de mercado automática calculada a partir da raridade (Comum, Incomum, Rara, Holo, Dupla Rara, Ultra Rara, Ilustração Especial, Hiper Rara) quando a listagem de resumos da API não contiver cotações imediatas, eliminando a exibição de indicadores vazios.

### 2. Motor de Cotações em Tempo Real e Multimercado
- Suporte nativo a duas moedas: Real Brasileiro (BRL / R$) e Dólar Americano (USD / $).
- Sincronização cambial em tempo real com a AwesomeAPI e armazenamento em cache offline.
- Cotações paralelas comparando o mercado nacional (LigaPokemon) com o mercado internacional (TCGPlayer convertido em BRL).
- Gráfico interativo de histórico e tendências de preço (fl_chart):
  - Formatação monetária estrita com 2 casas decimais e separador decimal por vírgula (ex.: R$ 25,50 ou $ 14,20), tanto nos eixos quanto no tooltip de toque, eliminando imperfeições de ponto flutuante.
  - 4 faixas temporais selecionáveis: 1 Semana (7 dias), 1 Mês (30 dias), 1 Ano (365 dias) e Desde o Lançamento (All-Time).
  - Prevenção de oscilação cúbica de Bézier (preventCurveOverShooting) e margens verticais seguras no eixo Y, impedindo que a curva encoste ou atravesse os rótulos de datas.
- Histórico de Compras Concluídas por Compradores:
  - Botão e modal dedicados para inspecionar transações reais pagas por colecionadores, diferindo do preço meramente anunciado.
  - Seletor de plataforma entre LigaPokemon e TCGPlayer.
  - Métricas consolidadas: Preço Médio Pago, Menor Preço Pago, Maior Preço Pago e Quantidade de Vendas Registradas.
  - Atalhos diretos para abrir o histórico e compras concluídas nos marketplaces oficiais.

### 3. Modo Fichário Virtual 3D
- Visualização de folhas em grade 3x3 (9 cartas por página) reproduzindo a experiência tátil de um fichário físico.
- Perspectiva com argolas metálicas realistas, margens em acabamento couro e folheamento fluido.
- Simulação de iluminação sobre cartas holográficas e gestos interativos de manipulação.

### 4. Gestão Financeira de Portfólio
- Total Investido versus Valor Estimado Atual de Mercado calculado automaticamente.
- Apuração de Lucro ou Prejuízo não realizado com indicadores percentuais coloridos.
- Classificação das 10 cartas mais valiosas da coleção.
- Distribuição analítica por estado de conservação, idioma, acabamento (Regular, Holográfica, Reverse Holo) e expansão.

### 5. Busca Semântica e DexMundial Bilíngue
- Normalização de termos e correspondência automática entre Português e Inglês.
- Consultas por nome, número de catálogo mundial, código da carta, coleção, ilustrador e raridade.
- DexMundial completa offline cobrindo todas as gerações, fraquezas, resistências e atributos elementares.

### 6. Armazenamento Local, Backup e Privacidade
- Persistência nativa em SQLite com Drift ORM, sem envio de telemetria, cookies ou rastreadores externos.
- Todas as coleções, notas pessoais e registros de preços permanecem restritos ao dispositivo local do usuário.
- Exportação e restauração completa de backup em formato JSON compatível com pastas do sistema.
- Modos de restauração por Mesclagem ou Substituição com validação estrutural de segurança.

### 7. Radar de Preços LigaPokémon (Pré-Vendas & Ofertas)
- Monitoramento contínuo de cartas avulsas e produtos selados cadastrados via URL direta da LigaPokémon.
- Detecção em tempo real de estoque, menor preço ofertado, nome da loja vendedora e badge de pré-venda.
- Notificações locais automáticas no sistema operacional quando ofertas caírem na faixa de preço desejada.
- Atalho direto para abrir o anúncio no navegador padrão com um clique.

### 8. Navegação Unificada e Persistência de Sessão
- Dock inferior unificado de 4 botões (Catálogo, Radar Liga, Coleções e Menu Mais) idêntico no Windows e Android.
- Menu "Mais Opções" estilizado para acesso imediato a WorldDex, Expansões TCG, Wishlist, Avaliador de Trocas e Ajustes.
- Persistência total de preferências: tema escolhido (Escuro, Claro Livro Antigo, Gramado, Wurmple, Lugia, Wurmple Shiny, Lugia Shiny e Dark Lugia), idioma ativo e escalas de zoom são restaurados automaticamente ao reabrir o app.
- Easter egg com minigame clicker para diversos Pokémon (Wurmple, Lugia, Dark Lugia), com sistema de melhorias e loja para temas usando pontos:
  - **Wurmple Clicker**: minigame clicker em tela cheia com upgrades de Enxame, animações de partículas e loja para desbloqueio do tema Shiny Wurmple (★ #265) por pontos acumulados.
  - **Lugia Clicker**: minigame temático acionado pelo mascote dinâmico do Lugia, com upgrades aerodinâmicos e loja para desbloqueio do tema Shiny Lugia (★ #249).
  - **Dark Lugia Clicker**: minigame temático sombrio desbloqueado ao criar uma coleção nomeada "DarkLugia".
  - **Gerenciador de Temas Extras nos Ajustes**: botão protegido pela senha "011" para desbloquear ou bloquear temas extras via dropdown a qualquer momento.

---

## Estrutura de Diretórios

```
WurmDex/
|-- android/                         # Configurações nativas da plataforma Android
|-- assets/
|   |-- icons/                       # Ícone da aplicação (icon.jpg)
|   `-- images/                      # Imagens estáticas e ilustrações
|-- build/                           # Artefatos temporários de compilação
|-- dist/                            # Pacotes compilados para distribuição
|   |-- windows/                     # Executável wurmdex.exe e dependências Win32
|   `-- android/                     # Pacote WurmDex-release.apk
|-- lib/
|   |-- core/                        # Módulos transversais, banco, temas e constantes
|   |   |-- constants/               # Proporções geométricas, URLs oficiais e padrões
|   |   |-- database/                # Esquemas SQLite, DAOs e migrações do Drift
|   |   |-- localization/            # Dicionário de internacionalização (pt-BR / en-US)
|   |   |-- navigation/              # Gerenciador centralizado de rotas
|   |   |-- network/                 # Cliente Dio com cache em memória e repetição
|   |   |-- providers/               # Notificadores de estado Riverpod
|   |   |-- theme/                   # Motor de temas (Escuro, Claro Papel, Gramado, Wurmple, Lugia)
|   |   `-- widgets/                 # Componentes universais (CardGridItem, Badges)
|   `-- features/                    # Módulos funcionais
|       |-- card_details/            # Detalhes da carta, gráfico e modal de compras
|       |-- catalog/                 # Mecanismo de busca e catálogo de cartas
|       |-- collections/             # Fichários, pastas e dashboard financeiro
|       |-- easter_egg/              # Minigame secreto Wurmple Clicker
|       |-- home/                    # Painel inicial, notícias e alertas de preço
|       |-- navigation/              # Estrutura de navegação e scaffold principal
|       |-- pokedex/                 # Índice da pokedex e galeria de cartas
|       |-- sets/                    # Lista de expansões e checklist de Master Set
|       |-- settings/                # Ajustes, temas, moedas, backup e aviso legal
|       `-- trade/                   # Calculadora de trocas justas
|-- scripts/                         # Automações de compilação para Windows e Android
|-- test/                            # Bateria completa de testes automatizados
|-- windows/                         # Runner nativo do Windows em C++ (Win32)
|-- LICENSE                          # Licença GNU General Public License v3.0
|-- pubspec.yaml                     # Manifesto de dependências do Flutter
|-- README_BR.md                     # Documentação em Português [BR]
|-- README_EN.md                     # Documentação em Inglês [EN]
|-- SECURITY_BR.md                   # Política de Segurança em Português [BR]
`-- SECURITY_EN.md                   # Política de Segurança em Inglês [EN]
```

---

## Instruções de Compilação e Execução

### Pré-requisitos do Ambiente

1. Flutter SDK versão 3.24.0 ou superior.
2. Dart SDK versão 3.5.0 ou superior.
3. Para compilação no Windows Desktop:
   - Windows 10 ou 11 (64 bits).
   - Visual Studio 2022 Community com a carga de trabalho "Desenvolvimento para desktop com C++" instalada.
4. Para compilação no Android:
   - Android SDK (API 34) e Java Development Kit (JDK 17).

### Instalação de Dependências

```bash
flutter pub get
```

### Execução dos Testes Automatizados

Valide todos os testes de unidade, widgets e arquitetura:

```bash
flutter test
```

### Compilação para Windows Desktop

Para gerar o binário de produção otimizado para Windows:

```bash
flutter build windows --release
```

O executável final estará disponível em:
`build/windows/x64/runner/Release/wurmdex.exe`

### Compilação para Android

Para gerar o pacote APK assinado de produção:

```bash
flutter build apk --release
```

O arquivo de instalação estará disponível em:
`build/app/outputs/flutter-apk/app-release.apk`

### Scripts Utilitários de Compilação

Atalhos de automação estão disponíveis na pasta `scripts/`:

Via PowerShell:
```powershell
.\scripts\build.ps1 -Platform windows
.\scripts\build.ps1 -Platform apk
.\scripts\build.ps1 -Platform all
```

Via Prompt de Comando (CMD):
```cmd
scripts\build.bat windows
scripts\build.bat apk
scripts\build.bat all
```

---

## Segurança e Política de Privacidade

- Sem Telemetria: O WurmDex não contém SDKs de analytics, publicidade ou rastreamento.
- Armazenamento Exclusivamente Local: Suas coleções e valores de compra ficam guardados somente no banco SQLite local do dispositivo.
- Comunicação Segura: Todas as conexões externas utilizam protocolo TLS/HTTPS com validação de certificados para consulta pública de cotações e notícias.
- Validação de Arquivos: A rotina de restauração de backup analisa o formato JSON e recusa arquivos corrompidos ou maliciosos.

---

## Uso do Codigo e Contribuicoes

Este e um projeto pessoal desenvolvido estritamente por diversao (hobby).

Por este motivo, o autor NAO procura, nao aceita e nao deseja contribuicoes externas, solicitacoes de funcionalidades (feature requests) ou pull requests.

No entanto, voce esta totalmente convidado e encorajado a clonar, realizar fork do repositorio e utilizar este codigo livremente como base, inspiracao, molde ou aprendizado para os seus proprios projetos, sob os termos da licenca GNU GPL-3.0.

