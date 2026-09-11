import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_language.dart';
export 'app_language.dart';

class AppStrings {
  final AppLanguage language;

  const AppStrings(this.language);

  bool get isEn => language == AppLanguage.enUs;

  // Common Actions
  String get cancel => isEn ? 'Cancel' : 'Cancelar';
  String get remove => isEn ? 'Remove' : 'Remover';
  String get reset => isEn ? 'Reset' : 'Resetar';
  String get save => isEn ? 'Save' : 'Salvar';

  // General App
  String get appTitle => 'WurmDex';
  String get appName => 'WurmDex';

  // Navigation
  String get navCatalog => isEn ? 'Catalog' : 'Catálogo';
  String get navPokedex => isEn ? 'WorldDex' : 'DexMundial';
  String get navSets => isEn ? 'Expansions' : 'Coleções TCG';
  String get navCollections => isEn ? 'Collections' : 'Coleções';
  String get navCollection => isEn ? 'Collection' : 'Coleção';
  String get navMonitoring => isEn ? 'Monitoring' : 'Monitoramento';
  String get emptySlot => isEn ? 'Empty Slot' : 'Espaço Vazio';
  String get navTrades => isEn ? 'Trades' : 'Trocas';
  String get navWishlist => 'Wishlist';
  String get navLigaRadar => isEn ? 'Liga Radar' : 'Radar Liga';
  String get navSettings => isEn ? 'Settings' : 'Ajustes';
  String get navMore => isEn ? 'More' : 'Mais';
  String get moreOptionsTitle => isEn ? 'More Features' : 'Mais Opções';
  String get moreOptionsSubtitle => isEn ? 'Select a section to navigate' : 'Selecione uma seção para navegar';
  String get descPokedex => isEn ? 'All Pokémon generations' : 'WorldDex de todas as gerações';
  String get descSets => isEn ? 'TCG sets and releases' : 'Expansões & lançamentos TCG';
  String get descCollections => isEn ? 'Binders, folders & cards' : 'Pastas, fichários e cartas';
  String get descTrades => isEn ? 'Trade evaluator' : 'Avaliador de trocas TCG';
  String get descWishlist => isEn ? 'Target prices and cards' : 'Cartas desejadas e metas';
  String get descSettings => isEn ? 'Theme, backup & language' : 'Tema, backup e preferências';

  // WorldDex Screen
  String get pokedexTitle => isEn ? 'WorldDex' : 'DexMundial';
  String get pokedexSearchHint => isEn ? 'Search Pokémon by name, #number, or type...' : 'Buscar Pokémon por nome, #número ou tipo...';
  String pokedexCardsFor(String name) => isEn ? 'Cards for $name' : 'Cartas de $name';
  String get pokedexAllGens => isEn ? 'All Gens' : 'Todas';
  String pokedexGen(int g) => isEn ? 'Gen $g' : 'Geração $g';
  String get pokedexNoResults => isEn ? 'No Pokémon found.' : 'Nenhum Pokémon encontrado.';
  String get pokedexLoadingCards => isEn ? 'Loading cards...' : 'Carregando cartas...';

  // Sets & Expansions Screen
  String get setsTitle => isEn ? 'TCG Expansions & Releases' : 'Expansões & Lançamentos TCG';
  String get tabReleasedSets => isEn ? 'Released Sets' : 'Coleções Lançadas';
  String get tabUpcomingReleases => isEn ? 'Upcoming Releases' : 'Futuros Lançamentos';
  String get tabSetProducts => isEn ? 'Set Products' : 'Produtos da Coleção';
  String get tabSetGallery => isEn ? 'Card Gallery' : 'Galeria de Cartas';
  String setsCount(int count) => isEn ? '$count ${count == 1 ? "set" : "sets"}' : '$count ${count == 1 ? "coleção" : "coleções"}';
  String get txtAllYears => isEn ? 'All' : 'Todos';
  String get txtMSRP => isEn ? 'MSRP' : 'Preço Sugerido';
  String get txtEstimatedPrice => isEn ? 'Est. Price' : 'Preço Estimado';
  String get txtReleaseDate => isEn ? 'Released' : 'Lançamento';
  String get txtCardsCount => isEn ? 'cards' : 'cartas';
  String get txtLoadingSets => isEn ? 'Loading Pokémon sets...' : 'Carregando coleções...';
  String get txtNoSetsFound => isEn ? 'No sets found.' : 'Nenhuma coleção encontrada.';
  String get txtUpcomingNotice => isEn ? 'Upcoming Release' : 'Lançamento Futuro';
  String get txtNoProducts => isEn ? 'Product details coming soon.' : 'Produtos desta coleção serão anunciados em breve.';
  String get txtTotalPrints => isEn ? 'Total Prints' : 'Total de Impressões';
  String get searchCardsPlaceholder => isEn ? 'Search cards in this set...' : 'Buscar cartas nesta coleção...';
  String get searchSetsPlaceholder => isEn ? 'Search sets by name...' : 'Buscar coleções pelo nome...';
  String get btnTryAgain => isEn ? 'Try Again' : 'Tentar Novamente';
  String get loadingCatalog => isEn ? 'Loading...' : 'Carregando...';
  String get errorLoadingNews => isEn ? 'Error loading data.' : 'Erro ao carregar dados.';

  // Catalog Screen
  String get selectCard => isEn ? 'Select Card' : 'Selecionar Carta';
  String get labelFolder => isEn ? 'Folder' : 'Pasta';
  String tapCardToAddToFolder(String name) => isEn ? 'Tap any card to add it to "$name"' : 'Toque em qualquer carta para adicioná-la em "$name"';

  // Home Dashboard
  String get btnSearchCards => isEn ? 'Search Cards' : 'Pesquisar Cartas';
  String get btnSearching => isEn ? 'Searching...' : 'Buscando...';
  String get btnViewCollection => isEn ? 'View Collection' : 'Ver Coleção';
  String get sectionTrending => isEn ? 'TRENDING CARDS RIGHT NOW' : 'CARTAS MAIS PROCURADAS NO MOMENTO';
  String get badgeTrending => isEn ? 'Trending' : 'Em Alta';
  String get sectionNews => isEn ? 'POKÉMON TCG NEWS & SCENE' : 'NOTÍCIAS & CENÁRIO DO POKÉMON TCG';
  String get sectionPriceAlerts => isEn ? 'COLLECTION PRICE UPDATES' : 'AVISOS DE MUDANÇA DE PREÇOS DA COLEÇÃO';
  String get statusStable => isEn ? 'Stable' : 'Estável';
  String get statusHigh => isEn ? 'Surging' : 'Em Alta';
  String get noPriceChanges => isEn
      ? 'No price fluctuations detected in your collection.'
      : 'Nenhuma oscilação relevante detectada na sua coleção.';
  String get searchHint => isEn
      ? 'Type card name, suffix or #number...'
      : 'Digite o nome da carta, sufixo ou #número...';
  String get btnHome => isEn ? 'Home' : 'Início';
  String get btnClearFilters => isEn ? 'Clear Filters' : 'Limpar Filtros';
  String get noCardsFound => isEn ? 'No cards found.' : 'Nenhuma carta encontrada.';
  String get tryAnotherSearch => isEn
      ? 'Try another search term or clear the filter.'
      : 'Tente outro termo ou limpe a busca.';
  String get noFilterMatch => isEn
      ? 'No cards match the active filters.'
      : 'Nenhuma carta corresponde aos filtros ativos.';
  String get scaleTooltip => isEn ? 'Adjust Card Scale' : 'Ajustar Escala das Cartas';
  String get scaleLayoutTooltip => isEn ? 'Scale / Layout' : 'Escala / Organização';
  String get gridModeTooltip => isEn ? 'Grid Mode' : 'Modo Grade';
  String get tableModeTooltip => isEn ? 'Table Mode' : 'Modo Planilha';
  String get refreshTooltip => isEn ? 'Refresh' : 'Atualizar';

  // News Widget
  String get chipAll => isEn ? 'All' : 'Todas';
  String get chipPokemonOfficial => isEn ? 'Pokemon.com (Official)' : 'Pokemon.com (Oficial)';
  String get chipBillsArchive => "Bill's Archive";
  String get chipTcgScene => isEn ? 'TCG Scene' : 'Cenário TCG';
  String get btnRefreshNews => isEn ? 'Refresh News' : 'Atualizar Notícias';
  String get fetchingNews => isEn ? 'Fetching latest news...' : 'Buscando últimas notícias...';
  String get noNewsFound => isEn
      ? 'No news articles available right now.'
      : 'Nenhuma notícia encontrada no momento.';
  String get tapRefreshNews => isEn
      ? 'Tap refresh to check for updates.'
      : 'Toque em atualizar para verificar novidades.';
  String get errOpenNews => isEn
      ? 'Unable to open article.'
      : 'Não foi possível abrir a notícia.';
  String get errOpenNewsLink => isEn
      ? 'Error opening article link.'
      : 'Erro ao abrir o link da notícia.';

