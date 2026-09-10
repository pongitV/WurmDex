import 'package:flutter/material.dart';

class AppColors {
  // Shared Red Accent for Dark and Light themes
  static const redAccent = Color(0xFFE11D48); // Vermelho vibrante moderno
  static const redAccentHover = Color(0xFFBE123C);

  // Dark Theme (Preto Profundo com Acento Vermelho)
  static const darkBackground = Color(0xFF000000); // Preto puro
  static const darkSurface = Color(0xFF141416); // Superfícies e cards bem escuros
  static const darkBorder = Color(0xFF26262A);
  static const darkTextPrimary = Color(0xFFEDEDED);
  static const darkTextSecondary = Color(0xFFA1A1AA);
  static const darkAccent = redAccent; // Acento Vermelho
  static const darkCyan = Color(0xFF38BDF8);

  // Light Theme (Branco de página de livro velho / bege suave aos olhos + Acento Lacre Carmesim)
  static const lightBackground = Color(0xFFF5F0E6); // Branco de folha de livro antigo / bege suave e leve aos olhos
  static const lightSurface = Color(0xFFFAF6EE); // Face da página / cartões em pergaminho suave
  static const lightSurfaceAlt = Color(0xFFECE5D5); // Superfície intermediária rebaixada / inputs
  static const lightBorder = Color(0xFFDED5C1); // Borda e lombada tom papel envelhecido
  static const lightTextPrimary = Color(0xFF2A231E); // Tinta sépia / carvão clássico (alto contraste sem agredir os olhos)
  static const lightTextSecondary = Color(0xFF6B6055); // Tinta nogueira suave para legendas
  static const lightAccent = Color(0xFF9E2A2B); // Vermelho carmesim de lacre clássico de livro
  static const lightAccentHover = Color(0xFF7E2122);

  // Gramado Theme (Antigo verde - Tons botânicos e relva)
  static const gramadoBackground = Color(0xFF132B1A); // Verde profundo sombreado da relva
  static const gramadoSurface = Color(0xFF1C3B24); // Verde vegetação da ilustração
  static const gramadoSurfaceLight = Color(0xFF2C5C38); // Verde folha intermediário
  static const gramadoBorder = Color(0xFF3B724A); // Borda verde vegetal
  static const gramadoPrimary = Color(0xFF60B478); // Verde relva vibrante
  static const gramadoPrimaryHover = Color(0xFF4FA066);
  static const gramadoSecondary = Color(0xFFD2DE54); // Verde limão da energia Planta TCG
  static const gramadoAccent = Color(0xFFF8D888); // Amarelo dente-de-leão
  static const gramadoTextPrimary = Color(0xFFF0FDF4); // Branco menta de alto contraste
  static const gramadoTextSecondary = Color(0xFFA7F3D0); // Menta suave para subtítulos

  // Wurmple Theme (Cores extraídas diretamente do ícone do Wurmple: #DC6A71 corpo, #F4E1A0 chifres, #D2CAB8 ventre e #210C08 contornos)
  static const wurmpleBackground = Color(0xFF1B0A07); // Tom escuro profundo derivado dos contornos do ícone (#210C08)
  static const wurmpleSurface = Color(0xFF2E1915); // Superfície café/espresso dos contornos do ícone (#2E1915)
  static const wurmpleSurfaceLight = Color(0xFF45241E); // Tom intermediário quente derivado
  static const wurmpleBorder = Color(0xFF5C332B); // Borda café tostado suave
  static const wurmplePrimary = Color(0xFFDC6A71); // Rosa coral do corpo do Wurmple (#DC6A71)
  static const wurmplePrimaryHover = Color(0xFFC7575E);
  static const wurmpleSecondary = Color(0xFFF4E1A0); // Amarelo suave dos chifres e espinho do Wurmple (#F4E1A0)
  static const wurmpleAccent = Color(0xFFD2CAB8); // Creme/bege do ventre e manchas do Wurmple (#D2CAB8)
  static const wurmpleTextPrimary = Color(0xFFF3EDE9); // Marfim claro de destaque do ícone (#F3EDE9)
  static const wurmpleTextSecondary = Color(0xFFD2CAB8); // Creme suave para textos secundários

