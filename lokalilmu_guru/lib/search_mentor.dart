import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/mentor_bloc.dart';
import '../../model/mentor_model.dart';
import '../../widgets/common/header.dart';
import '../../widgets/common/navbar.dart';

class SearchMentorPage extends StatefulWidget {
  const SearchMentorPage({Key? key}) : super(key: key);

  @override
  State<SearchMentorPage> createState() => _SearchMentorPageState();
}

class _SearchMentorPageState extends State<SearchMentorPage> {
  @override
  void initState() {
    super.initState();
    // Panggil method initialize() langsung, bukan add event
    context.read<MentorCubit>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: BlocBuilder<MentorCubit, MentorState>(
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                // App Bar
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            context.go('/dashboard');
                          }
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Cari Mentor',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Search and Categories
                Header(
                  // Panggil method langsung, bukan add event
                  onSearchChanged: (value) => 
                      context.read<MentorCubit>().searchMentors(value),
                  onCategorySelected: (category) => 
                      context.read<MentorCubit>().selectCategory(category),
                  selectedCategory: state.selectedCategory,
                ),

                // Mentor List
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.mentors.isEmpty
                          ? const Center(child: Text('Tidak ada mentor yang ditemukan'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.mentors.length,
                              itemBuilder: (context, index) {
                                return MentorCard(mentor: state.mentors[index]);
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavbar(currentIndex: 1),
    );
  }
}

class MentorCard extends StatelessWidget {
  final MentorModel mentor;
  
  const MentorCard({
    Key? key,
    required this.mentor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to mentor profile page with the mentor's ID
        context.go('/mentor/${mentor.id}');
      },
    child:  Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mentor info row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mentor photo
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(mentor.imageUrl),
                ),
                const SizedBox(width: 12),
                // Mentor details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mentor.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        mentor.institution,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rating
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      mentor.rating.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Subject tags
            Wrap(
              spacing: 8,
              children: mentor.categories.map((subject) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    subject,
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              mentor.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            
            // Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Biaya per sesi',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Rp${mentor.pricePerSession.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}