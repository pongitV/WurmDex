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

  // Status & Financial Indicators
  static const profitGreen = Color(0xFF10B981);
  static const lossRed = Color(0xFFEF4444);
  static const warningYellow = Color(0xFFF59E0B);
  static const goldRarity = Color(0xFFFFD700);
}
