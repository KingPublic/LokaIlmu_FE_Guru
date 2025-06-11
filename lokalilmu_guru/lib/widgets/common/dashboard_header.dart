import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lokalilmu_guru/blocs/auth_bloc.dart'; 

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
      titleSpacing: 0,
      title: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar dengan ukuran yang konsisten
            GestureDetector(
              onTap: () => _navigateToProfile(context),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black,
                child: Icon(Icons.person_outline, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            // Informasi pengguna
            Expanded(
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  // Handle any side effects if needed
                },
                builder: (context, state) {
                  String userName = 'Guest User';
                  bool isAuthenticated = false;
                  
                  // Get user name from AuthBloc state
                  if (state is AuthAuthenticated) {
                    userName = state.user?.namaLengkap ?? 
                              state.profilGuru?.namaLengkap ?? 
                              'User';
                    isAuthenticated = true;
                  } else if (state is AuthRegistrationSuccess) {
                    userName = state.user?.namaLengkap ?? 
                              state.profilGuru?.namaLengkap ?? 
                              'User';
                    isAuthenticated = true;
                  } else if (state is AuthLoading) {
                    userName = 'Loading...';
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      GestureDetector(
                        onTap: isAuthenticated ? () => _navigateToProfile(context) : null,
                        child: Text(
                          isAuthenticated ? 'Edit Profil' : 'Login untuk Edit Profil',
                          style: TextStyle(
                            color: isAuthenticated ? Colors.blue[400] : Colors.grey,
                            fontSize: 12,
                            decoration: isAuthenticated ? TextDecoration.underline : null,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Icon buttons
            IconButton(
              padding: const EdgeInsets.all(8.0),
              constraints: const BoxConstraints(),
              icon: SvgPicture.asset(
                'asset/icons/Chat.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  currentIndex == 0 ? activeColor : inactiveColor,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => _navigateToChat(context),
            ),
            const SizedBox(width: 8),
            IconButton(
              padding: const EdgeInsets.all(8.0),
              constraints: const BoxConstraints(),
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

  void _navigateToProfile(BuildContext context) {
    context.push('/edit-profile');
  }

  void _navigateToChat(BuildContext context) {
    context.push('/chat');
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}