  // Settings Screen
  String get settingsTitle => isEn ? 'Settings & System' : 'Ajustes & Sistema';
  String get sectionLanguage => isEn ? 'LANGUAGE' : 'IDIOMA';
  String get langEnglishTitle => isEn ? 'English (en-US, Default)' : 'Inglês (en-US, Padrão)';
  String get langEnglishSub => isEn ? 'Default system language' : 'Idioma padrão do sistema';
  String get langPortugueseTitle => isEn ? 'Portuguese (pt-BR)' : 'Português (pt-BR)';
  String get langPortugueseSub => isEn ? 'Brazilian Portuguese language' : 'Português do Brasil';

  String get sectionThemes => isEn ? 'THEME ENGINE' : 'MOTOR DE TEMAS';
  String get themeDarkTitle => isEn ? 'Dark Theme (Default)' : 'Tema Escuro (Padrão)';
  String get themeDarkSub => isEn ? 'Pure deep black with Vibrant Crimson Accent' : 'Preto profundo #000000 com Acento Vermelho vibrante';
  String get themeLightTitle => isEn ? 'Light Theme (Antique Book Page)' : 'Tema Claro (Página de Livro Antigo)';
  String get themeLightSub => isEn
      ? 'Soft antique book page beige, warm and gentle on the eyes'
      : 'Branco suave de página de livro velho, bege leve e agradável aos olhos';
  String get themeGramadoTitle => isEn ? 'Gramado Theme (Lawn / Grassland)' : 'Tema Gramado';
  String get themeGramadoSub => isEn ? 'Botanical green forest and meadow shades' : 'Fundos botânicos em verde relva e acentos da carta';
  String get themeWurmpleTitle => isEn ? 'Wurmple Theme (#265)' : 'Tema Wurmple (#265)';
  String get themeWurmpleSub => isEn
      ? "Wurmple's icon colors: Coral pink body, horn yellow, cream belly and dark espresso outline"
      : 'Cores do ícone do Wurmple: Corpo coral/carmesim, chifres amarelos, ventre creme e contorno café';
  String get themeLugiaTitle => isEn ? 'Lugia Theme (#249)' : 'Tema Lugia (#249)';
  String get themeLugiaSub => isEn
      ? 'Oceanic deep navy and aerilate blue inspired by Lugia (#249)'
      : 'Azul marinho abissal e tons oceânicos inspirados no Lugia (#249)';
  String get themeWurmpleShinyTitle => isEn ? 'Shiny Wurmple Theme (★ #265)' : 'Tema Wurmple Shiny (★ #265)';
  String get themeWurmpleShinySub => isEn
      ? 'Cosmic violet body with gold horns and radiant night hues'
      : 'Corpo violeta cósmico, chifres dourados e fundo ametista radiante';
  String get themeLugiaShinyTitle => isEn ? 'Shiny Lugia Theme (★ #249)' : 'Tema Lugia Shiny (★ #249)';
  String get themeLugiaShinySub => isEn
      ? 'Crimson-rose belly and silver wings on midnight oceanic canvas'
      : 'Ventre carmesim-rosa e asas prateadas sobre tela oceânica da meia-noite';
  String get themeDarkLugiaTitle => isEn ? 'Dark Lugia Theme (Shadow XD001)' : 'Tema Dark Lugia (Shadow XD001)';
  String get themeDarkLugiaSub => isEn
      ? 'Abyssal shadow corruption with spectral purple and crimson eye'
      : 'Sombra abissal corrompida com roxo espectral e olho carmesim';

  String get themeWurmpleShinyLockedSub => isEn
      ? 'Unlock with 1,000,000 pts in Wurmple Clicker'
      : 'Desbloqueie com 1.000.000 pts no Wurmple Clicker';
  String get themeLugiaShinyLockedSub => isEn
      ? 'Unlock with 1,000,000 pts in Lugia Clicker'
      : 'Desbloqueie com 1.000.000 pts no Lugia Clicker';
  String get themeDarkLugiaLockedSub => isEn
      ? 'Secret: Create a collection named "DarkLugia"'
      : 'Segredo: Crie uma coleção chamada "DarkLugia"';

  String get themeWurmpleShinyLockedToast => isEn
      ? 'Reach 1,000,000 pts in Wurmple Clicker to unlock!'
      : 'Alcance 1.000.000 pts no Wurmple Clicker para desbloquear!';
  String get themeLugiaShinyLockedToast => isEn
      ? 'Reach 1,000,000 pts in Lugia Clicker to unlock!'
      : 'Alcance 1.000.000 pts no Lugia Clicker para desbloquear!';
  String get themeDarkLugiaLockedToast => isEn
      ? 'Create a collection named "DarkLugia" to unlock!'
      : 'Crie uma coleção com o nome "DarkLugia" para desbloquear!';

  // Common Dialog Actions
  String get confirm => isEn ? 'Confirm' : 'Confirmar';
  String get done => isEn ? 'Done' : 'Concluir';

  // Extra Themes Unlock Dialog
  String get btnUnlockExtraThemes => isEn ? 'Unlock Extra Themes' : 'Desbloquear Temas Extras';
  String get manageExtraThemesTitle => isEn ? 'Manage Extra Themes' : 'Gerenciar Temas Extras';
  String get passwordPromptTitle => isEn ? 'Access Password' : 'Senha de Acesso';
  String get passwordPromptSubtitle => isEn ? 'Enter the passcode to manage extra themes:' : 'Digite a senha para gerenciar temas extras:';
  String get passwordHint => isEn ? 'Enter passcode...' : 'Digite a senha...';
  String get incorrectPasswordMsg => isEn ? 'Incorrect password!' : 'Senha incorreta!';
  String get selectThemeDropdownLabel => isEn ? 'Choose Theme to Configure' : 'Escolha o Tema para Alterar';
  String get themeUnlockedLabel => isEn ? 'Unlocked' : 'Desbloqueado';
  String get themeLockedLabel => isEn ? 'Locked' : 'Bloqueado';
  String get btnLock => isEn ? 'Lock Theme' : 'Bloquear Tema';
  String get btnUnlock => isEn ? 'Unlock Theme' : 'Desbloquear Tema';
  String get allThemesOption => isEn ? 'All Extra Themes' : 'Todos os Temas Extras';
  String get btnUnlockAll => isEn ? 'Unlock All' : 'Desbloquear Todos';
  String get btnLockAll => isEn ? 'Lock All' : 'Bloquear Todos';

  // Clicker Minigame Localization
  String get clickerResetTooltip => isEn ? 'Reset progress' : 'Resetar progresso';
  String clickerTotalClicks(int count) => isEn ? 'Total clicks: $count' : 'Total de cliques: $count';
  String get clickerPerSecond => isEn ? 'Per Second' : 'Por Segundo';
  String get clickerPerClick => isEn ? 'Per Click' : 'Por Clique';
  String get clickerUnlockShinyLugia => isEn ? 'Unlock Shiny Lugia Theme' : 'Desbloquear Tema Shiny Lugia';
  String get clickerUnlockShinyWurmple => isEn ? 'Unlock Shiny Wurmple Theme' : 'Desbloquear Tema Shiny Wurmple';
  String get clickerShinyUnlockCostDesc => isEn
      ? 'Costs 1,000,000 points. Keeps upgrades and score!'
      : 'Custa 1.000.000 pontos. Mantém upgrades e pontuação!';
  String get clickerUpgradesSection => isEn ? 'UPGRADES & EVOLUTION' : 'MELHORIAS & EVOLUÇÃO';
  String clickerLevel(int level) => isEn ? 'Lv. $level' : 'Nv. $level';
  String get clickerResetDialogTitle => isEn ? 'Reset Progress?' : 'Resetar Progresso?';
  String get clickerResetDialogMessage => isEn
      ? 'Are you sure you want to reset all points, clicks, and upgrades? This action cannot be undone.'
      : 'Tem certeza de que deseja zerar todos os pontos, cliques e melhorias? Esta ação não pode ser desfeita.';
  String get clickerResetConfirm => isEn ? 'Yes, Reset' : 'Sim, Resetar';
  String get clickerShinyLugiaUnlockedToast => isEn
      ? 'Congratulations! Shiny Lugia Theme unlocked and applied!'
      : 'Parabéns! Tema Shiny Lugia desbloqueado e ativado!';
  String get clickerShinyWurmpleUnlockedToast => isEn
      ? 'Congratulations! Shiny Wurmple Theme unlocked and applied!'
      : 'Parabéns! Tema Shiny Wurmple desbloqueado e ativado!';

