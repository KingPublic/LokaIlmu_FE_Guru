import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  
  const AppHeader({
    Key? key,
    required this.currentIndex,
    this.onSearchTap,
    this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF1B3C73);
    final Color inactiveColor = Colors.grey;

    return AppBar(
      backgroundColor: const Color(0xFFFAFAFA),
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0, // Menghilangkan spacing default dari title
      title: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0, // Padding horizontal yang konsisten
          vertical: 8.0,    // Padding vertical yang lebih kecil
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Memastikan alignment vertikal
          children: [
            // Avatar dengan ukuran yang konsisten
            const CircleAvatar(
              radius: 18, // Ukuran yang lebih konsisten
              backgroundColor: Colors.black,
              child: Icon(Icons.person_outline, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            // Informasi pengguna
            Expanded( // Menggunakan Expanded untuk menghindari overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Meminimalkan ukuran vertikal
                children: [
                  const Text(
                    'Kalvin Richie',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // Menangani nama yang panjang
                  ),
                  Text(
                    'Edit Profil',
                    style: TextStyle(
                      color: Colors.blue[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Icon buttons dengan padding yang lebih baik
            IconButton(
              padding: const EdgeInsets.all(8.0), // Padding yang lebih kecil
              constraints: const BoxConstraints(), // Menghilangkan constraints default
              icon: SvgPicture.asset(
                'asset/icons/Chat.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  currentIndex == 0 ? activeColor : inactiveColor,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: onSearchTap,
            ),
            const SizedBox(width: 8), // Spacing antar icon
            IconButton(
              padding: const EdgeInsets.all(8.0), // Padding yang lebih kecil
              constraints: const BoxConstraints(), // Menghilangkan constraints default
              icon: SvgPicture.asset(
                'asset/icons/Notification.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  currentIndex == 0 ? activeColor : inactiveColor,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: onNotificationTap,
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: const Color(0xFF1B3C73),
          height: 0.5,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0); // Ukuran standar AppBar
}