  // Lugia Theme (#249 - Deep Oceanic Silver-Blue & Aerilate Indigo)
  // Cores extraídas diretamente da arte do Lugia (#249): Tons de azul marinho profundo sem fundo branco
  static const lugiaBackground = Color(0xFF09111E); // Azul marinho abissal profundo
  static const lugiaSurface = Color(0xFF101F35); // Superfície oceânica aerilate
  static const lugiaSurfaceLight = Color(0xFF182D4B); // Superfície intermediária
  static const lugiaBorder = Color(0xFF223E63); // Borda azul aço/escamas
  static const lugiaPrimary = Color(0xFF3B82F6); // Azul royal do ventre e olho do Lugia
  static const lugiaPrimaryHover = Color(0xFF2563EB);
  static const lugiaSecondary = Color(0xFF60A5FA); // Azul cerúleo das nadadeiras e crista
  static const lugiaAccent = Color(0xFF93C5FD); // Destaque prata-azulado
  static const lugiaTextPrimary = Color(0xFFF0F6FC); // Branco prateado de alto contraste
  static const lugiaTextSecondary = Color(0xFF94A3B8); // Ardósia suave para subtítulos

  // Wurmple Shiny Theme (#265 Shiny - Violeta Cósmico com Chifres Dourados)
  static const wurmpleShinyBackground = Color(0xFF130722); // Roxo escuro profundo
  static const wurmpleShinySurface = Color(0xFF210E3B); // Superfície ametista escura
  static const wurmpleShinyBorder = Color(0xFF452077); // Borda violeta radiante
  static const wurmpleShinyPrimary = Color(0xFFA855F7); // Roxo vibrante do corpo do Wurmple Shiny
  static const wurmpleShinySecondary = Color(0xFFFACC15); // Amarelo dourado dos chifres
  static const wurmpleShinyTextPrimary = Color(0xFFFAF5FF); // Branco lilás de alto contraste
  static const wurmpleShinyTextSecondary = Color(0xFFC084FC); // Lavanda suave

  // Lugia Shiny Theme (#249 Shiny - Ventre Carmesim/Rosa com Asas Prateadas)
  static const lugiaShinyBackground = Color(0xFF0C0E1E); // Noite oceânica profunda
  static const lugiaShinySurface = Color(0xFF181B34); // Superfície anil
  static const lugiaShinyBorder = Color(0xFF383C66); // Borda prata-azulada
  static const lugiaShinyPrimary = Color(0xFFE11D48); // Vermelho carmesim do ventre e crista do Lugia Shiny
  static const lugiaShinySecondary = Color(0xFFFB7185); // Rosa do ventre
  static const lugiaShinyTextPrimary = Color(0xFFFFF1F2); // Branco rosa de alto contraste
  static const lugiaShinyTextSecondary = Color(0xFFFDA4AF); // Rosa suave

  // Dark Lugia Theme (Shadow Lugia XD001 - Corrupção Abissal com Olho Carmesim)
  static const darkLugiaBackground = Color(0xFF090512); // Preto sombra abissal
  static const darkLugiaSurface = Color(0xFF150D24); // Superfície sombra escura
  static const darkLugiaBorder = Color(0xFF3D1E63); // Borda púrpura corrompida
  static const darkLugiaPrimary = Color(0xFF9333EA); // Roxo espectral do Dark Lugia
  static const darkLugiaSecondary = Color(0xFFEF4444); // Vermelho vivo do olho sinistro
  static const darkLugiaTextPrimary = Color(0xFFF5F3FF); // Branco espectral
  static const darkLugiaTextSecondary = Color(0xFFA855F7); // Violeta sombra

  // Status & Financial Indicators
  static const profitGreen = Color(0xFF10B981);
  static const lossRed = Color(0xFFEF4444);
  static const warningYellow = Color(0xFFF59E0B);
  static const goldRarity = Color(0xFFFFD700);
}
