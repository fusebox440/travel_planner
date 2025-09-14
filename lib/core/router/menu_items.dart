import 'package:flutter/material.dart';

/// A model for the drawer menu items.
class MenuItem {
  final String label;
  final IconData icon;
  final String route;

  const MenuItem(this.label, this.icon, this.route);
}

/// The list of menu items to show in the drawer.
const List<MenuItem> menuItems = [
  MenuItem('My Trips', Icons.flight, '/'),
  MenuItem('Trip Templates', Icons.library_books, '/templates'),
  MenuItem('Assistant', Icons.chat, '/assistant'),
  MenuItem(
      'Currency Converter', Icons.currency_exchange, '/currency-converter'),
  MenuItem('Weather', Icons.wb_sunny, '/weather'),
  MenuItem('World Clock', Icons.access_time, '/world-clock'),
  MenuItem('Settings', Icons.settings, '/settings'),
];
