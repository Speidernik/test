import 'package:flutter/material.dart';

class AppStrings {
  final Locale locale;
  const AppStrings(this.locale);

  static const supportedLocales = [Locale('en'), Locale('de')];

  String _t(String en, String de) => locale.languageCode == 'de' ? de : en;

  // Auth
  String get appName => _t('Warehouse Pro', 'Warehouse Pro');
  String get signIn => _t('Sign In', 'Anmelden');
  String get signOut => _t('Sign Out', 'Abmelden');
  String get emailAddress => _t('Email Address', 'E-Mail-Adresse');
  String get password => _t('Password', 'Passwort');
  String get forgotPassword => _t('Forgot password?', 'Passwort vergessen?');
  String get requestAccess => _t('Request Access', 'Zugang beantragen');
  String get dontHaveAccount => _t("Don't have an account?", 'Kein Konto?');
  String get accessDashboard =>
      _t('Access your warehouse dashboard', 'Zugriff auf Ihr Lager-Dashboard');
  String get invalidCredentials => _t(
    'Invalid credentials. Please try again.',
    'Ungültige Anmeldedaten. Bitte erneut versuchen.',
  );

  // Navigation
  String get dashboard => _t('Dashboard', 'Übersicht');
  String get stockMovements => _t('Stock Movements', 'Warenbewegungen');
  String get picking => _t('Picking', 'Kommissionierung');
  String get settings => _t('Settings', 'Einstellungen');

  // Home / Dashboard
  String get goodMorning => _t('Good morning!', 'Guten Morgen!');
  String get warehouseRunning =>
      _t('Warehouse A is running smoothly.', 'Lager A läuft reibungslos.');
  String get overview => _t('Overview', 'Übersicht');
  String get itemsInStock => _t('Items in Stock', 'Artikel auf Lager');
  String get ordersToday => _t('Orders Today', 'Aufträge heute');
  String get pendingPicks => _t('Pending Picks', 'Offene Picks');
  String get lowStockAlerts => _t('Low Stock Alerts', 'Niedrige Bestände');
  String get recentActivity => _t('Recent Activity', 'Letzte Aktivitäten');

  // Stock Movement
  String get newMovement => _t('New Movement', 'Neue Bewegung');
  String get movement => _t('Movement', 'Bewegung');
  String get from => _t('From', 'Von');
  String get to => _t('To', 'Nach');
  String get operator => _t('Operator', 'Mitarbeiter');
  String get pending => _t('Pending', 'Ausstehend');
  String get inProgress => _t('In Progress', 'In Bearbeitung');
  String get completed => _t('Abgeschlossen', 'Abgeschlossen');
  String get scanToConfirm =>
      _t('Scan barcode to confirm item', 'Barcode scannen zum Bestätigen');
  String get orTypeManually => _t('or type manually', 'oder manuell eingeben');
  String get completeMovement =>
      _t('Complete Movement', 'Bewegung abschließen');
  String get allItemsConfirmed =>
      _t('All items confirmed!', 'Alle Artikel bestätigt!');
  String get itemConfirmed => _t('Item confirmed!', 'Artikel bestätigt!');
  String get barcodeNotFound => _t(
    'Barcode not found in this movement.',
    'Barcode in dieser Bewegung nicht gefunden.',
  );
  String get alreadyConfirmed =>
      _t('Item already confirmed.', 'Artikel bereits bestätigt.');

  // Picking
  String get pickingList => _t('Picking List', 'Kommissionierliste');
  String get order => _t('Order', 'Auftrag');
  String get customer => _t('Customer', 'Kunde');
  String get location => _t('Location', 'Lagerort');
  String get quantity => _t('Qty', 'Menge');
  String get picked => _t('Picked', 'Kommissioniert');
  String get scanItem => _t('Scan item barcode', 'Artikel-Barcode scannen');
  String get correctScan =>
      _t('Correct! Item picked.', 'Richtig! Artikel kommissioniert.');
  String get wrongBarcode =>
      _t('Wrong barcode — try again.', 'Falscher Barcode — erneut versuchen.');
  String get pickingComplete =>
      _t('Picking Complete!', 'Kommissionierung abgeschlossen!');
  String get completePicking =>
      _t('Complete Picking', 'Kommissionierung abschließen');
  String get nextItem => _t('Next', 'Weiter');
  String get prevItem => _t('Back', 'Zurück');

  // Settings
  String get appearance => _t('Appearance', 'Erscheinungsbild');
  String get darkMode => _t('Dark Mode', 'Dunkelmodus');
  String get colorProfile => _t('Color Profile', 'Farbprofil');
  String get language => _t('Language', 'Sprache');
  String get colorNormal => _t('Normal', 'Normal');
  String get colorHighContrast => _t('High Contrast', 'Hoher Kontrast');
  String get colorDeuteranopia => _t('Deuteranopia', 'Deuteranopie');
  String get colorProtanopia => _t('Protanopia', 'Protanopie');
  String get colorTritanopia => _t('Tritanopia', 'Tritanopie');
  String get colorProfileHint => _t(
    'Adjust colors for color vision differences',
    'Farben für Farbsehschwächen anpassen',
  );
  String get langEnglish => _t('English', 'Englisch');
  String get langGerman => _t('German', 'Deutsch');
  String get about => _t('About', 'Über die App');
  String get version => _t('Version', 'Version');
  String get scanner => _t('Scanner', 'Scanner');
  String get scannerHint => _t(
    'Zebra DataWedge — configure profile to send action: com.starter_app.ACTION_SCAN',
    'Zebra DataWedge — Profil konfigurieren mit Aktion: com.starter_app.ACTION_SCAN',
  );

  // General
  String get cancel => _t('Cancel', 'Abbrechen');
  String get confirm => _t('Confirm', 'Bestätigen');
  String get search => _t('Search', 'Suchen');
  String get all => _t('All', 'Alle');
  String get noData => _t('No data available', 'Keine Daten verfügbar');
  String get items => _t('Items', 'Artikel');
  String get status => _t('Status', 'Status');
  String get date => _t('Date', 'Datum');
  String get open => _t('Open', 'Offen');
}