  String get sectionEasterEgg => isEn ? 'MINIGAME & CLICKER' : 'MINIGAME & CLICKER';
  String get pauseAutoclickersTitle => isEn ? 'Pause Automatic Clicks' : 'Pausar Cliques Automáticos';
  String get pauseAutoclickersSub => isEn
      ? 'Pauses passive generation from autoclicker helpers'
      : 'Pausa a geração passiva dos ajudantes autoclickers';
  String get clickerAutoclickerPaused => isEn ? 'PAUSED' : 'PAUSADO';
  String get clickerPauseTooltip => isEn ? 'Pause automatic clicks' : 'Pausar cliques automáticos';
  String get clickerResumeTooltip => isEn ? 'Resume automatic clicks' : 'Retomar cliques automáticos';
  String get resetAutoclickersTitle => isEn ? 'Reset Autoclicker Progress' : 'Resetar Progresso dos Autoclickers';
  String get resetAutoclickersSub => isEn
      ? 'Resets points, clicks and upgrades. Unlocked themes are kept.'
      : 'Reseta pontos, cliques e upgrades. Temas desbloqueados são mantidos.';
  String get resetAutoclickersConfirm => isEn
      ? 'Are you sure? This erases all clicker points and upgrade progress.'
      : 'Tem certeza? Isso apaga todos os pontos e upgrades dos clickers.';
  String get resetAutoclickersSuccess => isEn
      ? 'Autoclicker progress reset.'
      : 'Progresso dos autoclickers resetado.';
  String get firstReleaseDateLabel => isEn ? 'Initial Release' : 'Primeiro Lançamento';
  String get reprintDatesLabel => isEn ? 'Reprint Dates' : 'Datas de Reimpressão';
  String get soonInExpectedMonth => isEn ? 'Soon in (expected month)' : 'Em breve (mês esperado)';

  String get sectionCardScale => isEn
      ? 'CARD VISUAL SCALE (MENU & COLLECTION)'
      : 'ESCALA VISUAL DAS CARTAS (MENU & COLEÇÃO)';
  String get sectionBackup => isEn ? 'LOCAL BACKUP & RESTORE' : 'BACKUP E RESTAURAÇÃO LOCAL';
  String get btnExportDatabase => isEn ? 'Export Database (.json)' : 'Exportar Banco de Dados (.json)';
  String get subExportDatabase => isEn
      ? 'Save collection, wishlist and folders'
      : 'Salvar coleção, wishlist e fichários';
  String get btnImportBackup => isEn ? 'Import Backup (.json)' : 'Importar Backup (.json)';
  String get subImportBackup => isEn
      ? 'Restore cards and folders from file'
      : 'Restaurar cartas e fichários de arquivo';
  String get sectionSystemInfo => isEn ? 'SYSTEM INFORMATION' : 'INFORMAÇÕES DO SISTEMA';
  String get labelCommercialRate => isEn ? 'Commercial USD Rate' : 'Cotação USD Comercial';
  String get subRateSource => isEn ? 'AwesomeAPI (Real-time live rate)' : 'AwesomeAPI (Tempo real)';
  String get btnRefreshQuote => isEn ? 'Refresh Quote' : 'Atualizar Cotação';
  String get labelLocalDb => isEn ? 'Local Database' : 'Banco de Dados Local';
  String get subLocalDb => isEn ? 'Drift SQLite (Native C++)' : 'Drift SQLite (Nativo C++)';
  String get labelStatus => isEn ? 'Status' : 'Status';
  String get subStatus => isEn ? 'Offline-First & Fast Local Cache' : 'Offline-First & Cache Local Rápido';
  String get labelLegalDisclaimer => isEn ? 'Legal Notice & Fair Use' : 'Aviso Legal e Uso Justo';
  String get subLegalDisclaimer => isEn ? 'Trademarks, fan project disclaimers' : 'Marcas registradas e isenções';
  String get legalNoticeTitle => isEn ? 'Legal Notice & Fan Disclaimer' : 'Aviso Legal e Isenção';
  String get legalNoticeBody => isEn
      ? 'Pokémon and Pokémon character names, card artwork, and assets are trademarks and copyrights of Nintendo, Creatures Inc., and GAME FREAK Inc.\n\n'
        'WurmDex is an independent, non-commercial fan application created strictly for personal organization, recreation, and educational purposes. WurmDex is NOT affiliated with, endorsed, sponsored, or specifically approved by Nintendo, The Pokémon Company, Creatures Inc., GAME FREAK Inc., TCGPlayer, or LigaPokémon.\n\n'
        'Marketplace names, prices, and external links (LigaPokémon, TCGPlayer, Cardmarket) are provided solely for convenience and collector reference under nominative fair use. All intellectual property remains the exclusive property of their respective owners.\n\n'
        'This software is distributed as-is without warranties of any kind.'
      : 'Pokémon e nomes de personagens, cartas e ilustrações são marcas registradas e direitos autorais da Nintendo, Creatures Inc. e GAME FREAK Inc.\n\n'
        'O WurmDex é um aplicativo independente de fãs, sem fins lucrativos, criado estritamente para organização pessoal, consulta e propósitos educacionais. O WurmDex NÃO possui qualquer vínculo, afiliação, endosso, patrocínio ou aprovação da Nintendo, The Pokémon Company, Creatures Inc., GAME FREAK Inc., TCGPlayer ou LigaPokémon.\n\n'
        'Nomes de marketplaces, cotações e links externos (LigaPokémon, TCGPlayer, Cardmarket) são disponibilizados exclusivamente para conveniência e referência do colecionador sob as diretrizes de uso justo nominativo (fair use). Toda propriedade intelectual pertence com exclusividade aos seus respectivos titulares.\n\n'
        'Este software é distribuído no estado em que se encontra, sem garantias de qualquer tipo.';

  // Data Sources & Community Credits
  String get labelDataSources => isEn ? 'Data Sources & Community Credits' : 'Fontes de Dados & Créditos';
  String get subDataSources => isEn ? 'TCGdex, PokéAPI, AwesomeAPI' : 'TCGdex, PokéAPI, AwesomeAPI';
  String get dataSourcesTitle => isEn ? 'Data Sources & Attribution' : 'Fontes de Dados & Atribuição';
  String get dataSourcesBody => isEn
      ? 'WurmDex aggregates publicly available community data from open APIs and services:\n\n'
        '• TCGdex: Comprehensive multilingual Pokémon TCG card database and high-resolution card artwork (https://tcgdex.dev)\n\n'
        '• PokéAPI: Public RESTful API providing Pokémon metadata, species numbers, and elemental attributes (https://pokeapi.co)\n\n'
        '• AwesomeAPI: Real-time currency exchange rates for USD to BRL market conversion (https://economia.awesomeapi.com.br)\n\n'
        'We express our gratitude to these open projects and community maintainers who make fan cataloging possible.'
      : 'O WurmDex integra e consolida dados públicos disponibilizados pela comunidade por meio de APIs abertas:\n\n'
        '• TCGdex: Banco de dados multilíngue de cartas do Pokémon TCG e ilustrações em alta resolução (https://tcgdex.dev)\n\n'
        '• PokéAPI: API REST pública fornecendo metadados, numeração oficial de espécies e atributos elementares (https://pokeapi.co)\n\n'
        '• AwesomeAPI: Cotação cambial em tempo real para conversão de mercado USD/BRL (https://economia.awesomeapi.com.br)\n\n'
        'Agradecemos a todos os mantenedores desses projetos abertos que viabilizam o gerenciamento de coleções pela comunidade.';

  // Collections Screen
  String get collectionsTitle => isEn ? 'My Folders & Collections' : 'Meus Fichários e Coleções';
  String get sectionFoldersAndBinders => isEn ? 'FOLDERS & BINDERS' : 'FICHÁRIOS E PASTAS';
  String get btnCreateFolder => isEn ? 'New Folder' : 'Novo Fichário';
  String get btnCreateFolderAction => isEn ? 'Create Folder' : 'Criar Pasta';
  String get generalCollectionTitle => isEn ? 'General Collection' : 'Coleção Geral';
  String get easterEggDarkLugiaUnlocked => isEn ? 'Easter Egg! Dark Lugia Theme unlocked!' : 'Easter Egg! Tema Dark Lugia desbloqueado!';
  String get generalCollectionSubtitle => isEn ? 'Loose cards without a specific folder' : 'Cartas avulsas sem fichário específico';
  String cardsCount(int count) => isEn ? '$count cards' : '$count cartas';
  String get tooltipDeleteFolder => isEn ? 'Delete Folder' : 'Excluir Pasta';
  String get dlgCreateFolderTitle => isEn ? 'New Folder / Collection' : 'Novo Fichário / Coleção';
  String get dlgEditFolderTitle => isEn ? 'Edit Collection' : 'Editar Coleção';
  String get inputFolderName => isEn ? 'Folder Name' : 'Nome do Fichário';
  String get inputFolderNameHint => isEn ? 'E.g.: 151 Master Set, Competitive Decks' : 'Ex: Master Set 151, Decks Competitivos';
  String get inputFolderDesc => isEn ? 'Description (optional)' : 'Descrição (opcional)';
  String get inputInitialMode => isEn ? 'Initial Appearance' : 'Aparência Inicial';
  String get optGridMode => isEn ? 'Grid Mode (Fast Browse)' : 'Modo Grade (Navegação Rápida)';
  String get optBinderMode => isEn ? 'Virtual Binder Mode (3x3 Pages)' : 'Modo Fichário Virtual (Páginas 3x3)';
  String get labelFolderColor => isEn ? 'Collection Color' : 'Cor da Coleção';
  String get labelFolderIcon => isEn ? 'Collection Icon' : 'Ícone da Coleção';
  String get btnCancel => isEn ? 'Cancel' : 'Cancelar';
  String get btnCreate => isEn ? 'Create' : 'Criar';
  String get btnSave => isEn ? 'Save' : 'Salvar';
  String get btnDelete => isEn ? 'Delete' : 'Excluir';
  String get confirmDeleteFolderTitle => isEn ? 'Delete Collection?' : 'Excluir Coleção?';
  String get confirmDeleteFolderMsg => isEn
      ? 'Are you sure you want to delete this collection and its cards?'
      : 'Tem certeza que deseja excluir esta coleção e seus registros?';

