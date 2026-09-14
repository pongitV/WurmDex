<p align="center">
  <img src="assets/icons/icon.jpg" width="120" height="120" alt="WurmDex Logo" />
</p>

# WurmDex [BR]

Gerenciador de Coleções, Fichário Virtual, Simulador de Trocas e Acompanhamento Financeiro de Mercado para Pokémon TCG

Idioma do Documento: [BR] | Document Language: [BR]
Alternar Idioma / Switch Language: [[EN] English (README_EN.md)](README_EN.md) | [[BR] Português do Brasil (README_BR.md)](README_BR.md)

---

## Especificações do Projeto [BR]

- Identificador de Idioma: [BR] (Português do Brasil)
- Propósito do Projeto: Projeto recreativo e pessoal desenvolvido estritamente por diversão (hobby).
- Aviso de Estabilidade: Este software foi concebido para fins de estudo e lazer, estando sujeito a refatorações estruturais e alterações de arquitetura sem aviso prévio.
- Idiomas Suportados na Interface do App: [BR] Português (Brasil) e [EN] Inglês (Estados Unidos).
- Tecnologias Principais: Dart 3.5+, Flutter 3.24+, C++ (Runner Nativo do Windows Desktop), SQLite 3 via Drift ORM, Dio e Riverpod.
- Plataformas Suportadas: Windows Desktop (x64, Windows 10/11) e Android (API 21+, ARM64/x86_64).
- Licença de Software: GNU General Public License v3.0 (GPL-3.0).

---

## Downloads Pré-Compilados (Instalação Direta)

Os binários executáveis prontos para uso são disponibilizados diretamente na pasta `dist/` do repositório:

- **Android (APK)**: [`dist/android/WurmDex-release.apk`](dist/android/WurmDex-release.apk)
- **Windows Desktop (EXE)**: [`dist/windows/wurmdex.exe`](dist/windows/wurmdex.exe) (execute diretamente da pasta `dist/windows`, contendo todas as bibliotecas e DLLs necessárias para execução independente)

---

## Isenção de Responsabilidade Legal e Direitos de Propriedade Intelectual

O WurmDex é um aplicativo de código aberto, gratuito, sem fins lucrativos e desenvolvido exclusivamente para propósitos educacionais, de arquivo e entretenimento recreativo de colecionadores.

### Nintendo e The Pokemon Company

Pokemon, nomes de personagens, designs de cartas, ilustrações, logotipos, marcas e elementos visuais correlatos são propriedades intelectuais registradas de:
- Nintendo Co., Ltd.
- Creatures Inc.
- GAME FREAK inc.
- The Pokemon Company e The Pokemon Company International.

O WurmDex não possui qualquer afiliação oficial, endosso, aprovação, vínculo comercial ou patrocínio da Nintendo, The Pokemon Company, Creatures Inc. ou GAME FREAK inc. Nenhuma infração de propriedade intelectual é pretendida. Todos os direitos permanecem sob titularidade exclusiva de seus respectivos detentores.

### Marketplaces e Provedores de Dados de Terceiros

- LigaPokemon é uma plataforma de marketplace operada por seus respectivos proprietários. O WurmDex fornece referências de cotação e atalhos de hiperlink externos exclusivamente para conveniência e consulta do colecionador, sob preceitos de uso justo (fair use).
- TCGPlayer é marca registrada de TCGplayer, Inc. / eBay Inc. Cotações em USD e hiperlinks externos são utilizados puramente como índice referencial.
- Cardmarket é marca registrada de Sammelkartenmarkt GmbH & Co. KG.
- TCGdex é um banco de dados aberto comunitário.
- PokeAPI é uma API aberta de dados sobre Pokemon.
- AwesomeAPI é um serviço público para consulta de taxas de câmbio monetário.

### Identidade Visual e Ativos do Aplicativo

O ícone do aplicativo, o mascote oficial do WurmDex e os elementos visuais de interface são obras originais da comunidade, sem a utilização de sprites, logotipos ou gráficos proprietários como identificadores do executável Windows (.EXE) ou do pacote Android (.APK).

O WurmDex não comercializa produtos físicos, não processa pagamentos monetários, não exibe anúncios publicitários e não efetua cobrança de taxas ou assinaturas.

---

## Arquitetura e Módulos do Sistema

