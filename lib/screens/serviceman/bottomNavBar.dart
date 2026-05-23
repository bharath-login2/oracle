import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      color: const Color(0xFF2a86c9),
      elevation: 8,
      child: SizedBox(
        height: 30, 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              padding: const EdgeInsets.all(0), 
              icon: Icon(
                Icons.home,
                size: 26, 
                color: selectedIndex == 0
                    ? Colors.white
                    : Colors.white.withOpacity(0.6),
              ),
              onPressed: () => onItemTapped(0),
            ),

            const SizedBox(width: 40), 
            IconButton(
              padding: const EdgeInsets.all(0),
              icon: Icon(
                Icons.account_balance_wallet,
                size: 26,
                color: selectedIndex == 1
                    ? Colors.white
                    : Colors.white.withOpacity(0.6),
              ),
              onPressed: () => onItemTapped(1),
            ),
          ],
        ),
      ),
    );
  }
}