  // Folder Detail Screen
  String get folderEmptyToShare => isEn ? 'The folder is empty to share.' : 'O fichário está vazio para compartilhar.';
  String get folderCopiedReadyShare => isEn ? 'Folder list copied and ready to share!' : 'Lista do fichário copiada e pronta para compartilhar!';
  String get tooltipShareFolder => isEn ? 'Share Folder' : 'Compartilhar Fichário';
  String get folderEmptyTitle => isEn ? 'This folder does not have any cards yet.' : 'Este fichário ainda não possui cartas.';
  String get folderEmptySubtitle => isEn ? 'Add cards from Catalog search!' : 'Adicione cartas a partir da busca no Catálogo!';
  String get viewAsBinder => isEn ? 'View as Virtual Binder' : 'Ver como Fichário Virtual';
  String get viewAsGrid => isEn ? 'View as Grid' : 'Ver como Grade';
  String get modePrefix => isEn ? 'Mode: ' : 'Modo: ';
  String get modeBinder => isEn ? 'Virtual Binder' : 'Fichário Virtual';
  String get modeGrid => isEn ? 'Grid' : 'Grade';
  String get searchCardInFolderHint => isEn ? 'Search card in folder by name or #...' : 'Buscar carta na pasta por nome ou #...';
  String cardRemovedFromFolder(String name) => isEn ? '$name removed from folder.' : '$name removida do fichário.';
  String cardRemovedFromCollection(String name) => isEn ? '$name removed from collection.' : '$name removida da coleção.';
  String cardAddedToCollection(String name) => isEn ? '$name added to collection!' : '$name adicionado à coleção!';
  String cardAddedToWishlist(String name) => isEn ? '$name added to Wishlist!' : '$name adicionado à Wishlist!';

  // Portfolio Dashboard
  String get sectionPortfolioSummary => isEn ? 'PORTFOLIO SUMMARY' : 'RESUMO DO PORTFÓLIO';
  String get labelTotalCards => isEn ? 'Total Cards' : 'Total de Cartas';
  String get labelInvested => isEn ? 'Invested' : 'Investido';
  String get labelEstimatedValue => isEn ? 'Estimated Value' : 'Valor Estimado';
  String get labelMarketValue => isEn ? 'Market Value' : 'Valor de Mercado';
  String get labelProfitLoss => isEn ? 'Profit / Loss' : 'Lucro / Prejuízo';
  String get btnShareBinder => isEn ? 'Share Collection' : 'Compartilhar Coleção';
  String get mostValuableCard => isEn ? 'Most Valuable Card' : 'Carta Mais Valiosa';
  String get cardFinishes => isEn ? 'Finishes' : 'Acabamentos';
  String get cardLanguages => isEn ? 'Languages' : 'Idiomas';
  String get unitPcs => isEn ? 'pcs' : 'un';

  // Virtual Binder View
  String get previous => isEn ? 'Previous' : 'Anterior';
  String get next => isEn ? 'Next' : 'Próxima';
  String pageOfTotal(int current, int total) => isEn ? 'Page $current of $total' : 'Página $current de $total';
  String get adjustScale => isEn ? 'Adjust Scale' : 'Ajustar Escala';
  String get viewQuoteAndHistory => isEn ? 'View Quote & History' : 'Ver Cotação e Histórico';
  String get removeFromFolder => isEn ? 'Remove from Folder' : 'Remover do Fichário';
  String get confirmRemoveFromFolderTitle => isEn ? 'Remove from Folder' : 'Remover do Fichário';
  String confirmRemoveFromFolderMsg(String name, String num) => isEn
      ? 'Do you want to remove $name ($num) from this folder?'
      : 'Deseja remover $name ($num) deste fichário?';

  // Card Details Screen
  String get illustratorPrefix => isEn ? 'Illustrator: ' : 'Ilustrador: ';
  String get realTimeMarketQuote => isEn ? 'REAL-TIME MARKET QUOTE' : 'COTAÇÃO EM TEMPO REAL';
  String get usdRatePrefix => isEn ? 'USD Rate: ' : 'Câmbio: ';
  String get nationalMarketBrl => isEn ? 'National Market (BRL)' : 'Mercado Nacional (R\$)';
  String get internationalUsdBrl => isEn ? 'International (USD → BRL)' : 'Internacional (US\$ → R\$)';
  String get priceLow => isEn ? 'Low' : 'Menor';
  String get priceMid => isEn ? 'Mid' : 'Médio';
  String get priceHigh => isEn ? 'High' : 'Maior';
  String get marketUsdLabel => 'Market (US\$)';
  String get convertedBrlLabel => isEn ? 'Converted (BRL)' : 'Convertido (R\$)';
  String get priceHistory30Days => isEn ? 'MARKET HISTORY & TREND' : 'HISTÓRICO E TENDÊNCIA DE MERCADO';
  String get timeRangeWeek => isEn ? '1 Week' : '1 Semana';
  String get timeRangeMonth => isEn ? '1 Month' : '1 Mês';
  String get timeRangeYear => isEn ? '1 Year' : '1 Ano';
  String get timeRangeAll => isEn ? 'Launch' : 'Lançamento';
  String get btnSalesHistory => isEn ? 'Purchase History (Liga & TCGPlayer)' : 'Histórico de Compras (Liga & TCGPlayer)';
  String get salesHistoryTitle => isEn ? 'Completed Purchases History' : 'Histórico de Compras Concluídas';
  String get salesHistorySubtitle => isEn ? 'Real prices paid by buyers (not asking price)' : 'Preços reais pagos por compradores (não apenas anúncio)';
  String get noPurchasesRecorded => isEn ? 'No purchases recorded.' : 'Nenhuma compra registrada.';
  String get conditionPrefix => isEn ? 'Condition: ' : 'Estado: ';
  String get salesAveragePaid => isEn ? 'Average Paid' : 'Média Paga';
  String get salesLowestPaid => isEn ? 'Lowest Paid' : 'Menor Pago';
  String get salesHighestPaid => isEn ? 'Highest Paid' : 'Maior Pago';
  String get salesTotalRecorded => isEn ? 'Recent Sales' : 'Vendas Recentes';
  String get openSalesLiga => isEn ? 'View on LigaPokémon' : 'Ver na LigaPokémon';
  String get openSalesTcg => isEn ? 'View on TCGPlayer' : 'Ver no TCGPlayer';
  String get btnAddToMyCollection => isEn ? 'Add to My Collection' : 'Adicionar à Minha Coleção';
  String get quickActionsTooltip => isEn ? 'Quick Actions' : 'Ações Rápidas';
  String confirmRemoveCardMsg(String name) => isEn
      ? 'Do you want to remove $name from your collection?'
      : 'Deseja remover $name da sua coleção?';

  // Trades
  String get tradesTitle => isEn ? 'Fair Trade Calculator' : 'Calculadora de Trocas Justas';
  String get tradeYouSend => isEn ? 'You Send' : 'Você Envia';
  String get tradeYouReceive => isEn ? 'You Receive' : 'Você Recebe';
  String get tradeFair => isEn ? 'Fair Trade' : 'Troca Justa';
  String get tradeAdvantageous => isEn ? 'Advantageous to You' : 'Vantajosa para Você';
  String get tradeUnfavorable => isEn ? 'Unfavorable to You' : 'Desfavorável para Você';
  String get btnAddCard => isEn ? 'Add Card' : 'Adicionar Carta';
  String get btnCopyTrade => isEn ? 'Copy Trade Summary' : 'Copiar Resumo da Troca';
  String get btnClearTrade => isEn ? 'Clear Trade' : 'Limpar Troca';
  String get tradePromptAddCards => isEn ? 'Add cards to evaluate trade' : 'Adicione cartas para simular a troca';
  String get tradeStatusBalanced => isEn ? 'Balanced Trade (Fair)' : 'Troca Equilibrada (Justa)';
  String get tradeDifferencePrefix => isEn ? 'Difference: ' : 'Diferenca: ';
  String get tradeSummaryCopied => isEn ? 'Trade summary copied to clipboard!' : 'Resumo da troca copiado para a area de transferencia!';
  String get dlgAddCardToTrade => isEn ? 'Add Card to Trade' : 'Adicionar Carta à Troca';
  String get tabMyCollection => isEn ? 'My Collection' : 'Minha Coleção';
  String get tabSearchCatalog => isEn ? 'Search Catalog' : 'Buscar no Catálogo';
  String get noCardsInCollection => isEn ? 'No cards found in your collection.' : 'Nenhuma carta encontrada na sua coleção.';
  String get searchCardByNameHint => isEn ? 'Search card by name...' : 'Buscar carta por nome...';
  String get typeCardNameEnter => isEn ? 'Type card name and press Enter.' : 'Digite o nome da carta e pressione Enter.';

