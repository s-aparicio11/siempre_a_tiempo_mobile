import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/widgets/coming_soon_screen.dart';
import '../features/home/presentation/home_screen.dart';

/// Contenedor principal con la barra de navegación inferior.
///
/// Usa `IndexedStack` para que cada pestaña conserve su estado —incluida la
/// posición de desplazamiento de Inicio— al cambiar de sección.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const List<Widget> _tabs = <Widget>[
    HomeScreen(),
    ComingSoonScreen(section: 'Mapa'),
    ComingSoonScreen(section: 'Perfil'),
  ];

  void _onTabSelected(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        items: const <BottomNavigationBarItem>[
          // Lucide no trae variantes rellenas, así que la pestaña activa se
          // distingue por color, que el tema ya resuelve.
          BottomNavigationBarItem(icon: Icon(LucideIcons.house), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Perfil'),
        ],
      ),
    );
  }
}