### 1. Padrão Universal de Exibição de Cartas
Todas as listagens de cartas (Catálogo, Expansões, Galeria da Pokédex, Fichários e Wishlist) adotam o componente unificado `CardGridItem`:
- Proporção física estrita de 63mm x 88mm (~0.7159), preservando a geometria oficial sem corte de cantos ou distorções visuais (BoxFit.contain).
- Estrutura vertical de metadados em 3 níveis:
  - Superior: Nome da carta e número oficial do colecionador formatado (ex.: Charizard-ex #199/197).
  - Intermediário: Nome da expansão oficial.
  - Inferior: Badge de estado de conservação (NM, SP, MP, HP, DMG) alinhado à esquerda, pareado com a cotação média de mercado à direita.
- Estimativa automática de piso de mercado baseada na raridade quando a listagem de resumos da API não contiver cotações imediatas, evitando indicadores vazios.

### 2. Motor de Cotações em Tempo Real e Multimercado
- Suporte nativo a Real Brasileiro (BRL / R$) e Dólar Americano (USD / $).
- Conversão cambial em tempo real sincronizada via AwesomeAPI, com armazenamento em cache local para operação offline.
- Cotações autênticas da LigaPokémon fundamentadas no Preço Médio oficial como métrica primária de mercado.
- Cotações específicas por estado de conservação (Near Mint, Slightly Played, Moderately Played, Heavily Played, Damaged) extraídas diretamente do catálogo e da tabela de ofertas ativas da LigaPokémon, sem aplicação de taxas arbitrárias ou fórmulas de multiplicação artificial.
- Gráfico interativo de histórico e tendências de preço (fl_chart):
  - Formatação monetária com duas casas decimais e separador por vírgula em todos os eixos e tooltips.
  - 4 faixas temporais selecionáveis: 1 Semana (7 dias), 1 Mês (30 dias), 1 Ano (365 dias) e Histórico Completo (All-Time).
  - Prevenção de oscilação cúbica de Bézier (preventCurveOverShooting) e margens seguras no eixo vertical, impedindo sobreposição com os rótulos de data.
- Histórico de Compras Concluídas:
  - Consulta de transações reais registradas por compradores em marketplaces.
  - Métricas agregadas: Preço Médio Pago, Menor Preço Pago, Maior Preço Pago e Total de Transações Registradas.
  - Atalhos diretos para verificar o histórico oficial no navegador web.

### 3. Simulador e Avaliador de Trocas Justas (Trade Evaluator)
- Painel para balanceamento de trocas entre duas partes: "Suas Cartas" (You Give) e "Cartas Recebidas" (You Receive).
- Cálculo dinâmico do somatório financeiro de cada lado, diferença líquida e parecer objetivo da negociação (Troca Equilibrada/Justa, Vantajosa para Você ou Desfavorável para Você).
- **Nome da Carta Clicável**: tocar no nome ou código de qualquer carta na tela de troca abre diretamente a tela completa de detalhes da carta do catálogo (`CardDetailsScreen`), exibindo cotações da LigaPokémon, histórico de preços, vendas recentes e visualizador em alta resolução.
- **Seletor Interativo de Estado de Conservação**: menu dropdown dedicado por carta (Near Mint, Slightly Played, Moderately Played, Heavily Played, Damaged) que atualiza o valor da carta de forma dinâmica com base nas cotações reais da LigaPokémon para aquela qualidade.
- **Edição de Valor Personalizado**: toque no preço da carta para inserir um valor acordado manualmente entre os negociadores.
- **Atualização de Preço Médio**: botão na barra superior para reconsultar em tempo real o Preço Médio das cartas da troca diretamente nos servidores da LigaPokémon.
- **Filtros e Ordenação**: modos de visualização (Todas as cartas, Apenas Suas, Apenas Recebidas) e ordenação por Maior Valor, Menor Valor ou Nome (A-Z).
- **Exportação de Resumo**: botão de ação rápida para copiar o resumo analítico da troca formatado diretamente para a área de transferência do sistema.

### 4. Fichário Virtual 3D (Virtual Binder)
- Grade de 9 bolsos por folha (3x3), reproduzindo a experiência tátil de um fichário físico de colecionador.
- Transições de página com argolas metálicas, textura de couro nas bordas e folheamento fluido.
- Efeitos visuais de reflexo holográfico sobre cartas especiais e suporte a manipulação por gestos.

### 5. Gestão Financeira de Portfólio e Coleções
- Consolidação do Total Investido (custo de aquisição registrado) versus Valor Atual de Mercado.
- Cálculo contínuo de Lucro ou Prejuízo não realizado com indicadores percentuais coloridos.
- Classificação analítica das 10 cartas mais valiosas do acervo.
- Relatórios de distribuição por estado de conservação, idioma da carta, acabamento (Regular, Holográfica, Reverse Holo) e expansão.
- Criação e gerenciamento ilimitado de pastas e fichários personalizados com metadados de compra.

### 6. Radar de Preços LigaPokémon (Produtos Selados e Cartas)
- Monitoramento contínuo de produtos cadastrados via URL direta da LigaPokémon.
- Identificação em tempo real de disponibilidade de estoque, menor preço ofertado, identificador da loja vendedora e detecção de itens em pré-venda.
- Notificações locais no sistema operacional quando ofertas entrarem na faixa de preço configurada.
- Verificação individual ou em lote sob demanda, com mensagens informando a atualização do preço médio de mercado.
- Abertura da oferta original no navegador padrão com um clique.

### 7. Lista de Desejos (Wishlist)
- Cadastro de cartas pretendidas com definição de faixa de preço-alvo (preço mínimo e máximo) e estado de conservação requerido.
- Atualização dinâmica de preços de mercado em comparação com a meta desejada.
- Organização por pastas temáticas e filtros rápidos por status de preço.

### 8. Busca Semântica e DexMundial Bilíngue
- Normalização de termos com correspondência cruzada entre Português e Inglês.
- Consultas por nome do Pokémon, número de catálogo nacional/mundial, código de colecionador, expansão, ilustrador e raridade.
- DexMundial completa cobrindo todas as 9 gerações com fraquezas, resistências e catálogo de lançamentos.

### 9. Armazenamento Local, Backup e Privacidade
- Persistência 100% offline em banco de dados SQLite embarcado gerenciado pelo Drift ORM.
- Zero envio de telemetria, cookies, identificadores de publicidade ou registros de uso.
- Rotina completa de exportação e importação de backup em formato JSON compatível com o explorador de arquivos nativo.
- Modos de restauração por Mesclagem ou Substituição Total com validação de esquema tipado para prevenir corrupção de dados.

### 10. Navegação Unificada e Persistência de Sessão
- Dock de navegação inferior com 4 botões de acesso rápido (Catálogo, Radar Liga, Coleções, Menu Mais) idêntico no Windows Desktop e Android.
- Menu estilizado para acesso imediato à WorldDex, Checklist de Expansões, Wishlist, Simulador de Trocas e Ajustes.
- Persistência total de sessão: tema ativo, idioma selecionado e níveis de zoom são restaurados automaticamente ao reiniciar o aplicativo.

### 11. Temas Visuais e Minigames Integrados
- Temas integrados: Modo Escuro (Padrão), Modo Claro Estilo Papel de Livro Antigo, Gramado Botânico, Wurmple Coral, Oceanic Lugia (#249), Shiny Wurmple (#265), Shiny Lugia (#249) e Dark Lugia Secreto (Shadow XD001, desbloqueado ao criar uma coleção nomeada "DarkLugia").
- Minigames de clique incremental para múltiplos Pokémon (Wurmple, Lugia, Dark Lugia) com sistema de upgrades e loja de desbloqueio de temas com pontos acumulados:
  - **Wurmple Clicker**: Minigame com melhorias de Enxame, efeitos de partículas e loja para desbloqueio do tema Shiny Wurmple (#265).
  - **Lugia Clicker**: Minigame acionado pelo mascote dinâmico do Lugia, com upgrades aerodinâmicos e loja para o tema Shiny Lugia (#249).
  - **Dark Lugia Clicker**: Minigame sombrio secreto ativado ao criar a coleção "DarkLugia".
  - **Gerenciador de Temas Extras nos Ajustes**: Painel protegido pela senha "011" que permite desbloquear ou bloquear novamente temas extras a qualquer instante.

---

## Estrutura de Diretórios

```
WurmDex/
|-- android/                         # Configuração nativa da plataforma Android
|-- assets/
|   |-- icons/                       # Ícone da aplicação (icon.jpg)
|   `-- images/                      # Imagens estáticas e ilustrações
|-- build/                           # Artefatos temporários de compilação
|-- dist/                            # Pacotes compilados para distribuição
|   |-- windows/                     # Executável wurmdex.exe e dependências Win32
|   `-- android/                     # Pacote WurmDex-release.apk
|-- lib/
|   |-- core/                        # Módulos transversais, banco de dados, temas e utilitários
|   |   |-- constants/               # Proporções geométricas, URLs oficiais e parâmetros padrão
|   |   |-- database/                # Tabelas SQLite, DAOs e migrações do Drift ORM
|   |   |-- localization/            # Dicionário bilíngue de internacionalização (pt-BR / en-US)
|   |   |-- navigation/              # Roteamento centralizado da aplicação (AppNavigator)
|   |   |-- network/                 # Cliente HTTP Dio com cache e políticas de repetição
|   |   |-- providers/               # Provedores de estado reativo Riverpod
|   |   |-- theme/                   # Motor de temas visuais e esquemas de cores
|   |   `-- widgets/                 # Componentes universais de interface (CardGridItem, Badges)
|   `-- features/                    # Módulos funcionais do sistema
|       |-- card_details/            # Visualizador de detalhes, gráficos de preço e histórico
|       |-- catalog/                 # Mecanismo de busca e catálogo de cartas
|       |-- collections/             # Fichários virtuais, pastas e dashboard financeiro
|       |-- easter_egg/              # Minigames clicker e gerenciador de temas secretos
|       |-- home/                    # Painel inicial, notícias TCG e alertas de mercado
|       |-- monitoring/              # Radar de preços LigaPokémon e monitor de produtos
|       |-- navigation/              # Scaffold principal e dock de navegação inferior
|       |-- pokedex/                 # Índice da Pokédex e galeria de espécies
|       |-- sets/                    # Lista de expansões oficiais e checklists de master set
|       |-- settings/                # Ajustes gerais, moeda, backup JSON e avisos legais
|       |-- trade/                   # Simulador e avaliador de trocas justas
|       `-- wishlist/                # Lista de desejos com rastreamento de preço-alvo
|-- scripts/                         # Scripts automatizados de compilação
|-- test/                            # Bateria completa de testes automatizados
|-- windows/                         # Runner nativo do Windows em C++ (Win32)
|-- LICENSE                          # Licença GNU General Public License v3.0
|-- pubspec.yaml                     # Manifesto de pacotes e dependências Flutter
|-- README_BR.md                     # Documentação completa em Português [BR]
|-- README_EN.md                     # Documentação completa em Inglês [EN]
|-- README.md                        # Apresentação geral do repositório
|-- SECURITY_BR.md                   # Política de segurança e privacidade em Português [BR]
`-- SECURITY_EN.md                   # Política de segurança e privacidade em Inglês [EN]
```

---

## Instruções de Compilação e Execução

### Pré-requisitos de Desenvolvimento

1. Flutter SDK versão 3.24.0 ou superior.
2. Dart SDK versão 3.5.0 ou superior.
3. Para compilação no Windows Desktop:
   - Sistema operacional Windows 10 ou Windows 11 (64 bits).
   - Visual Studio 2022 Community com a carga de trabalho "Desenvolvimento para desktop com C++" instalada.
4. Para compilação no Android:
   - Android SDK (API 34) e Java Development Kit (JDK 17).

### Obtenção de Dependências

```bash
flutter pub get
```

### Execução dos Testes Automatizados

Execute a bateria completa de testes de unidade, de widgets e de integração:

```bash
flutter test
```

### Compilação de Produção para Windows Desktop

Gere o executável nativo otimizado de 64 bits para Windows:

```bash
flutter build windows --release
```

O executável compilado estará localizado em:
`build/windows/x64/runner/Release/wurmdex.exe`

### Compilação de Produção para Android

Gere o pacote APK de distribuição:

```bash
flutter build apk --release
```

O pacote gerado estará disponível em:
`build/app/outputs/flutter-apk/app-release.apk`

### Scripts Automatizados de Build

Atalhos de compilação estão disponíveis na pasta `scripts/`:

Via PowerShell:
```powershell
.\scripts\build.ps1 -Target windows
.\scripts\build.ps1 -Target apk
.\scripts\build.ps1 -Target all
```

Via Prompt de Comando (CMD):
```cmd
scripts\build.bat windows
scripts\build.bat apk
scripts\build.bat all
```

---

## Segurança e Política de Privacidade

- Ausência de Telemetria: O WurmDex não inclui bibliotecas de analytics, publicidade comportamental ou rastreadores externos.
- Custódia Estritamente Local: Todas as informações de coleções, compras registradas e anotações pessoais são mantidas exclusivamente no banco de dados SQLite local do dispositivo.
- Comunicação de Rede Segura: Todas as conexões utilizam exclusivamente conexões criptografadas TLS/HTTPS para leitura de dados públicos de mercado, câmbio monetário e notícias.
- Validação de Entrada de Dados: O mecanismo de restauração analisa a estrutura tipada dos arquivos JSON de backup, recusando dados malformados ou corrompidos.

---

## Uso do Código e Contribuições

Este é um projeto pessoal desenvolvido estritamente por diversão (hobby).

Por este motivo, o autor não procura, não aceita e não revisa contribuições externas, solicitações de funcionalidades (feature requests) ou pull requests.

No entanto, você está totalmente convidado a clonar, realizar fork do repositório e utilizar este código livremente como base, inspiração, referência de estudo ou template para seus próprios projetos independentes, sob os termos da licença GNU General Public License v3.0.
