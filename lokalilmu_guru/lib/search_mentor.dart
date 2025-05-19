import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalilmu_guru/blocs/mentor_bloc.dart';
import 'package:lokalilmu_guru/model/mentor_model.dart';
import 'package:lokalilmu_guru/widgets/common/navbar.dart';

class MentorSearchPage extends StatefulWidget {
  const MentorSearchPage({Key? key}) : super(key: key);

  @override
  State<MentorSearchPage> createState() => _MentorSearchPageState();
}

class _MentorSearchPageState extends State<MentorSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSubject = 'Semua Subjek';
  
  final List<String> _subjects = [
    'Semua Subjek',
    'Informatika',
    'Sains',
    'Matematika',
    'Bahasa',
    'Ekonomi',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Cari Mentor',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFF1B3C73),
            height: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Mentor...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1B3C73)),
                ),
              ),
              onChanged: (value) {
                // Trigger search
                context.read<MentorBloc>().add(SearchMentorsEvent(value));
              },
            ),
          ),
          
          // Subject Filter
          Container(
            height: 50,
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                final subject = _subjects[index];
                final isSelected = subject == _selectedSubject;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(subject),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSubject = subject;
                      });
                      // Filter mentors by subject
                      context.read<MentorBloc>().add(FilterMentorsBySubjectEvent(subject));
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color(0xFF1B3C73),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              },
            ),
          ),
          
          // Mentor List
          Expanded(
            child: BlocBuilder<MentorBloc, MentorState>(
              builder: (context, state) {
                if (state is MentorLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MentorLoaded) {
                  final mentors = state.mentors;
                  
                  if (mentors.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada mentor yang ditemukan'),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: mentors.length,
                    itemBuilder: (context, index) {
                      final mentor = mentors[index];
                      return MentorCard(mentor: mentor);
                    },
                  );
                } else if (state is MentorError) {
                  return Center(
                    child: Text('Error: ${state.message}'),
                  );
                }
                
                return const Center(
                  child: Text('Cari mentor berdasarkan subjek atau keahlian'),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavbar(
        currentIndex: 1, // Cari Mentor tab
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}

class MentorCard extends StatelessWidget {
  final Mentor mentor;
  
  const MentorCard({
    Key? key,
    required this.mentor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
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
                  backgroundImage: NetworkImage(mentor.photoUrl),
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
              children: mentor.subjects.map((subject) {
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
    );
  }
}