  // Quick Action Sheet & Context Actions
  String get actionAddToCollection => isEn ? 'Add to Collection / Folder' : 'Adicionar à Coleção / Fichário';
  String get actionAddToCollectionSub => isEn ? 'Set condition, finish and purchase price' : 'Definir estado, acabamento e valor pago';
  String get actionAddToWishlist => isEn ? 'Add to Wishlist' : 'Adicionar à Lista de Desejos (Wishlist)';
  String get actionAddToWishlistSub => isEn ? 'Track target price and alerts' : 'Monitorar preço-alvo e alertas';
  String get actionViewDetails => isEn ? 'View Details & Pricing' : 'Ver Detalhes e Cotação';
  String get actionViewDetailsSub => isEn ? 'Compare LigaPokemon vs TCGPlayer in BRL' : 'Comparar LigaPokemon vs TCGPlayer em R\$';
  String get openInLiga => isEn ? 'Open in LigaPokémon (BRL)' : 'Abrir na LigaPokémon (R\$)';
  String get openInTcgPlayer => isEn ? 'Open in TCGPlayer (USD)' : 'Abrir no TCGPlayer (US\$)';
  String get deleteFromCollection => isEn ? 'Remove from Collection' : 'Remover da Coleção';
  String get confirmDeleteCardTitle => isEn ? 'Remove Card?' : 'Remover Carta?';
  String get confirmDeleteCardMsg => isEn
      ? 'Are you sure you want to remove this card from your collection?'
      : 'Tem certeza que deseja remover esta carta da sua coleção?';
  String get labelSelectFolder => isEn ? 'Select Folder' : 'Selecionar Fichário';
  String get labelGeneralCollectionNoFolder => isEn ? 'General Collection (No Folder)' : 'Coleção Geral (Sem Fichário)';
  String get labelPurchasePriceBrl => isEn ? 'Purchase Price (BRL)' : 'Valor Pago (R\$)';
  String get labelQuantity => isEn ? 'Quantity' : 'Quantidade';
  String get labelCondition => isEn ? 'Condition' : 'Estado de Conservação';
  String get labelFinish => isEn ? 'Finish' : 'Acabamento';
  String get labelLanguage => isEn ? 'Card Language' : 'Idioma da Carta';
  String get labelTargetPriceBrl => isEn ? 'Target Price (BRL)' : 'Preço-Alvo (R\$)';
  String get labelPriority => isEn ? 'Priority' : 'Prioridade';

  // Wishlist Screen
  String get wishlistTitle => isEn ? 'Wishlist' : 'Lista de Desejos (Wishlist)';
  String get wishlistEmptyTitle => isEn ? 'Your Wishlist is empty.' : 'Sua Lista de Desejos está vazia.';
  String get wishlistEmptySubtitle => isEn ? 'Add cards from Catalog to track price targets!' : 'Adicione cartas a partir do Catálogo para acompanhar metas de preço!';
  String get targetPricePrefix => isEn ? 'Target: ' : 'Meta: ';
  String get tooltipRemoveFromWishlist => isEn ? 'Remove from Wishlist' : 'Remover da Wishlist';
  String itemRemovedFromWishlist(String name) => isEn ? '$name removed from Wishlist.' : '$name removido da Wishlist.';
  String get priorityHigh => isEn ? 'High' : 'Alta';
  String get priorityMedium => isEn ? 'Medium' : 'Média';
  String get priorityLow => isEn ? 'Low' : 'Baixa';

  String get labelMinPrice => isEn ? 'Min Price (BRL)' : 'Preço Mín (R\$)';
  String get labelMaxPrice => isEn ? 'Max Price (BRL)' : 'Preço Máx (R\$)';
  String get priceRangeLabel => isEn ? 'Target Price Range (BRL)' : 'Faixa de Preço-Alvo (R\$)';
  String get sectionCardInfo => isEn ? 'Card Info' : 'Informações da Carta';
  String get manageWishlistFolders => isEn ? 'Manage Folders' : 'Gerenciar Pastas';
  String get editWishlistFolder => isEn ? 'Rename Folder' : 'Renomear Pasta';
  String get confirmDeleteWishlistFolderTitle => isEn ? 'Delete folder?' : 'Excluir pasta?';
  String confirmDeleteWishlistFolderMsg(String folder) => isEn
      ? 'Cards in "$folder" will be moved to General.'
      : 'As cartas em "$folder" serão movidas para "Geral".';
  String get wishlistFolderUpdated => isEn ? 'Wishlist folders updated.' : 'Pastas da wishlist atualizadas.';
  String get wishlistDesiredCondition => isEn ? 'Desired Condition' : 'Qualidade Desejada';
  String get wishlistDesiredLanguage => isEn ? 'Desired Language' : 'Idioma Desejado';
  String get wishlistDesiredFinish => isEn ? 'Desired Finish' : 'Acabamento Desejado';
  String get wishlistPriceRangeTitle => isEn ? 'Target Price Range' : 'Faixa de Preço Desejada';
  String get wishlistAnyCondition => isEn ? 'Any condition' : 'Qualquer qualidade';
  String get wishlistAnyLanguage => isEn ? 'Any language' : 'Qualquer idioma';
  String get wishlistAnyFinish => isEn ? 'Any finish' : 'Qualquer acabamento';
  String get wishlistMinPrice => isEn ? 'Min (R\$)' : 'Mín (R\$)';
  String get wishlistMaxPrice => isEn ? 'Max (R\$)' : 'Máx (R\$)';
  String get wishlistFolderRenamed => isEn ? 'Folder renamed.' : 'Pasta renomeada.';
  String get wishlistFolderDeleted => isEn ? 'Folder deleted.' : 'Pasta excluída.';
  String get wishlistNewFolderName => isEn ? 'New name' : 'Novo nome';

  // Card Scale Dialog
  String get scaleMenuAndCatalog => isEn ? 'Menu & Catalog' : 'Menu & Catálogo';
  String get scaleCollectionAndBinder => isEn ? 'Collection & Binder' : 'Coleção & Fichário';
  String get scaleMenuTitle => isEn ? 'Scale in Menu and Search' : 'Escala no Menu e Busca';
  String get scaleCollectionTitle => isEn ? 'Scale in Collection and Binder' : 'Escala na Coleção e Fichário';
  String get scaleMenuDesc => isEn
      ? 'Adjust the visual size of cards on the home screen, trending carousel, and Catalog search results.'
      : 'Ajuste o tamanho visual das cartas na tela inicial, carrossel de destaques e resultados de pesquisa do Catálogo.';
  String get scaleCollectionDesc => isEn
      ? 'Adjust the visual size of cards in the Folder Grid and sheet aspect ratio in Virtual Binder.'
      : 'Ajuste o tamanho visual das cartas na Grade de Pastas e proporção da folha no Fichário Virtual.';
  String get tooltipZoomOut => isEn ? 'Decrease Scale' : 'Diminuir Escala';
  String get tooltipZoomIn => isEn ? 'Increase Scale' : 'Aumentar Escala';
  String get btnResetMenuScale => isEn ? 'Reset Menu Default (115%)' : 'Restaurar Padrão do Menu (115%)';
  String get btnResetCollectionScale => isEn ? 'Reset Collection Default (85%)' : 'Restaurar Padrão da Coleção (85%)';

  // Universal Grid Composition
  String get gridCompositionTooltip => isEn ? 'Grid Layout (2x2, 3x3, etc.)' : 'Composição da Grade (2x2, 3x3, etc.)';
  String get gridCompAuto => isEn ? 'Auto (Responsive)' : 'Automático (Responsivo)';
  String get gridComp2x2 => isEn ? '2 Columns (2x2 Large)' : '2 Colunas (2x2 Grande)';
  String get gridComp3x3 => isEn ? '3 Columns (3x3 Binder)' : '3 Colunas (3x3 Fichário)';
  String get gridComp4x4 => isEn ? '4 Columns (4x4 Compact)' : '4 Colunas (4x4 Compacto)';
  String get gridComp5x5 => isEn ? '5 Columns (5x5 Dense)' : '5 Colunas (5x5 Denso)';
  String get gridComp6x6 => isEn ? '6 Columns (6x6 Panorama)' : '6 Colunas (6x6 Panorama)';
  String get gridCompFineTune => isEn ? 'Fine-tune Scale...' : 'Ajuste Fino de Escala...';

  // Price Alerts Widget
  String get portfolioActiveMonitoring => isEn ? 'Active Portfolio Monitoring' : 'Monitoramento Ativo da Carteira';
  String get portfolioMonitoringSubtitle => isEn
      ? 'Add cards to your collection to receive automatic value change updates.'
      : 'Adicione cartas à sua coleção para receber avisos automáticos de valorização.';
  String cardInMonitoring(String title) => isEn ? '$title in monitoring' : '$title em monitoramento';
  String get pricesStable24h => isEn ? 'Stable prices in the last 24h' : 'Cotações estáveis nas últimas 24h';
  String alertCardsSurging(int count) => isEn ? '$count surging' : '$count em alta';

