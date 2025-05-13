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
    final Color inactiveColor = Colors.grey;
    final Color activeColor = const Color(0xFF1B3C73);

    return AppBar(
      backgroundColor: const Color(0xFFFAFAFA),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.all(10.0), // ✅ Tambahkan padding di sini
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.person_outline, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kalvin Richie',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
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
            const Spacer(),
            IconButton(
              icon: SvgPicture.asset(
                'asset/icons/Chat.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  activeColor,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: onSearchTap,
            ),
            IconButton(
              icon: SvgPicture.asset(
                'asset/icons/Notification.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  activeColor,
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
  Size get preferredSize => const Size.fromHeight(60.0);
}