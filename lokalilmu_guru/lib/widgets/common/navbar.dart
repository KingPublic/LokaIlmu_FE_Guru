import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class AppBottomNavbar extends StatelessWidget {
  final int currentIndex;
  // final Function(int) onTap;

  const AppBottomNavbar({
    Key? key,
    required this.currentIndex,
    // required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definisikan warna untuk icon aktif dan tidak aktif
    final Color inactiveColor = Colors.grey;
    final Color activeColor = Color(0xFF1B3C73);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFF1B3C73), width: 1)
        ), // Outline tipis hitam
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: currentIndex,
          onTap: (index) {
            // // Jika onTap disediakan, gunakan itu
            // if (onTap != null) {
            //   onTap!(index);
            //   return;
            // }
            
            // Jika tidak, gunakan navigasi default
            _navigateToPage(context, index);
          },
          selectedItemColor: activeColor,
          unselectedItemColor: inactiveColor,
          selectedLabelStyle: TextStyle(fontSize: 8), // size when selected
          unselectedLabelStyle: TextStyle(fontSize: 8), // size when not selected
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'asset/icons/Beranda.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  currentIndex == 0 ? activeColor : inactiveColor,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'asset/icons/Pelatihan.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  currentIndex == 1 ? activeColor : inactiveColor,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Cari Mentor',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'asset/icons/Perpustakaan.svg',
                width: 24,
                height: 24, 
                colorFilter: ColorFilter.mode(
                  currentIndex == 2 ? activeColor : inactiveColor,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Perpustakaan',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'asset/icons/ForumDiskusi.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  currentIndex == 3 ? activeColor : inactiveColor,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Forum',
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    // Hindari navigasi jika sudah berada di halaman yang sama
    if (index == currentIndex) return;
    
    switch (index) {
      case 0:
        // Navigasi ke Beranda
        context.go('/dashboard');
        break;
      case 1:
        // Navigasi ke Cari Mentor
        context.go('/mentor');
        break;
      case 2:
        // Navigasi ke Perpustakaan
        // Ganti dengan route yang sesuai
        context.go('/perpustakaan');
        break;
      case 3:
        // Navigasi ke Forum
        // Ganti dengan route yang sesuai
        context.go('/forum');
        break;
    }
  }
}