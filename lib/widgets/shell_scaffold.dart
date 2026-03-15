import "package:flutter/material.dart";
import "../routes.dart";

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  final int currentIndex;
  final Widget child;

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == currentIndex) return;

    final target = index == 0 ? AppRoutes.records : AppRoutes.profile;
    Navigator.of(context).pushReplacementNamed(target);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (value) => _onDestinationSelected(context, value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: "璁板綍",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "鎴戠殑",
          ),
        ],
      ),
    );
  }
}