  // Filter labels in Catalog
  String get filterTypeLabel => isEn ? 'Type: ' : 'Tipo: ';
  String get filterRarityLabel => isEn ? 'Rarity: ' : 'Raridade: ';
  String get filterByType => isEn ? 'Type' : 'Tipo';

  // Marketplace URLs
  String errOpenMarketplace(String platform) => isEn
      ? 'Unable to open $platform link.'
      : 'Não foi possível abrir o link da $platform.';
  String errOpenBrowser(String platform) => isEn
      ? 'Error opening $platform in browser.'
      : 'Erro ao abrir $platform no navegador.';

  // Top 10 & Portfolio Metrics
  String get top10ValuableCards => isEn ? 'TOP 10 MOST VALUABLE CARDS' : 'TOP 10 CARTAS MAIS VALIOSAS';
  String get top5ValuableCards => top10ValuableCards;
  String get sectionPortfolioMetrics => isEn ? 'PORTFOLIO METRICS' : 'MÉTRICAS DO PORTFÓLIO';
  String get podiumTitle => isEn ? 'PODIUM' : 'PÓDIO';
  String get viewPodium => isEn ? 'View podium' : 'Ver pódio';
  String get ranked4To10Title => isEn ? 'RANKINGS 4-10' : 'CLASSIFICAÇÃO 4-10';
  String get dualCurrencyTotal => isEn ? 'Combined Portfolio Total' : 'Total Geral do Acervo';

  // Wishlist & Opportunity Alerts
  String get targetPriceReached => isEn ? 'Target Price Met' : 'Meta Atingida';
  String get goodOpportunity => isEn ? 'Good Opportunity' : 'Boa Oportunidade';
  String get aboveTarget => isEn ? 'Above Target' : 'Acima da Meta';
  String get currentMarketPrice => isEn ? 'Current Market' : 'Mercado Atual';
  String get btnAddToWishlist => isEn ? 'Add to Wishlist' : 'Adicionar à Wishlist';
  String get editWishlistItem => isEn ? 'Edit Target Price' : 'Editar Preço-Alvo';
  String get targetPricePrompt => isEn ? 'Define your target purchase price:' : 'Defina seu preço-alvo de compra:';
  String get backupAndRestore => isEn ? 'Backup & Restore' : 'Backup e Restauração';
  String get wishlistFolderAll => isEn ? 'All Folders' : 'Todas as Pastas';
  String get wishlistNewFolder => isEn ? 'New Folder' : 'Nova Pasta';
  String get wishlistFolderNamePrompt => isEn ? 'Enter folder name:' : 'Digite o nome da pasta:';
  String get wishlistFolderNameLabel => isEn ? 'Folder Name' : 'Nome da Pasta';
  String get wishlistFolderDefault => isEn ? 'General' : 'Geral';
  String get wishlistSortTitle => isEn ? 'Sort Wishlist' : 'Ordenar Wishlist';
  String get wishlistSortNewest => isEn ? 'Recently Added' : 'Mais Recentes';
  String get wishlistSortPriceAsc => isEn ? 'Target Price: Low to High' : 'Preço-Alvo: Menor para Maior';
  String get wishlistSortPriceDesc => isEn ? 'Target Price: High to Low' : 'Preço-Alvo: Maior para Menor';
  String get wishlistSortNameAsc => isEn ? 'Card Name (A - Z)' : 'Nome da Carta (A - Z)';
  String get wishlistSortPriority => isEn ? 'Priority (High first)' : 'Prioridade (Alta primeiro)';
  String get wishlistSortSetName => isEn ? 'Set Name' : 'Coleção / Expansão';
  String get wishlistMoveToCollection => isEn ? 'Purchased / Move to Collection' : 'Comprei / Mover para Coleção';
  String get wishlistMoveToCollectionSuccess => isEn ? 'Card moved to your collection!' : 'Carta movida para a sua coleção!';
  String get wishlistChangeFolder => isEn ? 'Change Folder' : 'Alterar Pasta';

  // Booster Pack Simulator
  String get boosterSimulator => isEn ? 'Booster Simulator' : 'Simulador de Booster';
  String get openBooster => isEn ? 'Open Booster Pack' : 'Abrir Booster Pack';
  String get openAnotherBooster => isEn ? 'Open Another Pack' : 'Abrir Outro Pacote';
  String get selectPackFormat => isEn ? 'Select Booster Format' : 'Selecione o Formato do Pacote';
  String get packFormatUsa => isEn ? '10 Cards (USA / International)' : '10 Cartas (USA / Internacional)';
  String get packFormatBra => isEn ? '6 Cards (Brazil / Copag)' : '6 Cartas (Brasil / Copag)';
  String get packFormatUsaSub => isEn ? '5 Commons, 3 Uncommons, 1 Reverse Holo, 1 Rare/Chase' : '5 Comuns, 3 Incomuns, 1 Reverse Holo, 1 Rara/Secreta';
  String get packFormatBraSub => isEn ? '3 Commons, 2 Uncommons, 1 Rare/Holo/Reverse' : '3 Comuns, 2 Incomuns, 1 Rara/Holo/Reverse';
  String get packTearInstruction => isEn ? 'Tap or slide down to tear open the pack!' : 'Toque ou deslize para baixo para abrir o pacote!';
  String cardRevealRemaining(int remaining) => isEn ? '$remaining cards remaining' : '$remaining cartas restantes';
  String get lastCardReveal => isEn ? 'Final Rare Card!' : 'Carta Rara Final!';
  String get boosterSummaryTitle => isEn ? 'Pack Opening Result' : 'Resultado da Abertura do Pacote';
  String get totalPackMarketValue => isEn ? 'Total Pack Value' : 'Valor Total do Pacote';
  String get packSimulatorDisclaimer => isEn ? 'Pure simulation for fun • Cards are not saved to collection' : 'Simulação recreativa • As cartas não são adicionadas ao acervo';

  // Holographic 3D Tilt Inspector
  String get holographicInspector => isEn ? '3D Holographic View' : 'Visualizador Holográfico 3D';
  String get holographicHint => isEn ? 'Move cursor or drag to tilt and inspect foil shine' : 'Mova o cursor ou arraste para inclinar e inspecionar o brilho foil';
  String get btnInspectHolo => isEn ? '3D Foil View' : 'Ver em 3D Foil';
  String get btnView3dFoil => btnInspectHolo;

  // Additional Booster Simulator & Target Price aliases
  String get boosterSimulatorTitle => boosterSimulator;
  String get tearBoosterButton => isEn ? 'Tear Booster' : 'Rasgar Booster';
  String get boosterFormatUsa10 => packFormatUsa;
  String get boosterFormatBrazil6 => packFormatBra;
  String revealingCardCount(int current, int total) => isEn ? 'Card $current of $total' : 'Carta $current de $total';
  String get viewBoosterSummary => isEn ? 'View Pack Summary' : 'Ver Resumo do Pacote';
  String get nextCardButton => isEn ? 'Next Card' : 'Próxima Carta';
  String get totalPackValueTitle => totalPackMarketValue;
  String get boosterSimulationNotice => packSimulatorDisclaimer;
  String get bestPullBadge => isEn ? 'BEST PULL' : 'MAIOR HIT';
  String get close => isEn ? 'Close' : 'Fechar';
  String get openAnotherBoosterButton => openAnotherBooster;
  String get labelTargetPriceUsd => isEn ? 'Target Price (USD)' : 'Preço-Alvo (USD)';
  String get godPackDetected => isEn ? 'GOD PACK DETECTED!' : 'GOD PACK DETECTADO!';
  String get godPackSubtitle => isEn ? 'Every card in this booster is an ultra rare chase hit!' : 'Todas as cartas deste booster são ultra raras especiais!';
  String get testGodPack => isEn ? 'Force God Pack' : 'Forçar God Pack';

  // Backup & Restore
  String get backupExportSuccess => isEn ? 'Backup exported successfully!' : 'Backup exportado com sucesso!';
  String get backupExportFailed => isEn ? 'Export cancelled or failed.' : 'Exportação cancelada ou falhou.';
  String get backupRestoreTitle => isEn ? 'Restore Collection' : 'Restaurar Coleção';
  String get backupRestoreExplanation => isEn
      ? 'Choose how you want to import the JSON backup:\n\n'
        '• Replace: wipes current collection and loads exactly the file data.\n'
        '• Merge: keeps your existing cards and adds cards from the file.'
      : 'Escolha como deseja importar o backup JSON:\n\n'
        '• Substituir: apaga a coleção atual e carrega exatamente os dados do arquivo.\n'
        '• Mesclar: mantém suas cartas atuais e adiciona as cartas do arquivo.';
  String get backupMerge => isEn ? 'Merge' : 'Mesclar';
  String get backupReplaceAll => isEn ? 'Replace All' : 'Substituir Tudo';
  String backupMergedCount(int count) => isEn ? '$count records merged successfully!' : '$count registros mesclados com sucesso!';
  String backupRestoredCount(int count) => isEn ? 'Collection restored with $count cards!' : 'Coleção restaurada com $count cartas!';
  String get backupInvalidFile => isEn ? 'Invalid file or error.' : 'Arquivo inválido ou erro.';

  // Trade Evaluator
  String get tradeEvaluationHeader => isEn ? 'TRADE EVALUATION' : 'AVALIAÇÃO DE TROCA';
  String get totalSent => isEn ? 'Total Sent' : 'Total Enviado';
  String get totalReceived => isEn ? 'Total Received' : 'Total Recebido/Ganho';
  String get youSendTitle => isEn ? 'You Send' : 'Você Envia';
  String get youSendSubtitle => isEn ? 'Left: Your Offer' : 'Esquerda: O que você envia';
  String get youGetTitle => isEn ? 'You Get' : 'Você Ganha';
  String get youGetSubtitle => isEn ? 'Right: What you receive' : 'Direita: O que você recebe';
  String get noCardsAdded => isEn ? 'No cards added.' : 'Nenhuma carta adicionada.';
  String get btnAdd => isEn ? 'Add' : 'Adicionar';

  // Collection & Set Filters
  String filterAllCards(int count) => isEn ? 'All Cards ($count)' : 'Todas as Cartas ($count)';
  String filterMissing(int count) => isEn ? 'Missing ($count)' : 'Faltantes ($count)';
  String filterOwned(int count) => isEn ? 'Owned ($count)' : 'Já Tenho ($count)';
  String get defaultRarity => isEn ? 'Collectible' : 'Colecionável';
  String get binderHeaderDefault => isEn ? 'BINDER' : 'FICHÁRIO';

  // Wishlist & Generic Helpers
  String get targetBudget => isEn ? 'Target Budget' : 'Orçamento Alvo';
  String cardsCountLabel(int count) => '$count ${isEn ? "cards" : "cartas"}';
  String errorWithMsg(dynamic err) => '${isEn ? "Error" : "Erro"}: $err';
  String errorLoadingWithMsg(dynamic err) => '${isEn ? "Error loading" : "Erro ao carregar"}: $err';

  // Quick Action Sheet & Card Tooltips
  String get viewOffersBrazil => isEn ? 'View offers and listings in Brazil (BRL)' : 'Ver ofertas e anúncios no Brasil (R\$)';
  String get viewMarketplaceInternational => isEn ? 'View international marketplace (USD)' : 'Ver mercado internacional (US\$)';
  String get copyFormattedIdentifier => isEn ? 'Copy Formatted Identifier' : 'Copiar Código Formatado';
  String copiedCode(String code) => isEn ? 'Copied: $code' : 'Copiado: $code';
  String addCardTitle(String name) => isEn ? 'Add $name' : 'Adicionar $name';
  String get saveToCollection => isEn ? 'Save to Collection' : 'Salvar na Coleção';
  String get saveToWishlist => isEn ? 'Save to Wishlist' : 'Salvar Desejo';
  String get alertPriceDropHelper => isEn ? 'Alerts if price drops below target' : 'Avisa se o preço ficar abaixo deste valor';
  String get notesObservationsLabel => isEn ? 'Notes / Observations' : 'Notas / Observações';
  String get notesObservationsHint => isEn ? 'e.g. Looking for Holofoil version' : 'Ex: Procurando versão Foil';
  String get filtersAndMore => isEn ? 'Filters & More' : 'Filtros e Mais';
  String get copyTradeSummaryTooltip => isEn ? 'Copy Trade Summary' : 'Copiar Resumo da Troca';

  // Price Monitoring Tab (Complete Feature & by Collection)
  String get monitoringTabTitle => isEn ? 'Price Monitoring' : 'Monitoramento de Preços';
  String get monitoringTabSubtitle => isEn
      ? 'Track market fluctuations, ROI and net gains by collection'
      : 'Acompanhe oscilações de mercado, ROI e lucros líquidos por coleção';
  String get allCollectionsChip => isEn ? 'All Collections' : 'Todas as Coleções';
  String get generalCollectionOnly => isEn ? 'General Collection (No Folder)' : 'Coleção Geral (Sem Pasta)';
  String get filterGainers => isEn ? 'Surging (+)' : 'Em Alta (+)';
  String get filterLosers => isEn ? 'Dropping (-)' : 'Em Baixa (-)';
  String get filterStableTrend => isEn ? 'Stable (±2%)' : 'Estáveis (±2%)';
  String get filterAllTrend => isEn ? 'All Cards' : 'Todas as Cartas';
  String get sortGainPct => isEn ? 'Highest % Gain' : 'Maior Valorização (%)';
  String get sortGainNominal => isEn ? 'Highest Profit' : 'Maior Lucro Nominal';
  String get sortLoss => isEn ? 'Biggest Drop' : 'Maior Queda';
  String get sortCurrentValue => isEn ? 'Highest Value' : 'Maior Valor Atual';
  String get sortRecentlyAdded => isEn ? 'Recently Added' : 'Mais Recentes';
  String get kpiTotalInvested => isEn ? 'Total Invested' : 'Total Investido';
  String get kpiCurrentValue => isEn ? 'Current Market Value' : 'Valor de Mercado Atual';
  String get kpiNetProfit => isEn ? 'Net Result (ROI)' : 'Resultado Líquido (ROI)';
  String get searchMonitoredHint => isEn ? 'Search card by name or #...' : 'Buscar carta por nome ou #...';
  String get noMonitoredCardsFound => isEn ? 'No cards match this filter.' : 'Nenhuma carta corresponde a este filtro.';
  String get noCardsInMonitoredFolder => isEn ? 'This collection does not have any cards yet.' : 'Esta coleção ainda não possui cartas.';
  String get btnEditPurchasePrice => isEn ? 'Edit Purchase Price' : 'Editar Valor Pago';
  String get editPurchasePriceTitle => isEn ? 'Edit Purchase Price' : 'Atualizar Preço de Compra';
  String get editPurchasePricePrompt => isEn
      ? 'Update the amount you originally paid in BRL (R\$):'
      : 'Informe o valor que você pagou por esta carta em R\$:';
  String get purchasePriceUpdatedSuccess => isEn ? 'Purchase price updated!' : 'Preço pago atualizado com sucesso!';
  String get paidPricePrefix => isEn ? 'Paid: ' : 'Pago: ';
  String get currentPricePrefix => isEn ? 'Now: ' : 'Agora: ';
  String get sortingMenuTooltip => isEn ? 'Sort Cards' : 'Ordenar Cartas';

  // Liga Radar & Pre-Sale Strings
  String get ligaRadarTitle => isEn ? 'LigaPokémon Radar' : 'Radar LigaPokémon';
  String get ligaRadarSubtitle => isEn
      ? 'Target price drops & pre-orders tracking'
      : 'Monitore faixas de preço e ofertas em pré-venda';
  String get btnAddAlert => isEn ? 'Monitor Product' : 'Monitorar Produto';
  String get btnCheckAllNow => isEn ? 'Check Prices Now' : 'Verificar Preços Agora';
  String get checkingAlerts => isEn ? 'Checking LigaPokémon...' : 'Consultando LigaPokémon...';
  String alertsCheckedSuccess(int count) => isEn
      ? '$count deals found in target range!'
      : '$count ofertas encontradas na faixa desejada!';
  String get lowestPriceUpdatedText => isEn ? 'Lowest price updated' : 'Menor preço atualizado';
  String get statusInRange => isEn ? 'In Target Range' : 'Dentro da Faixa';
  String get statusAboveRange => isEn ? 'Above Target' : 'Acima da Faixa';
  String get statusBelowRange => isEn ? 'Below Target' : 'Abaixo da Faixa';
  String get statusOutOfStock => isEn ? 'Out of Stock' : 'Sem Estoque';
  String get statusPreSale => isEn ? 'Pre-Order' : 'Pré-Venda';
  String get allowPreSaleLabel => isEn ? 'Include Pre-Orders' : 'Permitir itens em Pré-Venda';
  String get allowPreSaleDesc => isEn
      ? 'Alert if pre-sale deals match price range'
      : 'Ativar aviso quando ofertas em pré-venda entrarem na faixa';
  String get targetRangeLabel => isEn ? 'Target Price Range' : 'Faixa de Preço Desejada';
  String get minPriceLabel => isEn ? 'Min Price (R\$)' : 'Preço Mínimo (R\$)';
  String get maxPriceLabel => isEn ? 'Max Price (R\$)' : 'Preço Máximo (R\$)';
  String get urlOrQueryLabel => isEn ? 'LigaPokémon Link or Card Name' : 'Link da LigaPokémon ou Nome';
  String get urlOrQueryHint => isEn
      ? 'Paste URL from ligapokemon.com.br or type name'
      : 'Cole o link de ligapokemon.com.br ou digite o nome';
  String get deleteAlertTitle => isEn ? 'Remove Monitored Item' : 'Remover Monitoramento';
  String get deleteAlertConfirm => isEn
      ? 'Stop monitoring this product?'
      : 'Deseja parar de monitorar este produto?';
  String get emptyRadarTitle => isEn ? 'No monitored products yet' : 'Nenhum produto monitorado ainda';
  String get emptyRadarSubtitle => isEn
      ? 'Add a card or sealed item link from LigaPokémon to receive alerts when available in your price range.'
      : 'Adicione o link de uma carta ou produto da LigaPokémon para ser avisado quando entrar na faixa de preço desejada.';
  String get filterAllAlerts => isEn ? 'All' : 'Todos';
  String get filterInRangeAlerts => isEn ? 'In Range' : 'Na Faixa';
  String get filterPreSaleAlerts => isEn ? 'Pre-Order' : 'Pré-Venda';
  String get filterActiveAlerts => isEn ? 'Active' : 'Ativos';
  String get filterByCollection => isEn ? 'Collection' : 'Coleção';
  String get filterAllCollections => isEn ? 'All collections' : 'Todas as coleções';
  String get filterByLanguage => isEn ? 'Language' : 'Idioma';
  String get filterAllLanguages => isEn ? 'All languages' : 'Todos os idiomas';
  String get collectionLabel => isEn ? 'Collection' : 'Coleção';
  String get collectionHint => isEn
      ? 'e.g. Scarlet & Violet - 151'
      : 'Ex: Scarlet & Violet - 151';
  String get languageLabel => isEn ? 'Language' : 'Idioma';
  String get languageHint => isEn
      ? 'e.g. PT, EN, JP... (blank = Portuguese)'
      : 'Ex: PT, EN, JP... (vazio = Português)';
  String languageDisplayName(String code) {
    switch (code.toLowerCase()) {
      case 'en':
        return isEn ? 'English' : 'Inglês';
      case 'pt':
        return 'Português';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'zh-hans':
        return '简体中文';
      case 'zh-hant':
        return '繁體中文';
      default:
        return code.toUpperCase();
    }
  }
  String get kpiMonitoredTotal => isEn ? 'Monitored' : 'Monitorados';
  String get kpiInRangeTotal => isEn ? 'In Range' : 'Na Faixa';
  String get kpiPreSaleTotal => isEn ? 'Pre-Orders' : 'Em Pré-Venda';
  String get lastCheckedPrefix => isEn ? 'Checked: ' : 'Checado: ';
  String get neverChecked => isEn ? 'Never' : 'Nunca';
  String get lowestPricePrefix => isEn ? 'Lowest: ' : 'Menor: ';
  String get targetRangePrefix => isEn ? 'Target: ' : 'Alvo: ';
  String get activeToggle => isEn ? 'Active' : 'Ativo';
  String get inactiveToggle => isEn ? 'Paused' : 'Pausado';
  String get previewProductButton => isEn ? 'Search / Preview' : 'Consultar / Prévia';
  String get fetchingProductDetails => isEn ? 'Fetching product...' : 'Buscando informações...';
  String get registeredStoreLabel => isEn ? 'Store: ' : 'Loja: ';
  String get currentLowestPriceLabel => isEn ? 'Current Lowest Price' : 'Menor Preço Atual';
  String get monitoringBarTitle => isEn ? 'Active Monitoring' : 'Monitoramento Ativo';
  String get bestDealFound => isEn ? 'Lowest Price:' : 'Menor Preço:';
  String get marketplaceFallback => isEn ? 'Marketplace (LigaPokémon)' : 'Marketplace (LigaPokémon)';
  String get storeSellerHeader => isEn ? 'STORE / SELLER' : 'LOJA / VENDEDOR';
  String get currentLowestPriceHeader => isEn ? 'CURRENT LOWEST PRICE' : 'MENOR PREÇO ATUAL';
  String get targetRangeLabelText => isEn ? 'Target range: ' : 'Faixa desejada: ';
  String get openOfferInBrowser => isEn ? 'Open deal in browser' : 'Abrir oferta no navegador';
  String get noPriceCeiling => isEn ? 'No limit' : 'Sem teto';
  String get statusPending => isEn ? 'Pending...' : 'Aguardando...';
  String get preSaleAcceptedTag => isEn ? 'Pre-orders accepted' : 'Pré-venda aceita';
  String get filterProductsHint => isEn ? 'Filter products...' : 'Filtrar produtos...';
  String get alertUrlOrNameRequired => isEn
      ? 'Please enter the LigaPokémon product URL or name'
      : 'Informe o link ou nome do produto na LigaPokémon';
  String get alertTitleRequired => isEn
      ? 'Please provide a display name for the product'
      : 'Informe o nome para o produto';
  String get adjustGridOption => isEn ? 'Adjust Grid (2x2, 3x3, etc.)' : 'Ajustar Grade (2x2, 3x3, etc.)';
  String get viewAsList => isEn ? 'View as List' : 'Exibir em Lista';
  String get switchToBrl => isEn ? 'Switch to BRL (R\$)' : 'Mudar para Real (R\$)';
  String get switchToUsd => isEn ? 'Switch to USD (\$)' : 'Mudar para Dólar (\$)';
  String get priceMonitor => isEn ? 'Price Monitor' : 'Monitor de Preços';
  String get totalValue => isEn ? 'Total Value' : 'Preço Total';
  String get mostCommon => isEn ? 'Most Common' : 'Mais Comum';
  String get avgCondition => isEn ? 'Avg Condition' : 'Qualidade Média';
  String get collectionStats => isEn ? 'Collection Stats' : 'Resumo do Fichário';
  String get searchCardInSetHint => isEn ? 'Search card in set...' : 'Buscar carta na coleção...';
  String get comingSoon => isEn ? 'Coming soon' : 'Em breve';
  String get comingSoonExpected => isEn ? 'Coming soon (expected date)' : 'Em breve (data prevista)';
  String get noSealedProductsListed => isEn ? 'No sealed products listed' : 'Nenhum produto selado disponível';

  // Liga Radar background monitoring settings
  String get radarBackgroundSettings => isEn ? 'Background Monitoring' : 'Verificação em Segundo Plano';
  String get radarBackgroundSettingsTooltip => isEn
      ? 'Background monitoring options'
      : 'Opções de verificação em segundo plano';
  String get radarBackgroundEnabledLabel => isEn ? 'Monitor in background' : 'Monitorar em segundo plano';
  String get radarBackgroundEnabledDesc => isEn
      ? 'Checks the prices of active monitored products periodically, even while the app runs in background.'
      : 'Verifica periodicamente os preços dos produtos ativos no monitoramento, mesmo quando o app está em segundo plano.';
  String get radarBackgroundIntervalLabel => isEn ? 'Check interval' : 'Intervalo de verificação';
  String get radarBackgroundIntervalDesc => isEn
      ? 'Only products activated in monitoring are checked.'
      : 'Somente os produtos ativados no monitoramento são verificados.';
  String get radarBackgroundIntervalTypeHint => isEn
      ? 'Type the interval in minutes (minimum 5).'
      : 'Digite o intervalo em minutos (mínimo 5).';
  String get radarBackgroundNote => isEn
      ? 'The app needs to be running on the device for checks to happen.'
      : 'O app precisa estar em execução no dispositivo para que as verificações ocorram.';

  // Monitoring / portfolio strings (Bug fix: Portuguese leaked into English mode)
  String monitorSurging(int count) => isEn ? '▲ $count surging' : '▲ $count em alta';
  String monitorDropping(int count) => isEn ? '▼ $count dropping' : '▼ $count em baixa';
  String get noPricePaid => isEn ? 'No price paid' : 'Sem valor pago';
  String errorMessage(String err) => isEn ? 'Error: $err' : 'Erro: $err';
  String get profitText => isEn ? '+ profit' : '+ lucro';
  String get lossText => isEn ? '- loss' : '- perda';
  String get tradeLeftLabel => isEn ? '[LEFT]' : '[ESQUERDA]';
  String get tradeRightLabel => isEn ? '[RIGHT]' : '[DIREITA]';

  // Graded card badge label (PT 'Graduada' leaked into English mode)
  String get gradedShortLabel => isEn ? 'Graded' : 'Graduada';

  // Folder icon picker tooltips
  String folderIconLabel(String key) {
    final labels = isEn
        ? {
            'folder': 'Folder',
            'star': 'Favorites',
            'local_fire_department': 'Fire',
            'water_drop': 'Water',
            'bolt': 'Lightning',
            'grass': 'Grass',
            'psychology': 'Psychic',
            'shield': 'Steel',
            'military_tech': 'Competitive',
            'pest_control': 'Wurmple',
            'emoji_events': 'Trophy',
            'diamond': 'Rare',
            'inventory_2': 'Vault',
            'sell': 'Trades',
            'bookmark': 'Highlights',
          }
        : {
            'folder': 'Pasta',
            'star': 'Favoritas',
            'local_fire_department': 'Fogo',
            'water_drop': 'Agua',
            'bolt': 'Eletrico',
            'grass': 'Planta',
            'psychology': 'Psiquico',
            'shield': 'Aco',
            'military_tech': 'Competitivo',
            'pest_control': 'Wurmple',
            'emoji_events': 'Trofeu',
            'diamond': 'Raras',
            'inventory_2': 'Cofre',
            'sell': 'Trocas',
            'bookmark': 'Destaques',
          };
    return labels[key] ?? labels['folder']!;
  }
}

AppStrings getStrings(AppLanguage language) => AppStrings(language);

final appStringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(languageProvider);
  return getStrings(lang);
});
